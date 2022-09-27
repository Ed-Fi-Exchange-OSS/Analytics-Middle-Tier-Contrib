# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

from datetime import datetime
import pandas as pd
from common.helpers import question_marks


def factK12_student_enrollment(dataframes = {}, conn_source=None, conn_target=None) -> None:
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
        school_year_df = dataframes["dim_schools_years"]

        factK12_student_enrollment_df["dim_schools_years"] = '|'

        factK12_student_enrollment_df = pd.merge(
            left=factK12_student_enrollment_df,
            right=school_year_df,
            how="left",
            left_on="SchoolYearKey",
            right_on="SchoolYearKey",
            suffixes=('', 'right')
        )

        factK12_student_enrollment_df["dim_seas"] = '|'

        # Sea Dim
        k12_seas_dim = dataframes["dim_seas"]
        factK12_student_enrollment_df = pd.merge(
            left=factK12_student_enrollment_df,
            right=k12_seas_dim,
            how="left",
            left_on="SeaKey",
            right_on="SeaDimKey",
            suffixes=('', 'right')
        )

        factK12_student_enrollment_df["dim_ieus"] = '|'

        # Ieu Dim
        k12_ieus_dim = dataframes["dim_ieus"]
        factK12_student_enrollment_df = pd.merge(
            left=factK12_student_enrollment_df,
            right=k12_ieus_dim,
            how="left",
            left_on="IeuKey",
            right_on="IeuDimKey",
            suffixes=('', 'right')
        )

        factK12_student_enrollment_df["dim_leas"] = '|'

        # Lea Dim
        k12_leas_dim = dataframes["dim_leas"]
        factK12_student_enrollment_df = pd.merge(
            left=factK12_student_enrollment_df,
            right=k12_leas_dim,
            how="left",
            left_on="LeaKey",
            right_on="LeaKey",
            suffixes=('', 'right')
        )

        factK12_student_enrollment_df["dim_k12schools"] = '|'

        # K12 School Dim
        k12_school_dim = dataframes["dim_k12schools"]
        factK12_student_enrollment_df = pd.merge(
            left=factK12_student_enrollment_df,
            right=k12_school_dim,
            how="left",
            left_on="K12SchoolKey",
            right_on="K12SchoolKey",
            suffixes=('', 'right')
        )

        factK12_student_enrollment_df["dim_k12students"] = '|'

        # K12 Student Dim
        k12_student_dim = dataframes["dim_k12students"]
        factK12_student_enrollment_df = pd.merge(
            left=factK12_student_enrollment_df,
            right=k12_student_dim,
            how="left",
            left_on="K12StudentKey",
            right_on="K12StudentKey",
            suffixes=('', 'right')
        )

        factK12_student_enrollment_df["dim_K12enrollment_statuses"] = '|'

        # K12 Enrollment Status Dim
        k12_entollment_status_dim = dataframes["dim_K12enrollment_statuses"]
        factK12_student_enrollment_df = pd.merge(
            left=factK12_student_enrollment_df,
            right=k12_entollment_status_dim,
            how="left",
            left_on="K12EnrollmentStatusKey",
            right_on="K12EnrollmentStatusKey",
            suffixes=('', 'right')
        )

        factK12_student_enrollment_df["EntryGradeLevel"] = '|'

        # K12 Entry Grade Level Dim
        k12_grade_level_dim = dataframes["dim_grade_levels"]
        factK12_student_enrollment_df = pd.merge(
            left=factK12_student_enrollment_df,
            right=k12_grade_level_dim,
            how="left",
            left_on="EntryGradeLevelKey",
            right_on="GradeLevelKey",
            suffixes=('', 'right')
        )

        factK12_student_enrollment_df["ExitGradeLevel"] = '|'

        # K12 Exit Grade Level Dim
        k12_grade_level_dim = dataframes["dim_grade_levels"]
        factK12_student_enrollment_df = pd.merge(
            left=factK12_student_enrollment_df,
            right=k12_grade_level_dim,
            how="left",
            left_on="ExitGradeLevelKey",
            right_on="GradeLevelKey",
            suffixes=('', 'right')
        )

        factK12_student_enrollment_df["EnrollmentEntryDate"] = '|'

        # Enrollment Entry Date
        enrollment_entry_date_df = dataframes["dim_schools_years"]
        factK12_student_enrollment_df = pd.merge(
            left=factK12_student_enrollment_df,
            right=enrollment_entry_date_df,
            how="left",
            left_on="EnrollmentEntryDateKey",
            right_on="SchoolYearKey",
            suffixes=('', 'right')
        )

        factK12_student_enrollment_df["EnrollmentExitDate"] = '|'

        # Enrollment Exit Date
        enrollment_exit_date_df = dataframes["dim_schools_years"]
        factK12_student_enrollment_df = pd.merge(
            left=factK12_student_enrollment_df,
            right=enrollment_exit_date_df,
            how="left",
            left_on="EnrollmentExitDateKey",
            right_on="SchoolYearKey",
            suffixes=('', 'right')
        )

        factK12_student_enrollment_df["ProjectedGraduationDate"] = '|'

        # K12 Projected Graduation Date
        projected_graduation_date_df = dataframes["dim_schools_years"]
        factK12_student_enrollment_df = pd.merge(
            left=factK12_student_enrollment_df,
            right=projected_graduation_date_df,
            how="left",
            left_on="ProjectedGraduationDateKey",
            right_on="K12SchoolKey",
            suffixes=('', 'right')
        )

        factK12_student_enrollment_df["dim_K12demographics"] = '|'
        
        # K12 Demographic Dim
        k12_demographic_dim = dataframes["dim_K12demographics"]
        factK12_student_enrollment_df = pd.merge(
            left=factK12_student_enrollment_df,
            right=k12_demographic_dim,
            how="left",
            left_on="K12DemographicKey",
            right_on="K12DemographicKey",
            suffixes=('', 'right')
        )

        factK12_student_enrollment_df["dim_idea_statuses"] = '|'

        # K12 Idea Status Dim
        k12_idea_status_dim = dataframes["dim_idea_statuses"]
        factK12_student_enrollment_df = pd.merge(
            left=factK12_student_enrollment_df,
            right=k12_idea_status_dim,
            how="left",
            left_on="IdeaStatusKey",
            right_on="IdeaStatusKey",
            suffixes=('', 'right')
        )

        factK12_student_enrollment_df.to_csv("C:/GAP/EdFi/BIA-1210/factK12_student_enrollment_df.csv")

        # cursor_target = conn_target.cursor()
        
        # for index, row in factK12_student_enrollment_df.iterrows():
        #     cursor_target.execute(f"INSERT INTO RDS.FactK12ProgramParticipations ( \
        #             SchoolYearId \
        #             ,DataCollectionId \
        #             ,SeaId \
        #             ,IeuId \
        #             ,LeaId \
        #             ,K12SchoolId \
        #             ,K12StudentId \
        #             ,K12EnrollmentStatusId \
        #             ,EntryGradeLevelId \
        #             ,ExitGradeLevelId \
        #             ,EnrollmentEntryDateId \
        #             ,EnrollmentExitDateId \
        #             ,ProjectedGraduationDateId \
        #             ,K12DemographicId \
        #             ,IdeaStatusId \
        #             ,StudentCount \
        #         VALUES ({question_marks(14)})", 
        #             row.SchoolYearId
        #             ,1
        #             ,row.SeaKey
        #             ,row.IeuKey
        #             ,row.LeaKey
        #             ,row.K12SchoolId
        #             ,row.K12StudentId
        #             ,1
        #             ,row.EntryGradeLevelId
        #             ,row.ExitGradeLevelId
        #             ,row.EnrollmentEntryDateKey
        #             ,row.EnrollmentExitDateKey
        #             ,1
        #             ,1
        #             ,1
        #             ,row.StudentCount
        #     )

        # conn_target.commit()

    except Exception as error:
        print (error)
