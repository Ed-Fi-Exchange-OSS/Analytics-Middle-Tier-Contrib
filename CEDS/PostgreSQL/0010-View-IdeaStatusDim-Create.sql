-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
DROP VIEW IF EXISTS analytics.ceds_IdeaStatusDim;

CREATE VIEW analytics.ceds_IdeaStatusDim
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
    SELECT DISTINCT CONCAT (
            COALESCE(ReferenceBasisOfExitDescriptor.EdFactsCode, '')
            ,'-'
            ,COALESCE(ReferenceDisabilityDescriptor.EdFactsCode, '')
            ,'-'
            ,COALESCE(ReferenceEducationalEnvironmentDescriptor.EdFactsCode, '')
            ) AS IdeaStatusKey
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
    FROM 
        (SELECT ReferenceBasisOfExitDescriptor.CodeValue
                ,ReferenceBasisOfExitDescriptor.Description
                ,ReferenceBasisOfExitDescriptor.EdFactsCode
        FROM 
            edfi.ReasonExitedDescriptor
        LEFT JOIN 
            MapReferenceDescriptor ReferenceBasisOfExitDescriptor
                ON ReasonExitedDescriptor.ReasonExitedDescriptorId = ReferenceBasisOfExitDescriptor.DescriptorId
        WHERE ReferenceBasisOfExitDescriptor.TableName = 'xref.BasisOfExit'
    ) AS ReferenceBasisOfExitDescriptor
    CROSS JOIN 
        (SELECT ReferenceDisabilityDescriptor.CodeValue
                ,ReferenceDisabilityDescriptor.Description
                ,ReferenceDisabilityDescriptor.EdFactsCode
        FROM
            edfi.DisabilityDescriptor
        LEFT JOIN 
            MapReferenceDescriptor ReferenceDisabilityDescriptor
                ON DisabilityDescriptor.DisabilityDescriptorId = ReferenceDisabilityDescriptor.DescriptorId
        WHERE
            ReferenceDisabilityDescriptor.TableName = 'xref.DisabilityDescriptor'
    ) AS ReferenceDisabilityDescriptor
    CROSS JOIN  
        (SELECT ReferenceEducationalEnvironmentDescriptor.CodeValue
                ,ReferenceEducationalEnvironmentDescriptor.Description
                ,ReferenceEducationalEnvironmentDescriptor.EdFactsCode
        FROM 
            edfi.EducationalEnvironmentDescriptor
        LEFT JOIN
            MapReferenceDescriptor ReferenceEducationalEnvironmentDescriptor
                ON EducationalEnvironmentDescriptor.EducationalEnvironmentDescriptorId = ReferenceEducationalEnvironmentDescriptor.DescriptorId
        WHERE ReferenceEducationalEnvironmentDescriptor.TableName = 'xref.EducationalEnvironmentType') AS ReferenceEducationalEnvironmentDescriptor;
