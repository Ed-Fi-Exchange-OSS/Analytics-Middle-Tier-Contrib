-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
DROP VIEW

IF EXISTS analytics.ceds_FactK12ProgramParticipation;
    CREATE
        OR REPLACE VIEW analytics.ceds_FactK12ProgramParticipation AS
        WITH FactK12ProgramParticipation AS (
                SELECT CONCAT (
                        StudentSpecialEducationProgramAssociation.EducationOrganizationId
                        , '-'
                        , StudentSpecialEducationProgramAssociation.ProgramTypeDescriptorId
                        , '-'
                        , StudentSpecialEducationProgramAssociation.ProgramEducationOrganizationId
                        ) AS FactK12ProgramParticipationKey
                    , COALESCE(SchoolYearKey, '-1') AS SchoolYearKey
                    , COALESCE(SchoolYearDimId, '-1') AS SchoolYearDimId
                    , '' AS DateKey
                    , '' AS DataCollectionKey
                    , COALESCE(ceds_IeuDim.IeuDimKey, '-1') AS IeuKey
                    , COALESCE(ceds_IeuDim.IeuDimId, '-1') AS IeuDimId
                    , COALESCE(ceds_SeaDim.SeaDimKey, '-1') AS SeaKey
                    , COALESCE(ceds_SeaDim.SeaDimId, '-1') AS SeaDimId
                    , COALESCE(ceds_LeaDim.LeaKey, '-1') AS LeaKey
                    , COALESCE(ceds_LeaDim.LeaDimId, '-1') AS LeaDimId
                    , COALESCE(K12SchoolKey, '-1') AS K12SchoolKey
                    , COALESCE(K12SchoolDimId, '-1') AS K12SchoolDimId
                    , COALESCE(ceds_K12ProgramTypeDim.K12ProgramTypeKey, '-1') AS K12ProgramTypeKey
                    , COALESCE(ceds_K12ProgramTypeDim.K12ProgramTypeDimId, '-1') AS K12ProgramTypeDimId
                    , COALESCE(ceds_K12StudentDim.K12StudentKey, '-1') AS K12StudentKey
                    , COALESCE(ceds_K12StudentDim.K12StudentDimId, '-1') AS K12StudentDimId
                    , COALESCE(ceds_K12DemographicDim.K12DemographicKey, '-1') AS K12DemographicKey
                    , COALESCE(ceds_K12DemographicDim.K12DemographicDimId, '-1') AS K12DemographicDimId
                    , COALESCE(ceds_IdeaStatusDim.IdeaStatusKey, '-1') AS IdeaStatusKey
                    , COALESCE(ceds_IdeaStatusDim.IdeaStatusDimId, '-1') AS IdeaStatusDimId
                    , GeneralStudentProgramAssociation.BeginDate AS ProgramParticipationStartDateKey
                    , GeneralStudentProgramAssociation.EndDate AS ProgramParticipationExitDateKey
                FROM edfi.StudentSpecialEducationProgramAssociation
                INNER JOIN analytics.ceds_SchoolYearDim
                    ON StudentSpecialEducationProgramAssociation.BeginDate BETWEEN TO_DATE(ceds_SchoolYearDim.SessionBeginDate, 'MM-DD-YYYY')
                            AND TO_DATE(ceds_SchoolYearDim.SessionEndDate, 'MM-DD-YYYY')
                INNER JOIN analytics.ceds_K12SchoolDim
                    ON ceds_K12SchoolDim.SchoolIdentifierSea::TEXT = StudentSpecialEducationProgramAssociation.EducationOrganizationId::TEXT
                INNER JOIN analytics.ceds_IeuDim
                    ON ceds_K12SchoolDim.IeuOrganizationIdentifierSea = ceds_IeuDim.IeuOrganizationIdentifierSea
                INNER JOIN analytics.ceds_SeaDim
                    ON ceds_K12SchoolDim.SeaIdentifierSea = ceds_SeaDim.SeaIdentifierSea
                INNER JOIN analytics.ceds_LeaDim
                    ON ceds_K12SchoolDim.LeaIdentifierSea = ceds_LeaDim.LeaIdentifierSea
                INNER JOIN edfi.ProgramTypeDescriptor
                    ON ProgramTypeDescriptor.ProgramTypeDescriptorId = StudentSpecialEducationProgramAssociation.ProgramTypeDescriptorId
                INNER JOIN edfi.Descriptor
                    ON Descriptor.DescriptorId = ProgramTypeDescriptor.ProgramTypeDescriptorId
                INNER JOIN analytics.ceds_K12ProgramTypeDim
                    ON ceds_K12ProgramTypeDim.ProgramTypeCode = Descriptor.CodeValue
                INNER JOIN edfi.Student
                    ON Student.StudentUSI = StudentSpecialEducationProgramAssociation.StudentUSI
                INNER JOIN analytics.ceds_K12StudentDim
                    ON ceds_K12StudentDim.StudentIdentifierState = Student.StudentUniqueId
                INNER JOIN edfi.GeneralStudentProgramAssociation
                    ON GeneralStudentProgramAssociation.BeginDate = StudentSpecialEducationProgramAssociation.BeginDate
                        AND GeneralStudentProgramAssociation.EducationOrganizationId = StudentSpecialEducationProgramAssociation.EducationOrganizationId
                        AND GeneralStudentProgramAssociation.ProgramEducationOrganizationId = StudentSpecialEducationProgramAssociation.ProgramEducationOrganizationId
                        AND GeneralStudentProgramAssociation.ProgramName = StudentSpecialEducationProgramAssociation.ProgramName
                        AND GeneralStudentProgramAssociation.ProgramTypeDescriptorId = StudentSpecialEducationProgramAssociation.ProgramTypeDescriptorId
                        AND GeneralStudentProgramAssociation.StudentUSI = StudentSpecialEducationProgramAssociation.StudentUSI
                INNER JOIN edfi.StudentSpecialEducationProgramAssociationDisability
                    ON StudentSpecialEducationProgramAssociationDisability.BeginDate = StudentSpecialEducationProgramAssociation.BeginDate
                        AND StudentSpecialEducationProgramAssociationDisability.EducationOrganizationId = StudentSpecialEducationProgramAssociation.EducationOrganizationId
                        AND StudentSpecialEducationProgramAssociationDisability.ProgramEducationOrganizationId = StudentSpecialEducationProgramAssociation.ProgramEducationOrganizationId
                        AND StudentSpecialEducationProgramAssociationDisability.ProgramTypeDescriptorId = StudentSpecialEducationProgramAssociation.ProgramTypeDescriptorId
                        AND StudentSpecialEducationProgramAssociationDisability.StudentUSI = StudentSpecialEducationProgramAssociation.StudentUSI
                INNER JOIN edfi.Descriptor StudentSpecialEducationProgramAssociationDisabilityDescriptor
                    ON StudentSpecialEducationProgramAssociationDisability.DisabilityDescriptorId = StudentSpecialEducationProgramAssociationDisabilityDescriptor.DescriptorId
                INNER JOIN edfi.Descriptor ReasonExitedDescriptor
                    ON GeneralStudentProgramAssociation.ReasonExitedDescriptorId = ReasonExitedDescriptor.DescriptorId
                INNER JOIN analytics.ceds_IdeaStatusDim
                    ON ReasonExitedDescriptor.CodeValue = ceds_IdeaStatusDim.SpecialEducationExitReasonCode
                        AND ceds_IdeaStatusDim.PrimaryDisabilityTypeCode = StudentSpecialEducationProgramAssociationDisabilityDescriptor.CodeValue
                LEFT JOIN edfi.StudentEducationOrganizationAssociation
                    ON StudentEducationOrganizationAssociation.StudentUSI = StudentSpecialEducationProgramAssociation.StudentUSI
                        AND StudentEducationOrganizationAssociation.SexDescriptorId = StudentSpecialEducationProgramAssociation.ProgramTypeDescriptorId
                LEFT JOIN edfi.StudentEducationOrganizationAssociationStudentCharacteristic EconomicDisadvantageCharacteristic
                    ON StudentEducationOrganizationAssociation.StudentUSI = EconomicDisadvantageCharacteristic.StudentUSI
                LEFT JOIN analytics_config.ceds_TableInformation EconomicDisadvantage
                    ON EconomicDisadvantageCharacteristic.StudentCharacteristicDescriptorId = EconomicDisadvantage.DescriptorId
                LEFT JOIN analytics.ceds_K12DemographicDim
                    ON EconomicDisadvantage.CodeValue = ceds_K12DemographicDim.EconomicDisadvantageStatusCode
                LEFT JOIN edfi.StudentEducationOrganizationAssociationStudentCharacteristic HomelessnessCharacteristic
                    ON StudentEducationOrganizationAssociation.StudentUSI = HomelessnessCharacteristic.StudentUSI
                LEFT JOIN analytics_config.ceds_TableInformation Homelessness
                    ON HomelessnessCharacteristic.StudentCharacteristicDescriptorId = Homelessness.DescriptorId
                        AND ceds_K12DemographicDim.HomelessnessStatusCode = Homelessness.CodeValue
                LEFT JOIN edfi.StudentEducationOrganizationAssociationStudentCharacteristic EnglishLearnerCharacteristic
                    ON StudentEducationOrganizationAssociation.StudentUSI = EnglishLearnerCharacteristic.StudentUSI
                LEFT JOIN analytics_config.ceds_TableInformation EnglishLearner
                    ON EnglishLearnerCharacteristic.StudentCharacteristicDescriptorId = EnglishLearner.DescriptorId
                        AND ceds_K12DemographicDim.EnglishLearnerStatusCode = EnglishLearner.CodeValue
                LEFT JOIN edfi.StudentEducationOrganizationAssociationStudentCharacteristic MigrantCharacteristic
                    ON StudentEducationOrganizationAssociation.StudentUSI = MigrantCharacteristic.StudentUSI
                LEFT JOIN analytics_config.ceds_TableInformation Migrant
                    ON MigrantCharacteristic.StudentCharacteristicDescriptorId = Migrant.DescriptorId
                        AND ceds_K12DemographicDim.MigrantStatusCode = Migrant.CodeValue
                LEFT JOIN edfi.StudentEducationOrganizationAssociationStudentCharacteristic MilitaryConnectedCharacteristic
                    ON StudentEducationOrganizationAssociation.StudentUSI = MilitaryConnectedCharacteristic.StudentUSI
                LEFT JOIN analytics_config.ceds_TableInformation MilitaryConnected
                    ON MilitaryConnectedCharacteristic.StudentCharacteristicDescriptorId = MilitaryConnected.DescriptorId
                        AND ceds_K12DemographicDim.MilitaryConnectedStudentIndicatorCode = MilitaryConnected.CodeValue
                LEFT JOIN edfi.StudentEducationOrganizationAssociationStudentCharacteristic HomelessPrimaryNighttimeResidenceCharacteristic
                    ON StudentEducationOrganizationAssociation.StudentUSI = HomelessPrimaryNighttimeResidenceCharacteristic.StudentUSI
                LEFT JOIN analytics_config.ceds_TableInformation HomelessPrimaryNighttimeResidence
                    ON HomelessPrimaryNighttimeResidenceCharacteristic.StudentCharacteristicDescriptorId = HomelessPrimaryNighttimeResidence.DescriptorId
                        AND ceds_K12DemographicDim.HomelessPrimaryNighttimeResidenceCode = HomelessPrimaryNighttimeResidence.CodeValue
                LEFT JOIN edfi.StudentEducationOrganizationAssociationStudentCharacteristic HomelessUnaccompaniedYouthCharacteristic
                    ON StudentEducationOrganizationAssociation.StudentUSI = HomelessUnaccompaniedYouthCharacteristic.StudentUSI
                LEFT JOIN analytics_config.ceds_TableInformation HomelessUnaccompaniedYouth
                    ON HomelessUnaccompaniedYouthCharacteristic.StudentCharacteristicDescriptorId = HomelessUnaccompaniedYouth.DescriptorId
                        AND ceds_K12DemographicDim.HomelessUnaccompaniedYouthStatusCode = HomelessUnaccompaniedYouth.CodeValue
                LEFT JOIN analytics_config.ceds_TableInformation SexCode
                    ON StudentEducationOrganizationAssociation.SexDescriptorId = SexCode.DescriptorId
                        AND ceds_K12DemographicDim.SexCode = SexCode.CodeValue
                LEFT JOIN edfi.StudentHomelessProgramAssociation
                    ON StudentHomelessProgramAssociation.StudentUSI = StudentEducationOrganizationAssociation.StudentUSI
                )

SELECT CONCAT (
        SchoolYearKey
        , '-'
        , DateKey
        , '-'
        , DataCollectionKey
        , '-'
        , SeaKey
        , '-'
        , IeuKey
        , '-'
        , LeaKey
        , '-'
        , K12SchoolKey
        , '-'
        , K12ProgramTypeKey
        , '-'
        , K12StudentKey
        , '-'
        , K12DemographicKey
        , '-'
        , IdeaStatusKey
        , '-'
        , ProgramParticipationStartDateKey
        , '-'
        , ProgramParticipationExitDateKey
        ) AS FactK12ProgramParticipationKey
    , SchoolYearKey
    , DateKey
    , DataCollectionKey
    , SeaKey
    , IeuKey
    , LeaKey
    , K12SchoolKey
    , K12ProgramTypeKey
    , K12StudentKey
    , K12DemographicKey
    , IdeaStatusKey
    , ProgramParticipationStartDateKey
    , ProgramParticipationExitDateKey
    , SeaDimId
    , IeuDimId
    , LeaDimId
    , K12SchoolDimId
    , K12ProgramTypeDimId
    , K12StudentDimId
    , K12DemographicDimId
    , IdeaStatusDimId
    , COUNT(K12DemographicKey) AS StudentCount
FROM FactK12ProgramParticipation
GROUP BY SchoolYearKey
    , DateKey
    , DataCollectionKey
    , SeaKey
    , IeuKey
    , LeaKey
    , K12SchoolKey
    , K12ProgramTypeKey
    , K12StudentKey
    , K12DemographicKey
    , IdeaStatusKey
    , ProgramParticipationStartDateKey
    , ProgramParticipationExitDateKey
    , SeaDimId
    , IeuDimId
    , LeaDimId
    , K12SchoolDimId
    , K12ProgramTypeDimId
    , K12StudentDimId
    , K12DemographicDimId
    , IdeaStatusDimId;
