# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

import pandas as pd
from common.helpers import question_marks


def dim_K12demographics(conn_source, conn_target) -> pd.DataFrame:
    
    print("Inserting DimK12Demographics... ", end = '')

    data = pd.read_sql("SELECT  \
            K12DemographicKey, \
            EconomicDisadvantageStatusCode, \
            EconomicDisadvantageStatusDescription, \
            EconomicDisadvantageStatusEdFactsCode, \
            HomelessnessStatusCode, \
            HomelessnessStatusDescription, \
            HomelessnessStatusEdFactsCode, \
            EnglishLearnerStatusCode, \
            EnglishLearnerStatusDescription, \
            EnglishLearnerStatusEdFactsCode, \
            MigrantStatusCode, \
            MigrantStatusDescription, \
            MigrantStatusEdFactsCode, \
            MilitaryConnectedStudentIndicatorCode, \
            MilitaryConnectedStudentIndicatorDescription, \
            MilitaryConnectedStudentIndicatorEdFactsCode, \
            HomelessPrimaryNighttimeResidenceCode, \
            HomelessPrimaryNighttimeResidenceDescription, \
            HomelessPrimaryNighttimeResidenceEdFactsCode, \
            HomelessUnaccompaniedYouthStatusCode, \
            HomelessUnaccompaniedYouthStatusDescription, \
            HomelessUnaccompaniedYouthStatusEdFactsCode, \
            SexCode, \
            SexDescription, \
            SexEdFactsCode  \
        FROM analytics.ceds_K12DemographicDim;", conn_source)

    cursor_target = conn_target.cursor()

    for index, row in data.iterrows():
        row_insert = row[1:]

        cursor_target.execute(f"INSERT INTO RDS.DimK12Demographics ( \
            EconomicDisadvantageStatusCode, \
            EconomicDisadvantageStatusDescription, \
            EconomicDisadvantageStatusEdFactsCode, \
            HomelessnessStatusCode, \
            HomelessnessStatusDescription, \
            HomelessnessStatusEdFactsCode, \
            EnglishLearnerStatusCode, \
            EnglishLearnerStatusDescription, \
            EnglishLearnerStatusEdFactsCode, \
            MigrantStatusCode, \
            MigrantStatusDescription, \
            MigrantStatusEdFactsCode, \
            MilitaryConnectedStudentIndicatorCode, \
            MilitaryConnectedStudentIndicatorDescription, \
            MilitaryConnectedStudentIndicatorEdFactsCode, \
            HomelessPrimaryNighttimeResidenceCode, \
            HomelessPrimaryNighttimeResidenceDescription, \
            HomelessPrimaryNighttimeResidenceEdFactsCode, \
            HomelessUnaccompaniedYouthStatusCode, \
            HomelessUnaccompaniedYouthStatusDescription, \
            HomelessUnaccompaniedYouthStatusEdFactsCode, \
            SexCode, \
            SexDescription, \
            SexEdFactsCode) VALUES ({question_marks(24)});", *row_insert)
        identity = cursor_target.execute("SELECT @@IDENTITY AS id;").fetchone()[0]
        data.at[index, 'id'] = int(identity)

    data = data[['id', 'K12DemographicKey']]

    conn_target.commit()
    
    print("Done!")

    return data
