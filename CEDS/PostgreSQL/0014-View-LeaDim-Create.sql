-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.

DROP VIEW IF EXISTS xref.ceds_LeaDim;

CREATE VIEW xref.ceds_LeaDim AS
WITH OrganizationAddress
AS (
    SELECT LocalEducationAgency.LocalEducationAgencyId
        ,EducationOrganizationAddress.City AS AddressCity
        ,EducationOrganizationAddress.PostalCode AS AddressPostalCode
        ,Descriptor.CodeValue AS AddressStateAbbreviation
        ,EducationOrganizationAddress.StreetNumberName AS AddressStreetNumberAndName
        ,EducationOrganizationAddress.BuildingSiteNumber AS AddressApartmentRoomOrSuiteNumber
        ,DescriptorConstant.ConstantName AS AddressType
        ,COALESCE(EducationOrganizationAddress.Latitude, '') AS Latitude
        ,COALESCE(EducationOrganizationAddress.Longitude, '') AS Longitude
        ,EducationOrganizationAddress.StateAbbreviationDescriptorId
    FROM 
        edfi.LocalEducationAgency
    INNER JOIN 
        edfi.EducationOrganizationAddress
            ON LocalEducationAgency.LocalEducationAgencyId = EducationOrganizationAddress.EducationOrganizationId
    INNER JOIN 
        edfi.Descriptor
            ON AddressTypeDescriptorId = DescriptorId
    INNER JOIN 
        analytics_config.DescriptorMap
            ON Descriptor.DescriptorId = DescriptorMap.DescriptorId
    INNER JOIN 
        analytics_config.DescriptorConstant
            ON DescriptorConstant.DescriptorConstantId = DescriptorMap.DescriptorConstantId
    )
    ,MapReferenceDescriptor
AS (
    SELECT Descriptor.DescriptorId
        ,Descriptor.CodeValue
        ,Descriptor.Description
        ,EdFiTableReference.EdFiTableName
        ,EdFiTableInformation.EdFactsCode
    FROM 
        xref.EdFiTableInformation
    INNER JOIN 
        xref.EdFiTableReference
            ON EdFiTableInformation.EdFiTableId = EdFiTableReference.EdFiTableId
    INNER JOIN 
        edfi.Descriptor
            ON Descriptor.DescriptorId = EdFiTableInformation.EdFiDescriptorId
    )
SELECT 
    CONCAT(
	    EducationOrganizationLEA.EducationOrganizationId
		,'-',EducationOrganizationSEA.EducationOrganizationId
	) as K12SchoolKey
    ,CAST(EducationOrganizationLEA.EducationOrganizationId AS VARCHAR) as LocalEducationAgencyKey
    ,'' AS OperationalStatusEffectiveDate
    ,EducationOrganizationLEA.NameOfInstitution AS LeaName
    ,'' AS LeaIdentifierNces
    ,COALESCE(CAST(LocalEducationAgency.LocalEducationAgencyId as VARCHAR), '') AS LeaIdentifierSea
    ,EducationOrganizationLEA.NameOfInstitution AS NameOfInstitution
    ,'' AS PriorLeaIdentifierSea
    ,COALESCE(EducationOrganizationSEA.NameOfInstitution, '') AS SeaOrganizationName
    ,COALESCE(CAST(LocalEducationAgency.StateEducationAgencyId AS VARCHAR), '') AS SeaIdentifierSea
    ,'' AS StateAnsiCode
    ,COALESCE(StateAbbreviationDescriptor.CodeValue, '') AS StateAbbreviationCode
    ,COALESCE(StateAbbreviationDescriptor.Description, '') AS StateAbbreviationDescription
    ,'' AS LeaSupervisoryUnionIdentificationNumber
    ,'' AS ReportedFederally
    ,COALESCE(LeaTypeDescriptor.CodeValue, '') AS LeaTypeCode
    ,COALESCE(LeaTypeDescriptor.Description, '') AS LeaTypeDescription
    ,COALESCE(MapReferenceLeaTypeDescriptor.EdFactsCode, '') AS LeaTypeEdFactsCode
    ,COALESCE(MailingAddress.AddressCity, '') AS MailingAddressCity
    ,COALESCE(MailingAddress.AddressPostalCode, '') AS MailingAddressPostalCode
    ,COALESCE(MailingAddress.AddressStateAbbreviation, '') AS MailingAddressStateAbbreviation
    ,COALESCE(MailingAddress.AddressStreetNumberAndName, '') AS MailingAddressStreetNumberAndName
    ,COALESCE(MailingAddress.AddressApartmentRoomOrSuiteNumber, '') AS MailingAddressApartmentRoomOrSuiteNumber
    ,'' AS MailingAddressCountyAnsiCode
    ,COALESCE(PhysicalAddress.AddressCity, '') AS PhysicalAddressCity
    ,COALESCE(PhysicalAddress.AddressPostalCode, '') AS PhysicalAddressPostalCode
    ,COALESCE(PhysicalAddress.AddressStateAbbreviation, '') AS PhysicalAddressStateAbbreviation
    ,COALESCE(PhysicalAddress.AddressStreetNumberAndName, '') AS PhysicalAddressStreetNumberAndName
    ,COALESCE(PhysicalAddress.AddressApartmentRoomOrSuiteNumber, '') PhysicalAddressApartmentRoomOrSuiteNumber
    ,'' AS PhysicalAddressCountyAnsiCode
    ,COALESCE(EducationOrganizationInstitutionTelephone.TelephoneNumber, '') AS TelephoneNumber
    ,COALESCE(EducationOrganizationLEA.WebSite, '') AS WebSiteAddress
    ,(
        CASE 
            WHEN PhysicalAddress.StateAbbreviationDescriptorId IS NULL
                THEN true
            ELSE false
            END
        ) AS OutOfStateIndicator
    ,'' AS RecordStartDateTime
    ,'' AS RecordEndDateTime
    ,COALESCE(LEAOperationStatusDescriptor.CodeValue, '') AS LEAOperationalStatus
    ,COALESCE(CAST(MapReferenceLEAOperationStatusDescriptor.EdFactsCode AS INT), 0) AS LEAOperationalStatusEdFactsCode
    ,COALESCE(CharterLEAStatusDescriptor.CodeValue, '') AS CharterLEAStatus
    ,'' AS ReconstitutedStatus
    ,'' AS McKinneyVentoSubgrantRecipient
    ,COALESCE(IeuOrganization.NameOfInstitution, '') AS IeuOrganizationName
    ,COALESCE(LocalEducationAgency.EducationServiceCenterId, 0) AS IeuOrganizationIdentifierSea
    ,COALESCE(PhysicalAddress.Latitude, '') AS Latitude
    ,COALESCE(PhysicalAddress.Longitude, '') AS Longitude
    ,'' AS EffectiveDate
FROM edfi.LocalEducationAgency
INNER JOIN 
    edfi.EducationOrganization AS EducationOrganizationLEA
        ON LocalEducationAgency.LocalEducationAgencyId = EducationOrganizationLEA.EducationOrganizationId
LEFT JOIN 
    edfi.EducationOrganization AS EducationOrganizationSEA
        ON LocalEducationAgency.StateEducationAgencyId = EducationOrganizationSEA.EducationOrganizationId
LEFT JOIN 
    edfi.EducationOrganizationAddress
        ON LocalEducationAgency.LocalEducationAgencyId = EducationOrganizationAddress.EducationOrganizationId
LEFT JOIN 
    edfi.Descriptor AS StateAbbreviationDescriptor
        ON EducationOrganizationAddress.StateAbbreviationDescriptorId = StateAbbreviationDescriptor.DescriptorId
LEFT JOIN 
    edfi.EducationOrganizationCategory
        ON LocalEducationAgency.LocalEducationAgencyId = EducationOrganizationCategory.EducationOrganizationId
LEFT JOIN 
    edfi.Descriptor AS LeaTypeDescriptor
        ON EducationOrganizationCategory.EducationOrganizationCategoryDescriptorId = LeaTypeDescriptor.DescriptorId
LEFT JOIN 
    MapReferenceDescriptor AS MapReferenceLeaTypeDescriptor
        ON LeaTypeDescriptor.DescriptorId = MapReferenceLeaTypeDescriptor.DescriptorId
            AND MapReferenceLeaTypeDescriptor.EdFiTableName = 'xref.LEAType'
LEFT JOIN 
    OrganizationAddress AS MailingAddress
        ON LocalEducationAgency.LocalEducationAgencyId = MailingAddress.LocalEducationAgencyId
            AND MailingAddress.AddressType = 'Address.Mailing'
LEFT JOIN 
    OrganizationAddress AS PhysicalAddress
        ON LocalEducationAgency.LocalEducationAgencyId = MailingAddress.LocalEducationAgencyId
            AND MailingAddress.AddressType = 'Address.Physical'
LEFT JOIN 
    edfi.EducationOrganizationInstitutionTelephone
        ON LocalEducationAgency.LocalEducationAgencyId = EducationOrganizationInstitutionTelephone.EducationOrganizationId
LEFT JOIN 
    edfi.Descriptor AS LEAOperationStatusDescriptor
        ON EducationOrganizationLEA.OperationalStatusDescriptorId = LEAOperationStatusDescriptor.DescriptorId
LEFT JOIN 
    MapReferenceDescriptor AS MapReferenceLEAOperationStatusDescriptor
        ON MapReferenceLEAOperationStatusDescriptor.DescriptorId = LEAOperationStatusDescriptor.DescriptorId
            AND MapReferenceLEAOperationStatusDescriptor.EdFiTableName = 'xref.OperationalStatus'
LEFT JOIN 
    edfi.Descriptor AS CharterLEAStatusDescriptor
        ON LocalEducationAgency.CharterStatusDescriptorId = CharterLEAStatusDescriptor.DescriptorId
LEFT JOIN 
    edfi.EducationOrganization AS IeuOrganization
        ON LocalEducationAgency.EducationServiceCenterId = IeuOrganization.EducationOrganizationId;
