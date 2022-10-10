-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
DROP VIEW

IF EXISTS analytics.ceds_SeaDim;
    CREATE VIEW analytics.ceds_SeaDim
    AS
    WITH StateOrgEducationAddress
    AS (
        SELECT EducationOrganizationAddress.EducationOrganizationId
            , EducationOrganizationAddress.City
            , EducationOrganizationAddress.PostalCode
        , StateAbbreviationDesc.CodeValue AS StateAbbreviationCode
        , StateAbbreviationDesc.Description AS StateAbbreviationDescription
            , EducationOrganizationAddress.StreetNumberName
            , EducationOrganizationAddress.ApartmentRoomSuiteNumber
            , DescriptorConstant.ConstantName
        , EducationOrganizationAddress.StateAbbreviationDescriptorId
        , Latitude
        , Longitude
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
SELECT '-1' AS SeaDimId
    , '-1' AS SeaDimKey
    , '' AS SeaOrganizationName
    , '' AS SeaIdentifierSea
    , '' AS StateAnsiCode
    , '' AS StateAbbreviationCode
    , '' AS StateAbbreviationDescription
    ,
    --
    '' AS MailingAddressCity
    , '' AS MailingAddressPostalCode
    , '' AS MailingAddressStateAbbreviation
    , '' AS MailingAddressStreetNumberAndName
    , '' AS MailingAddressApartmentRoomOrSuiteNumber
    , '' AS MailingAddressCountyAnsiCode
    ,
    --
    '' AS PhysicalAddressCity
    , '' AS PhysicalAddressPostalCode
    , '' AS PhysicalAddressStateAbbreviation
    , '' AS PhysicalAddressStreetNumberAndName
    , '' AS PhysicalAddressApartmentRoomOrSuiteNumber
    , '' AS PhysicalAddressCountyAnsiCode
    ,
    --
    '' AS TelephoneNumber
    , '' AS WebSiteAddress
    , '' AS Latitude
    , '' AS Longitude
    , '' AS RecordStartDateTime
    , '' AS RecordEndDateTime
    , NOW() AS LastModifiedDate

UNION ALL

SELECT ROW_NUMBER() OVER (
        ORDER BY EducationOrganization.EducationOrganizationId
        ) AS SeaDimId
    , EducationOrganization.EducationOrganizationId AS SeaDimKey
        , EducationOrganization.NameOfInstitution AS SeaOrganizationName
        , CAST(StateEducationAgency.StateEducationAgencyId AS VARCHAR) AS SeaIdentifierSea
        , '' AS StateAnsiCode
    , COALESCE(PhysicalAddress.StateAbbreviationCode, '') AS StateAbbreviationCode
    , COALESCE(PhysicalAddress.StateAbbreviationDescription, '') AS StateAbbreviationDescription
        ,
        --
        COALESCE(MailingAddress.City, '') AS MailingAddressCity
        , COALESCE(MailingAddress.PostalCode, '') AS MailingAddressPostalCode
    , COALESCE(MailingAddress.StateAbbreviationCode, '') AS MailingAddressStateAbbreviation
        , COALESCE(MailingAddress.StreetNumberName, '') AS MailingAddressStreetNumberAndName
        , COALESCE(MailingAddress.ApartmentRoomSuiteNumber, '') AS MailingAddressApartmentRoomOrSuiteNumber
        , '' AS MailingAddressCountyAnsiCode
        ,
        --
        COALESCE(PhysicalAddress.City, '') AS PhysicalAddressCity
        , COALESCE(PhysicalAddress.PostalCode, '') AS PhysicalAddressPostalCode
    , COALESCE(PhysicalAddress.StateAbbreviationCode, '') AS PhysicalAddressStateAbbreviation
        , COALESCE(PhysicalAddress.StreetNumberName, '') AS PhysicalAddressStreetNumberAndName
        , COALESCE(PhysicalAddress.ApartmentRoomSuiteNumber, '') AS PhysicalAddressApartmentRoomOrSuiteNumber
        , '' AS PhysicalAddressCountyAnsiCode
        ,
        --
    COALESCE(OrganizationPhone.TelephoneNumber, '') AS TelephoneNumber
        , COALESCE(EducationOrganization.WebSite, '') AS WebSiteAddress
    , COALESCE(PhysicalAddress.Latitude, '') AS Latitude
    , COALESCE(PhysicalAddress.Longitude, '') AS Longitude
        , '' AS RecordStartDateTime
        , '' AS RecordEndDateTime
        , (
            SELECT MAX(MaxLastModifiedDate)
            FROM (
                VALUES (EducationOrganization.LastModifiedDate)
                ) AS VALUE(MaxLastModifiedDate)
            ) AS LastModifiedDate
    FROM edfi.EducationOrganization
    INNER JOIN edfi.StateEducationAgency
        ON EducationOrganization.EducationOrganizationId = StateEducationAgency.StateEducationAgencyId
    LEFT JOIN edfi.EducationServiceCenter
        ON StateEducationAgency.StateEducationAgencyId = EducationServiceCenter.StateEducationAgencyId
            AND EducationOrganization.EducationOrganizationId = EducationServiceCenter.EducationServiceCenterId
    -- Mailing
    LEFT OUTER JOIN StateOrgEducationAddress AS MailingAddress
        ON StateEducationAgency.StateEducationAgencyId = MailingAddress.EducationOrganizationId
            AND MailingAddress.ConstantName = 'Address.Mailing'
    -- Physical
    LEFT OUTER JOIN StateOrgEducationAddress AS PhysicalAddress
        ON StateEducationAgency.StateEducationAgencyId = PhysicalAddress.EducationOrganizationId
            AND PhysicalAddress.ConstantName = 'Address.Physical'
    -- Telephone
LEFT JOIN OrganizationPhone
    ON EducationOrganization.EducationOrganizationId = OrganizationPhone.EducationOrganizationId;
