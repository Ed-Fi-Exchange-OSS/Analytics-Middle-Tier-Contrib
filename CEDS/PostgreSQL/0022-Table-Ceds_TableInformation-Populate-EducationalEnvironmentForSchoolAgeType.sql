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
		('Classroom',''),
		('Homebound',''),
		('Hospital class',''),
		('In-school suspension',''),
		('Laboratory',''),
		('Mainstream (Special Education)',''),
		('Off-school center',''),
		('Pull-out class',''),
		('Resource room',''),
		('Self-contained (Special Education)',''),
		('Self-study',''),
		('Shop',''),
		('Single sex classroom','')
) MapReference (CodeValue, EdFactsCode)
INNER JOIN 
	edfi.Descriptor 
		ON MapReference.CodeValue = Descriptor.CodeValue
			AND Descriptor.Namespace like '%/EducationalEnvironmentDescriptor'
INNER JOIN 
	analytics_config.ceds_TableReference
		ON ceds_TableReference.TableName = 'xref.EducationalEnvironmentForSchoolAgeType'
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