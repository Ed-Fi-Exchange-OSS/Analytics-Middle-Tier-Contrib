-- ==========================================================================================
-- Author:		Virgi Hretcanu/NW Regional ESD, OregonNexus, vhretcanu@nwresd.k12.or.us
-- Create date: March 9, 2020
-- Description:	A procedure to extract and stage the data for the Freshmen On Track PowerBI Dashboard
-- ==========================================================================================

CREATE PROCEDURE [dbo].[StageAnalyticsData]
	@SchoolYear INT = NULL
AS
BEGIN
/* 

 If SchoolYear is missing use the current school year from the school calendar

*/

IF @SchoolYear IS NULL
BEGIN
	SELECT  @SchoolYear = max(DateDim.SchoolYear) FROM analytics.DateDim
END

/*

	Extract and populate the AtRiskBehavior table

*/

BEGIN TRY
    BEGIN TRANSACTION;

    DELETE FROM [analytics_data].[AtRiskBehavior] WHERE SchoolYear = @SchoolYear;

    WITH [totalcounts]
          AS (SELECT [ews_StudentEarlyWarningFact].[StudentKey], 
                     [ews_StudentEarlyWarningFact].[SchoolKey], 
                     SUM(ISNULL([CountByDayOfStateOffenses], 0)) AS [StateOffenses], 
                     SUM(ISNULL([CountByDayOfConductOffenses], 0)) AS [CodeOfConductOffenses],
					 [DateDim].[SchoolYear]
              FROM [analytics].[ews_StudentEarlyWarningFact]
                   JOIN [analytics].[DateDim] ON [ews_StudentEarlyWarningFact].[DateKey] = [DateDim].[DateKey]
              WHERE [IsInstructionalDay] = 1
              GROUP BY [StudentKey], 
                       [SchoolKey],
					   [SchoolYear])
		INSERT INTO [analytics_data].[AtRiskBehavior]
			   ([StudentKey]
			   ,[SchoolKey]
			   ,[SchoolYear]
			   ,[StateOffenses]
			   ,[BehaviorIndicator])
          SELECT DISTINCT 
                 [totalcounts].StudentKey, 
				 [totalcounts].StudentKey, 
				 [totalcounts].SchoolYear,
                 [totalcounts].[StateOffenses],
                 CASE
                     WHEN [StateOffenses] > 1
                     THEN 'Vulnerable'
                     ELSE 'On-Track'
                 END AS [BehaviorIndicator]
          FROM [totalcounts]
		  WHERE SchoolYear = @SchoolYear;

    COMMIT TRAN;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;
    THROW;  
END CATCH;


/*

	Extract and populate the AtRiskAttendance table

*/

BEGIN TRY
    BEGIN TRANSACTION;

    DELETE FROM [analytics_data].[AtRiskAttendance] WHERE SchoolYear = @SchoolYear;

	 WITH [attendanceData]
          AS (
			SELECT 
				[StudentKey], 
				[SchoolKey],
				  (
					  SELECT MAX(Absent)
					  FROM(VALUES([ews_StudentEarlyWarningFact].[IsAbsentFromSchoolExcused]), ([ews_StudentEarlyWarningFact].[IsAbsentFromSchoolUnexcused]), ([ews_StudentEarlyWarningFact].[IsAbsentFromHomeroomExcused]), ([ews_StudentEarlyWarningFact].[IsAbsentFromHomeroomUnexcused])) AS value(Absent)
				  ) AS [IsAbsent], 
                [IsEnrolled], 
                [ews_StudentEarlyWarningFact].[DateKey],
				[DateDim].[SchoolYear]
            FROM [analytics].[ews_StudentEarlyWarningFact] 
			JOIN [analytics].[DateDim]
				ON [ews_StudentEarlyWarningFact].[DateKey] = [DateDim].[DateKey]
            WHERE [IsInstructionalDay] = 1
          ),

          [rate]
          AS (SELECT [StudentKey],
					 [SchoolKey],
					 [SchoolYear],
                     (CAST(SUM([IsEnrolled]) AS DECIMAL) - CAST(SUM([IsAbsent]) AS DECIMAL)) / CAST(SUM([IsEnrolled]) AS DECIMAL) AS [AttendanceRate]
              FROM [attendanceData]
              GROUP BY [StudentKey],[SchoolKey],[SchoolYear]
			  )
		 INSERT INTO [analytics_data].[AtRiskAttendance]
			([StudentKey], 
			 [SchoolKey], 
			 [SchoolYear], 
			 [AttendanceRate], 
			 [AttendanceIndicator]
			)
		  SELECT DISTINCT 
                 [rate].StudentKey AS [StudentKey],
				 [rate].SchoolKey,
				 [rate].SchoolYear,
                 CAST([Rate].[AttendanceRate] AS NUMERIC(3, 2)) 'AttendanceRate',
                 CASE
                     WHEN [AttendanceRate] < [Ews].[AttendanceAtRisk]         THEN 'Off-Track'
                     WHEN [AttendanceRate] < [Ews].[AttendanceEarlyWarning]   THEN 'Vulnerable'
                     ELSE 'On-track'
                 END AS 'AttendanceIndicator'
          FROM [rate]
		  CROSS JOIN [analytics_config].[Ews]
		  WHERE SchoolYear = @SchoolYear;

    COMMIT TRAN;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;
    THROW;  
END CATCH;


/*

	Extract and populate the AtRiskGPA table

*/

SELECT [StudentSectionKey]
      ,[StudentKey]
      ,[SchoolKey]
      ,[SchoolYear]
	INTO #CurrentYearCoreSubjects
	FROM [analytics].[StudentSectionDim]
	WHERE analytics.StudentSectionDim.SchoolYear = @SchoolYear
		AND StudentSectionDim.Subject IN ('Mathematics', 'English Language Arts', 'Reading', 'Writing', 'Social Studies', 'Science');


BEGIN TRY
    BEGIN TRANSACTION;

    DELETE FROM [analytics_data].[AtRiskGPA] WHERE SchoolYear = @SchoolYear;

	WITH [gpa_values] AS 
	(
	SELECT [ews_StudentSectionGradeFact].[StudentKey]
		  ,[ews_StudentSectionGradeFact].[SchoolKey]
		  ,[StudentSectionDim].[SchoolYear]
		  ,CAST(
				(SUM(ews_StudentSectionGradeFact.NumericGradeEarned) OVER(PARTITION BY [StudentSectionDim].[StudentKey])) /
				CAST( COUNT(1) OVER(PARTITION BY [StudentSectionDim].[StudentKey]) AS NUMERIC(3,0)) AS NUMERIC(3,1))  AS [GPAScore]
	FROM [analytics].[ews_StudentSectionGradeFact] 
  
	  ------- Only the most recent grading period  
	  JOIN analytics.GradingPeriodDim 
		ON ews_StudentSectionGradeFact.GradingPeriodKey = GradingPeriodDim.GradingPeriodKey
	  JOIN [analytics].[MostRecentGradingPeriod]
		ON MostRecentGradingPeriod.GradingPeriodBeginDateKey = GradingPeriodDim.GradingPeriodBeginDateKey
		AND MostRecentGradingPeriod.SchoolKey = GradingPeriodDim.SchoolKey

	  ------ Current year and Core Subjects
	  JOIN #CurrentYearCoreSubjects AS StudentSectionDim
		ON [ews_StudentSectionGradeFact].[StudentSectionKey] = [StudentSectionDim].[StudentSectionKey]
	 )

	  INSERT INTO [analytics_data].[AtRiskGPA]
			([StudentKey], 
			 [SchoolKey], 
			 [SchoolYear], 
			 [GPAScore], 
			 [GPAIndicator]
			)

	SELECT gpa_values.*,
		   CASE 
			WHEN gpa_values.GPAScore >= 2.5 THEN 'On-Track'	
			ELSE 'Off-Track'
		   END [Indicator]
	FROM gpa_values

    COMMIT TRAN;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;
    THROW;  
END CATCH;



/*

	Extract and populate the AtRiskMarks table

*/

BEGIN TRY
    BEGIN TRANSACTION;

    DELETE FROM [analytics_data].[AtRiskMarks] WHERE SchoolYear = @SchoolYear;

	WITH grades AS (
		SELECT   [ews_StudentSectionGradeFact].[StudentKey]
				,[ews_StudentSectionGradeFact].[SchoolKey]
				,CoreSubjects.SchoolYear
				,[ews_StudentSectionGradeFact].[LetterGradeEarned]
		FROM [analytics].[ews_StudentSectionGradeFact]

		 ------- Only the most recent grading period  
		JOIN analytics.GradingPeriodDim 
			ON ews_StudentSectionGradeFact.GradingPeriodKey = GradingPeriodDim.GradingPeriodKey
		JOIN [analytics].[MostRecentGradingPeriod]
			ON MostRecentGradingPeriod.GradingPeriodBeginDateKey = GradingPeriodDim.GradingPeriodBeginDateKey
			AND MostRecentGradingPeriod.SchoolKey = GradingPeriodDim.SchoolKey

		JOIN #CurrentYearCoreSubjects AS CoreSubjects
			ON [ews_StudentSectionGradeFact].[StudentSectionKey] = [CoreSubjects].[StudentSectionKey]

		WHERE  [ews_StudentSectionGradeFact].[LetterGradeEarned] IN ('D', 'F')           
	)

	 INSERT INTO [analytics_data].[AtRiskMarks]
			([StudentKey], 
			 [SchoolKey], 
			 [SchoolYear], 
			 [CountF], 
			 [CountD],
			 [Indicator]
			)

	SELECT   g.StudentKey
			,g.SchoolKey
			,g.SchoolYear
			,g.CountF
			,g.CountD
			,CASE
				WHEN g.CountF = 0 AND g.CountD < 2 THEN	'On-Track'
				WHEN g.CountF = 1 OR g.CountD = 2  THEN 'Vulnerable'
				WHEN g.CountF = 1 OR g.CountD > 1 THEN  'Vulnerable'
				WHEN g.CountF > 1 THEN 'Off-Track' 
			END AS 'Indicator'

		  FROM     (
					SELECT DISTINCT d.StudentKey
									,d.SchoolKey
									,d.SchoolYear
									 ,(SELECT COUNT(1) FROM grades g WHERE LetterGradeEarned = 'F' AND d.studentkey = g.studentkey)'CountF'
									 ,(SELECT COUNT(1) FROM grades g WHERE LetterGradeEarned = 'D' AND d.studentkey = g.studentkey)'CountD'
					FROM [analytics].[StudentSectionDim] d
					) g
		  WHERE g.CountD + g.CountF > 0

	

    COMMIT TRAN;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;
    THROW;  
END CATCH;

DROP TABLE #CurrentYearCoreSubjects

END
GO

