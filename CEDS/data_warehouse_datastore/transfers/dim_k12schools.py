# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

import pandas as pd
from common.helpers import question_marks


def dim_k12schools(conn_source, conn_target) -> pd.DataFrame:

    print("Transfer DimK12Schools... ", end = '')

    data = pd.read_sql("SELECT  \
            K12SchoolKey, \
            LeaName, \
            LeaIdentifierNces, \
            LeaIdentifierSea, \
            NameOfInstitution, \
            SchoolIdentifierNces, \
            SchoolIdentifierSea, \
            SeaOrganizationName, \
            SeaIdentifierSea, \
            StateAnsiCode, \
            StateAbbreviationCode, \
            StateAbbreviationDescription, \
            PrimaryCharterSchoolAuthorizingOrganizationIdentifierSea, \
            SecondaryCharterSchoolAuthorizingOrganizationIdentifierSea, \
            OperationalStatusEffectiveDate, \
            PriorLeaIdentifierSea, \
            PriorSchoolIdentifierSea, \
            CharterSchoolIndicator, \
            CharterSchoolContractIdNumber, \
            CharterSchoolContractApprovalDate, \
            CharterSchoolContractRenewalDate, \
            ReportedFederally, \
            LeaTypeCode, \
            LeaTypeDescription, \
            LeaTypeEdFactsCode, \
            LeaTypeId, \
            SchoolTypeCode, \
            SchoolTypeDescription, \
            SchoolTypeEdFactsCode, \
            SchoolTypeId, \
            MailingAddressCity, \
            MailingAddressPostalCode, \
            MailingAddressStateAbbreviation, \
            MailingAddressStreetNumberAndName, \
            MailingAddressApartmentRoomOrSuiteNumber, \
            MailingAddressCountyAnsiCode, \
            PhysicalAddressCity, \
            PhysicalAddressPostalCode, \
            PhysicalAddressStateAbbreviation, \
            PhysicalAddressStreetNumberAndName, \
            PhysicalAddressApartmentRoomOrSuiteNumber, \
            PhysicalAddressCountyAnsiCode, \
            TelephoneNumber, \
            WebSiteAddress, \
            OutOfStateIndicator, \
            RecordStartDateTime, \
            RecordEndDateTime, \
            SchoolOperationalStatus, \
            CharterSchoolStatus, \
            ReconstitutedStatus, \
            IeuOrganizationName, \
            IeuOrganizationIdentifierSea, \
            Latitude, \
            Longitude, \
            SchoolOperationalStatusEffectiveDate, \
            AdministrativeFundingControlCode, \
            AdministrativeFundingControlDescription  \
        FROM analytics.ceds_K12SchoolDim;", conn_source)
    cursor_target = conn_target.cursor()
    
    for index, row in data.iterrows():
        row_insert = row[1:]

        cursor_target.execute(f"INSERT INTO RDS.DimK12Schools (\
            LeaName, \
            LeaIdentifierNces, \
            LeaIdentifierSea, \
            NameOfInstitution, \
            SchoolIdentifierNces, \
            SchoolIdentifierSea, \
            SeaOrganizationName, \
            SeaIdentifierSea, \
            StateAnsiCode, \
            StateAbbreviationCode, \
            StateAbbreviationDescription, \
            PrimaryCharterSchoolAuthorizingOrganizationIdentifierSea, \
            SecondaryCharterSchoolAuthorizingOrganizationIdentifierSea, \
            OperationalStatusEffectiveDate, \
            PriorLeaIdentifierSea, \
            PriorSchoolIdentifierSea, \
            CharterSchoolIndicator, \
            CharterSchoolContractIdNumber, \
            CharterSchoolContractApprovalDate, \
            CharterSchoolContractRenewalDate, \
            ReportedFederally, \
            LeaTypeCode, \
            LeaTypeDescription, \
            LeaTypeEdFactsCode, \
            LeaTypeId, \
            SchoolTypeCode, \
            SchoolTypeDescription, \
            SchoolTypeEdFactsCode, \
            SchoolTypeId, \
            MailingAddressCity, \
            MailingAddressPostalCode, \
            MailingAddressStateAbbreviation, \
            MailingAddressStreetNumberAndName, \
            MailingAddressApartmentRoomOrSuiteNumber, \
            MailingAddressCountyAnsiCode, \
            PhysicalAddressCity, \
            PhysicalAddressPostalCode, \
            PhysicalAddressStateAbbreviation, \
            PhysicalAddressStreetNumberAndName, \
            PhysicalAddressApartmentRoomOrSuiteNumber, \
            PhysicalAddressCountyAnsiCode, \
            TelephoneNumber, \
            WebSiteAddress, \
            OutOfStateIndicator, \
            RecordStartDateTime, \
            RecordEndDateTime, \
            SchoolOperationalStatus, \
            CharterSchoolStatus, \
            ReconstitutedStatus, \
            IeuOrganizationName, \
            IeuOrganizationIdentifierSea, \
            Latitude, \
            Longitude, \
            SchoolOperationalStatusEffectiveDate, \
            AdministrativeFundingControlCode, \
            AdministrativeFundingControlDescription) VALUES ({question_marks(56)});", *row_insert)
        identity = cursor_target.execute("SELECT @@IDENTITY AS id;").fetchone()[0]
        data.at[index, 'K12SchoolId'] = int(identity)

    data = data[['K12SchoolId', 'K12SchoolKey']]

    conn_target.commit()
    
    print("Done!")

    return data
