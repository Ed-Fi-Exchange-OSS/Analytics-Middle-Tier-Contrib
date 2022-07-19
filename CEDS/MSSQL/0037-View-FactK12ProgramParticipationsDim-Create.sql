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
        (
            SELECT
            CONCAT(EducationOrganizationId, '-', ProgramTypeDescriptorId,'-', ProgramEducationOrganizationId)
            FROM edfi.StudentSpecialEducationProgramAssociation
            GROUP BY EducationOrganizationId, ProgramTypeDescriptorId, ProgramEducationOrganizationId
	    ) AS FactK12ProgramParticipationId,
           SchoolYearKey
           ,'' AS DateKey
           ,'' AS DataCollectionKey
           ,IeuOrganizationIdentifierSea AS 'SeaKey'
           ,LeaIdentifierSea AS 'IeuKey'
           ,LeaIdentifierNces AS 'LeaKey'
           ,K12SchoolKey AS 'K12SchoolKey'
           ,K12ProgramTypeKey AS 'DimK12ProgramTypeKey'
           ,StudentSchoolKey AS 'DimK12StudentlKey'
           ,K12DemographicKey AS 'DimK12DemographicKey'
           ,IdeaStatusKey AS 'DimIdeaStatusKey'
           ,GeneralStudentProgramAssociation.BeginDate AS 'BeginDate'
           ,GeneralStudentProgramAssociation.EndDate AS 'EndDate'
        FROM
            edfi.StudentSpecialEducationProgramAssociation
        INNER JOIN
            analytics.ceds_SchoolYearsDim
        ON
            StudentSpecialEducationProgramAssociation.BeginDate 
                BETWEEN CONVERT(date, ceds_SchoolYearsDim.SessionBeginDate) AND CONVERT(date, ceds_SchoolYearsDim.SessionEndDate)
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
        LEFT JOIN
            edfi.StudentEducationOrganizationAssociation
        ON
            StudentEducationOrganizationAssociation.StudentUSI = StudentSpecialEducationProgramAssociation.StudentUSI 
            AND Descriptor.DescriptorId = StudentEducationOrganizationAssociation.SexDescriptorId
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
        INNER JOIN
            edfi.GeneralStudentProgramAssociation
                ON
                    GeneralStudentProgramAssociation.BeginDate = StudentSpecialEducationProgramAssociation.BeginDate
                    OR GeneralStudentProgramAssociation.EducationOrganizationId = StudentSpecialEducationProgramAssociation.EducationOrganizationId
                    OR GeneralStudentProgramAssociation.ProgramEducationOrganizationId = StudentSpecialEducationProgramAssociation.ProgramEducationOrganizationId
                    OR GeneralStudentProgramAssociation.ProgramName = StudentSpecialEducationProgramAssociation.ProgramName
                    OR GeneralStudentProgramAssociation.ProgramTypeDescriptorId = StudentSpecialEducationProgramAssociation.ProgramTypeDescriptorId
                    OR GeneralStudentProgramAssociation.StudentUSI = StudentSpecialEducationProgramAssociation.StudentUSI
        INNER JOIN 
            edfi.StudentSpecialEducationProgramAssociationDisability
                ON
                    StudentSpecialEducationProgramAssociationDisability.BeginDate = StudentSpecialEducationProgramAssociation.BeginDate
                    OR StudentSpecialEducationProgramAssociationDisability.EducationOrganizationId = StudentSpecialEducationProgramAssociation.EducationOrganizationId
                    OR StudentSpecialEducationProgramAssociationDisability.ProgramEducationOrganizationId = StudentSpecialEducationProgramAssociation.ProgramEducationOrganizationId
                    OR StudentSpecialEducationProgramAssociationDisability.ProgramTypeDescriptorId = StudentSpecialEducationProgramAssociation.ProgramTypeDescriptorId
                    OR StudentSpecialEducationProgramAssociationDisability.StudentUSI = StudentSpecialEducationProgramAssociation.StudentUSI
        INNER JOIN 
            analytics.ceds_IdeaStatusDim DimIdeaStatus
                ON
                    Descriptor.CodeValue = DimIdeaStatus.BasisOfExitCode 
                    AND Descriptor.CodeValue = DimIdeaStatus.DisabilityCode
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
			DimK12ProgramTypeKey,
			'-',
			DimK12StudentlKey,
			'-',
			DimK12DemographicKey,
			'-',
			DimIdeaStatusKey,
			'-',
			BeginDate,
			'-',
			EndDate
        ) AS FactK12ProgramParticipationKey
        ,SchoolYearKey
        ,DateKey
        ,DataCollectionKey
        ,SeaKey
        ,IeuKey
        ,LeaKey
        ,K12SchoolKey
        ,DimK12ProgramTypeKey
        ,DimK12StudentlKey
        ,DimK12DemographicKey
        ,DimIdeaStatusKey
        ,BeginDate
        ,EndDate
        ,COUNT(DimK12DemographicKey) AS 'StudentCount'
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
        ,DimK12ProgramTypeKey
        ,DimK12StudentlKey
        ,DimK12DemographicKey
        ,DimIdeaStatusKey
        ,BeginDate
        ,EndDate
