-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
DROP VIEW IF EXISTS xref.ceds_LeusDim;

CREATE VIEW xref.ceds_LeusDim AS
	WITH OrgEducationAddress AS (
        SELECT
			EducationOrganizationAddress.EducationOrganizationId,
            EducationOrganizationAddress.City,
			EducationOrganizationAddress.PostalCode,
			StateAbbreviationDesc.CodeValue AS StateAbbreviation,
			EducationOrganizationAddress.StreetNumberName,
			EducationOrganizationAddress.ApartmentRoomSuiteNumber,
			--
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
		EducationOrganization.NameOfInstitution AS IeuOrganizationName,
		EducationServiceCenter.EducationServiceCenterId AS IeuOrganizationIdentifierSea,
		StateEducationOrganization.NameOfInstitution AS SeaOrganizationName,
		EducationServiceCenter.StateEducationAgencyId AS SeaIdentifierSea,
		'' AS StateANSICode,
		--
		COALESCE(StateAbbreviationDesc.CodeValue, '') AS StateAbbreviationCode,
		COALESCE(StateAbbreviationDesc.Description, '') AS StateAbbreviationDescription,
		--
		COALESCE(MailingAddress.City, '') AS MailingAddressCity,
		COALESCE(MailingAddress.PostalCode, '') AS MailingAddressPostalCode,
		COALESCE(MailingAddress.StateAbbreviation, '') AS MailingAddressStateAbbreviation,
		COALESCE(MailingAddress.StreetNumberName, '') AS MailingAddressStreetNumberAndName,
		'' AS MailingAddressCountyAnsiCode,
		--
		CASE 
			WHEN PhysicalAddress.StateAbbreviation = StateAbbreviationDesc.CodeValue
				THEN 'true'
			ELSE
				'false'
		END AS OutOfStateIndicator,
		--
		OperationalStatusDescriptor.CodeValue AS OrganizationOperationalStatus,
		'' as OperationalStatusEffectiveDate,
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
		'' AS OrganizationRegionGeoJson,
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
		edfi.EducationServiceCenter
	INNER JOIN
		edfi.EducationOrganization
			ON EducationServiceCenter.EducationServiceCenterId = EducationOrganization.EducationOrganizationId
	INNER JOIN
		edfi.StateEducationAgency
			ON EducationServiceCenter.StateEducationAgencyId = StateEducationAgency.StateEducationAgencyId
	INNER JOIN
		edfi.EducationOrganization StateEducationOrganization
			ON EducationServiceCenter.StateEducationAgencyId = StateEducationAgency.StateEducationAgencyId
	LEFT JOIN
		edfi.EducationOrganizationAddress
			ON EducationOrganization.EducationOrganizationId = EducationOrganizationAddress.EducationOrganizationId
	LEFT JOIN
		edfi.StateAbbreviationDescriptor
			ON EducationOrganizationAddress.StateAbbreviationDescriptorId = StateAbbreviationDescriptor.StateAbbreviationDescriptorId
	LEFT JOIN
		edfi.Descriptor StateAbbreviationDesc
			ON StateAbbreviationDescriptor.StateAbbreviationDescriptorId = StateAbbreviationDesc.DescriptorId
	LEFT JOIN
		edfi.Descriptor OperationalStatusDescriptor
			ON EducationOrganization.OperationalStatusDescriptorId = OperationalStatusDescriptor.DescriptorId
	-- Mailing
	LEFT OUTER JOIN
        OrgEducationAddress AS MailingAddress
			ON EducationOrganization.EducationOrganizationId = MailingAddress.EducationOrganizationId
				AND MailingAddress.ConstantName = 'Address.Mailing'
	-- Physical
	LEFT OUTER JOIN
        OrgEducationAddress AS PhysicalAddress
			ON EducationOrganization.EducationOrganizationId = PhysicalAddress.EducationOrganizationId
				AND PhysicalAddress.ConstantName = 'Address.Physical'
	-- Telephone
	LEFT JOIN
		edfi.EducationOrganizationInstitutionTelephone
			ON EducationOrganization.EducationOrganizationId = EducationOrganizationInstitutionTelephone.EducationOrganizationId
	