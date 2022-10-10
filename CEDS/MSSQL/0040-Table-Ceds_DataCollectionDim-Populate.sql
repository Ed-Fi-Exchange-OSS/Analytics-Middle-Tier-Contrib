-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
MERGE INTO analytics_config.ceds_DataCollectionDim AS Target
USING (SELECT DataCollectionDimId
			, DataCollectionName
			, DataCollectionDescription
FROM
	(VALUES
		(1,'EdFi ODS','Membership Source System'),
		(2,'EdFi ODS','SPED Source System')
	) ReferenceTableName (DataCollectionDimId
			, DataCollectionName
			, DataCollectionDescription)
)  Source(DataCollectionDimId
			, DataCollectionName
			, DataCollectionDescription)
ON TARGET.DataCollectionDimId = Source.DataCollectionDimId
WHEN NOT MATCHED BY TARGET
THEN
      INSERT
	  (
		DataCollectionDimId
		, DataCollectionName
		, DataCollectionDescription
	  )
	  VALUES
      (
        Source.DataCollectionDimId
		, Source.DataCollectionName
		, Source.DataCollectionDescription
      );
	
