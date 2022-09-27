# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

import pandas as pd
from common.helpers import question_marks


def dim_data_collections(conn_source, conn_target) -> pd.DataFrame:

    print("Inserting DimDataCollections... ", end='')

    data = pd.read_sql("SELECT \
            DataCollectionDimKey, \
            SourceSystemDataCollectionIdentifier, \
            SourceSystemName, \
            DataCollectionName, \
            DataCollectionDescription, \
            DataCollectionOpenDate, \
            DataCollectionCloseDate, \
            DataCollectionAcademicSchoolYear, \
            DataCollectionSchoolYear  \
        FROM analytics_config.ceds_DataCollectionDim;", conn_source)
    
    cursor_target = conn_target.cursor()
    
    for index, row in data.iterrows():
        row_insert = row[1:]

        cursor_target.execute(f"INSERT INTO RDS.DimDataCollections ( \
                SourceSystemDataCollectionIdentifier, \
                SourceSystemName, \
                DataCollectionName, \
                DataCollectionDescription, \
                DataCollectionOpenDate, \
                DataCollectionCloseDate, \
                DataCollectionAcademicSchoolYear, \
                DataCollectionSchoolYear) \
            VALUES ({question_marks(8)});", *row_insert)
        identity = cursor_target.execute("SELECT @@IDENTITY AS id;").fetchone()[0]
        data.at[index, 'DataCollectionDimId'] = int(identity)

    data = data[['DataCollectionDimId', 'DataCollectionDimKey']]

    conn_target.commit()

    print("Done!")

    return data
