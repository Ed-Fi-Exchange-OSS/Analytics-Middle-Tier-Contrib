-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.

WITH source AS (VALUES
	('xref.LEAType'),
	('xref.SchoolType'),
	('xref.OperationalStatus'),
	('xref.GradeLevels'),
	('xref.BasisOfExit'),
	('xref.DisabilityDescriptor'),
	('xref.EducationalEnvironmentForSchoolAgeType'),
	('xref.EducationalEnvironmentForEarlyChildhoodType'),
	('xref.EconomicDisadvantageStatus'),
	('xref.HomelessnessStatus'),
	('xref.EnglishLearnerStatus'),
	('xref.MigrantStatus'),
	('xref.MilitaryConnectedStudentIndicator'),
	('xref.HomelessPrimaryNighttimeResidence'),
	('xref.HomelessUnaccompaniedYouthStatus'),
	('xref.Sex'),
	('xref.EntryType'),
	('xref.ProgramType'),
	('xref.Race'),
	('xref.ExitWithdrawType')
)
INSERT INTO 
    analytics_config.ceds_TableReference
(
	TableName
)
SELECT
    source.column1
FROM
    source
ON CONFLICT DO NOTHING;