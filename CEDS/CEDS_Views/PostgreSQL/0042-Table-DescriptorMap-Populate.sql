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
INSERT INTO analytics_config.DescriptorMap
(
    DescriptorConstantId, 
    DescriptorId, 
    CreateDate
)
SELECT  DescriptorConstantId
  ,DescriptorId
  ,NOW()
FROM telephoneMain
ON CONFLICT DO NOTHING;
