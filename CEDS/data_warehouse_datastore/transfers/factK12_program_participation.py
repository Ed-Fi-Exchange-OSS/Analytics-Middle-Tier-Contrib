# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

from datetime import datetime
import pandas as pd
from common.helpers import question_marks


def factK12_program_participation(dataframes = {}, conn_source, conn_target) -> None:
    try:
        query = ("SELECT \
                    [FactK12ProgramParticipationKey] \
                    ,[SchoolYearKey] \
                    ,[DateKey] \
                    ,[DataCollectionKey] \
                    ,[SeaKey] \
                    ,[IeuKey] \
                    ,[LeaKey] \
                    ,[K12SchoolKey] \
                    ,[K12ProgramTypeKey], \
                    [K12StudentKey] \
                    ,[K12DemographicKey] \
                    ,[IdeaStatusKey] \
                    ,[ProgramParticipationStartDateKey] \
                    ,[ProgramParticipationExitDateKey] \
                    ,[StudentCount] \
                FROM analytics.ceds_FactK12ProgramParticipation;")
        
        factK12_program_participation_df = pd.read_sql(query, conn_source)
        
        # School Year Id
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

        #  Date Id
        factK12_program_participation_df["DateId"] = int(datetime.strptime(factK12_program_participation_df["DateKey"], '%m/%d/%y').timestamp())

        # SeaId - Pending #

        # IeuId - Pending #

        # LeaId - Pending #

        # K12 School Dim
        k12_school_dim = dataframes["analytics.ceds_K12SchoolDim"]
        k12_school_dim = k12_school_dim[['K12SchoolKey', 'id']]
        
        factK12_program_participation_df = pd.merge(
            left=factK12_program_participation_df,
            right=k12_school_dim,
            how="left",
            left_on="K12SchoolKey",
            right_on="K12SchoolKey"
        )

        factK12_program_participation_df = factK12_program_participation_df.rename(columns={"id": "K12SchoolId"})

        # K12 Program Type Dim
        k12_programtypes_dim = dataframes["analytics.ceds_K12ProgramTypeDim"]
        k12_programtypes_dim = k12_programtypes_dim[['K12ProgramTypeKey','id']]
        
        factK12_program_participation_df = pd.merge(
            left=factK12_program_participation_df,
            right=k12_programtypes_dim,
            how="left",
            left_on="K12ProgramTypeKey",
            right_on="K12ProgramTypeKey"
        )

        factK12_program_participation_df = factK12_program_participation_df.rename(columns={"id": "K12ProgramTypeId"})

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

        # K12 Demographic Dim
        k12_demographic_dim = dataframes["analytics.ceds_K12DemographicDim"]
        k12_demographic_dim = k12_demographic_dim[['K12DemographicKey','id']]
        
        factK12_program_participation_df = pd.merge(
            left=factK12_program_participation_df,
            right=k12_demographic_dim,
            how="left",
            left_on="K12DemographicKey",
            right_on="K12DemographicKey"
        )

        factK12_program_participation_df = factK12_program_participation_df.rename(columns={"id": "K12DemographicId"})

        # K12 Idea Status Dim
        k12_idea_status_dim = dataframes["analytics.ceds_IdeaStatusDim"]
        k12_idea_status_dim = k12_idea_status_dim[['IdeaStatusKey','id']]
        
        factK12_program_participation_df = pd.merge(
            left=factK12_program_participation_df,
            right=k12_idea_status_dim,
            how="left",
            left_on="IdeaStatusKey",
            right_on="IdeaStatusKey"
        )

        factK12_program_participation_df = factK12_program_participation_df.rename(columns={"id": "IdeaStatusId"})

        #  Program Participation Start Date Id
        factK12_program_participation_df["ProgramParticipationStartDateId"] = int(datetime.strptime(factK12_program_participation_df["ProgramParticipationStartDateKey"], '%m/%d/%y').timestamp())
        
        #  Program Participation Exit Date Id
        factK12_program_participation_df["ProgramParticipationExitDateId"] = int(datetime.strptime(factK12_program_participation_df["ProgramParticipationExitDateKey"], '%m/%d/%y').timestamp())
        
        cursor_target = conn_target.cursor()
        
        for index, row in factK12_program_participation_df.iterrows():
            cursor_target.execute(f"INSERT INTO RDS.FactK12ProgramParticipations ( \
                    [SchoolYearId] \
                    ,[DateId] \
                    ,[DataCollectionId] \
                    ,[SeaId] \
                    ,[IeuId] \
                    ,[LeaId] \
                    ,[K12SchoolId] \
                    ,[K12ProgramTypeId] \
                    ,[K12StudentId] \
                    ,[K12DemographicId] \
                    ,[IdeaStatusId] \
                    ,[ProgramParticipationStartDateId] \
                    ,[ProgramParticipationExitDateId] \
                    ,[StudentCount] \
                VALUES ({question_marks(14)})",
                    row.SchoolYearId,
                    row.DateKey,
                    row.DataCollectionKey,
                    row.SeaKey,
                    row.IeuKey,
                    row.LeaKey,
                    row.K12SchoolId,
                    row.K12ProgramTypeKey,
                    row.K12StudentId,
                    row.K12DemographicKey,
                    row.IdeaStatusKey,
                    row.ProgramParticipationStartDateKey,
                    row.ProgramParticipationExitDateKey,
                    row.StudentCount
            )

        conn_target.commit()

    except Exception as error:
        print(error)
        
    