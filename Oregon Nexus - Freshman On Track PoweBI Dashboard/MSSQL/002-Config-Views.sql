CREATE VIEW [dbo].[OnTrackReport]
AS

WITH

/*

	GRADE LEVELS

*/

GRADE_LEVELS
AS
(
SELECT [Description]

,CASE WHEN Description = 'Preschool/Prekindergarten'  THEN 'PK'
	  WHEN Description like 'Kinder%'  THEN 'K'
	  WHEN Description like 'First%'  THEN '1'
	  WHEN Description like 'Second%'  THEN '2'
	  WHEN Description like 'Third%'  THEN '3'
	  WHEN Description like 'Fourth%'  THEN '4'
	  WHEN Description like 'Fifth%'  THEN '5'
	  WHEN Description like 'Six%'  THEN '6'
	  WHEN Description like 'Seven%'  THEN '7'
	  WHEN Description like 'Eight%'  THEN '8'
	  WHEN Description like 'Ninth%'  THEN '9'
	  WHEN Description like 'Ten%'  THEN '10'
	  WHEN Description like 'Eleven%'  THEN '11'
	  WHEN Description like 'Twel%'  THEN '12'
	  WHEN Description = 'Grade 13'  THEN '13'
 END as Grade_Num
 FROM  [edfi].[Descriptor]
 JOIN [edfi].[GradeLevelDescriptor]
	ON [edfi].[GradeLevelDescriptor].GradeLevelDescriptorId = [edfi].[Descriptor].DescriptorId
)

/*
	
	RACE

*/

	,STUDENT_RACE
	AS
	(
		SELECT sr.[StudentUSI]		as StudentID
			,sr.[RaceDescriptorId]		as TypeID
			,d.Description			as Description
		FROM [edfi].[StudentEducationOrganizationAssociationRace] sr
		JOIN [edfi].[Descriptor] d
			ON sr.RaceDescriptorId = d.DescriptorId
		JOIN [edfi].[RaceDescriptor]
			ON [edfi].[RaceDescriptor].RaceDescriptorId = d.DescriptorId
	)
	 
	
	SELECT distinct
      sd.StudentKey
      ,stu.StudentUniqueId as SSID
      ,sd.[StudentFirstName]
      ,sd.[StudentMiddleName]
      ,sd.[StudentLastName]
	  ,gl.Grade_Num
	  ,sd.SchoolKey
	  ,sch.SchoolName
      ,sd.[LimitedEnglishProficiency]
      --,sd.[IsEconomicallyDisadvantaged]
      ,sd.[IsHispanic]

	  ,CASE WHEN sd.IsHispanic = '1' THEN 'Hispanic'
	      WHEN (SELECT COUNT(StudentID) FROM STUDENT_RACE where StudentID = stu.StudentUSI ) > 1 THEN 'Multiple'
	      ELSE (SELECT Description FROM STUDENT_RACE where StudentID = stu.StudentUSI )
      END		as Race

      ,sd.[Sex]
	  ,gpa.GPAScore
	  ,gpa.GPAIndicator				as gpa_Indicator
	  ,marks.CountD					as marks_CountD
	  ,marks.CountF					as marks_CountF
	  ,marks.Indicator				as marks_Indicator
	  ,atnd.AttendanceRate			as atnd_Rate
	  ,atnd.AttendanceIndicator		as atnd_Indicator
	  ,bhv.StateOffenses			as bhv_Offenses
	  ,bhv.BehaviorIndicator		as bhv_Indicator

	  ,CASE WHEN (gpa.GPAIndicator like 'Off%'  OR  marks.Indicator like 'Off%'  OR  atnd.AttendanceIndicator like 'Off%'  OR  bhv.BehaviorIndicator like 'Off%') THEN 'Off-Track'
	        WHEN (gpa.GPAIndicator like 'Vul%'  OR  marks.Indicator like 'Vul%'  OR  atnd.AttendanceIndicator like 'Vul%'  OR  bhv.BehaviorIndicator like 'Vul%') THEN 'Vulnerable'
			ELSE  'On-Track'
		END  as Overall_Indicator,
		rank() OVER(PARTITION BY sd.StudentKey ORDER BY AttendanceRate) RNK
  FROM [analytics].[StudentSchoolDim] sd				
  INNER JOIN [edfi].[Student] stu on sd.StudentKey = stu.StudentUniqueId
  LEFT JOIN analytics_data.AtRiskGPA gpa on sd.StudentKey = gpa.StudentKey
  LEFT JOIN analytics_data.AtRiskMarks marks on sd.StudentKey = marks.StudentKey
  LEFT JOIN analytics_data.AtRiskAttendance atnd on sd.StudentKey = atnd.StudentKey
  LEFT JOIN analytics_data.AtRiskBehavior bhv on sd.StudentKey = bhv.StudentKey
  INNER JOIN analytics.SchoolDim sch on sd.SchoolKey = sch.SchoolKey
  LEFT JOIN GRADE_LEVELS gl ON sd.GradeLevel = gl.Description
  WHERE sd.GradeLevel = 'Ninth grade'
  
GO

CREATE VIEW [dbo].[SuccessByFactor]
AS
     SELECT 'Attendance' AS 'Type', 
            AttendanceIndicator AS 'Status', 
            COUNT(AttendanceIndicator) AS 'Count'
     FROM [analytics_data].AtRiskAttendance
     WHERE StudentKey IN
     (
         SELECT StudentKey
         FROM [dbo].[OnTrackReport]
     )
     GROUP BY AttendanceIndicator
     UNION ALL
     SELECT 'Grades' AS 'Type', 
            Indicator AS 'Status', 
            COUNT(Indicator) AS 'Count'
     FROM [analytics_data].AtRiskMarks
     WHERE StudentKey IN
     (
         SELECT StudentKey
         FROM [dbo].[OnTrackReport]
     )
     GROUP BY Indicator
     UNION ALL
     SELECT 'GPA' AS 'Type', 
            GPAIndicator AS 'Status', 
            COUNT(GPAIndicator) AS 'Count'
     FROM [analytics_data].AtRiskGPA
     WHERE StudentKey IN
     (
         SELECT StudentKey
         FROM [dbo].[OnTrackReport]
     )
     GROUP BY GPAIndicator
     UNION ALL
     SELECT 'Behavior' AS 'Type', 
            BehaviorIndicator AS 'Status', 
            COUNT(BehaviorIndicator) AS 'Count'
     FROM [analytics_data].AtRiskBehavior
     WHERE StudentKey IN
     (
         SELECT StudentKey
         FROM [dbo].[OnTrackReport]
     )
     GROUP BY BehaviorIndicator;
GO
