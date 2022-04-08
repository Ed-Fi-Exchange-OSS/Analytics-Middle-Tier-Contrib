-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.

WITH source AS (VALUES
	( -1, '-1', 'MISSING', 4),
	(471, 'Preschool/Prekindergarten', 'PK', 4),
	(467, 'Kindergarten', 'KG', 4),
	(463, 'First grade', '3', 4),
	(472, 'Second grade', '4', 4),
	(476, 'Third grade', '5', 4),
	(464, 'Fourth grade', '6', 4),
	(462, 'Fifth grade', '7', 4),
	(474, 'Sixth grade', '8', 4),
	(473, 'Seventh grade', '9', 4),
	(460, 'Eighth grade', '10', 4),
	(468, 'Ninth grade', '11', 4),
	(475, 'Tenth grade', '10', 4),
	(461, 'Eleventh grade', '11', 4),
	(477, 'Twelfth grade', '12', 4),
	(470, 'Postsecondary', 'HS', 4),
	(478, 'Ungraded', 'UG', 4),
	(458, 'Adult Education', 'AE', 4)
)
INSERT INTO 
    xref.EdfiTableInformation
(
	EdFiDescriptorId,
	EdFiCodeValue,
	EdFactsCode,
	EdFiTableId
)
SELECT
    source.column1,
	source.column2,
	source.column3,
	source.column4
FROM
    source
ON CONFLICT DO NOTHING;