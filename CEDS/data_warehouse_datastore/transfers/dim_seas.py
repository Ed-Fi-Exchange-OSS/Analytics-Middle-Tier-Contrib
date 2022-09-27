# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

import pandas as pd
from common.helpers import question_marks


def dim_seas(conn_source, conn_target) -> pd.DataFrame:

    print("Inserting DimSeas... ", end='')

    data = pd.read_sql("SELECT \
            SeaDimKey, \
            SeaOrganizationName, \
            SeaIdentifierSea, \
            StateAnsiCode, \
            StateAbbreviationCode, \
            StateAbbreviationDescription, \
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
            RecordStartDateTime, \
            RecordEndDateTime  \
        FROM analytics.ceds_SeaDim;", conn_source)
    
    cursor_target = conn_target.cursor()
    
    for index, row in data.iterrows():
        row_insert = row[1:]

        cursor_target.execute(f"INSERT INTO RDS.DimSeas ( \
                SeaOrganizationName, \
                SeaIdentifierSea, \
                StateAnsiCode, \
                StateAbbreviationCode, \
                StateAbbreviationDescription, \
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
                RecordStartDateTime, \
                RecordEndDateTime) VALUES ({question_marks(21)});", *row_insert)
        identity = cursor_target.execute("SELECT @@IDENTITY AS id;").fetchone()[0]
        data.at[index, 'SeaDimId'] = int(identity)

    data = data[['SeaDimId', 'SeaDimKey']]

    conn_target.commit()
    
    print("Done!")

    return data
