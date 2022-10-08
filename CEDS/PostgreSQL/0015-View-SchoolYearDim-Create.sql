-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
DROP VIEW

IF EXISTS analytics.ceds_SchoolYearDim;
    CREATE
        OR REPLACE VIEW analytics.ceds_SchoolYearDim AS (
        SELECT '-1' AS SchoolYearDimId
            , '-1' AS SchoolYearKey
            , '-1' AS SchoolYear
            , '' AS SessionBeginDate
            , '' AS SessionEndDate
            , 19000101 AS SessionBeginDateKey
            , 19000101 AS SessionEndDateKey
            , NOW() AS LastModifiedDate
        
        UNION ALL
        
        SELECT ROW_NUMBER() OVER (
                ORDER BY SchoolYearDescription
                ) AS SchoolYearDimId
            , SchoolYearDescription AS SchoolYearKey
        , CAST(SchoolYear AS VARCHAR) AS SchoolYear
        , CONCAT (
            '07-01-'
            , SUBSTRING(SchoolYearDescription, 1, 4)
            ) AS SessionBeginDate
        , CONCAT (
            '06-30-'
            , SUBSTRING(SchoolYearDescription, 6, 9)
            ) AS SessionEndDate
            , CAST(CONCAT (
                    SUBSTRING(SchoolYearDescription, 1, 4)
                    , '0701'
                    ) AS INT) AS SessionBeginDateKey
            , CAST(CONCAT (
                    SUBSTRING(SchoolYearDescription, 6, 9)
                    , '0630'
                    ) AS INT) AS SessionEndDateKey
            , LastModifiedDate
        FROM edfi.SchoolYearType
        );
