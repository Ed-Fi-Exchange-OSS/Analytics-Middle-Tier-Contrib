-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.

IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.VIEWS
        WHERE TABLE_SCHEMA = 'analytics' AND TABLE_NAME = 'ceds_FactK12StudentEnrollment'
        )
BEGIN
    DROP VIEW analytics.ceds_FactK12StudentEnrollment;
END;
GO

CREATE VIEW analytics.ceds_FactK12StudentEnrollment AS
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
	),
	FactK12StudentEnrollments 
	AS (
		SELECT 
			ceds_SchoolYearDim.SchoolYearKey AS SchoolYearKey,
			'' AS DataCollectionKey,
			ceds_IeuDim.IeuDimKey AS IeuKey,
            ceds_SeaDim.SeaDimKey AS SeaKey,
            ceds_LeaDim.LeaKey AS LeaKey,
            K12SchoolKey AS K12SchoolKey,
			ceds_K12StudentDim.K12StudentKey AS K12StudentKey,
			ceds_K12EnrollmentStatusDim.K12EnrollmentStatusKey AS K12EnrollmentStatusKey,
			CASE
				WHEN ceds_GradeLevelDim.GradeLevelKey IS NULL THEN '-1'
				ELSE ceds_GradeLevelDim.GradeLevelKey
			END AS EntryGradeLevelKey,
			CASE
				WHEN ceds_GradeLevelDim.GradeLevelKey IS NULL THEN '-1'
				ELSE ceds_GradeLevelDim.GradeLevelKey
			END AS ExitGradeLevelKey,
			SchoolYearsDim_EntryDate.SchoolYearKey AS EnrollmentEntryDateKey,
			SchoolYearsDim_ExitWithdrawDate.SchoolYearKey AS EnrollmentExitDateKey,
			CASE
				WHEN ceds_SchoolYearDim_SchoolYear.SchoolYearKey IS NULL THEN '-1'
				ELSE ceds_SchoolYearDim_SchoolYear.SchoolYearKey
			END AS ProjectedGraduationDateKey,
			CASE
				WHEN ceds_K12DemographicDim.K12DemographicKey IS NULL THEN '-1'
				ELSE ceds_K12DemographicDim.K12DemographicKey
			END AS K12DemographicKey,
			'' AS IdeaStatusKey
		FROM
			analytics.ceds_SchoolYearDim
		INNER JOIN 
			edfi.StudentSchoolAssociation
				ON StudentSchoolAssociation.EntryDate BETWEEN CONVERT(date, ceds_SchoolYearDim.SessionBeginDate) AND CONVERT(date, ceds_SchoolYearDim.SessionEndDate)
		INNER JOIN
			analytics.ceds_K12SchoolDim
				ON edfi.StudentSchoolAssociation.SchoolId = ceds_K12SchoolDim.SchoolIdentifierSea
		INNER JOIN
			analytics.ceds_IeuDim
		ON
			ceds_K12SchoolDim.IeuOrganizationIdentifierSea = ceds_IeuDim.IeuOrganizationIdentifierSea
		INNER JOIN
			analytics.ceds_SeaDim
		ON
			ceds_K12SchoolDim.SeaIdentifierSea = ceds_SeaDim.SeaIdentifierSea
		INNER JOIN
			analytics.ceds_LeaDim
		ON
			ceds_K12SchoolDim.LeaIdentifierSea = ceds_LeaDim.LeaIdentifierSea
		INNER JOIN
			edfi.Student
				ON StudentSchoolAssociation.StudentUSI = Student.StudentUSI
		INNER JOIN
			analytics.ceds_K12StudentDim
				ON Student.StudentUniqueId = ceds_K12StudentDim.StudentIdentifierState
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
			analytics.ceds_SchoolYearDim SchoolYearsDim_EntryDate
				ON StudentSchoolAssociation.EntryDate BETWEEN CONVERT(date, SchoolYearsDim_EntryDate.SessionBeginDate) AND CONVERT(date, SchoolYearsDim_EntryDate.SessionEndDate)
		INNER JOIN
			analytics.ceds_SchoolYearDim SchoolYearsDim_ExitWithdrawDate
				ON StudentSchoolAssociation.ExitWithdrawDate BETWEEN CONVERT(date, SchoolYearsDim_ExitWithdrawDate.SessionBeginDate) AND CONVERT(date, SchoolYearsDim_ExitWithdrawDate.SessionEndDate)
		LEFT JOIN
			analytics.ceds_SchoolYearDim ceds_SchoolYearDim_SchoolYear
				ON StudentSchoolAssociation.ClassOfSchoolYear = ceds_SchoolYearDim_SchoolYear.SchoolYear
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
	)
	SELECT
		CONCAT (
			SchoolYearKey,
			'-',
			DataCollectionKey,
			'-',
			SeaKey,
			'-',
			IeuKey,
			'-',
			LeaKey,
			'-',
			K12SchoolKey,
			'-',
			K12StudentKey,
			'-',
			K12EnrollmentStatusKey,
			'-',
			EntryGradeLevelKey,
			'-',
			ExitGradeLevelKey,
			'-',
			EnrollmentEntryDateKey,
			'-',
			EnrollmentExitDateKey,
			'-',
			ProjectedGraduationDateKey,
			'-',
			K12DemographicKey,
			'-',
			IdeaStatusKey
		) AS FactK12StudentEnrollmentKey,
		SchoolYearKey,
		DataCollectionKey,
		SeaKey,
		IeuKey,
		LeaKey,
		K12SchoolKey,
		K12StudentKey,
		K12EnrollmentStatusKey,
		EntryGradeLevelKey,
		ExitGradeLevelKey,
		EnrollmentEntryDateKey,
		EnrollmentExitDateKey,
		ProjectedGraduationDateKey,
		K12DemographicKey,
		IdeaStatusKey,
		COUNT (K12StudentKey) AS StudentCount
	FROM
		FactK12StudentEnrollments
	GROUP BY
		SchoolYearKey,
		DataCollectionKey,
		SeaKey,
		IeuKey,
		LeaKey,
		K12SchoolKey,
		K12StudentKey,
		K12EnrollmentStatusKey,
		EntryGradeLevelKey,
		ExitGradeLevelKey,
		EnrollmentEntryDateKey,
		EnrollmentExitDateKey,
		ProjectedGraduationDateKey,
		K12DemographicKey,
		IdeaStatusKey