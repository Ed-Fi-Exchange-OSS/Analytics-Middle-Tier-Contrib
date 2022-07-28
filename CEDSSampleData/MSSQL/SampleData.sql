INSERT INTO edfi.EducationOrganization(EducationOrganizationId,NameOfInstitution,Id,LastModifiedDate,CreateDate,Discriminator)
(SELECT TOP 1'1395665299','TX State Education Agency','54AF3D3A-34CF-4648-95AC-6FF4B5E8AD50','Dec 14 2018  1:08PM','Dec 14 2018  1:08PM','edfi.StateEducationAgency'
	WHERE NOT EXISTS(SELECT  1  FROM edfi.EducationOrganization WHERE   EducationOrganizationId= '1395665299'));

INSERT INTO edfi.StateEducationAgency(StateEducationAgencyId)
(SELECT TOP 1'1395665299'
	WHERE NOT EXISTS(SELECT  1  FROM edfi.StateEducationAgency WHERE StateEducationAgencyId = 1395665299));

UPDATE
	edfi.EducationServiceCenter 
SET
	StateEducationAgencyId = 1395665299 
WHERE
	EducationServiceCenterId = 255950;

-- Updating this field because SchoolId = 255901107 is ->  Grand Bend Elementary School. A Primary School.
-- The value was previously NULL.
UPDATE 
	edfi.StudentSchoolAssociation 
SET 
	PrimarySchool = '1'
WHERE 
	StudentSchoolAssociation.SchoolId = 255901107;

UPDATE 
	edfi.StudentSchoolAssociation
SET
	ExitWithdrawDate = CAST('2022-06-29' AS DATETIME)
WHERE
	SchoolId = 255901107
	AND
		EntryDate = '2021-08-23';

-- 
DECLARE @_EducationOrganizationId INT = 255901001;

MERGE INTO edfi.Program AS Target
USING (
	SELECT
		EducationOrganizationId,ProgramName,ProgramTypeDescriptorId,ProgramId,Discriminator,ChangeVersion
	FROM
		edfi.Program
) AS Source(EducationOrganizationId,ProgramName,ProgramTypeDescriptorId,ProgramId,Discriminator,ChangeVersion)
ON @_EducationOrganizationId = Target.EducationOrganizationId
    WHEN NOT MATCHED BY TARGET
    THEN
      INSERT
	  (
		EducationOrganizationId,ProgramName,ProgramTypeDescriptorId,ProgramId,Discriminator,CreateDate,LastModifiedDate,Id,ChangeVersion
	  )
      VALUES
      (
        @_EducationOrganizationId,
		Source.ProgramName,
		ProgramTypeDescriptorId,
		Source.ProgramId,
		Source.Discriminator,
		GETDATE(),
		GETDATE(),
		NEWID(),
		Source.ChangeVersion
      );
---

MERGE INTO edfi.GeneralStudentProgramAssociation AS Target
USING (
	SELECT
		BeginDate,EducationOrganizationId,ProgramEducationOrganizationId,ProgramName,ProgramTypeDescriptorId,StudentUSI,EndDate,ReasonExitedDescriptorId,ServedOutsideOfRegularSession,Discriminator,ChangeVersion
	FROM
		edfi.GeneralStudentProgramAssociation
	WHERE
		EducationOrganizationId = 255901 and ProgramName like '%Special Education%'
) AS Source(BeginDate,EducationOrganizationId,ProgramEducationOrganizationId,ProgramName,ProgramTypeDescriptorId,StudentUSI,EndDate,ReasonExitedDescriptorId,ServedOutsideOfRegularSession,Discriminator,ChangeVersion)
ON TARGET.EducationOrganizationId = @_EducationOrganizationId
		AND Target.ProgramEducationOrganizationId = @_EducationOrganizationId
    WHEN NOT MATCHED BY TARGET
    THEN
      INSERT
	  (
		BeginDate,EducationOrganizationId,ProgramEducationOrganizationId,ProgramName,ProgramTypeDescriptorId,StudentUSI,EndDate,ReasonExitedDescriptorId,ServedOutsideOfRegularSession,Discriminator,CreateDate,LastModifiedDate,Id,ChangeVersion
	  )
      VALUES
      (
		Source.BeginDate
		,@_EducationOrganizationId
		,@_EducationOrganizationId
		,Source.ProgramName
		,Source.ProgramTypeDescriptorId
		,Source.StudentUSI
		,Source.EndDate
		,Source.ReasonExitedDescriptorId
		,Source.ServedOutsideOfRegularSession
		,Source.Discriminator
		,GETDATE()
		,GETDATE()
		,NEWID()
		,Source.ChangeVersion
      );

---

MERGE INTO edfi.StudentSpecialEducationProgramAssociation AS Target
USING (
	SELECT
		BeginDate,EducationOrganizationId,ProgramEducationOrganizationId,ProgramName,ProgramTypeDescriptorId,StudentUSI,LastEvaluationDate,IEPReviewDate,IEPBeginDate
	FROM
    edfi.StudentSpecialEducationProgramAssociation
	WHERE
		EducationOrganizationId = 255901
) AS Source(BeginDate,EducationOrganizationId,ProgramEducationOrganizationId,ProgramName,ProgramTypeDescriptorId,StudentUSI,LastEvaluationDate,IEPReviewDate,IEPBeginDate)
ON TARGET.EducationOrganizationId = @_EducationOrganizationId
		AND Target.ProgramEducationOrganizationId = @_EducationOrganizationId
    WHEN NOT MATCHED BY TARGET
    THEN
      INSERT
	  (
		BeginDate,EducationOrganizationId,ProgramEducationOrganizationId,ProgramName,ProgramTypeDescriptorId,StudentUSI,LastEvaluationDate,IEPReviewDate,IEPBeginDate
	  )
      VALUES
      (
		Source.BeginDate,
		@_EducationOrganizationId,
		@_EducationOrganizationId,
		Source.ProgramName,
		Source.ProgramTypeDescriptorId,
		Source.StudentUSI,
		Source.LastEvaluationDate,
		Source.IEPReviewDate,
		Source.IEPBeginDate
      );

---

MERGE INTO edfi.StudentSpecialEducationProgramAssociationDisability AS Target
USING (
	SELECT
		BeginDate,DisabilityDescriptorId,EducationOrganizationId,ProgramEducationOrganizationId,ProgramName,ProgramTypeDescriptorId,StudentUSI,DisabilityDiagnosis,OrderOfDisability,DisabilityDeterminationSourceTypeDescriptorId
	FROM
    edfi.StudentSpecialEducationProgramAssociationDisability
	WHERE
		EducationOrganizationId = 255901
) AS Source(BeginDate,DisabilityDescriptorId,EducationOrganizationId,ProgramEducationOrganizationId,ProgramName,ProgramTypeDescriptorId,StudentUSI,DisabilityDiagnosis,OrderOfDisability,DisabilityDeterminationSourceTypeDescriptorId)
ON TARGET.EducationOrganizationId = @_EducationOrganizationId
		AND Target.ProgramEducationOrganizationId = @_EducationOrganizationId
    WHEN NOT MATCHED BY TARGET
    THEN
      INSERT
	  (
		BeginDate,DisabilityDescriptorId,EducationOrganizationId,ProgramEducationOrganizationId,ProgramName,ProgramTypeDescriptorId,StudentUSI,DisabilityDiagnosis,OrderOfDisability,DisabilityDeterminationSourceTypeDescriptorId,CreateDate
	  )
      VALUES
      (
		Source.BeginDate,
		Source.DisabilityDescriptorId,
		@_EducationOrganizationId,
		@_EducationOrganizationId,
		Source.ProgramName,
		Source.ProgramTypeDescriptorId,
		Source.StudentUSI,
		Source.DisabilityDiagnosis,
		Source.OrderOfDisability,
		Source.DisabilityDeterminationSourceTypeDescriptorId,
		GETDATE()
      );
