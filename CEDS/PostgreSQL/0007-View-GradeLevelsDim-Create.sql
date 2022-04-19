-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
DROP VIEW IF EXISTS xref.ceds_GradeLevelDim;

CREATE OR REPLACE VIEW xref.ceds_GradeLevelDim
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
            ReferenceBasisOfExitDescriptor.EdFactsCode, 
            '-', 
            ReferenceBasisOfExitDescriptor.CodeValue,
            '-',
            ReferenceBasisOfExitDescriptor.Description
        ) AS GradeLevelKey
    ,COALESCE(ReferenceBasisOfExitDescriptor.CodeValue, '') AS GradeLevelCode
    ,COALESCE(ReferenceBasisOfExitDescriptor.Description, '') AS GradeLevelDescription
    ,COALESCE(ReferenceBasisOfExitDescriptor.EdFactsCode, '') AS GradeLevelEdFactsCode
FROM 
    edfi.GradeLevelDescriptor
LEFT JOIN 
    MapReferenceDescriptor AS ReferenceBasisOfExitDescriptor
    ON GradeLevelDescriptor.GradeLevelDescriptorId = ReferenceBasisOfExitDescriptor.DescriptorId
	AND ReferenceBasisOfExitDescriptor.EdFiTableName = 'xref.GradeLevels'
WHERE 
    GradeLevelDescriptor.GradeLevelDescriptorId IS NOT NULL
    AND ReferenceBasisOfExitDescriptor.EdFiTableName IS NOT NULL
    AND ReferenceBasisOfExitDescriptor.EdFactsCode IS NOT NULL
ORDER BY
    GradeLevelKey
GO
