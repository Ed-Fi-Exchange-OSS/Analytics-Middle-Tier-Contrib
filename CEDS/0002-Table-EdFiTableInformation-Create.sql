-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.

CREATE TABLE xref.EdFiTableInformation (
	EdFiDescriptorId INT NOT NULL,
	EdFiCodeValue VARCHAR(50) NOT NULL,
	EdFactsCode VARCHAR(50) NOT NULL,
	EdFiTableId INT NOT NULL,
	CONSTRAINT FK_EdfiTableReference_EdfiTableInformation
	FOREIGN KEY (EdFiTableId)
	REFERENCES xref.EdfiTableReference(EdFiTableId)
)
