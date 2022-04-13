-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.VIEWS
        WHERE TABLE_SCHEMA = 'xref'
            AND TABLE_NAME = 'IdeaStatusDim'
        )
BEGIN
    DROP VIEW xref.IdeaStatusDim;
END;
GO

CREATE OR ALTER VIEW xref.IdeaStatusDim
AS
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
SELECT CONCAT (
        COALESCE(ReferenceBasisOfExitDescriptor.EdFactsCode, '')
        ,'-'
        ,COALESCE(ReferenceDisabilityDescriptor.CodeValue, '')
        ,'-'
        ,COALESCE(ReferenceEducationalEnvironmentDescriptor.CodeValue, '')
        ) AS IdeaStatusesKey
    ,COALESCE(ReferenceBasisOfExitDescriptor.CodeValue, '') AS BasisOfExitCode
    ,COALESCE(ReferenceBasisOfExitDescriptor.Description, '') AS BasisOfExitDescription
    ,COALESCE(ReferenceBasisOfExitDescriptor.EdFactsCode, '') AS BasisOfExitEdFactsCode
    ,'' AS BasisOfExitId
    ,COALESCE(ReferenceDisabilityDescriptor.CodeValue, '') AS DisabilityCode
    ,COALESCE(ReferenceDisabilityDescriptor.Description, '') AS DisabilityDescription
    ,COALESCE(ReferenceDisabilityDescriptor.EdFactsCode, '') AS DisabilityEdFactsCode
    ,'' AS DisabilityId
    ,COALESCE(ReferenceEducationalEnvironmentDescriptor.CodeValue, '') AS EducEnvCode
    ,COALESCE(ReferenceEducationalEnvironmentDescriptor.Description, '') AS EducEnvDescription
    ,COALESCE(ReferenceEducationalEnvironmentDescriptor.EdFactsCode, '') AS EducEnvEdFactsCode
    ,'' AS EducEnvId
FROM edfi.ReasonExitedDescriptor
INNER JOIN MapReferenceDescriptor ReferenceBasisOfExitDescriptor
    ON ReasonExitedDescriptor.ReasonExitedDescriptorId = ReferenceBasisOfExitDescriptor.DescriptorId
CROSS JOIN edfi.DisabilityDescriptor
INNER JOIN MapReferenceDescriptor ReferenceDisabilityDescriptor
    ON DisabilityDescriptor.DisabilityDescriptorId = ReferenceDisabilityDescriptor.DescriptorId
CROSS JOIN edfi.EducationalEnvironmentDescriptor
INNER JOIN MapReferenceDescriptor ReferenceEducationalEnvironmentDescriptor
    ON EducationalEnvironmentDescriptor.EducationalEnvironmentDescriptorId = ReferenceEducationalEnvironmentDescriptor.DescriptorId;
