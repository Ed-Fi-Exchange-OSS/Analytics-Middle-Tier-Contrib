-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.VIEWS
        WHERE TABLE_SCHEMA = 'analytics_config'
            AND TABLE_NAME = 'ceds_TableReference'
        )
BEGIN
    CREATE TABLE analytics_config.ceds_TableReference ( 
		TableId INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
		TableName VARCHAR(250) NOT NULL
	);
END;
	
