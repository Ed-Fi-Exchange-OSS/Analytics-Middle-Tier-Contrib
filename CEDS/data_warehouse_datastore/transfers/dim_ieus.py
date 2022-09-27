# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

import pandas as pd
from common.helpers import question_marks


def dim_ieus(conn_source, conn_target) -> pd.DataFrame:

    print("Inserting DimIeus... ", end = '')

    data = pd.read_sql("SELECT  \
            IeuDimKey, \
            IeuOrganizationName, \
            IeuOrganizationIdentifierSea, \
            SeaOrganizationName, \
            SeaIdentifierSea, \
            StateANSICode, \
            StateAbbreviationCode, \
            StateAbbreviationDescription, \
            MailingAddressCity, \
            MailingAddressPostalCode, \
            MailingAddressStateAbbreviation, \
            MailingAddressStreetNumberAndName, \
            MailingAddressCountyAnsiCode, \
            OutOfStateIndicator, \
            OrganizationOperationalStatus, \
            OperationalStatusEffectiveDate, \
            PhysicalAddressCity, \
            PhysicalAddressPostalCode, \
            PhysicalAddressStateAbbreviation, \
            PhysicalAddressStreetNumberAndName, \
            PhysicalAddressCountyAnsiCode, \
            TelephoneNumber, \
            WebSiteAddress, \
            OrganizationRegionGeoJson, \
            Latitude, \
            Longitude, \
            RecordStartDateTime, \
            RecordEndDateTime  \
        FROM analytics.ceds_IeuDim;", conn_source)
    
    cursor_target = conn_target.cursor()
    
    for index, row in data.iterrows():
        row_insert = row[1:]

        cursor_target.execute(f"INSERT INTO RDS.DimIeus ( \
            IeuOrganizationName, \
            IeuOrganizationIdentifierSea, \
            SeaOrganizationName, \
            SeaIdentifierSea, \
            StateANSICode, \
            StateAbbreviationCode, \
            StateAbbreviationDescription, \
            MailingAddressCity, \
            MailingAddressPostalCode, \
            MailingAddressStateAbbreviation, \
            MailingAddressStreetNumberAndName, \
            MailingAddressCountyAnsiCode, \
            OutOfStateIndicator, \
            OrganizationOperationalStatus, \
            OperationalStatusEffectiveDate, \
            PhysicalAddressCity, \
            PhysicalAddressPostalCode, \
            PhysicalAddressStateAbbreviation, \
            PhysicalAddressStreetNumberAndName, \
            PhysicalAddressCountyAnsiCode, \
            TelephoneNumber, \
            WebSiteAddress, \
            OrganizationRegionGeoJson, \
            Latitude, \
            Longitude, \
            RecordStartDateTime, \
            RecordEndDateTime ) VALUES ({question_marks(27)});", *row_insert)
        identity = cursor_target.execute("SELECT @@IDENTITY AS id;").fetchone()[0]
        data.at[index, 'IeuDimId'] = int(identity)

    data = data[['IeuDimId', 'IeuDimKey']]

    conn_target.commit()
    
    print("Done!")

    return data
