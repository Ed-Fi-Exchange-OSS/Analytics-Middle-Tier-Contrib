# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

from datetime import datetime
import pandas as pd
from common.helpers import question_marks


def factK12_student_enrollment(dataframes = {}, conn_source, conn_target) -> None:
    try:
        query = ("SELECT \
                    FactK12StudentEnrollmentKey \
                    ,SchoolYearKey \
                    ,DataCollectionKey \
                    ,SeaKey \
                    ,IeuKey \
                    ,LeaKey \
                    ,K12SchoolKey \
                    ,K12StudentKey \
                    ,K12EnrollmentStatusKey \
                    ,EntryGradeLevelKey \
                    ,ExitGradeLevelKey \
                    ,EnrollmentEntryDateKey \
                    ,ProjectedGraduationDateKey \
                    ,K12DemographicKey \
                    ,IdeaStatusKey \
                    ,StudentCount \
                FROM analytics.ceds_FactK12StudentEnrollment;")
        
        factK12_student_enrollment_df = pd.read_sql(query, conn_source)
        
        # School Year Id
        school_year_df = dataframes["analytics.ceds_SchoolYearDim"]

        factK12_student_enrollment_df = pd.merge(
            left=factK12_student_enrollment_df,
            right=school_year_df,
            how="left",
            left_on="SchoolYearKey",
            right_on="SchoolYearKey"
        )

        # Sea Dim
        k12_seas_dim = dataframes["analytics.dim_seas"]
        factK12_student_enrollment_df = pd.merge(
            left=factK12_student_enrollment_df,
            right=k12_seas_dim,
            how="left",
            left_on="SeaKey",
            right_on="SeaDimKey"
        )

        # Ieu Dim
        k12_ieus_dim = dataframes["analytics.dim_ieus"]
        factK12_student_enrollment_df = pd.merge(
            left=factK12_student_enrollment_df,
            right=k12_ieus_dim,
            how="left",
            left_on="IeuKey",
            right_on="IeuDimKey"
        )

        # Lea Dim
        k12_leas_dim = dataframes["analytics.dim_leas"]
        factK12_student_enrollment_df = pd.merge(
            left=factK12_student_enrollment_df,
            right=k12_leas_dim,
            how="left",
            left_on="IeuKey",
            right_on="IeuDimKey"
        )

        # K12 School Dim
        k12_school_dim = dataframes["analytics.ceds_K12SchoolDim"]
        factK12_student_enrollment_df = pd.merge(
            left=factK12_student_enrollment_df,
            right=k12_school_dim,
            how="left",
            left_on="K12SchoolKey",
            right_on="K12SchoolKey"
        )

        # K12 Student Dim
        k12_student_dim = dataframes["analytics.ceds_K12StudentDim"]
        factK12_student_enrollment_df = pd.merge(
            left=factK12_student_enrollment_df,
            right=k12_student_dim,
            how="left",
            left_on="K12StudentKey",
            right_on="K12StudentKey"
        )

        # K12 Enrollment Status Dim
        k12_entollment_status_dim = dataframes["analytics.ceds_K12EnrollmentStatusDim"]
        factK12_student_enrollment_df = pd.merge(
            left=factK12_student_enrollment_df,
            right=k12_entollment_status_dim,
            how="left",
            left_on="K12EnrollmentStatusKey",
            right_on="K12EnrollmentStatusKey"
        )

        factK12_student_enrollment_df = factK12_student_enrollment_df.rename(columns={"id": "K12EnrollmentStatusId"})

        # K12 Entry Grade Level Dim
        k12_grade_level_dim = dataframes["analytics.ceds_GradeLevelDim"]
        factK12_student_enrollment_df = pd.merge(
            left=factK12_student_enrollment_df,
            right=k12_grade_level_dim,
            how="left",
            left_on="EntryGradeLevelKey",
            right_on="GradeLevelKey"
        )

        # K12 Exit Grade Level Dim
        k12_grade_level_dim = dataframes["analytics.ceds_GradeLevelDim"]
        factK12_student_enrollment_df = pd.merge(
            left=factK12_student_enrollment_df,
            right=k12_grade_level_dim,
            how="left",
            left_on="ExitGradeLevelKey",
            right_on="GradeLevelKey"
        )

        # Enrollment Entry Date
        enrollment_entry_date_df = dataframes["analytics.ceds_SchoolYearDim"]
        factK12_student_enrollment_df = pd.merge(
            left=factK12_student_enrollment_df,
            right=enrollment_entry_date_df,
            how="left",
            left_on="EnrollmentEntryDateKey",
            right_on="SchoolYearKey"
        )

        # Enrollment Exit Date
        enrollment_exit_date_df = dataframes["analytics.ceds_SchoolYearDim"]
        factK12_student_enrollment_df = pd.merge(
            left=factK12_student_enrollment_df,
            right=enrollment_exit_date_df,
            how="left",
            left_on="EnrollmentExitDateKey",
            right_on="SchoolYearKey"
        )

        # K12 Projected Graduation Date
        projected_graduation_date_df = dataframes["analytics.ceds_SchoolYearDim"]
        factK12_student_enrollment_df = pd.merge(
            left=factK12_student_enrollment_df,
            right=projected_graduation_date_df,
            how="left",
            left_on="ProjectedGraduationDateKey",
            right_on="K12SchoolKey"
        )
        
        # K12 Demographic Dim
        k12_demographic_dim = dataframes["analytics.ceds_K12DemographicDim"]
        factK12_student_enrollment_df = pd.merge(
            left=factK12_student_enrollment_df,
            right=k12_demographic_dim,
            how="left",
            left_on="K12DemographicKey",
            right_on="K12DemographicKey"
        )

        # K12 Idea Status Dim
        k12_idea_status_dim = dataframes["analytics.ceds_IdeaStatusDim"]
        factK12_student_enrollment_df = pd.merge(
            left=factK12_student_enrollment_df,
            right=k12_idea_status_dim,
            how="left",
            left_on="IdeaStatusKey",
            right_on="IdeaStatusKey"
        )

        cursor_target = conn_target.cursor()
        
        for index, row in factK12_student_enrollment_df.iterrows():
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
                    ,StudentCount \
                VALUES ({question_marks(14)})", 
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

    except Exception as error:
        print (error)
