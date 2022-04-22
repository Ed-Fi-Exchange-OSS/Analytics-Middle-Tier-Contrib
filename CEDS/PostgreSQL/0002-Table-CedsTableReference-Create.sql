-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.

CREATE SEQUENCE IF NOT EXISTS analytics_config.ceds_TableReference_seq;

CREATE TABLE IF NOT EXISTS analytics_config.ceds_TableReference (
	TableId INT DEFAULT NEXTVAL('analytics_config.ceds_TableReference_seq') NOT NULL,
	TableName VARCHAR(250) NOT NULL,
	CONSTRAINT PK_ceds_TableReference_EdFiTable PRIMARY KEY(TableId)
)
