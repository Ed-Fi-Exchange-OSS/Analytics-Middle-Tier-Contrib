-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
DROP VIEW IF EXISTS analytics.ceds_SchoolYearsDim;

CREATE OR REPLACE VIEW analytics.ceds_SchoolYearsDim
AS (
    SELECT
        SchoolYearDescription AS SchoolYearKey,
        SchoolYear,
        CONCAT('01-07-',SUBSTRING(SchoolYearDescription, 1,4)) AS SessionBeginDate,
        CONCAT('06-30-',SUBSTRING(SchoolYearDescription, 6,9)) AS SessionEndDate,
        LastModifiedDate
    FROM edfi.SchoolYearType
)
