-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
DROP VIEW IF EXISTS xref.ceds_GradeLevelDim;

CREATE OR REPLACE VIEW xref.ceds_GradeLevelDim
AS 
WITH MapReferenceDescriptor
AS (
    SELECT 
         Descriptor.DescriptorId
        ,Descriptor.CodeValue
        ,Descriptor.Description
        ,EdFiTableReference.EdFiTableName
        ,EdFiTableInformation.EdFactsCode
        ,Descriptor.LastModifiedDate
    FROM 
        xref.EdFiTableInformation
    INNER JOIN 
        xref.EdFiTableReference
        ON EdFiTableInformation.EdFiTableId = EdFiTableReference.EdFiTableId
    INNER JOIN 
        edfi.Descriptor
        ON Descriptor.DescriptorId = EdFiTableInformation.EdFiDescriptorId
    INNER JOIN
        edfi.GradeLevelDescriptor
        ON GradeLevelDescriptor.GradeLevelDescriptorId = EdFiTableInformation.EdFiDescriptorId
    )
SELECT DISTINCT 
    CONCAT (
            MapReferenceDescriptor.EdFactsCode, 
            '-', 
            MapReferenceDescriptor.CodeValue,
            '-',
            MapReferenceDescriptor.Description
        ) AS GradeLevelKey
    ,COALESCE(MapReferenceDescriptor.CodeValue, '') AS GradeLevelCode
    ,COALESCE(MapReferenceDescriptor.Description, '') AS GradeLevelDescription
    ,COALESCE(MapReferenceDescriptor.EdFactsCode, '') AS GradeLevelEdFactsCode
    ,COALESCE(MapReferenceDescriptor.LastModifiedDate, '') AS LastModifiedDate
FROM 
    edfi.GradeLevelDescriptor
LEFT JOIN 
    MapReferenceDescriptor
    ON GradeLevelDescriptor.GradeLevelDescriptorId = MapReferenceDescriptor.DescriptorId
	AND MapReferenceDescriptor.EdFiTableName = 'xref.GradeLevels'
GO
