-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.VIEWS
        WHERE TABLE_SCHEMA = 'analytics'
            AND TABLE_NAME = 'ceds_RacesDim'
        )
BEGIN
    DROP VIEW analytics.ceds_RacesDim;
END;
GO

CREATE OR ALTER VIEW analytics.ceds_RacesDim
AS
WITH MapReferenceDescriptor
AS (
    SELECT
         Descriptor.DescriptorId
        ,Descriptor.CodeValue
        ,Descriptor.Description
        ,ceds_TableReference.TableName
        ,ceds_TableInformation.EdFactsCode
        ,Descriptor.LastModifiedDate
    FROM
        analytics_config.ceds_TableInformation
    INNER JOIN
        analytics_config.ceds_TableReference
        ON ceds_TableInformation.TableId = ceds_TableReference.TableId
    INNER JOIN
        edfi.Descriptor
        ON Descriptor.DescriptorId = ceds_TableInformation.DescriptorId
    )
SELECT DISTINCT
    CONCAT (
            MapReferenceDescriptor.EdFactsCode,
            '-',
            MapReferenceDescriptor.CodeValue
        ) AS RaceKey
    ,COALESCE(MapReferenceDescriptor.CodeValue, '') AS RaceCode
    ,COALESCE(MapReferenceDescriptor.Description, '') AS RaceDescription
    ,COALESCE(MapReferenceDescriptor.EdFactsCode, '') AS RaceEdFactsCode
    ,COALESCE(MapReferenceDescriptor.LastModifiedDate, '') AS LastModifiedDate
FROM
    edfi.Descriptor
LEFT JOIN
    MapReferenceDescriptor
    ON Descriptor.DescriptorId = MapReferenceDescriptor.DescriptorId
	AND MapReferenceDescriptor.TableName = 'xref.Races'