USE [EdFi_Ods_Glendale]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/****** Removing the older view if it previously exists in the data store        ******/
DROP VIEW IF EXISTS [analytics].[DateDim];

/****** Create Object:  View [analytics].[DateDim]                                      ******/
CREATE VIEW [analytics].[DateDim] AS

	WITH dates as (
		SELECT DISTINCT Date,
			CAST(SchoolYear AS VARCHAR)  as SchoolYear
		FROM edfi.CalendarDateCalendarEvent
	)
	SELECT
		CONVERT(varchar, Date, 112) as DateKey,
		CAST(CONVERT(varchar, Date, 1) as DATETIME) as Date,
		DAY(Date) as Day,
		MONTH(Date) as Month,
		DATENAME(month, Date) as MonthName,
		CASE 
			WHEN MONTH(Date) BETWEEN 1 AND 3 THEN 1
			WHEN MONTH(Date) BETWEEN 4 AND 6 THEN 2
			WHEN MONTH(Date) BETWEEN 7 AND 9 THEN 3
			WHEN MONTH(Date) BETWEEN 10 AND 12 THEN 4
		END as CalendarQuarter,
		CASE 
			WHEN MONTH(Date) BETWEEN 1 AND 3 THEN 'First'
			WHEN MONTH(Date) BETWEEN 4 AND 6 THEN 'Second'
			WHEN MONTH(Date) BETWEEN 7 AND 9 THEN 'Third'
			WHEN MONTH(Date) BETWEEN 10 AND 12 THEN 'Fourth'
		END as CalendarQuarterName,
		YEAR(Date) as CalendarYear,
		SchoolYear
	FROM dates
GO


