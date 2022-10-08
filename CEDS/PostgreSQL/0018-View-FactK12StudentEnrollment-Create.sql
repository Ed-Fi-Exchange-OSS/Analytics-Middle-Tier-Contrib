-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
DROP VIEW

IF EXISTS analytics.ceds_FactK12StudentEnrollment;
    CREATE
        OR REPLACE VIEW analytics.ceds_FactK12StudentEnrollment AS
        WITH StudentEnrollmentAcrossSchools AS (
                SELECT studentschoolassociation.StudentUSI
                    , studentschoolassociation.SchoolId
                    , Student.StudentUniqueId
                    , COUNT(1) AS Count
                FROM edfi.studentschoolassociation
                INNER JOIN edfi.Student
                    ON studentschoolassociation.StudentUSI = Student.StudentUSI
                WHERE StudentSchoolAssociation.ExitWithdrawDate IS NULL
                    OR StudentSchoolAssociation.ExitWithdrawDate >= NOW()
                GROUP BY studentschoolassociation.StudentUSI
                    , StudentUniqueId
                    , SchoolId
                )
            , StudentDemographicBridge AS (
                SELECT COALESCE(ceds_K12DemographicDim.K12DemographicKey, '-1') AS K12DemographicKey
                    , COALESCE(ceds_K12DemographicDim.K12DemographicDimId, '-1') AS K12DemographicDimId
                    , Student.StudentUniqueId AS StudentIdentifierState
                    , CAST(StudentSchoolAssociation.SchoolId AS VARCHAR) AS SchoolKey
                FROM edfi.Student
                INNER JOIN edfi.StudentSchoolAssociation
                    ON StudentSchoolAssociation.StudentUSI = Student.StudentUSI
                INNER JOIN edfi.StudentEducationOrganizationAssociation
                    ON StudentSchoolAssociation.StudentUSI = StudentEducationOrganizationAssociation.StudentUSI
                        AND StudentSchoolAssociation.SchoolId = StudentEducationOrganizationAssociation.EducationOrganizationId
                LEFT JOIN edfi.Descriptor SexDescriptor
                    ON StudentEducationOrganizationAssociation.SexDescriptorId = SexDescriptor.DescriptorId
                -- EconomicDisadvantage
                LEFT JOIN edfi.StudentEducationOrganizationAssociationStudentCharacteristic EconomicDisadvantageCharacteristic
                    ON StudentEducationOrganizationAssociation.StudentUSI = EconomicDisadvantageCharacteristic.StudentUSI
                        AND StudentEducationOrganizationAssociation.EducationOrganizationId = EconomicDisadvantageCharacteristic.EducationOrganizationId
                LEFT JOIN edfi.Descriptor EconomicDisadvantageDescriptor
                    ON EconomicDisadvantageCharacteristic.StudentCharacteristicDescriptorId = EconomicDisadvantageDescriptor.DescriptorId
                -- Homeless
                LEFT JOIN edfi.StudentEducationOrganizationAssociationStudentCharacteristic HomelessnessCharacteristic
                    ON StudentEducationOrganizationAssociation.StudentUSI = HomelessnessCharacteristic.StudentUSI
                        AND StudentEducationOrganizationAssociation.EducationOrganizationId = HomelessnessCharacteristic.EducationOrganizationId
                LEFT JOIN edfi.Descriptor HomelessnessCharacteristicDescriptor
                    ON HomelessnessCharacteristic.StudentCharacteristicDescriptorId = HomelessnessCharacteristicDescriptor.DescriptorId
                -- EnglishLearner
                LEFT JOIN edfi.StudentEducationOrganizationAssociationStudentCharacteristic EnglishLearnerCharacteristic
                    ON StudentEducationOrganizationAssociation.StudentUSI = EnglishLearnerCharacteristic.StudentUSI
                        AND StudentEducationOrganizationAssociation.EducationOrganizationId = EnglishLearnerCharacteristic.EducationOrganizationId
                LEFT JOIN edfi.Descriptor EnglishLearnerCharacteristicDescriptor
                    ON EnglishLearnerCharacteristic.StudentCharacteristicDescriptorId = EnglishLearnerCharacteristicDescriptor.DescriptorId
                -- Migrant
                LEFT JOIN edfi.StudentEducationOrganizationAssociationStudentCharacteristic MigrantCharacteristic
                    ON StudentEducationOrganizationAssociation.StudentUSI = MigrantCharacteristic.StudentUSI
                        AND StudentEducationOrganizationAssociation.EducationOrganizationId = MigrantCharacteristic.EducationOrganizationId
                LEFT JOIN edfi.Descriptor MigrantCharacteristicDescriptor
                    ON MigrantCharacteristic.StudentCharacteristicDescriptorId = MigrantCharacteristicDescriptor.DescriptorId
                -- MilitaryConnected
                LEFT JOIN edfi.StudentEducationOrganizationAssociationStudentCharacteristic MilitaryConnectedCharacteristic
                    ON StudentEducationOrganizationAssociation.StudentUSI = MilitaryConnectedCharacteristic.StudentUSI
                        AND StudentEducationOrganizationAssociation.EducationOrganizationId = MilitaryConnectedCharacteristic.EducationOrganizationId
                LEFT JOIN edfi.Descriptor MilitaryConnectedDescriptor
                    ON MilitaryConnectedCharacteristic.StudentCharacteristicDescriptorId = MilitaryConnectedDescriptor.DescriptorId
                -- HomelessPrimaryNighttimeResidence
                LEFT JOIN edfi.StudentEducationOrganizationAssociationStudentCharacteristic HomelessPrimaryNighttimeResidenceCharacteristic
                    ON StudentEducationOrganizationAssociation.StudentUSI = HomelessPrimaryNighttimeResidenceCharacteristic.StudentUSI
                        AND StudentEducationOrganizationAssociation.EducationOrganizationId = HomelessPrimaryNighttimeResidenceCharacteristic.EducationOrganizationId
                LEFT JOIN edfi.Descriptor HomelessPrimaryNighttimeResidenceCharacteristicDescriptor
                    ON HomelessPrimaryNighttimeResidenceCharacteristic.StudentCharacteristicDescriptorId = HomelessPrimaryNighttimeResidenceCharacteristicDescriptor.DescriptorId
                -- HomelessUnaccompaniedYouth
                LEFT JOIN edfi.StudentEducationOrganizationAssociationStudentCharacteristic HomelessUnaccompaniedYouthCharacteristic
                    ON StudentEducationOrganizationAssociation.StudentUSI = HomelessUnaccompaniedYouthCharacteristic.StudentUSI
                        AND StudentEducationOrganizationAssociation.EducationOrganizationId = HomelessUnaccompaniedYouthCharacteristic.EducationOrganizationId
                LEFT JOIN edfi.Descriptor HomelessUnaccompaniedYouthCharacteristicDescriptor
                    ON HomelessUnaccompaniedYouthCharacteristic.StudentCharacteristicDescriptorId = HomelessUnaccompaniedYouthCharacteristicDescriptor.DescriptorId
                LEFT JOIN analytics.ceds_K12DemographicDim
                    ON SexDescriptor.CodeValue = ceds_K12DemographicDim.SexCode
                        AND EconomicDisadvantageDescriptor.CodeValue = ceds_K12DemographicDim.EconomicDisadvantageStatusCode
                        AND HomelessnessCharacteristicDescriptor.CodeValue = ceds_K12DemographicDim.HomelessnessStatusCode
                        AND EnglishLearnerCharacteristicDescriptor.CodeValue = ceds_K12DemographicDim.EnglishLearnerStatusCode
                        AND MigrantCharacteristicDescriptor.CodeValue = ceds_K12DemographicDim.MigrantStatusCode
                        AND MilitaryConnectedDescriptor.CodeValue = ceds_K12DemographicDim.MilitaryConnectedStudentIndicatorCode
                        AND HomelessPrimaryNighttimeResidenceCharacteristicDescriptor.CodeValue = ceds_K12DemographicDim.HomelessPrimaryNighttimeResidenceCode
                        AND HomelessUnaccompaniedYouthCharacteristicDescriptor.CodeValue = ceds_K12DemographicDim.HomelessUnaccompaniedYouthStatusCode
                )
            , FactK12StudentEnrollments AS (
                SELECT COALESCE(ceds_SchoolYearDim.SchoolYearKey, '-1') AS SchoolYearKey
                    , COALESCE(ceds_SchoolYearDim.SchoolYearDimId, '-1') AS SchoolYearDimId
                    , '' AS DataCollectionKey
                    , COALESCE(ceds_IeuDim.IeuDimKey, '-1') AS IeuKey
                    , COALESCE(ceds_IeuDim.IeuDimId, '-1') AS IeuDimId
                    , COALESCE(ceds_SeaDim.SeaDimKey, '-1') AS SeaKey
                    , COALESCE(ceds_SeaDim.SeaDimId, '-1') AS SeaDimId
                    , COALESCE(ceds_LeaDim.LeaKey, '-1') AS LeaKey
                    , COALESCE(ceds_LeaDim.LeaDimId, '-1') AS LeaDimId
                    , COALESCE(K12SchoolKey, '-1') AS K12SchoolKey
                    , COALESCE(K12SchoolDimId, '-1') AS K12SchoolDimId
                    , COALESCE(ceds_K12StudentDim.K12StudentKey, '-1') AS K12StudentKey
                    , COALESCE(ceds_K12StudentDim.K12StudentDimId, '-1') AS K12StudentDimId
                    , COALESCE(ceds_K12EnrollmentStatusDim.K12EnrollmentStatusKey, '-1') AS K12EnrollmentStatusKey
                    , COALESCE(ceds_K12EnrollmentStatusDim.K12EnrollmentStatusDimId, '-1') AS K12EnrollmentStatusDimId
                    , COALESCE(ceds_GradeLevelDim.GradeLevelKey, '-1') AS EntryGradeLevelKey
                    , COALESCE(ceds_GradeLevelDim.GradeLevelDimId, '-1') AS EntryGradeLevelDimId
                    , COALESCE(ceds_GradeLevelDim.GradeLevelKey, '-1') AS ExitGradeLevelKey
                    , COALESCE(ceds_GradeLevelDim.GradeLevelDimId, '-1') AS ExitGradeLevelDimId
                    , ceds_SchoolYearDim.SchoolYearKey AS EnrollmentEntryDateKey
                    , SchoolYearsDim_ExitWithdrawDate.SchoolYearKey AS EnrollmentExitDateKey
                    , COALESCE(ceds_K12StudentDim.ClassOfSchoolYear, '-1') AS ProjectedGraduationDateKey
                    , COALESCE(StudentDemographicBridge.K12DemographicKey, '-1') AS K12DemographicKey
                    , COALESCE(StudentDemographicBridge.K12DemographicDimId, '-1') AS K12DemographicDimId
                    , '-1' AS IdeaStatusKey
                    , '-1' AS IdeaStatusDimId
                FROM analytics.ceds_SchoolYearDim
                INNER JOIN analytics.ceds_K12StudentDim
                    ON ceds_K12StudentDim.EntryDateKey BETWEEN ceds_SchoolYearDim.SessionBeginDateKey
                            AND ceds_SchoolYearDim.SessionEndDateKey
                INNER JOIN analytics.ceds_K12SchoolDim
                    ON ceds_K12StudentDim.SchoolKey = ceds_K12SchoolDim.SchoolKey
                INNER JOIN StudentDemographicBridge
                    ON StudentDemographicBridge.StudentIdentifierState = ceds_K12StudentDim.StudentIdentifierState
                        AND StudentDemographicBridge.SchoolKey = ceds_K12StudentDim.SchoolKey
                INNER JOIN analytics.ceds_IeuDim
                    ON ceds_K12SchoolDim.IeuOrganizationIdentifierSea = ceds_IeuDim.IeuOrganizationIdentifierSea
                INNER JOIN analytics.ceds_SeaDim
                    ON ceds_K12SchoolDim.SeaIdentifierSea = ceds_SeaDim.SeaIdentifierSea
                INNER JOIN analytics.ceds_LeaDim
                    ON ceds_K12SchoolDim.LeaIdentifierSea = ceds_LeaDim.LeaIdentifierSea
                LEFT JOIN edfi.Descriptor EntryTypeDescriptor
                    ON ceds_K12StudentDim.EntryTypeDescriptorId = EntryTypeDescriptor.DescriptorId
                LEFT JOIN edfi.Descriptor ExitWithdrawTypeDescriptor
                    ON ceds_K12StudentDim.ExitWithdrawTypeDescriptorId = ExitWithdrawTypeDescriptor.DescriptorId
                LEFT JOIN StudentEnrollmentAcrossSchools
                    ON ceds_K12StudentDim.StudentIdentifierState = StudentEnrollmentAcrossSchools.StudentUniqueId
                LEFT JOIN analytics.ceds_K12EnrollmentStatusDim
                    ON ceds_K12EnrollmentStatusDim.EntryTypeCode = EntryTypeDescriptor.CodeValue
                        AND ceds_K12EnrollmentStatusDim.ExitOrWithdrawalTypeCode = ExitWithdrawTypeDescriptor.CodeValue
                        AND (
                            CASE 
                                WHEN StudentEnrollmentAcrossSchools.Count IS NOT NULL
                                    AND StudentEnrollmentAcrossSchools.Count > 1
                                    THEN '01810'
                                WHEN CAST(TO_CHAR(NOW(), 'yyyymmdd') AS INT) BETWEEN EntryDateKey
                                        AND ExitWithdrawDateKey
                                    THEN '01811'
                                WHEN CAST(TO_CHAR(NOW(), 'yyyymmdd') AS INT) <= ExitWithdrawDateKey
                                    THEN '01812'
                                WHEN ExitWithdrawDateKey IS NOT NULL
                                    AND ExitWithdrawTypeDescriptor.CodeValue = 'Transferred'
                                    THEN '01813'
                                END
                            ) = EnrollmentStatusCode
                INNER JOIN edfi.Descriptor EntryGradeLevelDescriptor
                    ON ceds_K12StudentDim.EntryGradeLevelDescriptorId = EntryGradeLevelDescriptor.DescriptorId
                INNER JOIN analytics.ceds_GradeLevelDim
                    ON EntryGradeLevelDescriptor.CodeValue = ceds_GradeLevelDim.GradeLevelCode
                LEFT JOIN analytics.ceds_SchoolYearDim SchoolYearsDim_ExitWithdrawDate
                    ON ceds_K12StudentDim.ExitWithdrawDateKey BETWEEN SchoolYearsDim_ExitWithdrawDate.SessionBeginDateKey
                            AND SchoolYearsDim_ExitWithdrawDate.SessionEndDateKey
                WHERE COALESCE(ceds_K12StudentDim.ClassOfSchoolYear, ceds_SchoolYearDim.SchoolYear) = ceds_SchoolYearDim.SchoolYear
                )

SELECT CONCAT (
        SchoolYearKey
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
        , K12StudentKey
        , '-'
        , K12EnrollmentStatusKey
        , '-'
        , EntryGradeLevelKey
        , '-'
        , ExitGradeLevelKey
        , '-'
        , EnrollmentEntryDateKey
        , '-'
        , EnrollmentExitDateKey
        , '-'
        , ProjectedGraduationDateKey
        , '-'
        , K12DemographicKey
        , '-'
        , IdeaStatusKey
        ) AS FactK12StudentEnrollmentKey
    , SchoolYearKey
    , DataCollectionKey
    , SeaKey
    , IeuKey
    , LeaKey
    , K12SchoolKey
    , K12StudentKey
    , K12EnrollmentStatusKey
    , EntryGradeLevelKey
    , ExitGradeLevelKey
    , EnrollmentEntryDateKey
    , EnrollmentExitDateKey
    , ProjectedGraduationDateKey
    , K12DemographicKey
    , IdeaStatusKey
    , SchoolYearDimId
    , SeaDimId
    , IeuDimId
    , LeaDimId
    , K12SchoolDimId
    , K12StudentDimId
    , K12EnrollmentStatusDimId
    , EntryGradeLevelDimId
    , K12DemographicDimId
    , IdeaStatusDimId
    , COUNT(K12StudentKey) AS StudentCount
FROM FactK12StudentEnrollments
GROUP BY SchoolYearKey
    , DataCollectionKey
    , SeaKey
    , IeuKey
    , LeaKey
    , K12SchoolKey
    , K12StudentKey
    , K12EnrollmentStatusKey
    , EntryGradeLevelKey
    , ExitGradeLevelKey
    , EnrollmentEntryDateKey
    , EnrollmentExitDateKey
    , ProjectedGraduationDateKey
    , K12DemographicKey
    , IdeaStatusKey
    , SchoolYearDimId
    , SeaDimId
    , IeuDimId
    , LeaDimId
    , K12SchoolDimId
    , K12StudentDimId
    , K12EnrollmentStatusDimId
    , EntryGradeLevelDimId
    , K12DemographicDimId
    , IdeaStatusDimId;
