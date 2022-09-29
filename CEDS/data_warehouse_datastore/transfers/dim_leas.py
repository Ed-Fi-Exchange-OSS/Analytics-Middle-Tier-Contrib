# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

import pandas as pd
from common.helpers import question_marks


def dim_leas(conn_source, conn_target) -> pd.DataFrame:

    print("Transfer DimLeas... ", end = '')

    data = pd.read_sql("SELECT  \
            LeaKey, \
            OperationalStatusEffectiveDate, \
            LeaName, \
            LeaIdentifierNces, \
            LeaIdentifierSea, \
            NameOfInstitution, \
            PriorLeaIdentifierSea, \
            SeaOrganizationName, \
            SeaIdentifierSea, \
            StateAnsiCode, \
            StateAbbreviationCode, \
            StateAbbreviationDescription, \
            LeaSupervisoryUnionIdentificationNumber, \
            ReportedFederally, \
            LeaTypeCode, \
            LeaTypeDescription, \
            LeaTypeEdFactsCode, \
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
            LEAOperationalStatus, \
            LEAOperationalStatusEdFactsCode, \
            CharterLEAStatus, \
            ReconstitutedStatus, \
            McKinneyVentoSubgrantRecipient, \
            IeuOrganizationName, \
            IeuOrganizationIdentifierSea, \
            Latitude, \
            Longitude, \
            EffectiveDate  \
        FROM analytics.ceds_LeaDim;", conn_source)
    
    cursor_target = conn_target.cursor()
    
    for index, row in data.iterrows():
        row_insert = row[1:]

        cursor_target.execute(f"INSERT INTO RDS.DimLeas (\
            OperationalStatusEffectiveDate, \
            LeaName, \
            LeaIdentifierNces, \
            LeaIdentifierSea, \
            NameOfInstitution, \
            PriorLeaIdentifierSea, \
            SeaOrganizationName, \
            SeaIdentifierSea, \
            StateAnsiCode, \
            StateAbbreviationCode, \
            StateAbbreviationDescription, \
            LeaSupervisoryUnionIdentificationNumber, \
            ReportedFederally, \
            LeaTypeCode, \
            LeaTypeDescription, \
            LeaTypeEdFactsCode, \
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
            LEAOperationalStatus, \
            LEAOperationalStatusEdFactsCode, \
            CharterLEAStatus, \
            ReconstitutedStatus, \
            McKinneyVentoSubgrantRecipient, \
            IeuOrganizationName, \
            IeuOrganizationIdentifierSea, \
            Latitude, \
            Longitude, \
            EffectiveDate) VALUES ({question_marks(43)});", *row_insert)
        identity = cursor_target.execute("SELECT @@IDENTITY AS id;").fetchone()[0]
        data.at[index, 'LeaId'] = int(identity)

    data = data[['LeaId', 'LeaKey']]

    conn_target.commit()
    
    print("Done!")

    return data
