-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.VIEWS
        WHERE TABLE_SCHEMA = 'analytics'
            AND TABLE_NAME = 'ceds_K12SchoolDim'
        )
BEGIN
    DROP VIEW analytics.ceds_K12SchoolDim;
END;
GO

CREATE VIEW analytics.ceds_K12SchoolDim
AS
WITH OrganizationAddress
AS (
    SELECT School.SchoolId
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
        , StateAbbreviationDescriptor.Description AS StateAbbreviationDescription
    FROM edfi.School
    INNER JOIN edfi.EducationOrganizationAddress
        ON School.SchoolId = EducationOrganizationAddress.EducationOrganizationId
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
    SELECT School.SchoolId
        , EducationOrganizationInstitutionTelephone.TelephoneNumber
        , DescriptorConstant.ConstantName AS PhoneType
    FROM edfi.School
    INNER JOIN edfi.EducationOrganizationInstitutionTelephone
        ON School.SchoolId = EducationOrganizationInstitutionTelephone.EducationOrganizationId
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
SELECT '-1' AS K12SchoolDimId
    , '-1' AS K12SchoolKey
    , '' AS SchoolKey
    , '' AS LeaName
    , '' AS LeaIdentifierNces
    , '' AS LeaIdentifierSea
    , '' AS NameOfInstitution
    , '' AS SchoolIdentifierNces
    , '' AS SchoolIdentifierSea
    , '' AS SeaOrganizationName
    , '' AS SeaIdentifierSea
    , '' AS StateAnsiCode
    , '' AS StateAbbreviationCode
    , '' AS StateAbbreviationDescription
    , '' AS PrimaryCharterSchoolAuthorizingOrganizationIdentifierSea
    , '' AS SecondaryCharterSchoolAuthorizingOrganizationIdentifierSea
    , '' AS OperationalStatusEffectiveDate
    , '' AS PriorLeaIdentifierSea
    , '' AS PriorSchoolIdentifierSea
    , 0 AS CharterSchoolIndicator
    , '' AS CharterSchoolContractIdNumber
    , '' AS CharterSchoolContractApprovalDate
    , '' AS CharterSchoolContractRenewalDate
    , '' AS ReportedFederally
    , '' AS LeaTypeCode
    , '' AS LeaTypeDescription
    , '' AS LeaTypeEdFactsCode
    , - 1 AS LeaTypeId
    , '' AS SchoolTypeCode
    , '' AS SchoolTypeDescription
    , '' AS SchoolTypeEdFactsCode
    , - 1 AS SchoolTypeId
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
    , '' AS SchoolOperationalStatus
    , '' AS SchoolOperationalStatusEdFactsCode
    , '' AS CharterSchoolStatus
    , '' AS ReconstitutedStatus
    , '' AS IeuOrganizationName
    , '' AS IeuOrganizationIdentifierSea
    , '' AS Latitude
    , '' AS Longitude
    , '' AS SchoolOperationalStatusEffectiveDate
    , '' AS AdministrativeFundingControlCode
    , '' AS AdministrativeFundingControlDescription

UNION ALL

SELECT ROW_NUMBER() OVER (
        ORDER BY School.SchoolId
        ) AS K12SchoolDimId
    , COALESCE(CAST(School.SchoolId AS VARCHAR),'') AS K12SchoolKey
    , COALESCE(CAST(EducationOrganizationSchool.EducationOrganizationId AS VARCHAR),'') AS SchoolKey
    , COALESCE(EducationOrganizationLEA.NameOfInstitution, '') AS LeaName
    , '' AS LeaIdentifierNces
    , COALESCE(CAST(School.LocalEducationAgencyId AS VARCHAR), '') AS LeaIdentifierSea
    , COALESCE(EducationOrganizationSchool.NameOfInstitution, '') AS NameOfInstitution
    , '' AS SchoolIdentifierNces
    , COALESCE(CAST(School.SchoolId AS VARCHAR), '') AS SchoolIdentifierSea
    , COALESCE(EducationOrganizationSEA.NameOfInstitution, '') AS SeaOrganizationName
    , COALESCE(CAST(LocalEducationAgency.StateEducationAgencyId AS VARCHAR), '') AS SeaIdentifierSea
    , '' AS StateAnsiCode
    , COALESCE(PhysicalAddress.StateAbbreviationCode, '') AS StateAbbreviationCode
    , COALESCE(PhysicalAddress.StateAbbreviationDescription, '') AS StateAbbreviationDescription
    , '' AS PrimaryCharterSchoolAuthorizingOrganizationIdentifierSea
    , '' AS SecondaryCharterSchoolAuthorizingOrganizationIdentifierSea
    , '' AS OperationalStatusEffectiveDate
    , '' AS PriorLeaIdentifierSea
    , '' AS PriorSchoolIdentifierSea
    , CAST((
            CASE 
                WHEN School.CharterStatusDescriptorId IS NOT NULL
                    THEN 1
                ELSE 0
                END
            ) AS BIT) AS CharterSchoolIndicator
    , '' AS CharterSchoolContractIdNumber
    , '' AS CharterSchoolContractApprovalDate
    , '' AS CharterSchoolContractRenewalDate
    , CAST(0 AS BIT) AS ReportedFederally
    , COALESCE(OrganizationCategoryLEADescriptor.CodeValue, '') AS LeaTypeCode
    , COALESCE(OrganizationCategoryLEADescriptor.Description, '') AS LeaTypeDescription
    , COALESCE(MapReferenceOrganizationCategoryLEADescriptor.EdFactsCode, '') AS LeaTypeEdFactsCode
    , - 1 AS LeaTypeId
    , COALESCE(OrganizationCategorySchoolDescriptor.CodeValue, '') AS SchoolTypeCode
    , COALESCE(OrganizationCategorySchoolDescriptor.Description, '') AS SchoolTypeDescription
    , COALESCE(MapReferenceOrganizationCategorySchoolDescriptor.EdFactsCode, '') AS SchoolTypeEdFactsCode
    , - 1 AS SchoolTypeId
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
    , COALESCE(EducationOrganizationSchool.WebSite, '') AS WebSiteAddress
    , CAST((
            CASE 
                WHEN PhysicalAddress.StateAbbreviationDescriptorId IS NULL
                    THEN 1
                ELSE 0
                END
            ) AS BIT) AS OutOfStateIndicator
    , '' AS RecordStartDateTime
    , '' AS RecordEndDateTime
    , COALESCE(SchoolOperationStatusDescriptor.CodeValue, '') AS SchoolOperationalStatus
    , COALESCE(MapReferenceSchoolOperationStatusDescriptor.EdFactsCode, '') AS SchoolOperationalStatusEdFactsCode
    , COALESCE(CharterSchoolStatusDescriptor.CodeValue, '') AS CharterSchoolStatus
    , '' AS ReconstitutedStatus
    , COALESCE(IeuOrganization.NameOfInstitution, '') AS IeuOrganizationName
    , COALESCE(CAST(LocalEducationAgency.EducationServiceCenterId AS VARCHAR), '') AS IeuOrganizationIdentifierSea
    , COALESCE(PhysicalAddress.Latitude, '') AS Latitude
    , COALESCE(PhysicalAddress.Longitude, '') AS Longitude
    , '' AS SchoolOperationalStatusEffectiveDate
    , COALESCE(AdministrativeFundingControlDescriptor.CodeValue, '') AS AdministrativeFundingControlCode
    , COALESCE(AdministrativeFundingControlDescriptor.Description, '') AS AdministrativeFundingControlDescription
FROM edfi.School
LEFT JOIN edfi.EducationOrganization AS EducationOrganizationLEA
    ON School.LocalEducationAgencyId = EducationOrganizationLEA.EducationOrganizationId
LEFT JOIN edfi.EducationOrganization AS EducationOrganizationSchool
    ON School.SchoolId = EducationOrganizationSchool.EducationOrganizationId
LEFT JOIN edfi.LocalEducationAgency
    ON School.LocalEducationAgencyId = LocalEducationAgency.LocalEducationAgencyId
LEFT JOIN edfi.EducationOrganization AS EducationOrganizationSEA
    ON LocalEducationAgency.StateEducationAgencyId = EducationOrganizationSEA.EducationOrganizationId
LEFT JOIN edfi.EducationOrganizationCategory AS EducationOrganizationCategoryLEA
    ON School.LocalEducationAgencyId = EducationOrganizationCategoryLEA.EducationOrganizationId
LEFT JOIN edfi.Descriptor AS OrganizationCategoryLEADescriptor
    ON OrganizationCategoryLEADescriptor.DescriptorId = EducationOrganizationCategoryLEA.EducationOrganizationCategoryDescriptorId
LEFT JOIN MapReferenceDescriptor AS MapReferenceOrganizationCategoryLEADescriptor
    ON MapReferenceOrganizationCategoryLEADescriptor.DescriptorId = OrganizationCategoryLEADescriptor.DescriptorId
        AND MapReferenceOrganizationCategoryLEADescriptor.TableName = 'xref.LEAType'
LEFT JOIN edfi.EducationOrganizationCategory AS EducationOrganizationCategorySchool
    ON School.SchoolId = EducationOrganizationCategorySchool.EducationOrganizationId
LEFT JOIN edfi.Descriptor AS OrganizationCategorySchoolDescriptor
    ON OrganizationCategorySchoolDescriptor.DescriptorId = EducationOrganizationCategorySchool.EducationOrganizationCategoryDescriptorId
LEFT JOIN MapReferenceDescriptor AS MapReferenceOrganizationCategorySchoolDescriptor
    ON MapReferenceOrganizationCategorySchoolDescriptor.DescriptorId = OrganizationCategorySchoolDescriptor.DescriptorId
        AND MapReferenceOrganizationCategorySchoolDescriptor.TableName = 'xref.LEAType'
LEFT JOIN OrganizationAddress AS MailingAddress
    ON School.SchoolId = MailingAddress.SchoolId
        AND MailingAddress.AddressType = 'Address.Mailing'
LEFT JOIN OrganizationAddress AS PhysicalAddress
    ON School.SchoolId = PhysicalAddress.SchoolId
        AND PhysicalAddress.AddressType = 'Address.Physical'
LEFT JOIN OrganizationPhone
    ON School.SchoolId = OrganizationPhone.SchoolId
LEFT JOIN edfi.Descriptor AS SchoolOperationStatusDescriptor
    ON EducationOrganizationSchool.OperationalStatusDescriptorId = SchoolOperationStatusDescriptor.DescriptorId
LEFT JOIN MapReferenceDescriptor AS MapReferenceSchoolOperationStatusDescriptor
    ON MapReferenceSchoolOperationStatusDescriptor.DescriptorId = SchoolOperationStatusDescriptor.DescriptorId
        AND MapReferenceSchoolOperationStatusDescriptor.TableName = 'xref.OperationalStatus'
LEFT JOIN edfi.Descriptor AS CharterSchoolStatusDescriptor
    ON School.CharterStatusDescriptorId = CharterSchoolStatusDescriptor.DescriptorId
LEFT JOIN edfi.EducationOrganization AS IeuOrganization
    ON LocalEducationAgency.EducationServiceCenterId = IeuOrganization.EducationOrganizationId
LEFT JOIN edfi.Descriptor AS AdministrativeFundingControlDescriptor
    ON School.AdministrativeFundingControlDescriptorId = AdministrativeFundingControlDescriptor.DescriptorId;
