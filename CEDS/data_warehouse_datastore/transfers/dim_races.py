# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

import pandas as pd
from common.helpers import question_marks


def dim_races(conn_source, conn_target) -> pd.DataFrame:

    print("Transfer DimRaces... ", end='')

    data = pd.read_sql("SELECT \
            RaceKey, \
            RaceCode, \
            RaceDescription, \
            RaceEdFactsCode \
        FROM analytics.ceds_RaceDim;", conn_source)

    cursor_target = conn_target.cursor()

    for index, row in data.iterrows():
        row_insert = row[1:]

        cursor_target.execute(f"INSERT INTO RDS.DimRaces ( \
            RaceCode, \
            RaceDescription, \
            RaceEdFactsCode) VALUES ({question_marks(3)});", *row_insert)
        identity = cursor_target.execute("SELECT @@IDENTITY AS id;").fetchone()[0]
        data.at[index, 'RaceId'] = int(identity)

    data = data[['RaceId', 'RaceKey']]

    conn_target.commit()
    
    print("Done!")

    return data
