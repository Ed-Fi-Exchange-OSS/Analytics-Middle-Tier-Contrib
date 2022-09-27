# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

import pandas as pd
from common.helpers import question_marks


def dim_idea_statuses(conn_source, conn_target) -> pd.DataFrame:

    print("Inserting DimIdeaStatuses... ", end='')

    data = pd.read_sql("SELECT \
            IdeaStatusKey, \
            SpecialEducationExitReasonCode, \
            SpecialEducationExitReasonDescription, \
            SpecialEducationExitReasonEdFactsCode, \
            PrimaryDisabilityTypeCode, \
            PrimaryDisabilityTypeDescription, \
            PrimaryDisabilityTypeEdFactsCode, \
            IdeaEducationalEnvironmentForSchoolAgeCode, \
            IdeaEducationalEnvironmentForSchoolAgeDescription, \
            IdeaEducationalEnvironmentForSchoolAgeEdFactsCode,  \
            IdeaEducationalEnvironmentForEarlyChildhoodCode, \
            IdeaEducationalEnvironmentForEarlyChildhoodDescription, \
            IdeaEducationalEnvironmentForEarlyChildhoodEdFactsCode, \
            IdeaIndicatorCode, \
            IdeaIndicatorDescription, \
            IdeaIndicatorEdFactsCode \
        FROM analytics.ceds_IdeaStatusDim;", conn_source)

    cursor_target = conn_target.cursor()

    for index, row in data.iterrows():
        row_insert = row[1:]

        cursor_target.execute(f"INSERT INTO RDS.DimIdeaStatuses ( \
            SpecialEducationExitReasonCode, \
            SpecialEducationExitReasonDescription, \
            SpecialEducationExitReasonEdFactsCode, \
            PrimaryDisabilityTypeCode, \
            PrimaryDisabilityTypeDescription, \
            PrimaryDisabilityTypeEdFactsCode, \
            IdeaEducationalEnvironmentForSchoolAgeCode, \
            IdeaEducationalEnvironmentForSchoolAgeDescription, \
            IdeaEducationalEnvironmentForSchoolAgeEdFactsCode, \
            IdeaEducationalEnvironmentForEarlyChildhoodCode, \
            IdeaEducationalEnvironmentForEarlyChildhoodDescription, \
            IdeaEducationalEnvironmentForEarlyChildhoodEdFactsCode, \
            IdeaIndicatorCode, \
            IdeaIndicatorDescription, \
            IdeaIndicatorEdFactsCode) VALUES ({question_marks(15)});", *row_insert)
        identity = cursor_target.execute("SELECT @@IDENTITY AS id;").fetchone()[0]
        data.at[index, 'IdeaStatusId'] = int(identity)

    data = data[['IdeaStatusId', 'IdeaStatusKey']]

    conn_target.commit()

    print("Done!")

    return data
