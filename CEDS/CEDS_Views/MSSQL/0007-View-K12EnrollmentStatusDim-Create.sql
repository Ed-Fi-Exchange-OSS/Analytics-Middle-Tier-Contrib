-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.VIEWS
        WHERE TABLE_SCHEMA = 'analytics'
            AND TABLE_NAME = 'ceds_K12EnrollmentStatusDim'
        )
BEGIN
    DROP VIEW analytics.ceds_K12EnrollmentStatusDim;
END;
GO

CREATE VIEW analytics.ceds_K12EnrollmentStatusDim
AS
WITH MapReferenceDescriptor
AS (
    SELECT Descriptor.DescriptorId
        , Descriptor.CodeValue
        , Descriptor.Description
        , ceds_TableReference.TableName
        , ceds_TableInformation.EdFactsCode
    FROM analytics_config.ceds_TableInformation
    INNER JOIN analytics_config.ceds_TableReference
        ON ceds_TableInformation.TableId = ceds_TableReference.TableId
    INNER JOIN edfi.Descriptor
        ON Descriptor.DescriptorId = ceds_TableInformation.DescriptorId
    )
SELECT '-1' AS K12EnrollmentStatusDimId
    , '-1' AS K12EnrollmentStatusKey
    , '' AS EnrollmentStatusCode
    , '' AS EnrollmentStatusDescription
    , '' AS EntryTypeCode
    , '' AS EntryTypeDescription
    , '' AS ExitOrWithdrawalTypeCode
    , '' AS ExitOrWithdrawalTypeDescription
    , '' AS PostSecondaryEnrollmentStatusCode
    , '' AS PostSecondaryEnrollmentStatusDescription
    , '' AS PostSecondaryEnrollmentStatusEdFactsCode
    , '' AS EdFactsAcademicOrCareerAndTechnicalOutcomeTypeCode
    , '' AS EdFactsAcademicOrCareerAndTechnicalOutcomeTypeDescription
    , '' AS EdFactsAcademicOrCareerAndTechnicalOutcomeTypeEdFactsCode
    , '' AS EdFactsAcademicOrCareerAndTechnicalOutcomeExitTypeCode
    , '' AS EdFactsAcademicOrCareerAndTechnicalOutcomeExitTypeDescription
    , '' AS EdFactsAcademicOrCareerAndTechnicalOutcomeExitTypeEdFactsCode
    , GETDATE() AS LastModifiedDate

UNION ALL

SELECT ROW_NUMBER() OVER (
        ORDER BY CONCAT (
                EntryDescriptor.CodeValue
                , '-'
                , ExitWithdrawDescriptor.CodeValue
                )
        ) AS K12EnrollmentStatusDimId
    , CONCAT (
        EntryDescriptor.CodeValue
        , '-'
        , ExitWithdrawDescriptor.CodeValue
        ) AS K12EnrollmentStatusKey
    , '' AS EnrollmentStatusCode
    , '' AS EnrollmentStatusDescription
    , EntryDescriptor.CodeValue AS EntryTypeCode
    , EntryDescriptor.Description AS EntryTypeDescription
    , ExitWithdrawDescriptor.CodeValue AS ExitOrWithdrawalTypeCode
    , ExitWithdrawDescriptor.Description AS ExitOrWithdrawalTypeDescription
    , '' AS PostSecondaryEnrollmentStatusCode
    , '' AS PostSecondaryEnrollmentStatusDescription
    , '' AS PostSecondaryEnrollmentStatusEdFactsCode
    , '' AS EdFactsAcademicOrCareerAndTechnicalOutcomeTypeCode
    , '' AS EdFactsAcademicOrCareerAndTechnicalOutcomeTypeDescription
    , '' AS EdFactsAcademicOrCareerAndTechnicalOutcomeTypeEdFactsCode
    , '' AS EdFactsAcademicOrCareerAndTechnicalOutcomeExitTypeCode
    , '' AS EdFactsAcademicOrCareerAndTechnicalOutcomeExitTypeDescription
    , '' AS EdFactsAcademicOrCareerAndTechnicalOutcomeExitTypeEdFactsCode
    , (
        SELECT MAX(MaxLastModifiedDate)
        FROM (
            VALUES (EntryDescriptor.LastModifiedDate)
                , (ExitWithdrawDescriptor.LastModifiedDate)
            ) AS VALUE(MaxLastModifiedDate)
        ) AS LastModifiedDate
FROM (
    SELECT EntryDescriptor.CodeValue
        , EntryDescriptor.Description
        , EntryDescriptor.LastModifiedDate
    FROM edfi.EntryTypeDescriptor
    INNER JOIN edfi.Descriptor AS EntryDescriptor
        ON EntryTypeDescriptor.EntryTypeDescriptorId = EntryDescriptor.DescriptorId
    INNER JOIN MapReferenceDescriptor AS MapReferenceEntryDescriptor
        ON EntryDescriptor.DescriptorId = MapReferenceEntryDescriptor.DescriptorId
    WHERE MapReferenceEntryDescriptor.TableName = 'xref.EntryType'
    ) AS EntryDescriptor
CROSS JOIN (
    SELECT ExitWithdrawDescriptor.CodeValue
        , ExitWithdrawDescriptor.Description
        , ExitWithdrawDescriptor.LastModifiedDate
    FROM edfi.ExitWithdrawTypeDescriptor
    INNER JOIN edfi.Descriptor AS ExitWithdrawDescriptor
        ON ExitWithdrawTypeDescriptor.ExitWithdrawTypeDescriptorId = ExitWithdrawDescriptor.DescriptorId
    INNER JOIN MapReferenceDescriptor AS MapReferenceExitWithdrawDescriptor
        ON ExitWithdrawDescriptor.DescriptorId = MapReferenceExitWithdrawDescriptor.DescriptorId
    WHERE MapReferenceExitWithdrawDescriptor.TableName = 'xref.ExitWithdrawType'
    ) AS ExitWithdrawDescriptor;
