CREATE SCHEMA analytics_data;

GO

CREATE TABLE [analytics_data].[AtRiskAttendance](
	[StudentKey] [nvarchar](32) NOT NULL,
	[SchoolKey] [int] NOT NULL,
	[SchoolYear] [nvarchar](30) NULL,
	[AttendanceRate] [numeric](3, 2) NULL,
	[AttendanceIndicator] [varchar](10) NOT NULL
) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX IX_AtRiskAttendance ON analytics_data.AtRiskAttendance
	(
	StudentKey,
	SchoolKey
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX IX_AtRiskAttendance_SchoolYear ON analytics_data.AtRiskAttendance
	(
	SchoolYear DESC
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


CREATE TABLE [analytics_data].[AtRiskBehavior](
	[StudentKey] [nvarchar](32) NOT NULL,
	[SchoolKey] [int] NOT NULL,
	[SchoolYear] [nvarchar](30) NULL,
	[StateOffenses] [int] NULL,
	[BehaviorIndicator] [varchar](10) NOT NULL
) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX IX_AtRiskBehavior ON analytics_data.AtRiskBehavior
	(
	StudentKey,
	SchoolKey
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX IX_AtRiskBehavior_SchoolYear ON analytics_data.AtRiskBehavior
	(
	SchoolYear DESC
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE TABLE [analytics_data].[AtRiskGPA](
	[StudentKey] [nvarchar](32) NOT NULL,
	[SchoolKey] [int] NOT NULL,
	[SchoolYear] [nvarchar](30) NULL,
	[GPAScore] NUMERIC(3,1) NULL,
	[GPAIndicator] [varchar](10) NOT NULL
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_AtRiskGPA ON analytics_data.AtRiskGPA
	(
	StudentKey,
	SchoolKey
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX IX_AtRiskGPA_SchoolYear ON analytics_data.AtRiskGPA
	(
	SchoolYear DESC
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


CREATE TABLE [analytics_data].[AtRiskMarks](
	[StudentKey] [nvarchar](32) NOT NULL,
	[SchoolKey] [int] NOT NULL,
	[SchoolYear] [nvarchar](30) NULL,
	[CountF] [int] NULL,
	[CountD] [int] NULL,
	[Indicator] [varchar](10) NOT NULL
) ON [PRIMARY]
GO


CREATE NONCLUSTERED INDEX IX_AtRiskMarks ON analytics_data.AtRiskMarks
	(
	StudentKey,
	SchoolKey
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX IX_AtRiskMarks_SchoolYear ON analytics_data.AtRiskMarks
	(
	SchoolYear DESC
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE TABLE [analytics_config].[Ews](
	[GradeAtRisk] [decimal](3, 1) NOT NULL,
	[GradeEarlyWarning] [decimal](3, 1) NOT NULL,
	[AttendanceAtRisk] [decimal](3, 2) NOT NULL,
	[AttendanceEarlyWarning] [decimal](3, 2) NOT NULL,
	[OffenseAtRisk] [int] NOT NULL,
	[ConductAtRisk] [int] NOT NULL,
	[ConductEarlyWarning] [int] NOT NULL
) ON [PRIMARY]
GO

INSERT INTO [analytics_config].[Ews]
           ([GradeAtRisk]
           ,[GradeEarlyWarning]
           ,[AttendanceAtRisk]
           ,[AttendanceEarlyWarning]
           ,[OffenseAtRisk]
           ,[ConductAtRisk]
           ,[ConductEarlyWarning])
     VALUES
           (
65.0,	72.0,	0.80,	0.88,	0,	5,	2)
GO