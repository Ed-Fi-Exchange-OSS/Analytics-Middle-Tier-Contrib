-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
DROP VIEW

IF EXISTS analytics.ceds_IdeaStatusDim;
    CREATE VIEW analytics.ceds_IdeaStatusDim
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
SELECT '-1' IdeaStatusDimId
    , '-1' AS IdeaStatusKey
    , '' AS SpecialEducationExitReasonCode
    , '' AS SpecialEducationExitReasonDescription
    , '' AS SpecialEducationExitReasonEdFactsCode
    , '' AS PrimaryDisabilityTypeCode
    , '' AS PrimaryDisabilityTypeDescription
    , '' AS PrimaryDisabilityTypeEdFactsCode
    , '' AS IdeaEducationalEnvironmentForSchoolAgeCode
    , '' AS IdeaEducationalEnvironmentForSchoolAgeDescription
    , '' AS IdeaEducationalEnvironmentForSchoolAgeEdFactsCode
    , '' AS IdeaEducationalEnvironmentForEarlyChildhoodCode
    , '' AS IdeaEducationalEnvironmentForEarlyChildhoodDescription
    , '' AS IdeaEducationalEnvironmentForEarlyChildhoodEdFactsCode
    , '' AS IdeaIndicatorCode
    , '' AS IdeaIndicatorDescription
    , '' AS IdeaIndicatorEdFactsCode

UNION ALL

SELECT ROW_NUMBER() OVER (
        ORDER BY IdeaStatusKey
        ) AS IdeaStatusDimId
    , IdeaStatusKey
    , SpecialEducationExitReasonCode
    , SpecialEducationExitReasonDescription
    , SpecialEducationExitReasonEdFactsCode
    , PrimaryDisabilityTypeCode
    , PrimaryDisabilityTypeDescription
    , PrimaryDisabilityTypeEdFactsCode
    , IdeaEducationalEnvironmentForSchoolAgeCode
    , IdeaEducationalEnvironmentForSchoolAgeDescription
    , IdeaEducationalEnvironmentForSchoolAgeEdFactsCode
    , IdeaEducationalEnvironmentForEarlyChildhoodCode
    , IdeaEducationalEnvironmentForEarlyChildhoodDescription
    , IdeaEducationalEnvironmentForEarlyChildhoodEdFactsCode
    , IdeaIndicatorCode
    , IdeaIndicatorDescription
    , IdeaIndicatorEdFactsCode
FROM (
    SELECT CONCAT (
            COALESCE(ReferenceBasisOfExitDescriptor.EdFactsCode, '')
            , '-'
            , COALESCE(ReferenceBasisOfExitDescriptor.CodeValue, '')
            , '-'
            , COALESCE(ReferenceDisabilityDescriptor.EdFactsCode, '')
            , '-'
            , COALESCE(ReferenceDisabilityDescriptor.CodeValue, '')
            , '-'
            , COALESCE(ReferenceEducationalEnvironmentDescriptor.EdFactsCode, '')
            , '-'
            , COALESCE(ReferenceEducationalEnvironmentDescriptor.CodeValue, '')
            ) AS IdeaStatusKey
        , COALESCE(ReferenceBasisOfExitDescriptor.CodeValue, '') AS SpecialEducationExitReasonCode
        , COALESCE(ReferenceBasisOfExitDescriptor.Description, '') AS SpecialEducationExitReasonDescription
        , COALESCE(ReferenceBasisOfExitDescriptor.EdFactsCode, '') AS SpecialEducationExitReasonEdFactsCode
        , COALESCE(ReferenceDisabilityDescriptor.CodeValue, '') AS PrimaryDisabilityTypeCode
        , COALESCE(ReferenceDisabilityDescriptor.Description, '') AS PrimaryDisabilityTypeDescription
        , COALESCE(ReferenceDisabilityDescriptor.EdFactsCode, '') AS PrimaryDisabilityTypeEdFactsCode
        , COALESCE(ReferenceEducationalEnvironmentDescriptor.CodeValue, '') AS IdeaEducationalEnvironmentForSchoolAgeCode
        , COALESCE(ReferenceEducationalEnvironmentDescriptor.Description, '') AS IdeaEducationalEnvironmentForSchoolAgeDescription
        , COALESCE(ReferenceEducationalEnvironmentDescriptor.EdFactsCode, '') AS IdeaEducationalEnvironmentForSchoolAgeEdFactsCode
        , COALESCE(ReferenceEducationalEnvironmentDescriptor.CodeValue, '') AS IdeaEducationalEnvironmentForEarlyChildhoodCode
        , COALESCE(ReferenceEducationalEnvironmentDescriptor.Description, '') AS IdeaEducationalEnvironmentForEarlyChildhoodDescription
        , COALESCE(ReferenceEducationalEnvironmentDescriptor.EdFactsCode, '') AS IdeaEducationalEnvironmentForEarlyChildhoodEdFactsCode
        , CASE 
            WHEN ReferenceEducationalEnvironmentDescriptor.EdFactsCode IS NOT NULL
                THEN 'YES'
            ELSE 'NO'
            END AS IdeaIndicatorCode
        , CASE 
            WHEN ReferenceEducationalEnvironmentDescriptor.EdFactsCode IS NOT NULL
                THEN 'YES'
            ELSE 'NO'
            END AS IdeaIndicatorDescription
        , CASE 
            WHEN ReferenceEducationalEnvironmentDescriptor.EdFactsCode IS NOT NULL
                THEN 'YES'
            ELSE 'NO'
            END AS IdeaIndicatorEdFactsCode
    FROM (
        SELECT ReferenceBasisOfExitDescriptor.CodeValue
            , ReferenceBasisOfExitDescriptor.Description
            , ReferenceBasisOfExitDescriptor.EdFactsCode
        FROM edfi.ReasonExitedDescriptor
        LEFT JOIN MapReferenceDescriptor ReferenceBasisOfExitDescriptor
            ON ReasonExitedDescriptor.ReasonExitedDescriptorId = ReferenceBasisOfExitDescriptor.DescriptorId
        WHERE ReferenceBasisOfExitDescriptor.TableName = 'xref.BasisOfExit'
        ) AS ReferenceBasisOfExitDescriptor
    CROSS JOIN (
        SELECT ReferenceDisabilityDescriptor.CodeValue
            , ReferenceDisabilityDescriptor.Description
            , ReferenceDisabilityDescriptor.EdFactsCode
        FROM edfi.DisabilityDescriptor
        LEFT JOIN MapReferenceDescriptor ReferenceDisabilityDescriptor
            ON DisabilityDescriptor.DisabilityDescriptorId = ReferenceDisabilityDescriptor.DescriptorId
        WHERE ReferenceDisabilityDescriptor.TableName = 'xref.DisabilityDescriptor'
        ) AS ReferenceDisabilityDescriptor
    CROSS JOIN (
        SELECT ReferenceEducationalEnvironmentDescriptor.CodeValue
            , ReferenceEducationalEnvironmentDescriptor.Description
            , ReferenceEducationalEnvironmentDescriptor.EdFactsCode
        FROM edfi.EducationalEnvironmentDescriptor
        LEFT JOIN MapReferenceDescriptor ReferenceEducationalEnvironmentDescriptor
            ON EducationalEnvironmentDescriptor.EducationalEnvironmentDescriptorId = ReferenceEducationalEnvironmentDescriptor.DescriptorId
        WHERE ReferenceEducationalEnvironmentDescriptor.TableName = 'xref.EducationalEnvironmentForSchoolAgeType'
        ) AS ReferenceEducationalEnvironmentDescriptor
    ) AS IdeaStatusDim;
