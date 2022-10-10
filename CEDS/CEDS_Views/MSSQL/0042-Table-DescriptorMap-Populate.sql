-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.

WITH telephoneMain as (
	SELECT 
		DescriptorConstant.DescriptorConstantId,
		d.DescriptorId
	FROM 
		analytics_config.DescriptorConstant
	CROSS JOIN (
		SELECT 
			DescriptorId
		FROM
			edfi.InstitutionTelephoneNumberTypeDescriptor
		INNER JOIN
			edfi.Descriptor
		ON
			InstitutionTelephoneNumberTypeDescriptor.InstitutionTelephoneNumberTypeDescriptorId = Descriptor.DescriptorId
		WHERE
			CodeValue = 'Main'
	) as d
	WHERE DescriptorConstant.ConstantName = 'OrganizationTelephone.Main'
)
MERGE INTO analytics_config.DescriptorMap AS Target
USING (
	SELECT * FROM telephoneMain
	
) AS Source(DescriptorConstantId, DescriptorId)
ON TARGET.DescriptorConstantId = Source.DescriptorConstantId
    WHEN NOT MATCHED BY TARGET
    THEN
      INSERT
	  (
		DescriptorConstantId, 
		DescriptorId, 
		CreateDate
	  )
      VALUES
      (
        Source.DescriptorConstantId,
        Source.DescriptorId,
        getdate()
      )
OUTPUT $action,
       inserted.*;
