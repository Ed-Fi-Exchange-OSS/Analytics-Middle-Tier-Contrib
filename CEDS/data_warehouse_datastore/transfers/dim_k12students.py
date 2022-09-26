# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

import pandas as pd
from common.helpers import question_marks


def dim_k12students(conn_source, conn_target) -> pd.DataFrame:

    print("Inserting DimK12Students... ", end = '')

    data = pd.read_sql("SELECT \
            K12StudentKey, \
            BirthDate, \
            Cohort, \
            FirstName, \
            LastOrSurname, \
            MiddleName, \
            StudentIdentifierState, \
            RecordStartDateTime, \
            RecordEndDateTime  \
        FROM analytics.ceds_K12StudentDim;", conn_source)
    
    cursor_target = conn_target.cursor()
    
    for index, row in data.iterrows():
        row_insert = row[1:]

        cursor_target.execute(f"INSERT INTO RDS.DimK12Students ( \
            BirthDate, \
            Cohort, \
            FirstName, \
            LastOrSurname, \
            MiddleName, \
            StudentIdentifierState, \
            RecordStartDateTime, \
            RecordEndDateTime) VALUES ({question_marks(8)});", *row_insert)
        identity = cursor_target.execute("SELECT @@IDENTITY AS id;").fetchone()[0]
        data.at[index, 'id'] = int(identity)

    data = data[['id', 'K12StudentKey']]

    conn_target.commit()
    
    print("Done!")

    return data
