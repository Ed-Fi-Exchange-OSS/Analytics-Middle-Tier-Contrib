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
		('Autism Spectrum Disorders','AUT'),
		('Deaf-Blindness','DB'),
		('Hearing Impairment, including Deafness','HI'),
		('Infant/Toddler with a Disability','OHI'),
		('Intellectual Disability','ID'),
		('Medical condition','OHI'),
		('Mental impairment','OHI'),
		('Motor impairment','OHI'),
		('Multiple Disabilities','MD'),
		('Orthopedic Impairment','OI'),
		('Other','OHI'),
		('Other Health Impairment','OHI'),
		('Physical Disability','OHI'),
		('Preschooler with a Disability','OHI'),
		('Sensory impairment','OHI'),
		('Serious Emotional Disability','EMN'),
		('Specific Learning Disability','SLD'),
		('Speech or Language Impairment','SLI'),
		('Traumatic Brain Injury','TBI'),
		('Visual Impairment, including Blindness','VI')
) MapReference (CodeValue, EdFactsCode)
INNER JOIN 
	edfi.Descriptor 
		ON MapReference.CodeValue = Descriptor.CodeValue
			AND Descriptor.Namespace like '%/DisabilityDescriptor'
INNER JOIN 
	analytics_config.ceds_TableReference
		ON ceds_TableReference.TableName = 'xref.DisabilityDescriptor'
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