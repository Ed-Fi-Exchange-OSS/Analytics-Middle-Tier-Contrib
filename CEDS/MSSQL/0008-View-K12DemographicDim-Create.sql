-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.VIEWS
        WHERE TABLE_SCHEMA = 'xref'
            AND TABLE_NAME = 'ceds_K12DemographicDim'
        )
BEGIN
    DROP VIEW xref.ceds_K12DemographicDim;
END;
GO

CREATE OR ALTER VIEW xref.ceds_K12DemographicDim
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
        COALESCE(ReferenceEconomicDisadvantageStatusDescriptor.EdFactsCode, '')
        ,'-'
        ,COALESCE(ReferenceHomelessnessStatusDescriptor.EdFactsCode, '')
        ,'-'
        ,COALESCE(ReferenceEnglishLearnerStatusDescriptor.EdFactsCode, '')
        ,'-'
        ,COALESCE(ReferenceMigrantStatusDescriptor.EdFactsCode, '')
        ,'-'
        ,COALESCE(ReferenceMilitaryConnectedStudentIndicatorDescriptor.EdFactsCode, '')
        ,'-'
        ,COALESCE(ReferenceHomelessPrimaryNighttimeResidenceDescriptor.EdFactsCode, '')
        ,'-'
        ,COALESCE(ReferenceHomelessUnaccompaniedYouthStatusDescriptor.EdFactsCode, '')
        ,'-'
        ,COALESCE(ReferenceSexDescriptor.EdFactsCode, '')
        ) AS K12DemographicsKey
    ,COALESCE(ReferenceEconomicDisadvantageStatusDescriptor.CodeValue, '') AS EconomicDisadvantageStatusCode
    ,COALESCE(ReferenceEconomicDisadvantageStatusDescriptor.Description, '') AS Description
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
FROM edfi.StudentCharacteristicDescriptor AS EconomicDisadvantageStatusDescriptor
LEFT JOIN MapReferenceDescriptor ReferenceEconomicDisadvantageStatusDescriptor
    ON EconomicDisadvantageStatusDescriptor.StudentCharacteristicDescriptorId = ReferenceEconomicDisadvantageStatusDescriptor.DescriptorId
        AND ReferenceEconomicDisadvantageStatusDescriptor.EdFiTableName = 'xref.EconomicDisadvantageStatus'
CROSS JOIN edfi.StudentCharacteristicDescriptor AS HomelessnessStatusDescriptor
LEFT JOIN MapReferenceDescriptor ReferenceHomelessnessStatusDescriptor
    ON HomelessnessStatusDescriptor.StudentCharacteristicDescriptorId = ReferenceHomelessnessStatusDescriptor.DescriptorId
        AND ReferenceHomelessnessStatusDescriptor.EdFiTableName = 'xref.HomelessnessStatus'
CROSS JOIN MapReferenceDescriptor ReferenceEnglishLearnerStatusDescriptor
CROSS JOIN edfi.StudentCharacteristicDescriptor AS MigrantStatusDescriptor
LEFT JOIN MapReferenceDescriptor ReferenceMigrantStatusDescriptor
    ON MigrantStatusDescriptor.StudentCharacteristicDescriptorId = ReferenceMigrantStatusDescriptor.DescriptorId
        AND ReferenceMigrantStatusDescriptor.EdFiTableName = 'xref.MigrantStatus'
CROSS JOIN edfi.StudentCharacteristicDescriptor AS MilitaryConnectedStudentIndicator
LEFT JOIN MapReferenceDescriptor ReferenceMilitaryConnectedStudentIndicatorDescriptor
    ON MilitaryConnectedStudentIndicator.StudentCharacteristicDescriptorId = ReferenceMilitaryConnectedStudentIndicatorDescriptor.DescriptorId
        AND ReferenceMilitaryConnectedStudentIndicatorDescriptor.EdFiTableName = 'xref.MigrantStatus'
CROSS JOIN edfi.StudentCharacteristicDescriptor AS HomelessPrimaryNighttimeResidence
LEFT JOIN MapReferenceDescriptor ReferenceHomelessPrimaryNighttimeResidenceDescriptor
    ON HomelessPrimaryNighttimeResidence.StudentCharacteristicDescriptorId = ReferenceHomelessPrimaryNighttimeResidenceDescriptor.DescriptorId
        AND ReferenceHomelessPrimaryNighttimeResidenceDescriptor.EdFiTableName = 'xref.HomelessPrimaryNighttimeResidence'
CROSS JOIN edfi.StudentCharacteristicDescriptor AS HomelessUnaccompaniedYouthStatusCode
LEFT JOIN MapReferenceDescriptor ReferenceHomelessUnaccompaniedYouthStatusDescriptor
    ON HomelessUnaccompaniedYouthStatusCode.StudentCharacteristicDescriptorId = ReferenceHomelessUnaccompaniedYouthStatusDescriptor.DescriptorId
        AND ReferenceHomelessUnaccompaniedYouthStatusDescriptor.EdFiTableName = 'xref.HomelessUnaccompaniedYouthStatus'
CROSS JOIN edfi.StudentCharacteristicDescriptor AS SexDescriptor
LEFT JOIN MapReferenceDescriptor ReferenceSexDescriptor
    ON SexDescriptor.StudentCharacteristicDescriptorId = ReferenceSexDescriptor.DescriptorId
        AND ReferenceSexDescriptor.EdFiTableName = 'xref.HomelessUnaccompaniedYouthStatus'
WHERE (
        ReferenceEnglishLearnerStatusDescriptor.EdFiTableName IS NULL
        OR ReferenceEnglishLearnerStatusDescriptor.EdFiTableName = 'xref.EnglishLearnerStatus'
        );