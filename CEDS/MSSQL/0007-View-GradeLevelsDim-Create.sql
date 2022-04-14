-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.VIEWS
        WHERE TABLE_SCHEMA = 'xref'
            AND TABLE_NAME = 'ceds_GradeLevelDim'
        )
BEGIN
    DROP VIEW xref.ceds_GradeLevelDim;
END;
GO

CREATE OR ALTER VIEW xref.ceds_GradeLevelDim
AS 
WITH MapReferenceDescriptor
AS (
    SELECT 
         Descriptor.DescriptorId
        ,Descriptor.CodeValue
        ,Descriptor.Description
        ,EdFiTableReference.EdFiTableName
        ,EdFiTableInformation.EdFactsCode
    FROM 
        xref.EdFiTableInformation
    INNER JOIN 
        xref.EdFiTableReference
        ON EdFiTableInformation.EdFiTableId = EdFiTableReference.EdFiTableId
    INNER JOIN 
        edfi.Descriptor
        ON Descriptor.DescriptorId = EdFiTableInformation.EdFiDescriptorId
    INNER JOIN
        edfi.GradeLevelDescriptor
        ON GradeLevelDescriptor.GradeLevelDescriptorId = EdFiTableInformation.EdFiDescriptorId
    )
SELECT DISTINCT 
    CONCAT (
        COALESCE(ReferenceBasisOfExitDescriptor.EdFactsCode, '')
        ,'-'
        ,COALESCE(ReferenceBasisOfExitDescriptor.CodeValue, '')
        ,'-'
        ,COALESCE(ReferenceBasisOfExitDescriptor.Description, '')
        ) AS GradeLevelKey
    ,COALESCE(ReferenceBasisOfExitDescriptor.CodeValue, '') AS GradeLevelCode
    ,COALESCE(ReferenceBasisOfExitDescriptor.Description, '') AS GradeLevelDescription
    ,COALESCE(ReferenceBasisOfExitDescriptor.EdFactsCode, '') AS GradeLevelEdFactsCode
FROM 
    edfi.ReasonExitedDescriptor
LEFT JOIN 
    MapReferenceDescriptor ReferenceBasisOfExitDescriptor
    ON ReasonExitedDescriptor.ReasonExitedDescriptorId = ReferenceBasisOfExitDescriptor.DescriptorId
	AND ReferenceBasisOfExitDescriptor.EdFiTableName = 'xref.GradeLevels'
