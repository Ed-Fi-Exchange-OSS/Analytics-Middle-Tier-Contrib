-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.VIEWS
        WHERE TABLE_SCHEMA = 'analytics'
            AND TABLE_NAME = 'ceds_K12DemographicDim'
        )
BEGIN
    DROP VIEW analytics.ceds_K12DemographicDim;
END;
GO

CREATE OR ALTER VIEW analytics.ceds_K12DemographicDim
AS
WITH MapReferenceDescriptor
AS (
    SELECT Descriptor.DescriptorId
        ,Descriptor.CodeValue
        ,Descriptor.Description
        ,ceds_TableReference.TableName
        ,ceds_TableInformation.EdFactsCode
    FROM
		analytics_config.ceds_TableInformation
    INNER JOIN
		analytics_config.ceds_TableReference
			ON ceds_TableInformation.TableId = ceds_TableReference.TableId
    INNER JOIN
		edfi.Descriptor
			ON Descriptor.DescriptorId = ceds_TableInformation.DescriptorId
    )
SELECT DISTINCT CONCAT (
        ReferenceEconomicDisadvantageStatusDescriptor.DescriptorId
        ,'-'
        ,ReferenceHomelessnessStatusDescriptor.DescriptorId
        ,'-'
        ,ReferenceEnglishLearnerStatusDescriptor.DescriptorId
        ,'-'
        ,ReferenceMigrantStatusDescriptor.DescriptorId
        ,'-'
        ,ReferenceMilitaryConnectedStudentIndicatorDescriptor.DescriptorId
        ,'-'
        ,ReferenceHomelessPrimaryNighttimeResidenceDescriptor.DescriptorId
        ,'-'
        ,ReferenceHomelessUnaccompaniedYouthStatusDescriptor.DescriptorId
        ,'-'
        ,ReferenceSexDescriptor.DescriptorId
        ) AS K12DemographicKey
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
    SELECT
		ReferenceEconomicDisadvantageStatusDescriptorm.CodeValue
        ,ReferenceEconomicDisadvantageStatusDescriptorm.Description
        ,ReferenceEconomicDisadvantageStatusDescriptorm.EdFactsCode
		,ReferenceEconomicDisadvantageStatusDescriptorm.DescriptorId
    FROM
		MapReferenceDescriptor ReferenceEconomicDisadvantageStatusDescriptorm
	INNER JOIN
		edfi.StudentCharacteristicDescriptor AS EconomicDisadvantageStatusDescriptor
			ON EconomicDisadvantageStatusDescriptor.StudentCharacteristicDescriptorId = ReferenceEconomicDisadvantageStatusDescriptorm.DescriptorId
	WHERE
         ReferenceEconomicDisadvantageStatusDescriptorm.TableName = 'xref.EconomicDisadvantageStatus'
    ) AS ReferenceEconomicDisadvantageStatusDescriptor
CROSS JOIN (
    SELECT
		ReferenceHomelessnessStatusDescriptor.CodeValue
        ,ReferenceHomelessnessStatusDescriptor.Description
        ,ReferenceHomelessnessStatusDescriptor.EdFactsCode
		,ReferenceHomelessnessStatusDescriptor.DescriptorId
    FROM
		MapReferenceDescriptor ReferenceHomelessnessStatusDescriptor
	INNER JOIN
		edfi.StudentCharacteristicDescriptor AS HomelessnessStatusDescriptor
			ON HomelessnessStatusDescriptor.StudentCharacteristicDescriptorId = ReferenceHomelessnessStatusDescriptor.DescriptorId
	WHERE
		ReferenceHomelessnessStatusDescriptor.TableName = 'xref.HomelessnessStatus'
    ) AS ReferenceHomelessnessStatusDescriptor
CROSS JOIN (
    SELECT
		ReferenceEnglishLearnerStatusDescriptor.CodeValue
        ,ReferenceEnglishLearnerStatusDescriptor.Description
        ,ReferenceEnglishLearnerStatusDescriptor.EdFactsCode
		,ReferenceEnglishLearnerStatusDescriptor.DescriptorId
    FROM
		MapReferenceDescriptor ReferenceEnglishLearnerStatusDescriptor
	INNER JOIN
		edfi.Program
			ON ReferenceEnglishLearnerStatusDescriptor.CodeValue = Program.ProgramName
    WHERE
		ReferenceEnglishLearnerStatusDescriptor.TableName = 'xref.EnglishLearnerStatus'
    ) AS ReferenceEnglishLearnerStatusDescriptor
CROSS JOIN (
    SELECT
		ReferenceMigrantStatusDescriptor.CodeValue
        ,ReferenceMigrantStatusDescriptor.Description
        ,ReferenceMigrantStatusDescriptor.EdFactsCode
		,ReferenceMigrantStatusDescriptor.DescriptorId
    FROM
		MapReferenceDescriptor ReferenceMigrantStatusDescriptor
	INNER JOIN
		edfi.Program
			ON ReferenceMigrantStatusDescriptor.CodeValue = Program.ProgramName
	WHERE
            ReferenceMigrantStatusDescriptor.TableName = 'xref.MigrantStatus'
    ) AS ReferenceMigrantStatusDescriptor
CROSS JOIN (
    SELECT
		ReferenceMilitaryConnectedStudentIndicatorDescriptor.CodeValue
        ,ReferenceMilitaryConnectedStudentIndicatorDescriptor.Description
        ,ReferenceMilitaryConnectedStudentIndicatorDescriptor.EdFactsCode
		,ReferenceMilitaryConnectedStudentIndicatorDescriptor.DescriptorId
    FROM
		MapReferenceDescriptor ReferenceMilitaryConnectedStudentIndicatorDescriptor
	INNER JOIN
		edfi.StudentCharacteristicDescriptor AS MilitaryConnectedStudentIndicator
			ON MilitaryConnectedStudentIndicator.StudentCharacteristicDescriptorId = ReferenceMilitaryConnectedStudentIndicatorDescriptor.DescriptorId
	WHERE
		ReferenceMilitaryConnectedStudentIndicatorDescriptor.TableName = 'xref.MilitaryConnectedStudentIndicator'
    ) AS ReferenceMilitaryConnectedStudentIndicatorDescriptor
CROSS JOIN (
    SELECT
		ReferenceHomelessPrimaryNighttimeResidenceDescriptor.DescriptorId,
		ReferenceHomelessPrimaryNighttimeResidenceDescriptor.CodeValue
        ,ReferenceHomelessPrimaryNighttimeResidenceDescriptor.Description
        ,ReferenceHomelessPrimaryNighttimeResidenceDescriptor.EdFactsCode
    FROM 
		MapReferenceDescriptor ReferenceHomelessPrimaryNighttimeResidenceDescriptor
    INNER JOIN 
		edfi.StudentCharacteristicDescriptor AS HomelessPrimaryNighttimeResidence
			ON HomelessPrimaryNighttimeResidence.StudentCharacteristicDescriptorId = ReferenceHomelessPrimaryNighttimeResidenceDescriptor.DescriptorId
	WHERE
		ReferenceHomelessPrimaryNighttimeResidenceDescriptor.TableName = 'xref.HomelessPrimaryNighttimeResidence'
    ) AS ReferenceHomelessPrimaryNighttimeResidenceDescriptor
CROSS JOIN (
    SELECT
		ReferenceHomelessUnaccompaniedYouthStatusDescriptor.DescriptorId
		,ReferenceHomelessUnaccompaniedYouthStatusDescriptor.CodeValue
        ,ReferenceHomelessUnaccompaniedYouthStatusDescriptor.Description
        ,ReferenceHomelessUnaccompaniedYouthStatusDescriptor.EdFactsCode
    FROM
		MapReferenceDescriptor ReferenceHomelessUnaccompaniedYouthStatusDescriptor
	INNER JOIN
		edfi.StudentCharacteristicDescriptor AS HomelessUnaccompaniedYouthStatusCode
			ON HomelessUnaccompaniedYouthStatusCode.StudentCharacteristicDescriptorId = ReferenceHomelessUnaccompaniedYouthStatusDescriptor.DescriptorId
	WHERE
		ReferenceHomelessUnaccompaniedYouthStatusDescriptor.TableName = 'xref.HomelessUnaccompaniedYouthStatus'
    ) AS ReferenceHomelessUnaccompaniedYouthStatusDescriptor
CROSS JOIN (
    SELECT
		ReferenceSexDescriptor.CodeValue
        ,ReferenceSexDescriptor.Description
        ,ReferenceSexDescriptor.EdFactsCode
		,ReferenceSexDescriptor.DescriptorId
    FROM
		MapReferenceDescriptor ReferenceSexDescriptor
	LEFT JOIN
		edfi.Student
			ON BirthSexDescriptorId = ReferenceSexDescriptor.DescriptorId
	WHERE
		ReferenceSexDescriptor.TableName = 'xref.Sex'
    ) AS ReferenceSexDescriptor;