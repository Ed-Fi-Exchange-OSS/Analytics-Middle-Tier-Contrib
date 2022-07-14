-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.

MERGE INTO analytics_config.ceds_TableInformation AS Target
USING (SELECT Descriptor.DescriptorId
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
INNER JOIN 
	analytics_config.ceds_TableReference
		ON ceds_TableReference.TableName = 'xref.GradeLevels'
) AS Source(DescriptorId, CodeValue, EdFactsCode, TableId)
ON TARGET.CodeValue = Source.CodeValue
	AND TARGET.EdFactsCode = Source.EdFactsCode
    WHEN NOT MATCHED BY TARGET
    THEN
      INSERT
	  (
		DescriptorId
		, CodeValue
		, EdFactsCode
		, TableId
	  )
      VALUES
      (
        Source.DescriptorId
		, Source.CodeValue
		, Source.EdFactsCode
		, Source.TableId
      );