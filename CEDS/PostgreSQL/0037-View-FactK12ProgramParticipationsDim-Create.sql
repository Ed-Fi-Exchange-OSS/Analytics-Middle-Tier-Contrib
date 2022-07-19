-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.

DROP VIEW IF EXISTS analytics.ceds_FactK12ProgramParticipation;

CREATE OR REPLACE VIEW analytics.ceds_FactK12ProgramParticipation
AS
	WITH FactK12ProgramParticipation
	AS (
        SELECT
        (
            SELECT
            CONCAT(EducationOrganizationId, '-', ProgramTypeDescriptorId,'-', ProgramEducationOrganizationId)
            FROM edfi.StudentSpecialEducationProgramAssociation
            GROUP BY EducationOrganizationId, ProgramTypeDescriptorId, ProgramEducationOrganizationId
	    ) AS FactK12ProgramParticipationId,
           SchoolYearKey
           ,'' AS DateId
           ,'' AS DataCollectionId
           ,SeaIdentifierSea AS SeaId
           ,LeaIdentifierSea AS IeuId
           ,LeaIdentifierNces AS LeaId
           ,K12SchoolKey AS K12SchoolId
           ,K12ProgramTypeKey AS DimK12ProgramTypeId
           ,StudentSchoolKey AS DimK12StudentlId
           ,K12DemographicKey AS DimK12DemographicId
           ,IdeaStatusKey AS DimIdeaStatusId
           ,GeneralStudentProgramAssociation.BeginDate AS BeginDate
           ,GeneralStudentProgramAssociation.EndDate AS EndDate
        FROM
            edfi.StudentSpecialEducationProgramAssociation
        INNER JOIN
            analytics.ceds_SchoolYearsDim
        ON
            StudentSpecialEducationProgramAssociation.BeginDate
            BETWEEN TO_DATE(ceds_SchoolYearsDim.SessionBeginDate, 'MM-DD-YYYY') AND TO_DATE(ceds_SchoolYearsDim.SessionEndDate, 'MM-DD-YYYY')
        INNER JOIN
            analytics.ceds_K12SchoolDim
        ON
            ceds_K12SchoolDim.K12SchoolKey = StudentSpecialEducationProgramAssociation.EducationOrganizationId
        INNER JOIN
            edfi.ProgramTypeDescriptor
        ON
            ProgramTypeDescriptor.ProgramTypeDescriptorId = StudentSpecialEducationProgramAssociation.ProgramTypeDescriptorId
        INNER JOIN
            edfi.Descriptor
        ON
            Descriptor.DescriptorId = ProgramTypeDescriptor.ProgramTypeDescriptorId
        INNER JOIN
            analytics.ceds_K12ProgramTypeDim
        ON
            Descriptor.CodeValue = ceds_K12ProgramTypeDim.ProgramTypeCode
        INNER JOIN
            edfi.Student
        ON
            Student.StudentUSI = StudentSpecialEducationProgramAssociation.StudentUSI
        INNER JOIN
            analytics.ceds_K12StudentDim
        ON
            ceds_K12StudentDim.StudentIdentifierState = Student.StudentUniqueId
        LEFT JOIN
            edfi.StudentEducationOrganizationAssociation
        ON
            StudentEducationOrganizationAssociation.StudentUSI = StudentSpecialEducationProgramAssociation.StudentUSI AND Descriptor.Namespace = StudentEducationOrganizationAssociation.SexDescriptorId
        INNER JOIN
            edfi.StudentEducationOrganizationAssociationStudentCharacteristic
        ON
            StudentEducationOrganizationAssociationStudentCharacteristic.EducationOrganizationId = StudentSpecialEducationProgramAssociation.EducationOrganizationId
        INNER JOIN
            edfi.StudentHomelessProgramAssociation
        ON
            StudentHomelessProgramAssociation.StudentUSI = StudentEducationOrganizationAssociation.StudentUSI
        INNER JOIN
            analytics.ceds_K12DemographicDim
        ON
            ceds_K12DemographicDim.K12DemographicKey = StudentHomelessProgramAssociation.ProgramName
        INNER JOIN
            edfi.GeneralStudentProgramAssociation
        ON
            GeneralStudentProgramAssociation.BeginDate = StudentSpecialEducationProgramAssociation.BeginDate OR
            GeneralStudentProgramAssociation.EducationOrganizationId = StudentSpecialEducationProgramAssociation.EducationOrganizationId OR
            GeneralStudentProgramAssociation.ProgramEducationOrganizationId = StudentSpecialEducationProgramAssociation.ProgramEducationOrganizationId OR
            GeneralStudentProgramAssociation.ProgramName = StudentSpecialEducationProgramAssociation.ProgramName OR
            GeneralStudentProgramAssociation.ProgramTypeDescriptorId = StudentSpecialEducationProgramAssociation.ProgramTypeDescriptorId OR
            GeneralStudentProgramAssociation.StudentUSI = StudentSpecialEducationProgramAssociation.StudentUSI
        INNER JOIN
            analytics.ceds_IdeaStatusDim
        ON
            ceds_IdeaStatusDim.DisabilityCode = Descriptor.CodeValue AND ceds_IdeaStatusDim.BasisOfExitCode = Descriptor.CodeValue
        )
    SELECT
        CONCAT(
            SchoolYearKey,
			'-',
			DateId,
			'-',
			DataCollectionId,
			'-',
			SeaId,
			'-',
			IeuId,
			'-',
			LeaId,
			'-',
			K12SchoolId,
			'-',
			DimK12ProgramTypeId,
			'-',
			DimK12StudentlId,
			'-',
			DimK12DemographicId,
			'-',
			DimIdeaStatusId,
			'-',
			BeginDate,
			'-',
			EndDate
        ) AS FactK12ProgramParticipationKey
        ,SchoolYearKey
        ,DateId
        ,DataCollectionId
        ,SeaId
        ,IeuId
        ,LeaId
        ,K12SchoolId
        ,DimK12ProgramTypeId
        ,DimK12StudentlId
        ,DimK12DemographicId
        ,DimIdeaStatusId
        ,BeginDate
        ,EndDate
        ,COUNT(DimK12DemographicId) AS StudentCount
    FROM
        FactK12ProgramParticipation
    GROUP BY
     SchoolYearKey
    ,DateId
    ,DataCollectionId
    ,SeaId
    ,IeuId
    ,LeaId
    ,K12SchoolId
    ,DimK12ProgramTypeId
    ,DimK12StudentlId
    ,DimK12DemographicId
    ,DimIdeaStatusId
    ,BeginDate
    ,EndDate