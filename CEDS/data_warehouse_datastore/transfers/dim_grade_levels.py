# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

import pandas as pd
from common.helpers import question_marks


def dim_grade_levels(conn_source, conn_target) -> pd.DataFrame:

    print("Inserting DimGradeLevels... ", end='')

    data = pd.read_sql("SELECT \
            GradeLevelKey, \
            GradeLevelCode, \
            GradeLevelDescription, \
            GradeLevelEdFactsCode  \
        FROM analytics.ceds_GradeLevelDim;", conn_source)

    cursor_target = conn_target.cursor()

    for index, row in data.iterrows():
        row_insert = row[1:]

        cursor_target.execute(f"INSERT INTO RDS.DimGradeLevels ( \
            GradeLevelCode, \
            GradeLevelDescription, \
            GradeLevelEdFactsCode) VALUES ({question_marks(3)});", *row_insert)
        identity = cursor_target.execute("SELECT @@IDENTITY AS id;").fetchone()[0]
        data.at[index, 'GradeLevelId'] = int(identity)

    data = data[['GradeLevelId', 'GradeLevelKey']]

    conn_target.commit()
    
    print("Done!")

    return data
