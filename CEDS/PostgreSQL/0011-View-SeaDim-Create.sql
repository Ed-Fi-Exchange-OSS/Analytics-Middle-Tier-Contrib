-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
DROP VIEW IF EXISTS xref.ceds_SeaDim;

CREATE VIEW xref.ceds_SeaDim
AS
	WITH StateOrgEducationAddress AS (
        SELECT
			EducationOrganizationAddress.EducationOrganizationId,
            EducationOrganizationAddress.City,
			EducationOrganizationAddress.PostalCode,
			StateAbbreviationDesc.CodeValue AS StateAbbreviation,
			EducationOrganizationAddress.StreetNumberName,
			EducationOrganizationAddress.ApartmentRoomSuiteNumber,
			DescriptorConstant.ConstantName
        FROM
            edfi.EducationOrganizationAddress
		INNER JOIN
            edfi.Descriptor AS AddressType
				ON EducationOrganizationAddress.AddressTypeDescriptorId = AddressType.DescriptorId
		INNER JOIN
            analytics_config.DescriptorMap
				ON AddressType.DescriptorId = DescriptorMap.DescriptorId
        INNER JOIN
            analytics_config.DescriptorConstant
				ON DescriptorConstant.DescriptorConstantId = DescriptorMap.DescriptorConstantId
		LEFT JOIN
			edfi.StateAbbreviationDescriptor
				ON EducationOrganizationAddress.StateAbbreviationDescriptorId = StateAbbreviationDescriptor.StateAbbreviationDescriptorId
		LEFT JOIN
			edfi.Descriptor StateAbbreviationDesc
				ON StateAbbreviationDescriptor.StateAbbreviationDescriptorId = StateAbbreviationDesc.DescriptorId
    )
	SELECT
		CONCAT(
			EducationOrganization.EducationOrganizationId, 
			'-', EducationOrganizationAddress.AddressTypeDescriptorId,
			'-', EducationOrganizationAddress.City,
			'-', EducationOrganizationAddress.PostalCode,
			'-', EducationOrganizationAddress.StateAbbreviationDescriptorId,
			'-', EducationOrganizationAddress.StreetNumberName
		) AS SeaDimKey,
		EducationOrganization.NameOfInstitution AS SeaOrganizationName,
		StateEducationAgency.StateEducationAgencyId AS SeaIdentifierSea,
		'' AS StateAnsiCode,
		COALESCE(StateAbbreviationDesc.CodeValue, '') AS StateAbbreviationCode,
		COALESCE(StateAbbreviationDesc.Description, '') AS StateAbbreviationDescription,
		--
		COALESCE(MailingAddress.City, '') AS MailingAddressCity,
		COALESCE(MailingAddress.PostalCode, '') AS MailingAddressPostalCode,
		COALESCE(MailingAddress.StateAbbreviation, '') AS MailingAddressStateAbbreviation,
		COALESCE(MailingAddress.StreetNumberName, '') AS MailingAddressStreetNumberAndName,
		COALESCE(MailingAddress.ApartmentRoomSuiteNumber, '') AS MailingAddressApartmentRoomOrSuiteNumber,
		'' AS MailingAddressCountyAnsiCode,
		--
		COALESCE(PhysicalAddress.City, '') AS PhysicalAddressCity,
		COALESCE(PhysicalAddress.PostalCode, '') AS PhysicalAddressPostalCode,
		COALESCE(PhysicalAddress.StateAbbreviation, '') AS PhysicalAddressStateAbbreviation,
		COALESCE(PhysicalAddress.StreetNumberName, '') AS PhysicalAddressStreetNumberAndName,
		COALESCE(PhysicalAddress.ApartmentRoomSuiteNumber, '') AS PhysicalAddressApartmentRoomOrSuiteNumber,
		'' AS PhysicalAddressCountyAnsiCode,
		--
		COALESCE(EducationOrganizationInstitutionTelephone.TelephoneNumber, '') AS TelephoneNumber,
		COALESCE(EducationOrganization.WebSite, '') AS WebSiteAddress,
		COALESCE(EducationOrganizationAddress.Latitude, '') AS Latitude,
		COALESCE(EducationOrganizationAddress.Longitude, '') AS Longitude,
		'' AS RecordStartDateTime,
		'' AS RecordEndDateTime,
        (
            SELECT
                MAX(MaxLastModifiedDate)
            FROM (VALUES
                (EducationOrganization.LastModifiedDate)
                ,(StateAbbreviationDesc.LastModifiedDate)
            ) AS VALUE(MaxLastModifiedDate)
        ) AS LastModifiedDate
	FROM
		edfi.EducationOrganization
	INNER JOIN
		edfi.StateEducationAgency
			ON EducationOrganization.EducationOrganizationId = StateEducationAgency.StateEducationAgencyId
	LEFT JOIN
		edfi.EducationServiceCenter
			ON StateEducationAgency.StateEducationAgencyId = EducationServiceCenter.StateEducationAgencyId
				AND EducationOrganization.EducationOrganizationId = EducationServiceCenter.EducationServiceCenterId
	LEFT JOIN
		edfi.EducationOrganizationAddress
			ON EducationOrganization.EducationOrganizationId = EducationOrganizationAddress.EducationOrganizationId
	LEFT JOIN
		edfi.StateAbbreviationDescriptor
			ON EducationOrganizationAddress.StateAbbreviationDescriptorId = StateAbbreviationDescriptor.StateAbbreviationDescriptorId
	LEFT JOIN
		edfi.Descriptor StateAbbreviationDesc
			ON StateAbbreviationDescriptor.StateAbbreviationDescriptorId = StateAbbreviationDesc.DescriptorId
	-- Mailing
	LEFT OUTER JOIN
        StateOrgEducationAddress AS MailingAddress
			ON StateEducationAgency.StateEducationAgencyId = MailingAddress.EducationOrganizationId
				AND MailingAddress.ConstantName = 'Address.Mailing'
	-- Physical
	LEFT OUTER JOIN
        StateOrgEducationAddress AS PhysicalAddress
			ON StateEducationAgency.StateEducationAgencyId = PhysicalAddress.EducationOrganizationId
				AND PhysicalAddress.ConstantName = 'Address.Physical'
	-- Telephone
	LEFT JOIN
		edfi.EducationOrganizationInstitutionTelephone
			ON EducationOrganization.EducationOrganizationId = EducationOrganizationInstitutionTelephone.EducationOrganizationId
		