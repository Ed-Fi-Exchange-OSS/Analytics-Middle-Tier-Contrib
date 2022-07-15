-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.

CREATE TABLE IF NOT EXISTS analytics_config.ceds_TableInformation (
	DescriptorId INT NOT NULL,
	CodeValue VARCHAR(50) NOT NULL,
	EdFactsCode VARCHAR(50) NOT NULL,
	TableId INT NOT NULL,
	CONSTRAINT FK_ceds_TableReference_ceds_TableInformation PRIMARY KEY(DescriptorId,TableId),
	CONSTRAINT FK_ceds_TableInformation_CedsTable FOREIGN KEY (TableId) REFERENCES analytics_config.ceds_TableReference(TableId)
)