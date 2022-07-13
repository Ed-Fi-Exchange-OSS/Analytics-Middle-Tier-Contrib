-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.

IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.VIEWS
        WHERE TABLE_SCHEMA = 'analytics' AND TABLE_NAME = 'ceds_FactK12StudentEnrollments'
        )
BEGIN
    DROP VIEW analytics.ceds_FactK12StudentEnrollments;
END;
GO

-- ToDo: Change Id for Key where necessary.

CREATE VIEW analytics.ceds_FactK12StudentEnrollments AS
	WITH StudentEnrollmentAcrossSchools
	AS (
		SELECT
			studentschoolassociation.StudentUSI,
			studentschoolassociation.SchoolId,
			COUNT(1) AS Count
		FROM 
			edfi.studentschoolassociation
		WHERE
            StudentSchoolAssociation.ExitWithdrawDate IS NULL
            OR StudentSchoolAssociation.ExitWithdrawDate >= GETDATE()
		GROUP BY StudentUSI,SchoolId
	)
	SELECT
		ceds_SchoolYearsDim.SchoolYearKey AS SchoolYearKey,
		'' AS DataCollectionKey,
		ceds_K12SchoolDim.SeaIdentifierSea AS SeaKey,
		ceds_K12SchoolDim.IeuOrganizationIdentifierSea AS IeuKey,
		ceds_K12SchoolDim.LeaIdentifierSea AS LeaKey,
		ceds_K12SchoolDim.SchoolIdentifierSea AS K12SchoolKey,
		ceds_K12StudentDim.K12StudentKey AS K12StudentKey,
		ceds_K12EnrollmentStatusDim.K12EnrollmentStatusKey AS K12EnrollmentStatusKey,
		ceds_GradeLevelDim.GradeLevelKey AS EntryGradeLevelKey,
		ceds_GradeLevelDim.GradeLevelKey AS ExitGradeLevelKey,
		SchoolYearsDim_ExitWithdrawDate.SchoolYearKey AS EnrollmentEntryDateKey,
		ceds_SchoolYearsDim_SchoolYear.SchoolYearKey AS ProjectedGraduationDateKey,
		ceds_K12DemographicDim.K12DemographicKey AS K12DemographicKey,
		'' AS IdeaStatusKey

	FROM
		analytics.ceds_SchoolYearsDim
	INNER JOIN 
		edfi.StudentSchoolAssociation
			ON StudentSchoolAssociation.EntryDate BETWEEN CONVERT(date, ceds_SchoolYearsDim.SessionBeginDate) AND CONVERT(date, ceds_SchoolYearsDim.SessionEndDate)
	INNER JOIN
		analytics.ceds_K12SchoolDim
			ON edfi.StudentSchoolAssociation.SchoolId = ceds_K12SchoolDim.SchoolIdentifierSea
	INNER JOIN
		edfi.Student
			ON StudentSchoolAssociation.StudentUSI = Student.StudentUSI
	INNER JOIN
		analytics.ceds_K12StudentDim
			ON Student.StudentUniqueId = ceds_K12StudentDim.StudentIdentifierState
	--
	LEFT JOIN
		edfi.Descriptor EntryTypeDescriptor
			ON StudentSchoolAssociation.EntryTypeDescriptorId = EntryTypeDescriptor.DescriptorId
	LEFT JOIN
		edfi.Descriptor ExitWithdrawTypeDescriptor
			ON StudentSchoolAssociation.ExitWithdrawTypeDescriptorId = ExitWithdrawTypeDescriptor.DescriptorId
	LEFT JOIN
		StudentEnrollmentAcrossSchools
			ON StudentSchoolAssociation.StudentUSI = StudentEnrollmentAcrossSchools.StudentUSI
				AND StudentSchoolAssociation.SchoolId = StudentEnrollmentAcrossSchools.SchoolId
	LEFT JOIN
		analytics.ceds_K12EnrollmentStatusDim
			ON ceds_K12EnrollmentStatusDim.EntryTypeCode = EntryTypeDescriptor.CodeValue
				AND ceds_K12EnrollmentStatusDim.ExitOrWithdrawalTypeCode = ExitWithdrawTypeDescriptor.CodeValue
				AND (
					CASE
						WHEN StudentEnrollmentAcrossSchools.Count IS NOT NULL AND StudentEnrollmentAcrossSchools.Count > 1
							THEN 01810
						WHEN GETDATE() BETWEEN EntryDate AND ExitWithdrawDate
							THEN 01811
						WHEN GETDATE() <= ExitWithdrawDate
							THEN 01812
						WHEN ExitWithdrawDate IS NOT NULL AND ExitWithdrawTypeDescriptor.CodeValue = 'Transferred'
							THEN 01813
					END
				) = EnrollmentStatusCode
	INNER JOIN
		edfi.Descriptor EntryGradeLevelDescriptor
			ON StudentSchoolAssociation.EntryGradeLevelDescriptorId = EntryGradeLevelDescriptor.DescriptorId
	INNER JOIN
		analytics.ceds_GradeLevelDim
			ON EntryGradeLevelDescriptor.CodeValue = ceds_GradeLevelDim.GradeLevelCode
	INNER JOIN
		analytics.ceds_SchoolYearsDim SchoolYearsDim_ExitWithdrawDate
			ON StudentSchoolAssociation.ExitWithdrawDate BETWEEN CONVERT(date, SchoolYearsDim_ExitWithdrawDate.SessionBeginDate) AND CONVERT(date, SchoolYearsDim_ExitWithdrawDate.SessionEndDate)
	LEFT JOIN
		analytics.ceds_SchoolYearsDim ceds_SchoolYearsDim_SchoolYear
			ON StudentSchoolAssociation.ClassOfSchoolYear = ceds_SchoolYearsDim_SchoolYear.SchoolYear
	LEFT JOIN
		edfi.StudentEducationOrganizationAssociation
			ON StudentSchoolAssociation.StudentUSI = StudentEducationOrganizationAssociation.StudentUSI
				AND StudentSchoolAssociation.SchoolId = StudentEducationOrganizationAssociation.EducationOrganizationId
	LEFT JOIN
		edfi.Descriptor SexDescriptor
			ON StudentEducationOrganizationAssociation.SexDescriptorId = SexDescriptor.DescriptorId
	-- EconomicDisadvantage
	LEFT JOIN
		edfi.StudentEducationOrganizationAssociationStudentCharacteristic EconomicDisadvantageCharacteristic
			ON StudentEducationOrganizationAssociation.StudentUSI = EconomicDisadvantageCharacteristic.StudentUSI
	LEFT JOIN
		analytics_config.ceds_TableInformation EconomicDisadvantage
			ON EconomicDisadvantageCharacteristic.StudentCharacteristicDescriptorId = EconomicDisadvantage.DescriptorId
	LEFT JOIN
		analytics.ceds_K12DemographicDim
			ON EconomicDisadvantage.CodeValue = ceds_K12DemographicDim.EconomicDisadvantageStatusCode
	-- Homeless
	LEFT JOIN
		edfi.StudentEducationOrganizationAssociationStudentCharacteristic HomelessnessCharacteristic
			ON StudentEducationOrganizationAssociation.StudentUSI = HomelessnessCharacteristic.StudentUSI
	LEFT JOIN
		analytics_config.ceds_TableInformation Homelessness
			ON HomelessnessCharacteristic.StudentCharacteristicDescriptorId = Homelessness.DescriptorId
				AND ceds_K12DemographicDim.HomelessnessStatusCode = Homelessness.CodeValue
	-- EnglishLearner
	LEFT JOIN
		edfi.StudentEducationOrganizationAssociationStudentCharacteristic EnglishLearnerCharacteristic
			ON StudentEducationOrganizationAssociation.StudentUSI = EnglishLearnerCharacteristic.StudentUSI
	LEFT JOIN
		analytics_config.ceds_TableInformation EnglishLearner
			ON EnglishLearnerCharacteristic.StudentCharacteristicDescriptorId = EnglishLearner.DescriptorId
				AND ceds_K12DemographicDim.EnglishLearnerStatusCode = EnglishLearner.CodeValue
	-- Migrant
	LEFT JOIN
		edfi.StudentEducationOrganizationAssociationStudentCharacteristic MigrantCharacteristic
			ON StudentEducationOrganizationAssociation.StudentUSI = MigrantCharacteristic.StudentUSI
	LEFT JOIN
		analytics_config.ceds_TableInformation Migrant
			ON MigrantCharacteristic.StudentCharacteristicDescriptorId = Migrant.DescriptorId
				AND ceds_K12DemographicDim.MigrantStatusCode = Migrant.CodeValue
	-- MilitaryConnected
	LEFT JOIN
		edfi.StudentEducationOrganizationAssociationStudentCharacteristic MilitaryConnectedCharacteristic
			ON StudentEducationOrganizationAssociation.StudentUSI = MilitaryConnectedCharacteristic.StudentUSI
	LEFT JOIN
		analytics_config.ceds_TableInformation MilitaryConnected
			ON MilitaryConnectedCharacteristic.StudentCharacteristicDescriptorId = MilitaryConnected.DescriptorId
				AND ceds_K12DemographicDim.MilitaryConnectedStudentIndicatorCode = MilitaryConnected.CodeValue
	-- HomelessPrimaryNighttimeResidence
	LEFT JOIN
		edfi.StudentEducationOrganizationAssociationStudentCharacteristic HomelessPrimaryNighttimeResidenceCharacteristic
			ON StudentEducationOrganizationAssociation.StudentUSI = HomelessPrimaryNighttimeResidenceCharacteristic.StudentUSI
	LEFT JOIN
		analytics_config.ceds_TableInformation HomelessPrimaryNighttimeResidence
			ON HomelessPrimaryNighttimeResidenceCharacteristic.StudentCharacteristicDescriptorId = HomelessPrimaryNighttimeResidence.DescriptorId
				AND ceds_K12DemographicDim.HomelessPrimaryNighttimeResidenceCode = HomelessPrimaryNighttimeResidence.CodeValue
	-- HomelessUnaccompaniedYouth
	LEFT JOIN
		edfi.StudentEducationOrganizationAssociationStudentCharacteristic HomelessUnaccompaniedYouthCharacteristic
			ON StudentEducationOrganizationAssociation.StudentUSI = HomelessUnaccompaniedYouthCharacteristic.StudentUSI
	LEFT JOIN
		analytics_config.ceds_TableInformation HomelessUnaccompaniedYouth
			ON HomelessUnaccompaniedYouthCharacteristic.StudentCharacteristicDescriptorId = HomelessUnaccompaniedYouth.DescriptorId
				AND ceds_K12DemographicDim.HomelessUnaccompaniedYouthStatusCode = HomelessUnaccompaniedYouth.CodeValue
	-- SexCode
	LEFT JOIN
		analytics_config.ceds_TableInformation SexCode
			ON StudentEducationOrganizationAssociation.SexDescriptorId = SexCode.DescriptorId
				AND ceds_K12DemographicDim.SexCode = SexCode.CodeValue
