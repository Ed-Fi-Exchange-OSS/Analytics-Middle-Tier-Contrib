-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.

CREATE SEQUENCE IF NOT EXISTS xref.EdFiTableReference_seq;

CREATE TABLE IF NOT EXISTS xref.EdFiTableReference (
	EdFiTableId INT DEFAULT NEXTVAL('xref.EdFiTableReference_seq') NOT NULL,
	EdFiTableName VARCHAR(250) NOT NULL,
	CONSTRAINT PK_EdFiTableReference_EdFiTable PRIMARY KEY(EdFiTableId)
)
