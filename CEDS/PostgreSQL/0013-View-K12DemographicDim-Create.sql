-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
DROP VIEW IF EXISTS xref.ceds_K12DemographicDim;

CREATE VIEW xref.ceds_K12DemographicDim
AS
WITH MapReferenceDescriptor
AS (
    SELECT Descriptor.DescriptorId
        ,Descriptor.CodeValue
        ,Descriptor.Description
        ,EdFiTableReference.EdFiTableName
        ,EdFiTableInformation.EdFactsCode
    FROM xref.EdFiTableInformation
    INNER JOIN xref.EdFiTableReference
        ON EdFiTableInformation.EdFiTableId = EdFiTableReference.EdFiTableId
    INNER JOIN edfi.Descriptor
        ON Descriptor.DescriptorId = EdFiTableInformation.EdFiDescriptorId
    )
SELECT DISTINCT CONCAT (
        ReferenceEconomicDisadvantageStatusDescriptor.EdFactsCode
        ,'-'
        ,ReferenceHomelessnessStatusDescriptor.EdFactsCode
        ,'-'
        ,ReferenceEnglishLearnerStatusDescriptor.EdFactsCode
        ,'-'
        ,ReferenceMigrantStatusDescriptor.EdFactsCode
        ,'-'
        ,ReferenceMilitaryConnectedStudentIndicatorDescriptor.EdFactsCode
        ,'-'
        ,ReferenceHomelessPrimaryNighttimeResidenceDescriptor.EdFactsCode
        ,'-'
        ,ReferenceHomelessUnaccompaniedYouthStatusDescriptor.EdFactsCode
        ,'-'
        ,ReferenceSexDescriptor.EdFactsCode
        ) AS K12DemographicsKey
    ,COALESCE(ReferenceEconomicDisadvantageStatusDescriptor.CodeValue, '') AS EconomicDisadvantageStatusCode
    ,COALESCE(ReferenceEconomicDisadvantageStatusDescriptor.Description, '') AS EconomicDisadvantageStatusDescription
    ,COALESCE(ReferenceEconomicDisadvantageStatusDescriptor.EdFactsCode, '') AS EconomicDisadvantageStatusEdFactsCode
    ,COALESCE(ReferenceHomelessnessStatusDescriptor.CodeValue, '') AS HomelessnessStatusCode
    ,COALESCE(ReferenceHomelessnessStatusDescriptor.Description, '') AS HomelessnessStatusDescription
    ,COALESCE(ReferenceHomelessnessStatusDescriptor.EdFactsCode, '') AS HomelessnessStatusEdFactsCode
    ,COALESCE(ReferenceEnglishLearnerStatusDescriptor.CodeValue, '') AS EnglishLearnerStatusCode
    ,COALESCE(ReferenceEnglishLearnerStatusDescriptor.Description, '') AS EnglishLearnerStatusDescription
    ,COALESCE(ReferenceEnglishLearnerStatusDescriptor.EdFactsCode, '') AS EnglishLearnerStatusEdFactsCode
    ,COALESCE(ReferenceMigrantStatusDescriptor.CodeValue, '') AS MigrantStatusCode
    ,COALESCE(ReferenceMigrantStatusDescriptor.Description, '') AS MigrantStatusDescription
    ,COALESCE(ReferenceMigrantStatusDescriptor.EdFactsCode, '') AS MigrantStatusEdFactsCode
    ,COALESCE(ReferenceMilitaryConnectedStudentIndicatorDescriptor.CodeValue, '') AS MilitaryConnectedStudentIndicatorCode
    ,COALESCE(ReferenceMilitaryConnectedStudentIndicatorDescriptor.Description, '') AS MilitaryConnectedStudentIndicatorDescription
    ,COALESCE(ReferenceMilitaryConnectedStudentIndicatorDescriptor.EdFactsCode, '') AS MilitaryConnectedStudentIndicatorEdFactsCode
    ,COALESCE(ReferenceHomelessPrimaryNighttimeResidenceDescriptor.CodeValue, '') AS HomelessPrimaryNighttimeResidenceCode
    ,COALESCE(ReferenceHomelessPrimaryNighttimeResidenceDescriptor.Description, '') AS HomelessPrimaryNighttimeResidenceDescription
    ,COALESCE(ReferenceHomelessPrimaryNighttimeResidenceDescriptor.EdFactsCode, '') AS HomelessPrimaryNighttimeResidenceEdFactsCode
    ,COALESCE(ReferenceHomelessUnaccompaniedYouthStatusDescriptor.CodeValue, '') AS HomelessUnaccompaniedYouthStatusCode
    ,COALESCE(ReferenceHomelessUnaccompaniedYouthStatusDescriptor.Description, '') AS HomelessUnaccompaniedYouthStatusDescription
    ,COALESCE(ReferenceHomelessUnaccompaniedYouthStatusDescriptor.EdFactsCode, '') AS HomelessUnaccompaniedYouthStatusEdFactsCode
    ,COALESCE(ReferenceSexDescriptor.CodeValue, '') AS SexCode
    ,COALESCE(ReferenceSexDescriptor.Description, '') AS SexDescription
    ,COALESCE(ReferenceSexDescriptor.EdFactsCode, '') AS SexEdFactsCode
FROM (
    SELECT ReferenceEconomicDisadvantageStatusDescriptor.CodeValue
        ,ReferenceEconomicDisadvantageStatusDescriptor.Description
        ,ReferenceEconomicDisadvantageStatusDescriptor.EdFactsCode
    FROM edfi.StudentCharacteristicDescriptor AS EconomicDisadvantageStatusDescriptor
    LEFT JOIN MapReferenceDescriptor ReferenceEconomicDisadvantageStatusDescriptor
        ON EconomicDisadvantageStatusDescriptor.StudentCharacteristicDescriptorId = ReferenceEconomicDisadvantageStatusDescriptor.DescriptorId
            AND ReferenceEconomicDisadvantageStatusDescriptor.EdFiTableName = 'xref.EconomicDisadvantageStatus'
    ) AS ReferenceEconomicDisadvantageStatusDescriptor
CROSS JOIN (
    SELECT ReferenceHomelessnessStatusDescriptor.CodeValue
        ,ReferenceHomelessnessStatusDescriptor.Description
        ,ReferenceHomelessnessStatusDescriptor.EdFactsCode
    FROM edfi.StudentCharacteristicDescriptor AS HomelessnessStatusDescriptor
    LEFT JOIN MapReferenceDescriptor ReferenceHomelessnessStatusDescriptor
        ON HomelessnessStatusDescriptor.StudentCharacteristicDescriptorId = ReferenceHomelessnessStatusDescriptor.DescriptorId
            AND ReferenceHomelessnessStatusDescriptor.EdFiTableName = 'xref.HomelessnessStatus'
    ) AS ReferenceHomelessnessStatusDescriptor
CROSS JOIN (
    SELECT ReferenceEnglishLearnerStatusDescriptor.CodeValue
        ,ReferenceEnglishLearnerStatusDescriptor.Description
        ,ReferenceEnglishLearnerStatusDescriptor.EdFactsCode
    FROM MapReferenceDescriptor ReferenceEnglishLearnerStatusDescriptor
    WHERE ReferenceEnglishLearnerStatusDescriptor.EdFiTableName = 'xref.EnglishLearnerStatus'
    ) AS ReferenceEnglishLearnerStatusDescriptor
CROSS JOIN (
    SELECT ReferenceMigrantStatusDescriptor.CodeValue
        ,ReferenceMigrantStatusDescriptor.Description
        ,ReferenceMigrantStatusDescriptor.EdFactsCode
    FROM edfi.StudentCharacteristicDescriptor AS MigrantStatusDescriptor
    LEFT JOIN MapReferenceDescriptor ReferenceMigrantStatusDescriptor
        ON MigrantStatusDescriptor.StudentCharacteristicDescriptorId = ReferenceMigrantStatusDescriptor.DescriptorId
            AND ReferenceMigrantStatusDescriptor.EdFiTableName = 'xref.MigrantStatus'
    ) AS ReferenceMigrantStatusDescriptor
CROSS JOIN (
    SELECT ReferenceMilitaryConnectedStudentIndicatorDescriptor.CodeValue
        ,ReferenceMilitaryConnectedStudentIndicatorDescriptor.Description
        ,ReferenceMilitaryConnectedStudentIndicatorDescriptor.EdFactsCode
    FROM edfi.StudentCharacteristicDescriptor AS MilitaryConnectedStudentIndicator
    LEFT JOIN MapReferenceDescriptor ReferenceMilitaryConnectedStudentIndicatorDescriptor
        ON MilitaryConnectedStudentIndicator.StudentCharacteristicDescriptorId = ReferenceMilitaryConnectedStudentIndicatorDescriptor.DescriptorId
            AND ReferenceMilitaryConnectedStudentIndicatorDescriptor.EdFiTableName = 'xref.MigrantStatus'
    ) AS ReferenceMilitaryConnectedStudentIndicatorDescriptor
CROSS JOIN (
    SELECT ReferenceHomelessPrimaryNighttimeResidenceDescriptor.CodeValue
        ,ReferenceHomelessPrimaryNighttimeResidenceDescriptor.Description
        ,ReferenceHomelessPrimaryNighttimeResidenceDescriptor.EdFactsCode
    FROM edfi.StudentCharacteristicDescriptor AS HomelessPrimaryNighttimeResidence
    LEFT JOIN MapReferenceDescriptor ReferenceHomelessPrimaryNighttimeResidenceDescriptor
        ON HomelessPrimaryNighttimeResidence.StudentCharacteristicDescriptorId = ReferenceHomelessPrimaryNighttimeResidenceDescriptor.DescriptorId
            AND ReferenceHomelessPrimaryNighttimeResidenceDescriptor.EdFiTableName = 'xref.HomelessPrimaryNighttimeResidence'
    ) AS ReferenceHomelessPrimaryNighttimeResidenceDescriptor
CROSS JOIN (
    SELECT ReferenceHomelessUnaccompaniedYouthStatusDescriptor.CodeValue
        ,ReferenceHomelessUnaccompaniedYouthStatusDescriptor.Description
        ,ReferenceHomelessUnaccompaniedYouthStatusDescriptor.EdFactsCode
    FROM edfi.StudentCharacteristicDescriptor AS HomelessUnaccompaniedYouthStatusCode
    LEFT JOIN MapReferenceDescriptor ReferenceHomelessUnaccompaniedYouthStatusDescriptor
        ON HomelessUnaccompaniedYouthStatusCode.StudentCharacteristicDescriptorId = ReferenceHomelessUnaccompaniedYouthStatusDescriptor.DescriptorId
            AND ReferenceHomelessUnaccompaniedYouthStatusDescriptor.EdFiTableName = 'xref.HomelessUnaccompaniedYouthStatus'
    ) AS ReferenceHomelessUnaccompaniedYouthStatusDescriptor
CROSS JOIN (
    SELECT ReferenceSexDescriptor.CodeValue
        ,ReferenceSexDescriptor.Description
        ,ReferenceSexDescriptor.EdFactsCode
    FROM edfi.StudentCharacteristicDescriptor AS SexDescriptor
    LEFT JOIN MapReferenceDescriptor ReferenceSexDescriptor
        ON SexDescriptor.StudentCharacteristicDescriptorId = ReferenceSexDescriptor.DescriptorId
            AND ReferenceSexDescriptor.EdFiTableName = 'xref.HomelessUnaccompaniedYouthStatus'
    ) AS ReferenceSexDescriptor;