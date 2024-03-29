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
) AS Source(DescriptorId, CodeValue, EdFactsCode, TableId)
ON TARGET.CodeValue = Source.CodeValue
	AND TARGET.EdFactsCode = Source.EdFactsCode
	AND TARGET.TableId = Source.TableId
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