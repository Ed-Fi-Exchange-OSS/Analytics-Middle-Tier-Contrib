-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
MERGE INTO analytics_config.ceds_TableReference AS Target
USING (SELECT TableName
FROM
	(VALUES
		('xref.LEAType'),
		('xref.SchoolType'),
		('xref.OperationalStatus'),
		('xref.GradeLevels'),
		('xref.BasisOfExit'),
		('xref.DisabilityDescriptor'),
		('xref.EducationalEnvironmentType'),
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
	) ReferenceTableName (TableName)
)  Source(TableName)
ON TARGET.TableName = Source.TableName
WHEN NOT MATCHED BY TARGET
THEN
      INSERT
	  (
		TableName
	  )
	  VALUES
      (
        Source.TableName
      );
	
