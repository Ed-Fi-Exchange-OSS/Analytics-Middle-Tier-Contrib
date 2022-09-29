# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

import pyodbc

from common.config import get_configuration
from dummy_values.main import insert_dummy_values

# Dim views
from transfers.dim_schools_years import dim_schools_years
from transfers.dim_data_collections import dim_data_collections
from transfers.dim_seas import dim_seas
from transfers.dim_ieus import dim_ieus
from transfers.dim_leas import dim_leas
from transfers.dim_k12schools import dim_k12schools
from transfers.dim_k12students import dim_k12students
from transfers.dim_grade_levels import dim_grade_levels
from transfers.dim_idea_statuses import dim_idea_statuses
from transfers.dim_K12enrollment_statuses import dim_K12enrollment_statuses
from transfers.dim_k12program_types import dim_k12program_types
from transfers.dim_K12demographics import dim_K12demographics
from transfers.dim_races import dim_races

# Fact views
from transfers.factK12_program_participation import factK12_program_participation
from transfers.factK12_student_enrollment import factK12_student_enrollment

import warnings

warnings.filterwarnings('ignore')

if __name__ == "__main__":
    dataFrames = {}
    config = get_configuration()
    insert_dummy_values(config)

    try:
        conn_source = pyodbc.connect(
            f'Driver={"SQL Server"};Server={config["OdsConfig"]["Server"]};Database={config["OdsConfig"]["Database"]};Trusted_Connection={config["OdsConfig"]["Trusted_Connection"]};')

        conn_target = pyodbc.connect(
            f'Driver={"SQL Server"};Server={config["CedsConfig"]["Server"]};Database={config["CedsConfig"]["Database"]};Trusted_Connection={config["CedsConfig"]["Trusted_Connection"]};')

        dataFrames["dim_schools_years"] = dim_schools_years(conn_source, conn_target)
        dataFrames["dim_data_collections"] = dim_data_collections(conn_source, conn_target)
        dataFrames["dim_seas"] = dim_seas(conn_source, conn_target)
        dataFrames["dim_ieus"] = dim_ieus(conn_source, conn_target)
        dataFrames["dim_leas"] = dim_leas(conn_source, conn_target)
        dataFrames["dim_k12schools"] = dim_k12schools(conn_source, conn_target)
        dataFrames["dim_k12students"] = dim_k12students(conn_source, conn_target)
        dataFrames["dim_grade_levels"] = dim_grade_levels(conn_source, conn_target)
        dataFrames["dim_idea_statuses"] = dim_idea_statuses(conn_source, conn_target)
        dataFrames["dim_K12enrollment_statuses"] = dim_K12enrollment_statuses(conn_source, conn_target)
        dataFrames["dim_k12program_types"] = dim_k12program_types(conn_source, conn_target)
        dataFrames["dim_K12demographics"] = dim_K12demographics(conn_source, conn_target)
        dataFrames["dim_races"] = dim_races(conn_source, conn_target)

        # fact tables:
        factK12_program_participation(dataFrames, conn_source, conn_target)
        factK12_student_enrollment(dataFrames, conn_source, conn_target)

    except Exception as error:
        print(error)

    finally:
        conn_source.close()
        conn_target.close()
