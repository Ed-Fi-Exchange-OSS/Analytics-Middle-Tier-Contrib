-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.

IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.VIEWS
        WHERE TABLE_SCHEMA = 'analytics' AND TABLE_NAME = 'ceds_BridgeK12StudentEnrollmentRace'
        )
BEGIN
    DROP VIEW analytics.ceds_BridgeK12StudentEnrollmentRace;
END;
GO

CREATE VIEW analytics.ceds_BridgeK12StudentEnrollmentRace AS
	SELECT ceds_FactK12StudentEnrollment.FactK12StudentEnrollmentKey AS FactK12StudentEnrollmentKey,
        Descriptor.Description AS RaceKey
    FROM edfi.Student
    INNER JOIN edfi.StudentSchoolAssociation
        ON Student.StudentUSI = StudentSchoolAssociation.StudentUSI
    INNER JOIN analytics.ceds_K12SchoolDim
        ON StudentSchoolAssociation.SchoolId = ceds_K12SchoolDim.SchoolKey
    INNER JOIN analytics.ceds_K12StudentDim
        ON Student.StudentUniqueId = ceds_K12StudentDim.K12StudentKey
    INNER JOIN analytics.ceds_FactK12StudentEnrollment
        ON ceds_K12SchoolDim.SchoolKey = ceds_FactK12StudentEnrollment.K12SchoolKey
            AND ceds_K12StudentDim.K12StudentKey = ceds_FactK12StudentEnrollment.K12StudentKey
    INNER JOIN edfi.StudentEducationOrganizationAssociationRace
        ON Student.StudentUSI = StudentEducationOrganizationAssociationRace.StudentUSI
            AND StudentSchoolAssociation.SchoolId = StudentEducationOrganizationAssociationRace.EducationOrganizationId
    INNER JOIN edfi.Descriptor
        ON Descriptor.DescriptorId = StudentEducationOrganizationAssociationRace.RaceDescriptorId,
            analytics.ceds_SchoolYearDim
    WHERE StudentSchoolAssociation.EntryDate  BETWEEN CAST(ceds_SchoolYearDim.SessionBeginDate AS DATE)
        AND CAST(ceds_SchoolYearDim.SessionEndDate AS DATE);

