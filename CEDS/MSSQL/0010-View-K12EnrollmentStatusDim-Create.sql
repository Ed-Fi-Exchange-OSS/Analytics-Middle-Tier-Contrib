-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.VIEWS
        WHERE TABLE_SCHEMA = 'xref'
            AND TABLE_NAME = 'ceds_K12EnrollmentStatusDim'
        )
BEGIN
    DROP VIEW xref.ceds_K12EnrollmentStatusDim;
END;
GO
CREATE VIEW xref.ceds_K12EnrollmentStatusDim AS
WITH MapReferenceDescriptor
AS (
    SELECT Descriptor.DescriptorId
        ,Descriptor.CodeValue
        ,Descriptor.Description
        ,EdFiTableReference.EdFiTableName
        ,EdFiTableInformation.EdFactsCode
    FROM xref.EdFiTableInformation
    INNER JOIN xref.EdFiTableReference
        ON EdFiTableInformation.EdFiTableId = EdFiTableReference.EdFiTableId
    INNER JOIN edfi.Descriptor
        ON Descriptor.DescriptorId = EdFiTableInformation.EdFiDescriptorId
    )
SELECT CONCAT(
		EntryDescriptor.CodeValue,'-'
		,ExitWithdrawDescriptor.CodeValue
	) as K12EnrollmentStatusKey
	,'' as EnrollmentStatusCode
	,'' as EnrollmentStatusDescription
	,EntryDescriptor.CodeValue as EntryTypeCode
	,EntryDescriptor.Description as EntryTypeDescription
	,ExitWithdrawDescriptor.CodeValue as ExitOrWithdrawalTypeCode
	,ExitWithdrawDescriptor.Description as ExitOrWithdrawalTypeDescription
	,'' as	PostSecondaryEnrollmentStatusCode
	,'' as	PostSecondaryEnrollmentStatusDescription
	,'' as	PostSecondaryEnrollmentStatusEdFactsCode
	,'' as	EdFactsAcademicOrCareerAndTechnicalOutcomeTypeCode
	,'' as	EdFactsAcademicOrCareerAndTechnicalOutcomeTypeDescription
	,'' as	EdFactsAcademicOrCareerAndTechnicalOutcomeTypeEdFactsCode
	,'' as	EdFactsAcademicOrCareerAndTechnicalOutcomeExitTypeCode
	,'' as	EdFactsAcademicOrCareerAndTechnicalOutcomeExitTypeDescription
	,'' as	EdFactsAcademicOrCareerAndTechnicalOutcomeExitTypeEdFactsCode
	,(
		SELECT MAX(MaxLastModifiedDate)
		FROM (
			VALUES (EntryDescriptor.LastModifiedDate)
				,(ExitWithdrawDescriptor.LastModifiedDate)
			) AS VALUE(MaxLastModifiedDate)
		) AS LastModifiedDate
FROM 
	(
		SELECT EntryDescriptor.CodeValue
			,EntryDescriptor.Description
			,EntryDescriptor.LastModifiedDate
		FROM 
			edfi.EntryTypeDescriptor
		INNER JOIN 
			edfi.Descriptor as EntryDescriptor
				ON EntryTypeDescriptor.EntryTypeDescriptorId = EntryDescriptor.DescriptorId
		INNER JOIN 
			MapReferenceDescriptor as MapReferenceEntryDescriptor
				ON EntryDescriptor.DescriptorId = MapReferenceEntryDescriptor.DescriptorId
		WHERE MapReferenceEntryDescriptor.EdFiTableName = 'xref.EntryType'
	) as EntryDescriptor
	CROSS JOIN (
		SELECT ExitWithdrawDescriptor.CodeValue
			,ExitWithdrawDescriptor.Description 
			,ExitWithdrawDescriptor.LastModifiedDate
		FROM 
			edfi.ExitWithdrawTypeDescriptor
		INNER JOIN 
			edfi.Descriptor as ExitWithdrawDescriptor
				ON ExitWithdrawTypeDescriptor.ExitWithdrawTypeDescriptorId = ExitWithdrawDescriptor.DescriptorId
		INNER JOIN 
			MapReferenceDescriptor as MapReferenceExitWithdrawDescriptor
				ON ExitWithdrawDescriptor.DescriptorId = MapReferenceExitWithdrawDescriptor.DescriptorId
		WHERE MapReferenceExitWithdrawDescriptor.EdFiTableName = 'xref.ExitWithdrawType'
	) as ExitWithdrawDescriptor;

