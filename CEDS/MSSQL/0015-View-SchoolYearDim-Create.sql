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

CREATE OR ALTER VIEW analytics.ceds_SchoolYearDim
AS (
    SELECT
        SchoolYearDescription AS SchoolYearKey,
        SchoolYear,
        CONCAT('01-07-',SUBSTRING(SchoolYearDescription, 1,4)) AS SessionBeginDate,
        CONCAT('06-30-',SUBSTRING(SchoolYearDescription, 6,9)) AS SessionEndDate,
        LastModifiedDate
    FROM edfi.SchoolYearType
)
