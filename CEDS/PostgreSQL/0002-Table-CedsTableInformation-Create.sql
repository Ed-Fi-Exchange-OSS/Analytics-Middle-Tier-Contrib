-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.

CREATE TABLE IF NOT EXISTS xref.CedsTableInformation (
	DescriptorId INT NOT NULL,
	CodeValue VARCHAR(50) NOT NULL,
	EdFactsCode VARCHAR(50) NOT NULL,
	TableId INT NOT NULL,
	CONSTRAINT FK_CedsTableReference_CedsTableInformation PRIMARY KEY(DescriptorId),
	CONSTRAINT FK_CedsTableInformation_CedsTable FOREIGN KEY (TableId) REFERENCES xref.CedsTableReference(TableId)
)