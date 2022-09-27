-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.

IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.VIEWS
        WHERE TABLE_SCHEMA = 'analytics' AND TABLE_NAME = 'ceds_FactK12ProgramParticipation'
        )
BEGIN
    DROP VIEW analytics.ceds_FactK12ProgramParticipation;
END;
GO

CREATE VIEW analytics.ceds_FactK12ProgramParticipation AS
	WITH FactK12ProgramParticipation
	AS (
        SELECT
            CONCAT(StudentSpecialEducationProgramAssociation.EducationOrganizationId, '-',
                   StudentSpecialEducationProgramAssociation.ProgramTypeDescriptorId, '-',
                   StudentSpecialEducationProgramAssociation.ProgramEducationOrganizationId)
            AS FactK12ProgramParticipationKey
           ,SchoolYearKey
           ,'' AS DateKey
           ,'' AS DataCollectionKey
           ,IeuOrganizationIdentifierSea AS SeaKey
           ,LeaIdentifierSea AS IeuKey
           ,LeaIdentifierNces AS LeaKey
           ,K12SchoolKey AS K12SchoolKey
           ,K12ProgramTypeKey AS K12ProgramTypeKey
           ,ceds_K12StudentDim.K12StudentKey AS K12StudentKey
           ,K12DemographicKey AS K12DemographicKey
           ,IdeaStatusKey AS IdeaStatusKey
           ,GeneralStudentProgramAssociation.BeginDate AS ProgramParticipationStartDateKey
           ,GeneralStudentProgramAssociation.EndDate AS ProgramParticipationExitDateKey
        FROM
            edfi.StudentSpecialEducationProgramAssociation
        INNER JOIN
            analytics.ceds_SchoolYearDim
        ON
            StudentSpecialEducationProgramAssociation.BeginDate
                BETWEEN CONVERT(date, ceds_SchoolYearDim.SessionBeginDate) AND CONVERT(date, ceds_SchoolYearDim.SessionEndDate)
        INNER JOIN
            analytics.ceds_K12SchoolDim
        ON
            ceds_K12SchoolDim.SchoolIdentifierSea = StudentSpecialEducationProgramAssociation.EducationOrganizationId
        INNER JOIN
            edfi.ProgramTypeDescriptor
        ON
            ProgramTypeDescriptor.ProgramTypeDescriptorId = StudentSpecialEducationProgramAssociation.ProgramTypeDescriptorId
        INNER JOIN
            edfi.Descriptor
        ON
            Descriptor.DescriptorId = ProgramTypeDescriptor.ProgramTypeDescriptorId
        INNER JOIN
            analytics.ceds_K12ProgramTypeDim
        ON
           ceds_K12ProgramTypeDim.ProgramTypeCode = Descriptor.CodeValue
        INNER JOIN
            edfi.Student
        ON
            Student.StudentUSI = StudentSpecialEducationProgramAssociation.StudentUSI
        INNER JOIN
            analytics.ceds_K12StudentDim
        ON
            ceds_K12StudentDim.StudentIdentifierState = Student.StudentUniqueId
        INNER JOIN
            edfi.GeneralStudentProgramAssociation
                ON
                    GeneralStudentProgramAssociation.BeginDate = StudentSpecialEducationProgramAssociation.BeginDate
                    AND GeneralStudentProgramAssociation.EducationOrganizationId = StudentSpecialEducationProgramAssociation.EducationOrganizationId
                    AND GeneralStudentProgramAssociation.ProgramEducationOrganizationId = StudentSpecialEducationProgramAssociation.ProgramEducationOrganizationId
                    AND GeneralStudentProgramAssociation.ProgramName = StudentSpecialEducationProgramAssociation.ProgramName
                    AND GeneralStudentProgramAssociation.ProgramTypeDescriptorId = StudentSpecialEducationProgramAssociation.ProgramTypeDescriptorId
                    AND GeneralStudentProgramAssociation.StudentUSI = StudentSpecialEducationProgramAssociation.StudentUSI
        INNER JOIN
			edfi.StudentSpecialEducationProgramAssociationDisability
				ON
					StudentSpecialEducationProgramAssociationDisability.BeginDate = StudentSpecialEducationProgramAssociation.BeginDate
					AND StudentSpecialEducationProgramAssociationDisability.EducationOrganizationId = StudentSpecialEducationProgramAssociation.EducationOrganizationId
					AND StudentSpecialEducationProgramAssociationDisability.ProgramEducationOrganizationId = StudentSpecialEducationProgramAssociation.ProgramEducationOrganizationId
					AND StudentSpecialEducationProgramAssociationDisability.ProgramTypeDescriptorId = StudentSpecialEducationProgramAssociation.ProgramTypeDescriptorId
					AND StudentSpecialEducationProgramAssociationDisability.StudentUSI = StudentSpecialEducationProgramAssociation.StudentUSI
		INNER JOIN
			edfi.Descriptor StudentSpecialEducationProgramAssociationDisabilityDescriptor
				ON
					StudentSpecialEducationProgramAssociationDisability.DisabilityDescriptorId = StudentSpecialEducationProgramAssociationDisabilityDescriptor.DescriptorId
		INNER JOIN
			edfi.Descriptor ReasonExitedDescriptor
				ON
					GeneralStudentProgramAssociation.ReasonExitedDescriptorId = ReasonExitedDescriptor.DescriptorId
		INNER JOIN
			analytics.ceds_IdeaStatusDim
				ON
					ReasonExitedDescriptor.CodeValue = ceds_IdeaStatusDim.SpecialEducationExitReasonCode
					AND ceds_IdeaStatusDim.PrimaryDisabilityTypeCode = StudentSpecialEducationProgramAssociationDisabilityDescriptor.CodeValue
        LEFT JOIN
            edfi.StudentEducationOrganizationAssociation
        ON
            StudentEducationOrganizationAssociation.StudentUSI = StudentSpecialEducationProgramAssociation.StudentUSI
            AND StudentEducationOrganizationAssociation.SexDescriptorId = StudentSpecialEducationProgramAssociation.ProgramTypeDescriptorId
        LEFT JOIN
			edfi.StudentEducationOrganizationAssociationStudentCharacteristic EconomicDisadvantageCharacteristic
				ON StudentEducationOrganizationAssociation.StudentUSI = EconomicDisadvantageCharacteristic.StudentUSI
		LEFT JOIN
			analytics_config.ceds_TableInformation EconomicDisadvantage
				ON EconomicDisadvantageCharacteristic.StudentCharacteristicDescriptorId = EconomicDisadvantage.DescriptorId
		LEFT JOIN
			analytics.ceds_K12DemographicDim
				ON EconomicDisadvantage.CodeValue = ceds_K12DemographicDim.EconomicDisadvantageStatusCode
		LEFT JOIN
			edfi.StudentEducationOrganizationAssociationStudentCharacteristic HomelessnessCharacteristic
				ON StudentEducationOrganizationAssociation.StudentUSI = HomelessnessCharacteristic.StudentUSI
		LEFT JOIN
			analytics_config.ceds_TableInformation Homelessness
				ON HomelessnessCharacteristic.StudentCharacteristicDescriptorId = Homelessness.DescriptorId
					AND ceds_K12DemographicDim.HomelessnessStatusCode = Homelessness.CodeValue
		LEFT JOIN
			edfi.StudentEducationOrganizationAssociationStudentCharacteristic EnglishLearnerCharacteristic
				ON StudentEducationOrganizationAssociation.StudentUSI = EnglishLearnerCharacteristic.StudentUSI
		LEFT JOIN
			analytics_config.ceds_TableInformation EnglishLearner
				ON EnglishLearnerCharacteristic.StudentCharacteristicDescriptorId = EnglishLearner.DescriptorId
					AND ceds_K12DemographicDim.EnglishLearnerStatusCode = EnglishLearner.CodeValue
		LEFT JOIN
			edfi.StudentEducationOrganizationAssociationStudentCharacteristic MigrantCharacteristic
				ON StudentEducationOrganizationAssociation.StudentUSI = MigrantCharacteristic.StudentUSI
		LEFT JOIN
			analytics_config.ceds_TableInformation Migrant
				ON MigrantCharacteristic.StudentCharacteristicDescriptorId = Migrant.DescriptorId
					AND ceds_K12DemographicDim.MigrantStatusCode = Migrant.CodeValue
		LEFT JOIN
			edfi.StudentEducationOrganizationAssociationStudentCharacteristic MilitaryConnectedCharacteristic
				ON StudentEducationOrganizationAssociation.StudentUSI = MilitaryConnectedCharacteristic.StudentUSI
		LEFT JOIN
			analytics_config.ceds_TableInformation MilitaryConnected
				ON MilitaryConnectedCharacteristic.StudentCharacteristicDescriptorId = MilitaryConnected.DescriptorId
					AND ceds_K12DemographicDim.MilitaryConnectedStudentIndicatorCode = MilitaryConnected.CodeValue
		LEFT JOIN
			edfi.StudentEducationOrganizationAssociationStudentCharacteristic HomelessPrimaryNighttimeResidenceCharacteristic
				ON StudentEducationOrganizationAssociation.StudentUSI = HomelessPrimaryNighttimeResidenceCharacteristic.StudentUSI
		LEFT JOIN
			analytics_config.ceds_TableInformation HomelessPrimaryNighttimeResidence
				ON HomelessPrimaryNighttimeResidenceCharacteristic.StudentCharacteristicDescriptorId = HomelessPrimaryNighttimeResidence.DescriptorId
					AND ceds_K12DemographicDim.HomelessPrimaryNighttimeResidenceCode = HomelessPrimaryNighttimeResidence.CodeValue
		LEFT JOIN
			edfi.StudentEducationOrganizationAssociationStudentCharacteristic HomelessUnaccompaniedYouthCharacteristic
				ON StudentEducationOrganizationAssociation.StudentUSI = HomelessUnaccompaniedYouthCharacteristic.StudentUSI
		LEFT JOIN
			analytics_config.ceds_TableInformation HomelessUnaccompaniedYouth
				ON HomelessUnaccompaniedYouthCharacteristic.StudentCharacteristicDescriptorId = HomelessUnaccompaniedYouth.DescriptorId
					AND ceds_K12DemographicDim.HomelessUnaccompaniedYouthStatusCode = HomelessUnaccompaniedYouth.CodeValue
		LEFT JOIN
			analytics_config.ceds_TableInformation SexCode
				ON StudentEducationOrganizationAssociation.SexDescriptorId = SexCode.DescriptorId
					AND ceds_K12DemographicDim.SexCode = SexCode.CodeValue
        LEFT JOIN
            edfi.StudentHomelessProgramAssociation
                ON StudentHomelessProgramAssociation.StudentUSI = StudentEducationOrganizationAssociation.StudentUSI
        )
    SELECT
        CONCAT(
            SchoolYearKey,
			'-',
			DateKey,
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
			K12ProgramTypeKey,
			'-',
			K12StudentKey,
			'-',
			K12DemographicKey,
			'-',
			IdeaStatusKey,
			'-',
			ProgramParticipationStartDateKey,
			'-',
			ProgramParticipationExitDateKey
        ) AS FactK12ProgramParticipationKey
        ,SchoolYearKey
        ,DateKey
        ,DataCollectionKey
        ,SeaKey
        ,IeuKey
        ,LeaKey
        ,K12SchoolKey
        ,K12ProgramTypeKey
        ,K12StudentKey
        ,K12DemographicKey
        ,IdeaStatusKey
        ,ProgramParticipationStartDateKey
        ,ProgramParticipationExitDateKey
        ,COUNT(K12DemographicKey) AS StudentCount
    FROM
        FactK12ProgramParticipation
    GROUP BY
        SchoolYearKey
        ,DateKey
        ,DataCollectionKey
        ,SeaKey
        ,IeuKey
        ,LeaKey
        ,K12SchoolKey
        ,K12ProgramTypeKey
        ,K12StudentKey
        ,K12DemographicKey
        ,IdeaStatusKey
        ,ProgramParticipationStartDateKey
        ,ProgramParticipationExitDateKey
