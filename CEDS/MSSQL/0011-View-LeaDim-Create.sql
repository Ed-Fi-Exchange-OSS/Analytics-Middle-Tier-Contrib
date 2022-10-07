-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.VIEWS
        WHERE TABLE_SCHEMA = 'analytics'
            AND TABLE_NAME = 'ceds_LeaDim'
        )
BEGIN
    DROP VIEW analytics.ceds_LeaDim;
END;
GO

CREATE VIEW analytics.ceds_LeaDim
AS
WITH OrganizationAddress
AS (
    SELECT LocalEducationAgency.LocalEducationAgencyId
        , EducationOrganizationAddress.AddressTypeDescriptorId
        , EducationOrganizationAddress.City AS AddressCity
        , EducationOrganizationAddress.PostalCode AS AddressPostalCode
        , Descriptor.CodeValue AS AddressStateAbbreviation
        , EducationOrganizationAddress.StreetNumberName AS AddressStreetNumberAndName
        , EducationOrganizationAddress.BuildingSiteNumber AS AddressApartmentRoomOrSuiteNumber
        , DescriptorConstant.ConstantName AS AddressType
        , COALESCE(EducationOrganizationAddress.Latitude, '') AS Latitude
        , COALESCE(EducationOrganizationAddress.Longitude, '') AS Longitude
        , EducationOrganizationAddress.StateAbbreviationDescriptorId
		, StateAbbreviationDescriptor.CodeValue AS StateAbbreviationCode
		, StateAbbreviationDescriptor.Description StateAbbreviationDescription
    FROM edfi.LocalEducationAgency
    INNER JOIN edfi.EducationOrganizationAddress
        ON LocalEducationAgency.LocalEducationAgencyId = EducationOrganizationAddress.EducationOrganizationId
    INNER JOIN edfi.Descriptor
        ON AddressTypeDescriptorId = DescriptorId
    INNER JOIN analytics_config.DescriptorMap
        ON Descriptor.DescriptorId = DescriptorMap.DescriptorId
    INNER JOIN analytics_config.DescriptorConstant
        ON DescriptorConstant.DescriptorConstantId = DescriptorMap.DescriptorConstantId
	LEFT JOIN edfi.Descriptor AS StateAbbreviationDescriptor
        ON StateAbbreviationDescriptor.DescriptorId = EducationOrganizationAddress.StateAbbreviationDescriptorId
    )
    , OrganizationPhone
AS (
    SELECT EducationOrganizationInstitutionTelephone.EducationOrganizationId
        , EducationOrganizationInstitutionTelephone.TelephoneNumber
        , DescriptorConstant.ConstantName AS PhoneType
    FROM edfi.EducationOrganizationInstitutionTelephone
    INNER JOIN edfi.Descriptor
        ON EducationOrganizationInstitutionTelephone.InstitutionTelephoneNumberTypeDescriptorId = DescriptorId
    INNER JOIN analytics_config.DescriptorMap
        ON Descriptor.DescriptorId = DescriptorMap.DescriptorId
    INNER JOIN analytics_config.DescriptorConstant
        ON DescriptorConstant.DescriptorConstantId = DescriptorMap.DescriptorConstantId
    WHERE DescriptorConstant.ConstantName = 'OrganizationTelephone.Main'
    )
    , MapReferenceDescriptor
AS (
    SELECT Descriptor.DescriptorId
        , Descriptor.CodeValue
        , Descriptor.Description
        , ceds_TableReference.TableName
        , ceds_TableInformation.EdFactsCode
    FROM analytics_config.ceds_TableInformation
    INNER JOIN analytics_config.ceds_TableReference
        ON ceds_TableInformation.TableId = ceds_TableReference.TableId
    INNER JOIN edfi.Descriptor
        ON Descriptor.DescriptorId = ceds_TableInformation.DescriptorId
    )
SELECT '-1' AS LeaDimId
    , '-1' AS LeaKey
    , '' AS LocalEducationAgencyKey
    , '' AS OperationalStatusEffectiveDate
    , '' AS LeaName
    , '' AS LeaIdentifierNces
    , '' AS LeaIdentifierSea
    , '' AS NameOfInstitution
    , '' AS PriorLeaIdentifierSea
    , '' AS SeaOrganizationName
    , '' AS SeaIdentifierSea
    , '' AS StateAnsiCode
    , '' AS StateAbbreviationCode
    , '' AS StateAbbreviationDescription
    , '' AS LeaSupervisoryUnionIdentificationNumber
    , '' AS ReportedFederally
    , '' AS LeaTypeCode
    , '' AS LeaTypeDescription
    , '' AS LeaTypeEdFactsCode
    , '' AS MailingAddressCity
    , '' AS MailingAddressPostalCode
    , '' AS MailingAddressStateAbbreviation
    , '' AS MailingAddressStreetNumberAndName
    , '' AS MailingAddressApartmentRoomOrSuiteNumber
    , '' AS MailingAddressCountyAnsiCode
    , '' AS PhysicalAddressCity
    , '' AS PhysicalAddressPostalCode
    , '' AS PhysicalAddressStateAbbreviation
    , '' AS PhysicalAddressStreetNumberAndName
    , '' AS PhysicalAddressApartmentRoomOrSuiteNumber
    , '' AS PhysicalAddressCountyAnsiCode
    , '' AS TelephoneNumber
    , '' AS WebSiteAddress
    , 0 AS OutOfStateIndicator
    , '' AS RecordStartDateTime
    , '' AS RecordEndDateTime
    , '' AS LEAOperationalStatus
    , '' AS LEAOperationalStatusEdFactsCode
    , '' AS CharterLEAStatus
    , '' AS ReconstitutedStatus
    , '' AS McKinneyVentoSubgrantRecipient
    , '' AS IeuOrganizationName
    , '' AS IeuOrganizationIdentifierSea
    , '' AS Latitude
    , '' AS Longitude
    , '' AS EffectiveDate

UNION ALL

SELECT ROW_NUMBER() OVER (
        ORDER BY LeaKey
        ) AS LeaDimId
    , LeaKey
    , LocalEducationAgencyKey
    , OperationalStatusEffectiveDate
    , LeaName
    , LeaIdentifierNces
    , LeaIdentifierSea
    , NameOfInstitution
    , PriorLeaIdentifierSea
    , SeaOrganizationName
    , SeaIdentifierSea
    , StateAnsiCode
    , StateAbbreviationCode
    , StateAbbreviationDescription
    , LeaSupervisoryUnionIdentificationNumber
    , ReportedFederally
    , LeaTypeCode
    , LeaTypeDescription
    , LeaTypeEdFactsCode
    , MailingAddressCity
    , MailingAddressPostalCode
    , MailingAddressStateAbbreviation
    , MailingAddressStreetNumberAndName
    , MailingAddressApartmentRoomOrSuiteNumber
    , MailingAddressCountyAnsiCode
    , PhysicalAddressCity
    , PhysicalAddressPostalCode
    , PhysicalAddressStateAbbreviation
    , PhysicalAddressStreetNumberAndName
    , PhysicalAddressApartmentRoomOrSuiteNumber
    , PhysicalAddressCountyAnsiCode
    , TelephoneNumber
    , WebSiteAddress
    , OutOfStateIndicator
    , RecordStartDateTime
    , RecordEndDateTime
    , LEAOperationalStatus
    , LEAOperationalStatusEdFactsCode
    , CharterLEAStatus
    , ReconstitutedStatus
    , McKinneyVentoSubgrantRecipient
    , IeuOrganizationName
    , IeuOrganizationIdentifierSea
    , Latitude
    , Longitude
    , EffectiveDate
FROM (
    SELECT EducationOrganizationLEA.EducationOrganizationId AS LeaKey
        , CAST(EducationOrganizationLEA.EducationOrganizationId AS VARCHAR) AS LocalEducationAgencyKey
        , '' AS OperationalStatusEffectiveDate
        , EducationOrganizationLEA.NameOfInstitution AS LeaName
        , '' AS LeaIdentifierNces
        , COALESCE(CAST(LocalEducationAgency.LocalEducationAgencyId AS VARCHAR), '') AS LeaIdentifierSea
        , EducationOrganizationLEA.NameOfInstitution AS NameOfInstitution
        , '' AS PriorLeaIdentifierSea
        , COALESCE(EducationOrganizationSEA.NameOfInstitution, '') AS SeaOrganizationName
        , COALESCE(CAST(LocalEducationAgency.StateEducationAgencyId AS VARCHAR), '') AS SeaIdentifierSea
        , '' AS StateAnsiCode
        , COALESCE(PhysicalAddress.StateAbbreviationCode, '') AS StateAbbreviationCode
        , COALESCE(PhysicalAddress.StateAbbreviationDescription, '') AS StateAbbreviationDescription
        , '' AS LeaSupervisoryUnionIdentificationNumber
        , '' AS ReportedFederally
        , COALESCE(LeaTypeDescriptor.CodeValue, '') AS LeaTypeCode
        , COALESCE(LeaTypeDescriptor.Description, '') AS LeaTypeDescription
        , COALESCE(MapReferenceLeaTypeDescriptor.EdFactsCode, '') AS LeaTypeEdFactsCode
        , COALESCE(MailingAddress.AddressCity, '') AS MailingAddressCity
        , COALESCE(MailingAddress.AddressPostalCode, '') AS MailingAddressPostalCode
        , COALESCE(MailingAddress.AddressStateAbbreviation, '') AS MailingAddressStateAbbreviation
        , COALESCE(MailingAddress.AddressStreetNumberAndName, '') AS MailingAddressStreetNumberAndName
        , COALESCE(MailingAddress.AddressApartmentRoomOrSuiteNumber, '') AS MailingAddressApartmentRoomOrSuiteNumber
        , '' AS MailingAddressCountyAnsiCode
        , COALESCE(PhysicalAddress.AddressCity, '') AS PhysicalAddressCity
        , COALESCE(PhysicalAddress.AddressPostalCode, '') AS PhysicalAddressPostalCode
        , COALESCE(PhysicalAddress.AddressStateAbbreviation, '') AS PhysicalAddressStateAbbreviation
        , COALESCE(PhysicalAddress.AddressStreetNumberAndName, '') AS PhysicalAddressStreetNumberAndName
        , COALESCE(PhysicalAddress.AddressApartmentRoomOrSuiteNumber, '') PhysicalAddressApartmentRoomOrSuiteNumber
        , '' AS PhysicalAddressCountyAnsiCode
        , COALESCE(OrganizationPhone.TelephoneNumber, '') AS TelephoneNumber
        , COALESCE(EducationOrganizationLEA.WebSite, '') AS WebSiteAddress
        , CAST((
                CASE 
                    WHEN PhysicalAddress.StateAbbreviationDescriptorId IS NULL
                        THEN 1
                    ELSE 0
                    END
                ) AS BIT) AS OutOfStateIndicator
        , '' AS RecordStartDateTime
        , '' AS RecordEndDateTime
        , COALESCE(LEAOperationStatusDescriptor.CodeValue, '') AS LEAOperationalStatus
        , COALESCE(CAST(MapReferenceLEAOperationStatusDescriptor.EdFactsCode AS INT), 0) AS LEAOperationalStatusEdFactsCode
        , COALESCE(CharterLEAStatusDescriptor.CodeValue, '') AS CharterLEAStatus
        , '' AS ReconstitutedStatus
        , '' AS McKinneyVentoSubgrantRecipient
        , COALESCE(IeuOrganization.NameOfInstitution, '') AS IeuOrganizationName
        , COALESCE(CAST(LocalEducationAgency.EducationServiceCenterId AS VARCHAR), '') AS IeuOrganizationIdentifierSea
        , COALESCE(PhysicalAddress.Latitude, '') AS Latitude
        , COALESCE(PhysicalAddress.Longitude, '') AS Longitude
        , '' AS EffectiveDate
    FROM edfi.LocalEducationAgency
    INNER JOIN edfi.EducationOrganization AS EducationOrganizationLEA
        ON LocalEducationAgency.LocalEducationAgencyId = EducationOrganizationLEA.EducationOrganizationId
    LEFT JOIN edfi.EducationOrganization AS EducationOrganizationSEA
        ON LocalEducationAgency.StateEducationAgencyId = EducationOrganizationSEA.EducationOrganizationId
    LEFT JOIN edfi.EducationOrganizationCategory
        ON LocalEducationAgency.LocalEducationAgencyId = EducationOrganizationCategory.EducationOrganizationId
    LEFT JOIN edfi.Descriptor AS LeaTypeDescriptor
        ON EducationOrganizationCategory.EducationOrganizationCategoryDescriptorId = LeaTypeDescriptor.DescriptorId
    LEFT JOIN MapReferenceDescriptor AS MapReferenceLeaTypeDescriptor
        ON LeaTypeDescriptor.DescriptorId = MapReferenceLeaTypeDescriptor.DescriptorId
            AND MapReferenceLeaTypeDescriptor.TableName = 'xref.LEAType'
    LEFT JOIN OrganizationAddress AS MailingAddress
        ON LocalEducationAgency.LocalEducationAgencyId = MailingAddress.LocalEducationAgencyId
            AND MailingAddress.AddressType = 'Address.Mailing'
    LEFT JOIN OrganizationAddress AS PhysicalAddress
        ON LocalEducationAgency.LocalEducationAgencyId = MailingAddress.LocalEducationAgencyId
            AND MailingAddress.AddressType = 'Address.Physical'
    LEFT JOIN OrganizationPhone
        ON LocalEducationAgency.LocalEducationAgencyId = OrganizationPhone.EducationOrganizationId
    LEFT JOIN edfi.Descriptor AS LEAOperationStatusDescriptor
        ON EducationOrganizationLEA.OperationalStatusDescriptorId = LEAOperationStatusDescriptor.DescriptorId
    LEFT JOIN MapReferenceDescriptor AS MapReferenceLEAOperationStatusDescriptor
        ON MapReferenceLEAOperationStatusDescriptor.DescriptorId = LEAOperationStatusDescriptor.DescriptorId
            AND MapReferenceLEAOperationStatusDescriptor.TableName = 'xref.OperationalStatus'
    LEFT JOIN edfi.Descriptor AS CharterLEAStatusDescriptor
        ON LocalEducationAgency.CharterStatusDescriptorId = CharterLEAStatusDescriptor.DescriptorId
    LEFT JOIN edfi.EducationOrganization AS IeuOrganization
        ON LocalEducationAgency.EducationServiceCenterId = IeuOrganization.EducationOrganizationId
    ) AS LeaDim;
