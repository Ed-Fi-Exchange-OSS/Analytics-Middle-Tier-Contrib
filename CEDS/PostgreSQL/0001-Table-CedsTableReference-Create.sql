-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.

CREATE SEQUENCE IF NOT EXISTS xref.CedsTableReference_seq;

CREATE TABLE IF NOT EXISTS xref.CedsTableReference (
	TableId INT DEFAULT NEXTVAL('xref.CedsTableReference_seq') NOT NULL,
	TableName VARCHAR(250) NOT NULL,
	CONSTRAINT PK_CedsTableReference_EdFiTable PRIMARY KEY(TableId)
)
