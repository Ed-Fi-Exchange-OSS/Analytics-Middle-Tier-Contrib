-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.VIEWS
        WHERE TABLE_SCHEMA = 'analytics'
            AND TABLE_NAME = 'ceds_SchoolYearDim'
        )
BEGIN
    DROP VIEW analytics.ceds_SchoolYearDim;
END;
GO

CREATE
    OR

ALTER VIEW analytics.ceds_SchoolYearDim
AS
(
        SELECT '-1' AS SchoolYearDimId
            , '-1' AS SchoolYearKey
            , '' AS SchoolYear
            , '' AS SessionBeginDate
            , '' AS SessionEndDate
            , 19000101 AS SessionBeginDateKey
            , 19000101 AS SessionEndDateKey
            , GETDATE() AS LastModifiedDate
        
        UNION ALL
        
        SELECT ROW_NUMBER() OVER (
                ORDER BY SchoolYearDescription
                ) AS SchoolYearDimId
            , SchoolYearDescription AS SchoolYearKey
            , SchoolYear
            , CONCAT (
                '01-07-'
                , SUBSTRING(SchoolYearDescription, 1, 4)
                ) AS SessionBeginDate
            , CONCAT (
                '30-06-'
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
