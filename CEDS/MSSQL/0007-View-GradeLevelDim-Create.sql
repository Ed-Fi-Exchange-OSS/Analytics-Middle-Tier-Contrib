-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.VIEWS
        WHERE TABLE_SCHEMA = 'xref'
            AND TABLE_NAME = 'ceds_GradeLevelDim'
        )
BEGIN
    DROP VIEW xref.ceds_GradeLevelDim;
END;
GO

CREATE OR ALTER VIEW xref.ceds_GradeLevelDim
AS 
WITH MapReferenceDescriptor
AS (
    SELECT 
         Descriptor.DescriptorId
        ,Descriptor.CodeValue
        ,Descriptor.Description
        ,CedsTableReference.TableName
        ,CedsTableInformation.EdFactsCode
        ,Descriptor.LastModifiedDate
    FROM 
        xref.CedsTableInformation
    INNER JOIN 
        xref.CedsTableReference
        ON CedsTableInformation.TableId = CedsTableReference.TableId
    INNER JOIN 
        edfi.Descriptor
        ON Descriptor.DescriptorId = CedsTableInformation.DescriptorId
    INNER JOIN
        edfi.GradeLevelDescriptor
        ON GradeLevelDescriptor.GradeLevelDescriptorId = CedsTableInformation.DescriptorId
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
	AND MapReferenceDescriptor.TableName = 'xref.GradeLevels'
