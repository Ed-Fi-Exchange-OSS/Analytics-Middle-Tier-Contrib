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
		('Graduated with a high school diploma', 'GHS'),
		('Received Degree', 'GRADALTDPL'),
		('Received certificate of completion or equivalent', 'RC'),
		('Reached maximum age', 'RMA'),
		('Other', ''),
		('Suspended or expelled from school', 'DROPOUT'),
		('Completed', ''),
		('Withdrawal by a parent (or guardian)', 'MKC'),
		('Moved out of state', 'MKC'),
		('Transferred to another district or school', 'TRAN'),
		('Discontinued schooling', 'DROPOUT'),
		('Died or is permanently incapacitated', 'D')
	) MapReference (CodeValue, EdFactsCode)
INNER JOIN 
	edfi.Descriptor 
		ON MapReference.CodeValue = Descriptor.CodeValue
			AND Descriptor.Namespace like'%/ReasonExitedDescriptor'
INNER JOIN 
	analytics_config.ceds_TableReference
		ON ceds_TableReference.TableName = 'xref.BasisOfExit'
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