-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_SCHEMA = 'analytics_config'
            AND TABLE_NAME = 'ceds_DataCollectionDim'
        )
BEGIN
    CREATE TABLE analytics_config.ceds_DataCollectionDim (
        DataCollectionDimId INT NOT NULL,
        SourceSystemDataCollectionIdentifier INT NULL,
        SourceSystemName VARCHAR(100) NULL,
        DataCollectionName VARCHAR(100) NOT NULL,
		DataCollectionDescription VARCHAR(1000) NOT NULL,
        DataCollectionOpenDate DATETIME NULL,
        DataCollectionCloseDate DATETIME NULL,
        DataCollectionAcademicSchoolYear VARCHAR(7) NULL,
        DataCollectionSchoolYear VARCHAR(7) NULL,
        CONSTRAINT PK_ceds_DataCollectionDim PRIMARY KEY CLUSTERED (DataCollectionDimId ASC)
        )
END;
