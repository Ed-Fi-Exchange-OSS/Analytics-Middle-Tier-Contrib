-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
DROP VIEW IF EXISTS xref.K12StudentsDim;

CREATE OR REPLACE VIEW xref.K12StudentsDim AS
    SELECT
        CONCAT(Student.StudentUniqueId, '-', StudentSchoolAssociation.SchoolId, '-', StudentSchoolAssociation.ClassOfSchoolYear) as K12StudentsKey,
        CONCAT(Student.StudentUniqueId, '-', StudentSchoolAssociation.SchoolId) AS StudentSchoolKey,
        Student.BirthDate,
        StudentSchoolAssociation.ClassOfSchoolYear AS Cohort,
        Student.FirstName,
        Student.LastSurname,
        COALESCE(Student.MiddleName, '') AS MiddleName,
        Student.StudentUniqueId AS StudentIdentifierState,
        '' AS RecordStartDateTime,
        '' AS RecordEndDateTime
    FROM 
        edfi.Student
    LEFT JOIN 
        edfi.StudentSchoolAssociation
    ON 
        Student.StudentUSI = StudentSchoolAssociation.StudentUSI
    WHERE 
        StudentSchoolAssociation.PrimarySchool = '1'
    GROUP BY 
            Student.BirthDate,
            Student.FirstName, 
            Student.LastSurname, 
            Student.MiddleName, 
            Student.StudentUniqueId,
            StudentSchoolAssociation.SchoolId,
            StudentSchoolAssociation.ClassOfSchoolYear
