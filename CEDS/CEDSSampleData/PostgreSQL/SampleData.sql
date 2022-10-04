INSERT INTO edfi.EducationOrganization(EducationOrganizationId,NameOfInstitution,Id,LastModifiedDate,CreateDate,Discriminator)
(SELECT '1395665299','TX State Education Agency','54AF3D3A-34CF-4648-95AC-6FF4B5E8AD50','Dec 14 2018  1:08PM','Dec 14 2018  1:08PM','edfi.StateEducationAgency'
	WHERE NOT EXISTS(SELECT  1  FROM edfi.EducationOrganization WHERE   EducationOrganizationId= '1395665299'));

INSERT INTO edfi.StateEducationAgency(StateEducationAgencyId)
(SELECT '1395665299'
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
	ExitWithdrawDate = TO_DATE('2022-06-29', 'YYYY-MM-DD')
WHERE
	SchoolId = 255901107
	AND
		EntryDate = '2021-08-23';

-- 
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

SET myvars.EducationOrganization TO 255901001;

WITH SOURCE AS (
	SELECT
		EducationOrganizationId,ProgramName,ProgramTypeDescriptorId,ProgramId,Discriminator,ChangeVersion
	FROM
		edfi.Program
	WHERE
		EducationOrganizationId = 255901
)
INSERT INTO edfi.Program
	  (
		EducationOrganizationId,ProgramName,ProgramTypeDescriptorId,ProgramId,Discriminator,CreateDate,LastModifiedDate,Id,ChangeVersion
	  )
      SELECT
	  	current_setting('myvars.EducationOrganization')::integer,
		Source.ProgramName,
		Source.ProgramTypeDescriptorId,
		Source.ProgramId,
		Source.Discriminator,
		NOW(),
		NOW(),
		uuid_generate_v4(),
		Source.ChangeVersion
      FROM SOURCE
	ON CONFLICT DO NOTHING;
---

WITH SOURCE AS (
	SELECT
		BeginDate,EducationOrganizationId,ProgramEducationOrganizationId,ProgramName,ProgramTypeDescriptorId,StudentUSI,EndDate,ReasonExitedDescriptorId,ServedOutsideOfRegularSession,Discriminator,ChangeVersion
	FROM
		edfi.generalstudentprogramassociation
	WHERE
	    EducationOrganizationId = 255901 and ProgramName like '%Special Education%'
) 
	INSERT INTO edfi.generalstudentprogramassociation
	  (
		BeginDate,EducationOrganizationId,ProgramEducationOrganizationId,ProgramName,ProgramTypeDescriptorId,StudentUSI,EndDate,ReasonExitedDescriptorId,ServedOutsideOfRegularSession,Discriminator,CreateDate,LastModifiedDate,Id,ChangeVersion
	  )
      SELECT
		Source.BeginDate
		,current_setting('myvars.EducationOrganization')::integer
		,current_setting('myvars.EducationOrganization')::integer
		,Source.ProgramName
		,Source.ProgramTypeDescriptorId
		,Source.StudentUSI
		,Source.EndDate
		,Source.ReasonExitedDescriptorId
		,Source.ServedOutsideOfRegularSession
		,Source.Discriminator
		,NOW()
		,NOW()
		,uuid_generate_v4()
		,Source.ChangeVersion
	  FROM SOURCE
	ON CONFLICT DO NOTHING;
---
WITH SOURCE AS (
	SELECT
		BeginDate,EducationOrganizationId,ProgramEducationOrganizationId,ProgramName,ProgramTypeDescriptorId,StudentUSI,LastEvaluationDate,IEPReviewDate,IEPBeginDate
	FROM
		edfi.studentspecialeducationprogramassociation
	WHERE
		EducationOrganizationId = 255901
) INSERT INTO edfi.studentspecialeducationprogramassociation
	  (
		BeginDate,EducationOrganizationId,ProgramEducationOrganizationId,ProgramName,ProgramTypeDescriptorId,StudentUSI,LastEvaluationDate,IEPReviewDate,IEPBeginDate
	  )
      SELECT
		Source.BeginDate,
		current_setting('myvars.EducationOrganization')::integer,
		current_setting('myvars.EducationOrganization')::integer,
		Source.ProgramName,
		Source.ProgramTypeDescriptorId,
		Source.StudentUSI,
		Source.LastEvaluationDate,
		Source.IEPReviewDate,
		Source.IEPBeginDate
      FROM Source
	ON CONFLICT DO NOTHING;
---

WITH SOURCE AS (
	SELECT
		BeginDate,DisabilityDescriptorId,EducationOrganizationId,ProgramEducationOrganizationId,ProgramName,ProgramTypeDescriptorId,StudentUSI,DisabilityDiagnosis,OrderOfDisability,DisabilityDeterminationSourceTypeDescriptorId
	FROM
		edfi.studentspecialeducationprogramassociationdisability
	WHERE
		EducationOrganizationId = 255901
	) 
      INSERT INTO edfi.studentspecialeducationprogramassociationdisability
	  (
		BeginDate,DisabilityDescriptorId,EducationOrganizationId,ProgramEducationOrganizationId,ProgramName,ProgramTypeDescriptorId,StudentUSI,DisabilityDiagnosis,OrderOfDisability,DisabilityDeterminationSourceTypeDescriptorId,CreateDate
	  )
      SELECT
		Source.BeginDate,
		Source.DisabilityDescriptorId,
		current_setting('myvars.EducationOrganization')::integer,
		current_setting('myvars.EducationOrganization')::integer,
		Source.ProgramName,
		Source.ProgramTypeDescriptorId,
		Source.StudentUSI,
		Source.DisabilityDiagnosis,
		Source.OrderOfDisability,
		Source.DisabilityDeterminationSourceTypeDescriptorId,
		NOW()
	  FROM SOURCE
	ON CONFLICT DO NOTHING;