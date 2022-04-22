-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.VIEWS
        WHERE TABLE_SCHEMA = 'analytics'
            AND TABLE_NAME = 'ceds_K12StudentDim'
        )
BEGIN
    DROP VIEW analytics.ceds_K12StudentDim;
END;
GO

CREATE OR ALTER VIEW analytics.ceds_K12StudentDim AS
(
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
);
