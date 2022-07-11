-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
DROP VIEW IF EXISTS analytics.ceds_RacesDim;

CREATE OR REPLACE VIEW analytics.ceds_RacesDim
AS (
      SELECT 
         Descriptor.DescriptorId AS 'RaceKey'
        ,Descriptor.CodeValue AS 'RaceCode'
        ,Descriptor.ShortDescription AS 'RaceDescription'
        ,ceds_TableInformation.EdFactsCode AS 'RaceEdFactsCode'
    FROM analytics_config.ceds_TableInformation
    INNER JOIN analytics_config.ceds_TableReference
        ON ceds_TableInformation.TableId = ceds_TableReference.TableId
    INNER JOIN edfi.Descriptor
        ON Descriptor.DescriptorId = ceds_TableInformation.DescriptorId
    WHERE ceds_TableReference.TableName = 'xref.Races'
)
