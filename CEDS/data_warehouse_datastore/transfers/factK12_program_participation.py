# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

from datetime import datetime
import pandas as pd
from common.helpers import question_marks


def factK12_program_participation(dataframes={}, conn_source=None, conn_target=None) -> None:

    print("Inserting FactK12ProgramParticipations... ", end='')

    try:
        query = ("SELECT \
                    FactK12ProgramParticipationKey \
                    ,SchoolYearKey \
                    ,DateKey \
                    ,DataCollectionKey \
                    ,SeaKey \
                    ,IeuKey \
                    ,LeaKey \
                    ,K12SchoolKey \
                    ,K12ProgramTypeKey \
                    ,K12StudentKey \
                    ,K12DemographicKey \
                    ,IdeaStatusKey \
                    ,ProgramParticipationStartDateKey \
                    ,ProgramParticipationExitDateKey \
                    ,StudentCount \
                FROM analytics.ceds_FactK12ProgramParticipation;")

        factK12_program_participation_df = pd.read_sql(query, conn_source)

        # School Year Dim
        school_year_df = dataframes["dim_schools_years"]

        factK12_program_participation_df = pd.merge(
            left=factK12_program_participation_df,
            right=school_year_df,
            how="left",
            left_on="SchoolYearKey",
            right_on="SchoolYearKey",
            suffixes=('', 'right')
        )

        # Sea Dim
        k12_seas_dim = dataframes["dim_seas"]
        factK12_program_participation_df = pd.merge(
            left=factK12_program_participation_df,
            right=k12_seas_dim,
            how="left",
            left_on="SeaKey",
            right_on="SeaDimKey",
            suffixes=('', 'right')
        )

        # Ieu Dim
        k12_ieus_dim = dataframes["dim_ieus"]
        factK12_program_participation_df = pd.merge(
            left=factK12_program_participation_df,
            right=k12_ieus_dim,
            how="left",
            left_on="IeuKey",
            right_on="IeuDimKey",
            suffixes=('', 'right')
        )

        # Lea Dim
        k12_leas_dim = dataframes["dim_leas"]
        factK12_program_participation_df = pd.merge(
            left=factK12_program_participation_df,
            right=k12_leas_dim,
            how="left",
            left_on="LeaKey",
            right_on="LeaKey",
            suffixes=('', 'right')
        )

        # K12 School Dim
        k12_school_dim = dataframes["dim_k12schools"]
        factK12_program_participation_df = pd.merge(
            left=factK12_program_participation_df,
            right=k12_school_dim,
            how="left",
            left_on="K12SchoolKey",
            right_on="K12SchoolKey",
            suffixes=('', 'right')
        )

        # Program Type
        k12_program_type_dim = dataframes["dim_k12program_types"]
        factK12_program_participation_df = pd.merge(
            left=factK12_program_participation_df,
            right=k12_program_type_dim,
            how="left",
            left_on="K12ProgramTypeKey",
            right_on="K12ProgramTypeKey",
            suffixes=('', 'right')
        )

        # K12 Student Dim
        k12_student_dim = dataframes["dim_k12students"]
        factK12_program_participation_df = pd.merge(
            left=factK12_program_participation_df,
            right=k12_student_dim,
            how="left",
            left_on="K12StudentKey",
            right_on="K12StudentKey",
            suffixes=('', 'right')
        )

        # K12 Demographic Dim
        k12_demographic_dim = dataframes["dim_K12demographics"]
        
        factK12_program_participation_df = pd.merge(
            left=factK12_program_participation_df,
            right=k12_demographic_dim,
            how="left",
            left_on="K12DemographicKey",
            right_on="K12DemographicKey",
            suffixes=('', 'right')
        )

        # K12 Idea Status Dim
        k12_idea_status_dim = dataframes["dim_idea_statuses"]
        
        factK12_program_participation_df = pd.merge(
            left=factK12_program_participation_df,
            right=k12_idea_status_dim,
            how="left",
            left_on="IdeaStatusKey",
            right_on="IdeaStatusKey",
            suffixes=('', 'right')
        )

        factK12_program_participation_df.to_csv("C:/GAP/EdFi/BIA-1210/factK12_program_participation_df.csv")

        #  Program Participation Start Date Id
        # factK12_program_participation_df["ProgramParticipationStartDateId"] = int(datetime.strptime(factK12_program_participation_df["ProgramParticipationStartDateKey"], '%m/%d/%y').timestamp())

        #  Program Participation Exit Date Id
        # factK12_program_participation_df["ProgramParticipationExitDateId"] = int(datetime.strptime(factK12_program_participation_df["ProgramParticipationExitDateKey"], '%m/%d/%y').timestamp())

        cursor_target = conn_target.cursor()

        for index, row in factK12_program_participation_df.iterrows():

            # row.ProgramParticipationStartDateId = int(datetime.strptime(row.ProgramParticipationStartDateKey, '%m/%d/%y').timestamp())
            row.ProgramParticipationStartDateId = int(datetime.strptime(row.ProgramParticipationStartDateKey, '%Y-%m-%d').timestamp())
            # row.ProgramParticipationExitDateId = int(datetime.strptime(row.ProgramParticipationExitDateKey, '%m/%d/%y').timestamp())
            row.ProgramParticipationExitDateId = int(datetime.strptime(row.ProgramParticipationExitDateKey, '%Y-%m-%d').timestamp())

            cursor_target.execute(f"INSERT INTO RDS.FactK12ProgramParticipations ( \
                    SchoolYearId \
                    ,DateId \
                    ,DataCollectionId \
                    ,SeaId \
                    ,IeuId \
                    ,LeaId \
                    ,K12SchoolId \
                    ,K12ProgramTypeId \
                    ,K12StudentId \
                    ,K12DemographicId \
                    ,IdeaStatusId \
                    ,ProgramParticipationStartDateId \
                    ,ProgramParticipationExitDateId \
                    ,StudentCount) \
                VALUES ({question_marks(14)})",
                    row.SchoolYearId,
                    1,
                    1,
                    row.SeaDimId,
                    row.IeuDimId,
                    row.LeaId,
                    row.K12SchoolId,
                    row.K12ProgramTypeId,
                    row.K12StudentId,
                    1,
                    row.IdeaStatusId,
                    row.ProgramParticipationStartDateId,
                    row.ProgramParticipationExitDateId,
                    row.StudentCount
            )

        conn_target.commit()

        print("Done!")

    except Exception as error:
        print(error)
