-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.VIEWS
        WHERE TABLE_SCHEMA = 'analytics'
            AND TABLE_NAME = 'ceds_IeuDim'
        )
BEGIN
    DROP VIEW analytics.ceds_IeuDim;
END;
GO

CREATE VIEW analytics.ceds_IeuDim
AS
WITH OrgEducationAddress
AS (
    SELECT EducationOrganizationAddress.AddressTypeDescriptorId
        , EducationOrganizationAddress.EducationOrganizationId
        , EducationOrganizationAddress.City
        , EducationOrganizationAddress.PostalCode
        , EducationOrganizationAddress.StateAbbreviationDescriptorId
        , StateAbbreviationDesc.CodeValue AS StateAbbreviation
        , EducationOrganizationAddress.StreetNumberName
        , EducationOrganizationAddress.ApartmentRoomSuiteNumber
        , DescriptorConstant.ConstantName
    FROM edfi.EducationOrganizationAddress
    INNER JOIN edfi.Descriptor AS AddressType
        ON EducationOrganizationAddress.AddressTypeDescriptorId = AddressType.DescriptorId
    INNER JOIN analytics_config.DescriptorMap
        ON AddressType.DescriptorId = DescriptorMap.DescriptorId
    INNER JOIN analytics_config.DescriptorConstant
        ON DescriptorConstant.DescriptorConstantId = DescriptorMap.DescriptorConstantId
    LEFT JOIN edfi.StateAbbreviationDescriptor
        ON EducationOrganizationAddress.StateAbbreviationDescriptorId = StateAbbreviationDescriptor.StateAbbreviationDescriptorId
    LEFT JOIN edfi.Descriptor StateAbbreviationDesc
        ON StateAbbreviationDescriptor.StateAbbreviationDescriptorId = StateAbbreviationDesc.DescriptorId
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
SELECT '-1' IeuDimId
    , '-1' AS IeuDimKey
    , '' IeuOrganizationName
    , '' IeuOrganizationIdentifierSea
    , '' SeaOrganizationName
    , '' SeaIdentifierSea
    , '' StateANSICode
    , '' StateAbbreviationCode
    , '' StateAbbreviationDescription
    , '' MailingAddressCity
    , '' MailingAddressPostalCode
    , '' MailingAddressStateAbbreviation
    , '' MailingAddressStreetNumberAndName
    , '' MailingAddressCountyAnsiCode
    , '' OutOfStateIndicator
    , '' OrganizationOperationalStatus
    , '' OperationalStatusEffectiveDate
    , '' PhysicalAddressCity
    , '' PhysicalAddressPostalCode
    , '' PhysicalAddressStateAbbreviation
    , '' PhysicalAddressStreetNumberAndName
    , '' PhysicalAddressApartmentRoomOrSuiteNumber
    , '' PhysicalAddressCountyAnsiCode
    , '' TelephoneNumber
    , '' WebSiteAddress
    , '' OrganizationRegionGeoJson
    , '' Latitude
    , '' Longitude
    , '' RecordStartDateTime
    , '' RecordEndDateTime
    , GETDATE() LastModifiedDate

UNION ALL

SELECT ROW_NUMBER() OVER (
        ORDER BY IeuDimKey
        ) AS IeuDimId
    , IeuDimKey
    , IeuOrganizationName
    , IeuOrganizationIdentifierSea
    , SeaOrganizationName
    , SeaIdentifierSea
    , StateANSICode
    , StateAbbreviationCode
    , StateAbbreviationDescription
    , MailingAddressCity
    , MailingAddressPostalCode
    , MailingAddressStateAbbreviation
    , MailingAddressStreetNumberAndName
    , MailingAddressCountyAnsiCode
    , OutOfStateIndicator
    , OrganizationOperationalStatus
    , OperationalStatusEffectiveDate
    , PhysicalAddressCity
    , PhysicalAddressPostalCode
    , PhysicalAddressStateAbbreviation
    , PhysicalAddressStreetNumberAndName
    , PhysicalAddressApartmentRoomOrSuiteNumber
    , PhysicalAddressCountyAnsiCode
    , TelephoneNumber
    , WebSiteAddress
    , OrganizationRegionGeoJson
    , Latitude
    , Longitude
    , RecordStartDateTime
    , RecordEndDateTime
    , LastModifiedDate
FROM (
    SELECT DISTINCT CONCAT (
            EducationOrganization.EducationOrganizationId
            , '-'
            , CAST(EducationServiceCenter.EducationServiceCenterId AS VARCHAR)
            , '-'
            , CAST(EducationServiceCenter.StateEducationAgencyId AS VARCHAR)
            ) AS IeuDimKey
        , EducationOrganization.NameOfInstitution AS IeuOrganizationName
        , CAST(EducationServiceCenter.EducationServiceCenterId AS VARCHAR) AS IeuOrganizationIdentifierSea
        , StateEducationOrganization.NameOfInstitution AS SeaOrganizationName
        , CAST(EducationServiceCenter.StateEducationAgencyId AS VARCHAR) AS SeaIdentifierSea
        , '' AS StateANSICode
        , COALESCE(StateAbbreviationDesc.CodeValue, '') AS StateAbbreviationCode
        , COALESCE(StateAbbreviationDesc.Description, '') AS StateAbbreviationDescription
        , COALESCE(MailingAddress.City, '') AS MailingAddressCity
        , COALESCE(MailingAddress.PostalCode, '') AS MailingAddressPostalCode
        , COALESCE(MailingAddress.StateAbbreviation, '') AS MailingAddressStateAbbreviation
        , COALESCE(MailingAddress.StreetNumberName, '') AS MailingAddressStreetNumberAndName
        , '' AS MailingAddressCountyAnsiCode
        , CAST((
                CASE 
                    WHEN PhysicalAddress.StateAbbreviation IS NULL
                        THEN 1
                    ELSE 0
                    END
                ) AS BIT) AS OutOfStateIndicator
        , OperationalStatusDescriptor.CodeValue AS OrganizationOperationalStatus
        , '' AS OperationalStatusEffectiveDate
        , COALESCE(PhysicalAddress.City, '') AS PhysicalAddressCity
        , COALESCE(PhysicalAddress.PostalCode, '') AS PhysicalAddressPostalCode
        , COALESCE(PhysicalAddress.StateAbbreviation, '') AS PhysicalAddressStateAbbreviation
        , COALESCE(PhysicalAddress.StreetNumberName, '') AS PhysicalAddressStreetNumberAndName
        , COALESCE(PhysicalAddress.ApartmentRoomSuiteNumber, '') AS PhysicalAddressApartmentRoomOrSuiteNumber
        , '' AS PhysicalAddressCountyAnsiCode
        , COALESCE(OrganizationPhone.TelephoneNumber, '') AS TelephoneNumber
        , COALESCE(EducationOrganization.WebSite, '') AS WebSiteAddress
        , '' AS OrganizationRegionGeoJson
        , COALESCE(EducationOrganizationAddress.Latitude, '') AS Latitude
        , COALESCE(EducationOrganizationAddress.Longitude, '') AS Longitude
        , '' AS RecordStartDateTime
        , '' AS RecordEndDateTime
        , (
            SELECT MAX(MaxLastModifiedDate)
            FROM (
                VALUES (EducationOrganization.LastModifiedDate)
                    , (StateAbbreviationDesc.LastModifiedDate)
                ) AS VALUE(MaxLastModifiedDate)
            ) AS LastModifiedDate
    FROM edfi.EducationServiceCenter
    INNER JOIN edfi.EducationOrganization
        ON EducationServiceCenter.EducationServiceCenterId = EducationOrganization.EducationOrganizationId
    INNER JOIN edfi.EducationOrganization StateEducationOrganization
        ON EducationServiceCenter.StateEducationAgencyId = StateEducationOrganization.EducationOrganizationId
    LEFT JOIN edfi.EducationOrganizationAddress
        ON EducationOrganization.EducationOrganizationId = EducationOrganizationAddress.EducationOrganizationId
    LEFT JOIN edfi.StateAbbreviationDescriptor
        ON EducationOrganizationAddress.StateAbbreviationDescriptorId = StateAbbreviationDescriptor.StateAbbreviationDescriptorId
    LEFT JOIN edfi.Descriptor StateAbbreviationDesc
        ON StateAbbreviationDescriptor.StateAbbreviationDescriptorId = StateAbbreviationDesc.DescriptorId
    LEFT JOIN edfi.Descriptor OperationalStatusDescriptor
        ON EducationOrganization.OperationalStatusDescriptorId = OperationalStatusDescriptor.DescriptorId
    LEFT JOIN OrgEducationAddress AS MailingAddress
        ON EducationOrganization.EducationOrganizationId = MailingAddress.EducationOrganizationId
            AND MailingAddress.ConstantName = 'Address.Mailing'
    LEFT JOIN OrgEducationAddress AS PhysicalAddress
        ON EducationOrganization.EducationOrganizationId = PhysicalAddress.EducationOrganizationId
            AND PhysicalAddress.ConstantName = 'Address.Physical'
    LEFT JOIN OrganizationPhone
        ON EducationOrganization.EducationOrganizationId = OrganizationPhone.EducationOrganizationId
    ) AS IeuColumns;
