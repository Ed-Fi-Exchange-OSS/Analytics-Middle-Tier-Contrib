# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

from datetime import datetime
import pyodbc 
# import json
import pandas as pd

def factK12_student_enrollment(dataframes = {}, views_info = [], config = None) -> None:
    conn_source = pyodbc.Connection
    # conn_target = pyodbc.Connection
    try:
        conn_source = pyodbc.connect(
            f'Driver={"SQL Server"};Server={config["Source"]["Server"]};Database={config["Source"]["Database"]};Trusted_Connection={config["Source"]["Trusted_Connection"]};')
        query = ("SELECT "\
                    "[FactK12StudentEnrollmentKey]" \
                    ",[SchoolYearKey]" \
                    ",[DataCollectionKey]" \
                    ",[SeaKey]" \
                    ",[IeuKey]" \
                    ",[LeaKey]" \
                    ",[K12SchoolKey]" \
                    ",[K12StudentKey]" \
                    ",[K12EnrollmentStatusKey]" \
                    ",[EntryGradeLevelKey]" \
                    ",[ExitGradeLevelKey]" \
                    ",[EnrollmentEntryDateKey]" \
                    ",[ProjectedGraduationDateKey]" \
                    ",[K12DemographicKey]" \
                    ",[IdeaStatusKey]" \
                    ",[StudentCount]"\
                "FROM analytics.ceds_FactK12StudentEnrollment;")
        
        factK12_student_enrollment_df = pd.read_sql(query, conn_source)
        
        # School Year Id
        school_year_df = dataframes["analytics.ceds_SchoolYearDim"]
        school_year_df = school_year_df[['SchoolYearKey','id']]

        factK12_student_enrollment_df = pd.merge(
            left=factK12_student_enrollment_df,
            right=school_year_df,
            how="left",
            left_on="SchoolYearKey",
            right_on="SchoolYearKey"
        )

        factK12_student_enrollment_df = factK12_student_enrollment_df.rename(columns={"id": "SchoolYearId"})

        # SeaId - Pending #

        # IeuId - Pending #

        # LeaId - Pending #

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

        # K12 Enrollment Status Dim
        k12_entollment_status_dim = dataframes["analytics.ceds_K12EnrollmentStatusDim"]
        k12_entollment_status_dim = k12_entollment_status_dim[['K12EnrollmentStatusKey','id']]
        
        factK12_program_participation_df = pd.merge(
            left=factK12_program_participation_df,
            right=k12_entollment_status_dim,
            how="left",
            left_on="K12EnrollmentStatusKey",
            right_on="K12EnrollmentStatusKey"
        )

        factK12_program_participation_df = factK12_program_participation_df.rename(columns={"id": "K12EnrollmentStatusId"})

        # K12 Entry Grade Level Dim
        k12_grade_level_dim = dataframes["analytics.ceds_GradeLevelDim"]
        k12_grade_level_dim = k12_grade_level_dim[['GradeLevelKey','id']]
        
        factK12_program_participation_df = pd.merge(
            left=factK12_program_participation_df,
            right=k12_grade_level_dim,
            how="left",
            left_on="EntryGradeLevelKey",
            right_on="GradeLevelKey"
        )

        factK12_program_participation_df = factK12_program_participation_df.rename(columns={"id": "EntryGradeLevelId"})

        # K12 Exit Grade Level Dim
        k12_grade_level_dim = dataframes["analytics.ceds_GradeLevelDim"]
        k12_grade_level_dim = k12_grade_level_dim[['GradeLevelKey','id']]
        
        factK12_program_participation_df = pd.merge(
            left=factK12_program_participation_df,
            right=k12_grade_level_dim,
            how="left",
            left_on="ExitGradeLevelKey",
            right_on="GradeLevelKey"
        )

        factK12_program_participation_df = factK12_program_participation_df.rename(columns={"id": "ExitGradeLevelId"})

        # K12 Enrollment Entry Date
        school_year_df = dataframes["analytics.ceds_SchoolYearDim"]
        school_year_df = school_year_df[['SchoolYearKey','id']]

        factK12_student_enrollment_df = pd.merge(
            left=factK12_student_enrollment_df,
            right=school_year_df,
            how="left",
            left_on="EnrollmentEntryDateKey",
            right_on="SchoolYearKey"
        )

        factK12_student_enrollment_df = factK12_student_enrollment_df.rename(columns={"id": "EnrollmentEntryDateId"})

        # EnrollmentExitDateId Pending #

        # K12 Projected Graduation Date
        school_year_df = dataframes["analytics.ceds_SchoolYearDim"]
        school_year_df = school_year_df[['SchoolYearKey','id']]
        
        factK12_program_participation_df = pd.merge(
            left=factK12_program_participation_df,
            right=school_year_df,
            how="left",
            left_on="ProjectedGraduationDateKey",
            right_on="K12SchoolKey"
        )

        factK12_program_participation_df = factK12_program_participation_df.rename(columns={"id": "ProjectedGraduationDateId"})
        
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

        conn_target = pyodbc.connect(
            f'Driver={"SQL Server"};Server={config["Target"]["Server"]};Database={config["Target"]["Database"]};Trusted_Connection={config["Target"]["Trusted_Connection"]};')

        cursor_target = conn_target.cursor()
        
        for index, row in factK12_program_participation_df.iterrows():
            cursor_target.execute(f"INSERT INTO RDS.FactK12ProgramParticipations (" \
                    "[SchoolYearId]" \
                    ",[DateId]" \
                    ",[DataCollectionId]" \
                    ",[SeaId]" \
                    ",[IeuId]" \
                    ",[LeaId]" \
                    ",[K12SchoolId]" \
                    ",[K12ProgramTypeId]" \
                    ",[K12StudentId]" \
                    ",[K12DemographicId]" \
                    ",[IdeaStatusId]" \
                    ",[ProgramParticipationStartDateId]" \
                    ",[ProgramParticipationExitDateId]" \
                    ",[StudentCount]" \
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
