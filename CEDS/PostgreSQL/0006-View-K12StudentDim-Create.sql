-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
-- Drop ceds_BridgeK12StudentEnrollmentRace first because it uses ceds_K12StudentDim
DROP VIEW

IF EXISTS analytics.ceds_BridgeK12StudentEnrollmentRace;
    -- Drop ceds_FactK12StudentEnrollment first because it uses ceds_K12StudentDim
    DROP VIEW

IF EXISTS analytics.ceds_FactK12StudentEnrollment;
    -- Drop ceds_FactK12ProgramParticipation first because it uses ceds_K12StudentDim
    DROP VIEW

IF EXISTS analytics.ceds_FactK12ProgramParticipation;
    DROP VIEW

IF EXISTS analytics.ceds_K12StudentDim;
    CREATE
        OR REPLACE VIEW analytics.ceds_K12StudentDim AS

SELECT '-1' AS K12StudentDimId
    , '-1' AS K12StudentKey
    , '' AS StudentSchoolKey
    , '1900-01-01' AS BirthDate
    , NULL AS Cohort
    , '' AS FirstName
    , '' AS LastOrSurname
    , '' AS MiddleName
    , '' AS StudentIdentifierState
    , '' AS RecordStartDateTime
    , '' AS RecordEndDateTime
    , '' AS SchoolKey
    , '' AS ClassOfSchoolYear
    , 19000101 AS EntryDateKey
    , NULL AS ExitWithdrawDateKey
    , - 1 AS EntryTypeDescriptorId
    , - 1 AS ExitWithdrawTypeDescriptorId
    , - 1 AS EntryGradeLevelDescriptorId
    , NOW() AS LastModifiedDate

UNION ALL

SELECT ROW_NUMBER() OVER (
        ORDER BY CONCAT (
                Student.StudentUniqueId
                , '-'
                , StudentSchoolAssociation.SchoolId
                , '-'
                , StudentSchoolAssociation.EntryDate
                )
        ) AS K12StudentDimId
    , CONCAT (
        Student.StudentUniqueId
        , '-'
        , StudentSchoolAssociation.SchoolId
        , '-'
        , to_char(StudentSchoolAssociation.EntryDate, 'yyyymmdd')
        ) AS K12StudentKey
    , CONCAT (
        Student.StudentUniqueId
        , '-'
        , StudentSchoolAssociation.SchoolId
        ) AS StudentSchoolKey
    , Student.BirthDate
    , StudentSchoolAssociation.ClassOfSchoolYear AS Cohort
    , Student.FirstName
    , Student.LastSurname AS LastOrSurname
    , COALESCE(Student.MiddleName, '') AS MiddleName
    , Student.StudentUniqueId AS StudentIdentifierState
    , '' AS RecordStartDateTime
    , '' AS RecordEndDateTime
    , CAST(StudentSchoolAssociation.SchoolId AS VARCHAR) AS SchoolKey
    , CAST(StudentSchoolAssociation.ClassOfSchoolYear AS VARCHAR) AS ClassOfSchoolYear
    , CAST(to_char(StudentSchoolAssociation.EntryDate, 'yyyymmdd') AS INT) AS EntryDateKey
    , CAST(to_char(StudentSchoolAssociation.ExitWithdrawDate, 'yyyymmdd') AS INT) AS ExitWithdrawDateKey
    , COALESCE(StudentSchoolAssociation.EntryTypeDescriptorId, - 1) AS EntryTypeDescriptorId
    , COALESCE(StudentSchoolAssociation.ExitWithdrawTypeDescriptorId, - 1) AS ExitWithdrawTypeDescriptorId
    , COALESCE(StudentSchoolAssociation.EntryGradeLevelDescriptorId, - 1) AS EntryGradeLevelDescriptorId
    , (
        SELECT MAX(MaxLastModifiedDate)
        FROM (
            VALUES (Student.LastModifiedDate)
                , (StudentSchoolAssociation.LastModifiedDate)
            ) AS VALUE(MaxLastModifiedDate)
        ) AS LastModifiedDate
FROM edfi.Student
INNER JOIN edfi.StudentSchoolAssociation
    ON Student.StudentUSI = StudentSchoolAssociation.StudentUSI
WHERE StudentSchoolAssociation.PrimarySchool = '1';
