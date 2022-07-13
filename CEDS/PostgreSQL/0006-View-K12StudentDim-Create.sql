-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.

-- Drop ceds_FactK12StudentEnrollments first because it uses ceds_K12StudentDim
DROP VIEW IF EXISTS analytics.ceds_FactK12StudentEnrollments;

DROP VIEW IF EXISTS analytics.ceds_K12StudentDim;

CREATE OR REPLACE VIEW analytics.ceds_K12StudentDim AS
    SELECT
        CONCAT(Student.StudentUniqueId, '-', StudentSchoolAssociation.SchoolId, '-', StudentSchoolAssociation.ClassOfSchoolYear) as K12StudentKey,
        CONCAT(Student.StudentUniqueId, '-', StudentSchoolAssociation.SchoolId) AS StudentSchoolKey,
        Student.BirthDate,
        StudentSchoolAssociation.ClassOfSchoolYear AS Cohort,
        Student.FirstName,
        Student.LastSurname,
        COALESCE(Student.MiddleName, '') AS MiddleName,
        Student.StudentUniqueId AS StudentIdentifierState,
        '' AS RecordStartDateTime,
        '' AS RecordEndDateTime,
        (
		SELECT MAX(MaxLastModifiedDate)
		FROM (
			VALUES (Student.LastModifiedDate)
				,(StudentSchoolAssociation.LastModifiedDate)
			) AS VALUE(MaxLastModifiedDate)
		) AS LastModifiedDate
    FROM 
        edfi.Student
    LEFT JOIN 
        edfi.StudentSchoolAssociation
    ON 
        Student.StudentUSI = StudentSchoolAssociation.StudentUSI
    WHERE 
        StudentSchoolAssociation.PrimarySchool = '1'
