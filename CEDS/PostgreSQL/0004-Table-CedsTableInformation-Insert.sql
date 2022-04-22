-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.

WITH SOURCE AS (SELECT Descriptor.DescriptorId
	, Descriptor.CodeValue
	, MapReference.EdFactsCode
	, MapReference.TableId
FROM
	(VALUES
		('uri://ed-fi.org/GradeLevelDescriptor','Preschool/Prekindergarten', 'PK', 4),
		('uri://ed-fi.org/GradeLevelDescriptor','Kindergarten', 'KG', 4),
		('uri://ed-fi.org/GradeLevelDescriptor','First grade', '3', 4),
		('uri://ed-fi.org/GradeLevelDescriptor','Second grade', '4', 4),
		('uri://ed-fi.org/GradeLevelDescriptor','Third grade', '5', 4),
		('uri://ed-fi.org/GradeLevelDescriptor','Fourth grade', '6', 4),
		('uri://ed-fi.org/GradeLevelDescriptor','Fifth grade', '7', 4),
		('uri://ed-fi.org/GradeLevelDescriptor','Sixth grade', '8', 4),
		('uri://ed-fi.org/GradeLevelDescriptor','Seventh grade', '9', 4),
		('uri://ed-fi.org/GradeLevelDescriptor','Eighth grade', '10', 4),
		('uri://ed-fi.org/GradeLevelDescriptor','Ninth grade', '11', 4),
		('uri://ed-fi.org/GradeLevelDescriptor','Tenth grade', '10', 4),
		('uri://ed-fi.org/GradeLevelDescriptor','Eleventh grade', '11', 4),
		('uri://ed-fi.org/GradeLevelDescriptor','Twelfth grade', '12', 4),
		('uri://ed-fi.org/GradeLevelDescriptor','Postsecondary', 'HS', 4),
		('uri://ed-fi.org/GradeLevelDescriptor','Ungraded', 'UG', 4),
		('uri://ed-fi.org/GradeLevelDescriptor','Adult Education', 'AE', 4)
	) MapReference (Namespace, CodeValue, EdFactsCode, TableId)
INNER JOIN 
	edfi.Descriptor 
		ON MapReference.CodeValue = Descriptor.CodeValue
			AND Descriptor.Namespace='uri://ed-fi.org/GradeLevelDescriptor'
)
  INSERT INTO xref.CedsTableInformation
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