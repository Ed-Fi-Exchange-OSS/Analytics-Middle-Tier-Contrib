-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.

WITH SOURCE AS (SELECT Descriptor.DescriptorId
	, Descriptor.CodeValue
	, MapReference.EdFactsCode
	, ceds_TableReference.TableId
FROM
	(VALUES
		('Preschool/Prekindergarten', 'PK'),
		('Kindergarten', 'KG'),
		('First grade', '3'),
		('Second grade', '4'),
		('Third grade', '5'),
		('Fourth grade', '6'),
		('Fifth grade', '7'),
		('Sixth grade', '8'),
		('Seventh grade', '9'),
		('Eighth grade', '10'),
		('Ninth grade', '11'),
		('Tenth grade', '10'),
		('Eleventh grade', '11'),
		('Twelfth grade', '12'),
		('Postsecondary', 'HS'),
		('Ungraded', 'UG'),
		('Adult Education', 'AE')
	) MapReference (CodeValue, EdFactsCode)
INNER JOIN 
	edfi.Descriptor 
		ON MapReference.CodeValue = Descriptor.CodeValue
			AND Descriptor.Namespace='uri://ed-fi.org/GradeLevelDescriptor'
)
  INSERT INTO analytics_config.ceds_TableInformation
	  (
		DescriptorId
		, CodeValue
		, EdFactsCode
		, TableId
	  )
    SELECT
        Source.DescriptorId
		  , Source.CodeValue
		  , Source.EdFactsCode
		  , Source.TableId
    FROM Source
ON CONFLICT DO NOTHING;