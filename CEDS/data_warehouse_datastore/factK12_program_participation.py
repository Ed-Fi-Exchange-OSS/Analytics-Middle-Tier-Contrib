# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

import pyodbc 
import json
import pandas as pd

def factK12_program_participation(dataframes = {}, views_info = [], config = None) -> None:
    conn_source = pyodbc.Connection
    # conn_target = pyodbc.Connection
    try:
        conn_source = pyodbc.connect(
            f'Driver={"SQL Server"};Server={config["Source"]["Server"]};Database={config["Source"]["Database"]};Trusted_Connection={config["Source"]["Trusted_Connection"]};')
        query = ("SELECT "\
                    "[FactK12ProgramParticipationKey],[SchoolYearKey],[DateKey],[DataCollectionKey],[SeaKey],[IeuKey],[LeaKey],[K12SchoolKey],[K12ProgramTypeKey],"\
                    "[K12StudentKey],[K12DemographicKey],[IdeaStatusKey],[ProgramParticipationStartDateKey],[ProgramParticipationExitDateKey],[StudentCount] "\
                "FROM analytics.ceds_FactK12ProgramParticipation;")
        
        factK12_program_participation_df = pd.read_sql(query, conn_source)
        
        factK12_program_participation_df.to_csv("./ceds_FactK12ProgramParticipation.csv")

        # School Year map
        school_year_df = dataframes["analytics.ceds_SchoolYearDim"]

        factK12_program_participation_df = pd.merge(
            left=factK12_program_participation_df,
            right=school_year_df,
            how="left",
            left_on="SchoolYearKey",
            right_on="SchoolYearKey"
        )

        factK12_program_participation_df = factK12_program_participation_df.drop(columns=["SchoolYearKey","SchoolYear","SessionBeginDate","SessionEndDate"])
        factK12_program_participation_df = factK12_program_participation_df.rename(columns={"id": "SchoolYearId"})

        factK12_program_participation_df.to_csv("./factK12_program_participation_df1.csv")

        # K12 School Dim
        k12_school_dim = dataframes["analytics.ceds_K12SchoolDim"]
        k12_school_dim = k12_school_dim[['K12SchoolKey','id']]
        
        factK12_program_participation_df = pd.merge(
            left=factK12_program_participation_df,
            right=k12_school_dim,
            how="left",
            left_on="K12SchoolKey",
            right_on="K12SchoolKey"
        )

        factK12_program_participation_df = factK12_program_participation_df.rename(columns={"id": "K12SchoolId"})

        factK12_program_participation_df.to_csv("./factK12_program_participation_df2.csv")

        # K12 School Dim
        k12_programtypes_dim = dataframes["analytics.ceds_K12ProgramTypeDim"]
        k12_programtypes_dim = k12_school_dim[['K12ProgramTypeKey','id']]
        
        factK12_program_participation_df = pd.merge(
            left=factK12_program_participation_df,
            right=k12_programtypes_dim,
            how="left",
            left_on="K12ProgramTypeKey",
            right_on="K12ProgramTypeKey"
        )

        factK12_program_participation_df = factK12_program_participation_df.rename(columns={"id": "K12ProgramTypeId"})

        factK12_program_participation_df.to_csv("./factK12_program_participation_df3.csv")

        # K12 Student Dim
        k12_student_dim = dataframes["analytics.ceds_K12StudentDim"]
        k12_student_dim = k12_student_dim[['K12StudentKey','id']]
        
        factK12_program_participation_df = pd.merge(
            left=factK12_program_participation_df,
            right=k12_student_dim,
            how="left",
            left_on="K12StudentKey",
            right_on="K12StudentKey"
        )

        factK12_program_participation_df = factK12_program_participation_df.rename(columns={"id": "K12StudentId"})

        factK12_program_participation_df.to_csv("./factK12_program_participation_df4.csv")

        conn_target = pyodbc.connect(
            f'Driver={"SQL Server"};Server={config["Target"]["Server"]};Database={config["Target"]["Database"]};Trusted_Connection={config["Target"]["Trusted_Connection"]};')

        cursor_target = conn_target.cursor()
        
        for index, row in factK12_program_participation_df.iterrows():

            cursor_target.execute(f"INSERT INTO [analytics].[ceds_FactK12ProgramParticipation] (" \
                    "[SchoolYearKey]" \
                    ",[DateKey]" \
                    ",[DataCollectionKey]" \
                    ",[SeaKey]" \
                    ",[IeuKey]" \
                    ",[LeaKey]" \
                    ",[K12SchoolKey]" \
                    ",[K12ProgramTypeKey]" \
                    ",[K12StudentKey]" \
                    ",[K12DemographicKey]" \
                    ",[IdeaStatusKey]" \
                    ",[ProgramParticipationStartDateKey]" \
                    ",[ProgramParticipationExitDateKey]" \
                    ",[StudentCount])" \
                "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)", 
                    row.SchoolYearId
                    ,row.DateKey
                    ,row.DataCollectionKey
                    ,row.SeaKey
                    ,row.IeuKey
                    ,row.LeaKey
                    ,row.K12SchoolId
                    ,row.K12ProgramTypeKey
                    ,row.K12StudentId
                    ,row.K12DemographicKey
                    ,row.IdeaStatusKey
                    ,row.ProgramParticipationStartDateKey
                    ,row.ProgramParticipationExitDateKey
                    ,row.StudentCount
                    )

        conn_target.commit()
        cursor_target.close()

    except Exception as error:
        print (error)
        
    finally:
        conn_source.close()
        conn_target.close()
