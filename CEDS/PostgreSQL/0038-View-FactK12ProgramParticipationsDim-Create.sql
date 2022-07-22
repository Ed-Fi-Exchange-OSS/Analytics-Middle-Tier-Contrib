-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
DROP VIEW IF EXISTS analytics.ceds_BridgeK12StudentEnrollmentRace;

CREATE OR REPLACE VIEW analytics.ceds_BridgeK12StudentEnrollmentRace
	SELECT ceds_FactK12StudentEnrollment.FactK12StudentEnrollmentKey AS FactK12StudentEnrollmentId,
        Descriptor.Description AS RaceId
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
    WHERE StudentSchoolAssociation.EntryDate BETWEEN ceds_SchoolYearDim.SessionBeginDate
            AND ceds_SchoolYearDim.SessionEndDate;
