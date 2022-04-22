-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.VIEWS
        WHERE TABLE_SCHEMA = 'analytics' AND TABLE_NAME = 'ceds_K12SchoolDim'
        )
BEGIN
    DROP VIEW analytics.ceds_K12SchoolDim;
END;
GO

CREATE VIEW analytics.ceds_K12SchoolDim AS
WITH OrganizationAddress
AS (
    SELECT School.SchoolId
        ,EducationOrganizationAddress.City AS AddressCity
        ,EducationOrganizationAddress.PostalCode AS AddressPostalCode
        ,Descriptor.CodeValue AS AddressStateAbbreviation
        ,EducationOrganizationAddress.StreetNumberName AS AddressStreetNumberAndName
        ,EducationOrganizationAddress.BuildingSiteNumber AS AddressApartmentRoomOrSuiteNumber
        ,DescriptorConstant.ConstantName AS AddressType
        ,COALESCE(EducationOrganizationAddress.Latitude, '') AS Latitude
        ,COALESCE(EducationOrganizationAddress.Longitude, '') AS Longitude
        ,EducationOrganizationAddress.StateAbbreviationDescriptorId
    FROM edfi.School
    INNER JOIN 
		edfi.EducationOrganizationAddress
			ON School.SchoolId = EducationOrganizationAddress.EducationOrganizationId
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
        ,ceds_TableReference.TableName
        ,ceds_TableInformation.EdFactsCode
    FROM analytics_config.ceds_TableInformation
    INNER JOIN 
		analytics_config.ceds_TableReference
			ON ceds_TableInformation.TableId = ceds_TableReference.TableId
    INNER JOIN 
		edfi.Descriptor
			ON Descriptor.DescriptorId = ceds_TableInformation.DescriptorId
    )
SELECT CONCAT(
		EducationOrganizationSchool.EducationOrganizationId
		,'-',EducationOrganizationLEA.EducationOrganizationId
		,'-',EducationOrganizationSEA.EducationOrganizationId
	) as K12SchoolKey
    ,EducationOrganizationSchool.EducationOrganizationId as SchoolKey
	,COALESCE(EducationOrganizationLEA.NameOfInstitution,'') AS LeaName
    ,'' AS LeaIdentifierNces
    ,COALESCE(CAST(School.LocalEducationAgencyId as VARCHAR),'') AS LeaIdentifierSea
    ,COALESCE(EducationOrganizationSchool.NameOfInstitution,'') AS NameOfInstitution
    ,'' AS SchoolIdentifierNces
    ,COALESCE(CAST(School.SchoolId AS VARCHAR),'') AS SchoolIdentifierSea
    ,COALESCE(EducationOrganizationSEA.NameOfInstitution,'') AS SeaOrganizationName
    ,COALESCE(CAST(LocalEducationAgency.StateEducationAgencyId AS VARCHAR),'') AS SeaIdentifierSea
    ,'' AS StateAnsiCode
    ,COALESCE(StateAbbreviationDescriptor.CodeValue,'') AS StateAbbreviationCode
    ,COALESCE(StateAbbreviationDescriptor.Description,'') AS StateAbbreviationDescription
    ,'' AS PrimaryCharterSchoolAuthorizingOrganizationIdentifierSea
    ,'' AS SecondaryCharterSchoolAuthorizingOrganizationIdentifierSea
    ,'' AS OperationalStatusEffectiveDate
    ,'' AS PriorLeaIdentifierSea
    ,'' AS PriorSchoolIdentifierSea
    ,CAST((
            CASE 
                WHEN School.CharterStatusDescriptorId IS NOT NULL
                    THEN 1
                ELSE 0
                END
            ) AS BIT) AS CharterSchoolIndicator
    ,'' AS CharterSchoolContractIdNumber
    ,'' AS CharterSchoolContractApprovalDate
    ,'' AS CharterSchoolContractRenewalDate
    ,CAST(0 as bit) AS ReportedFederally
    ,COALESCE(OrganizationCategoryLEADescriptor.CodeValue,'') AS LeaTypeCode
    ,COALESCE(OrganizationCategoryLEADescriptor.Description,'') AS LeaTypeDescription
    ,COALESCE(MapReferenceOrganizationCategoryLEADescriptor.EdFactsCode,'') AS LeaTypeEdFactsCode
    ,-1 as LeaTypeId
    ,COALESCE(OrganizationCategorySchoolDescriptor.CodeValue,'') AS SchoolTypeCode
    ,COALESCE(OrganizationCategorySchoolDescriptor.Description,'') AS SchoolTypeDescription
    ,COALESCE(MapReferenceOrganizationCategorySchoolDescriptor.EdFactsCode,'') AS SchoolTypeEdFactsCode
    ,-1 AS SchoolTypeId
    ,COALESCE(MailingAddress.AddressCity,'') AS MailingAddressCity
    ,COALESCE(MailingAddress.AddressPostalCode,'') AS MailingAddressPostalCode
    ,COALESCE(MailingAddress.AddressStateAbbreviation,'') AS MailingAddressStateAbbreviation
    ,COALESCE(MailingAddress.AddressStreetNumberAndName,'') AS MailingAddressStreetNumberAndName
    ,COALESCE(MailingAddress.AddressApartmentRoomOrSuiteNumber,'') AS MailingAddressApartmentRoomOrSuiteNumber
    ,'' AS MailingAddressCountyAnsiCode
    ,COALESCE(PhysicalAddress.AddressCity,'') AS PhysicalAddressCity
    ,COALESCE(PhysicalAddress.AddressPostalCode,'') AS PhysicalAddressPostalCode
    ,COALESCE(PhysicalAddress.AddressStateAbbreviation,'') AS PhysicalAddressStateAbbreviation
    ,COALESCE(PhysicalAddress.AddressStreetNumberAndName,'') AS PhysicalAddressStreetNumberAndName
    ,COALESCE(PhysicalAddress.AddressApartmentRoomOrSuiteNumber,'') PhysicalAddressApartmentRoomOrSuiteNumber
    ,'' AS PhysicalAddressCountyAnsiCode
    ,COALESCE(EducationOrganizationInstitutionTelephone.TelephoneNumber,'') AS TelephoneNumber
    ,COALESCE(EducationOrganizationSchool.WebSite,'') AS WebSiteAddress
    ,CAST((
            CASE 
                WHEN PhysicalAddress.StateAbbreviationDescriptorId IS NULL
                    THEN 1
                ELSE 0
                END
            ) AS BIT) AS OutOfStateIndicator
    ,'' AS RecordStartDateTime
    ,'' AS RecordEndDateTime
    ,COALESCE(SchoolOperationStatusDescriptor.CodeValue,'') AS SchoolOperationalStatus
    ,COALESCE(CAST(MapReferenceSchoolOperationStatusDescriptor.EdFactsCode AS INT),0) AS SchoolOperationalStatusEdFactsCode
    ,COALESCE(CharterSchoolStatusDescriptor.CodeValue,'') AS CharterSchoolStatus
    ,'' AS ReconstitutedStatus
    ,COALESCE(IeuOrganization.NameOfInstitution,'') AS IeuOrganizationName
	,COALESCE(CAST(LocalEducationAgency.EducationServiceCenterId AS VARCHAR),'') AS IeuOrganizationIdentifierSea
	,COALESCE(PhysicalAddress.Latitude,'') AS Latitude
    ,COALESCE(PhysicalAddress.Longitude,'') AS Longitude
    ,'' AS SchoolOperationalStatusEffectiveDate
	,COALESCE(AdministrativeFundingControlDescriptor.CodeValue,'') AS AdministrativeFundingControlCode
    ,COALESCE(AdministrativeFundingControlDescriptor.Description,'') AS AdministrativeFundingControlDescription
FROM edfi.School
LEFT JOIN 
	edfi.EducationOrganization AS EducationOrganizationLEA
	    ON School.LocalEducationAgencyId = EducationOrganizationLEA.EducationOrganizationId
LEFT JOIN 
	edfi.EducationOrganization AS EducationOrganizationSchool
		ON School.SchoolId = EducationOrganizationSchool.EducationOrganizationId
LEFT JOIN 
	edfi.LocalEducationAgency
		ON School.LocalEducationAgencyId = LocalEducationAgency.LocalEducationAgencyId
LEFT JOIN 
	edfi.EducationOrganizationAddress
		ON School.SchoolId = EducationOrganizationAddress.EducationOrganizationId
LEFT JOIN 
	edfi.EducationOrganization AS EducationOrganizationSEA
		ON LocalEducationAgency.StateEducationAgencyId = EducationOrganizationSEA.EducationOrganizationId
LEFT JOIN 
	edfi.Descriptor AS StateAbbreviationDescriptor
		ON StateAbbreviationDescriptor.DescriptorId = EducationOrganizationAddress.StateAbbreviationDescriptorId
LEFT JOIN 
	edfi.EducationOrganizationCategory AS EducationOrganizationCategoryLEA
		ON School.LocalEducationAgencyId = EducationOrganizationCategoryLEA.EducationOrganizationId
LEFT JOIN 
	edfi.EducationOrganizationCategoryDescriptor AS EducationOrganizationCategoryLEADescriptor
	    ON EducationOrganizationCategoryLEADescriptor.EducationOrganizationCategoryDescriptorId = EducationOrganizationCategoryLEA.EducationOrganizationCategoryDescriptorId
LEFT JOIN 
	edfi.Descriptor AS OrganizationCategoryLEADescriptor
		ON OrganizationCategoryLEADescriptor.DescriptorId = EducationOrganizationCategoryLEADescriptor.EducationOrganizationCategoryDescriptorId
LEFT JOIN 
	MapReferenceDescriptor AS MapReferenceOrganizationCategoryLEADescriptor
		ON MapReferenceOrganizationCategoryLEADescriptor.DescriptorId = OrganizationCategoryLEADescriptor.DescriptorId
			AND MapReferenceOrganizationCategoryLEADescriptor.TableName = 'xref.LEAType'
LEFT JOIN 
	edfi.EducationOrganizationCategory AS EducationOrganizationCategorySchool
		ON School.SchoolId = EducationOrganizationCategorySchool.EducationOrganizationId
LEFT JOIN edfi.EducationOrganizationCategoryDescriptor AS EducationOrganizationCategorySchoolDescriptor
    ON EducationOrganizationCategorySchoolDescriptor.EducationOrganizationCategoryDescriptorId = EducationOrganizationCategorySchool.EducationOrganizationCategoryDescriptorId
LEFT JOIN edfi.Descriptor AS OrganizationCategorySchoolDescriptor
    ON OrganizationCategorySchoolDescriptor.DescriptorId = EducationOrganizationCategorySchoolDescriptor.EducationOrganizationCategoryDescriptorId
LEFT JOIN 
	MapReferenceDescriptor AS MapReferenceOrganizationCategorySchoolDescriptor
		ON MapReferenceOrganizationCategorySchoolDescriptor.DescriptorId = OrganizationCategorySchoolDescriptor.DescriptorId
			AND MapReferenceOrganizationCategorySchoolDescriptor.TableName = 'xref.LEAType'
LEFT JOIN 
	OrganizationAddress AS MailingAddress
		ON School.SchoolId = MailingAddress.SchoolId
			AND MailingAddress.AddressType = 'Address.Mailing'
LEFT JOIN 
	OrganizationAddress AS PhysicalAddress
		ON School.SchoolId = MailingAddress.SchoolId
			AND MailingAddress.AddressType = 'Address.Physical'
LEFT JOIN 
	edfi.EducationOrganizationInstitutionTelephone
		ON School.SchoolId = EducationOrganizationInstitutionTelephone.EducationOrganizationId
LEFT JOIN 
	edfi.Descriptor AS SchoolOperationStatusDescriptor
		ON EducationOrganizationSchool.OperationalStatusDescriptorId = SchoolOperationStatusDescriptor.DescriptorId
LEFT JOIN 
	MapReferenceDescriptor AS MapReferenceSchoolOperationStatusDescriptor
		ON MapReferenceSchoolOperationStatusDescriptor.DescriptorId = SchoolOperationStatusDescriptor.DescriptorId
        AND MapReferenceSchoolOperationStatusDescriptor.TableName = 'xref.OperationalStatus'
LEFT JOIN 
	edfi.Descriptor AS CharterSchoolStatusDescriptor
		ON School.CharterStatusDescriptorId = CharterSchoolStatusDescriptor.DescriptorId
LEFT JOIN 
	edfi.EducationOrganization as IeuOrganization
		ON LocalEducationAgency.EducationServiceCenterId = IeuOrganization.EducationOrganizationId
LEFT JOIN 
	edfi.Descriptor AS AdministrativeFundingControlDescriptor
		ON School.AdministrativeFundingControlDescriptorId = AdministrativeFundingControlDescriptor.DescriptorId;