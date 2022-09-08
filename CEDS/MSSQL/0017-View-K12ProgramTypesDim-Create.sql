-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.VIEWS
        WHERE TABLE_SCHEMA = 'analytics'
            AND TABLE_NAME = 'ceds_K12ProgramTypeDim'
        )
BEGIN
    DROP VIEW analytics.ceds_K12ProgramTypeDim;
END;
GO

CREATE OR ALTER VIEW analytics.ceds_K12ProgramTypeDim
AS 
    WITH MapReferenceDescriptor
    AS (
        SELECT Descriptor.DescriptorId
            ,Descriptor.CodeValue
            ,Descriptor.Description
            ,ceds_TableReference.TableName
            ,ceds_TableInformation.EdFactsCode
        FROM analytics_config.ceds_TableInformation
        INNER JOIN analytics_config.ceds_TableReference
            ON ceds_TableInformation.TableId = ceds_TableReference.TableId
        INNER JOIN edfi.Descriptor
            ON Descriptor.DescriptorId = ceds_TableInformation.DescriptorId
        )
    SELECT
        CONCAT(Descriptor.CodeValue
            ,'-'
            ,Descriptor.ShortDescription) as K12ProgramTypeKey
        , Descriptor.CodeValue as ProgramTypeCode
        , Descriptor.ShortDescription as ProgramTypeDescription
        , Descriptor.Description as ProgramTypeDefinition
    FROM edfi.ProgramTypeDescriptor
    INNER JOIN edfi.Descriptor
    ON ProgramTypeDescriptor.ProgramTypeDescriptorId = Descriptor.DescriptorId
    INNER JOIN MapReferenceDescriptor xrefProgramTypes
    ON Descriptor.DescriptorId=xrefProgramTypes.DescriptorId;

