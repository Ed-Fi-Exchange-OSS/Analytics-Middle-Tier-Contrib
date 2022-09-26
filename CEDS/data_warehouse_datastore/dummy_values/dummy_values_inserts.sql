-------------------------------
-- DimSchoolYears
-------------------------------

SET IDENTITY_INSERT [RDS].[DimSchoolYears] ON

IF NOT EXISTS (SELECT 1 FROM [RDS].[DimSchoolYears] WHERE [DimSchoolYearId] = -1)
BEGIN
	INSERT INTO [RDS].[DimSchoolYears] ([DimSchoolYearId],[SchoolYear],[SessionBeginDate],[SessionEndDate]) 
		VALUES (-1, '', GETDATE(), GETDATE())
END

SET IDENTITY_INSERT [RDS].[DimSchoolYears] OFF

-------------------------------
-- DimK12Students
-------------------------------

SET IDENTITY_INSERT [RDS].[DimK12Students] ON

IF NOT EXISTS (SELECT 1 FROM [RDS].[DimK12Students] WHERE [DimK12StudentId] = -1)
BEGIN
	INSERT INTO [RDS].[DimK12Students] ([DimK12StudentId]) 
		VALUES (-1)
END

SET IDENTITY_INSERT [RDS].[DimK12Students] OFF

-------------------------------
-- DimGradeLevels
-------------------------------

SET IDENTITY_INSERT [RDS].[DimGradeLevels] ON

IF NOT EXISTS (SELECT 1 FROM [RDS].[DimGradeLevels] WHERE [DimGradeLevelId] = -1)
BEGIN
	INSERT INTO [RDS].[DimGradeLevels] ([DimGradeLevelId],[GradeLevelCode])
		VALUES (-1,'MISSING')
END

SET IDENTITY_INSERT [RDS].[DimGradeLevels] OFF

-------------------------------
-- DimIdeaStatuses
-------------------------------

SET IDENTITY_INSERT [RDS].[DimIdeaStatuses] ON

IF NOT EXISTS (SELECT 1 FROM [RDS].[DimIdeaStatuses] WHERE [DimIdeaStatusId] = -1)
BEGIN
	INSERT INTO [RDS].[DimIdeaStatuses] ([DimIdeaStatusId],[SpecialEducationExitReasonCode],[PrimaryDisabilityTypeCode],[IdeaEducationalEnvironmentForSchoolAgeCode]) 
		VALUES (-1,'MISSING','MISSING','MISSING')
END

SET IDENTITY_INSERT [RDS].[DimIdeaStatuses] OFF

-------------------------------
-- DimK12EnrollmentStatuses
-------------------------------

SET IDENTITY_INSERT [RDS].[DimK12EnrollmentStatuses] ON

IF NOT EXISTS (SELECT 1 FROM [RDS].[DimK12EnrollmentStatuses] WHERE [DimK12EnrollmentStatusId] = -1)
BEGIN
	INSERT INTO [RDS].[DimK12EnrollmentStatuses] ([DimK12EnrollmentStatusId]) 
		VALUES (-1)
END

SET IDENTITY_INSERT [RDS].[DimK12EnrollmentStatuses] OFF

-------------------------------
-- DimK12Demographics
-------------------------------

SET IDENTITY_INSERT [RDS].[DimK12Demographics] ON

IF NOT EXISTS (SELECT 1 FROM [RDS].[DimK12Demographics] WHERE [DimK12DemographicId] = -1)
BEGIN
	INSERT INTO [RDS].[DimK12Demographics] ([DimK12DemographicId],[EconomicDisadvantageStatusCode],[HomelessnessStatusCode],[EnglishLearnerStatusCode],[MigrantStatusCode],[MilitaryConnectedStudentIndicatorCode],[HomelessPrimaryNighttimeResidenceCode],[HomelessUnaccompaniedYouthStatusCode],[SexCode]) 
		VALUES (-1,'MISSING','MISSING','MISSING','MISSING','MISSING','MISSING','MISSING','MISSING')
END

SET IDENTITY_INSERT [RDS].[DimK12Demographics] OFF


