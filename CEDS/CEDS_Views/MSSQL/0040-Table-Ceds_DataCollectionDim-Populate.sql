-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.
MERGE INTO analytics_config.ceds_DataCollectionDim AS Target
USING (SELECT DataCollectionDimKey
			, DataCollectionName
			, DataCollectionDescription
FROM
	(VALUES
		(1,'EdFi ODS','Membership Source System'),
		(2,'EdFi ODS','SPED Source System')
	) ReferenceTableName (DataCollectionDimKey
			, DataCollectionName
			, DataCollectionDescription)
)  Source(DataCollectionDimKey
			, DataCollectionName
			, DataCollectionDescription)
ON TARGET.DataCollectionDimKey = Source.DataCollectionDimKey
WHEN NOT MATCHED BY TARGET
THEN
      INSERT
	  (
		DataCollectionDimKey
		, DataCollectionName
		, DataCollectionDescription
	  )
	  VALUES
      (
        Source.DataCollectionDimKey
		, Source.DataCollectionName
		, Source.DataCollectionDescription
      );
	
