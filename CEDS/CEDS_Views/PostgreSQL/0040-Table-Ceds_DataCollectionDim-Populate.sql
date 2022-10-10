-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
WITH source AS (VALUES
	(1,'EdFi ODS','Membership Source System'),
	(2,'EdFi ODS','SPED Source System')
)
INSERT INTO 
    analytics_config.ceds_DataCollectionDim
(
	DataCollectionDimKey
	, DataCollectionName
	, DataCollectionDescription
)
SELECT
    *
FROM
    source
ON CONFLICT DO NOTHING;