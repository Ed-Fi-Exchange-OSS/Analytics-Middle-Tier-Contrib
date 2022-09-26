# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

import json
import pandas as pd
from sqlalchemy.engine import URL
from sqlalchemy import create_engine
from sqlalchemy.types import Integer, Text, String, DateTime

def dim_school_years(config) -> pd.DataFrame:
    try:
        source_connection_string = f'Driver={"SQL Server"};Server={config["Source"]["Server"]};Database={config["Source"]["Database"]};Trusted_Connection={config["Source"]["Trusted_Connection"]};'
        source_connection_url = URL.create("mssql+pyodbc", query={"odbc_connect": source_connection_string})
        source_engine = create_engine(source_connection_url).execution_options(isolation_level="AUTOCOMMIT")
        
        school_year_dim = pd.DataFrame
        with source_engine.connect() as conection_source:
            school_year_dim = pd.read_sql(f"select [SchoolYearKey],[SchoolYear],[SessionBeginDate],[SessionEndDate] from analytics.ceds_SchoolYearDim;", conection_source)
            
        target_connection_string = f'Driver={"SQL Server"};Server={config["Target"]["Server"]};Database={config["Target"]["Database"]};Trusted_Connection={config["Target"]["Trusted_Connection"]};'
        target_connection_url = URL.create("mssql+pyodbc", query={"odbc_connect": target_connection_string})
        target_engine = create_engine(target_connection_url).execution_options(isolation_level="AUTOCOMMIT")
        
        target_engine.execute('lock tables analytics.ceds_SchoolYearDim write')
        max_id_query = 'select max(DimSchoolYearId) FROM RDS.DimSchoolYears'
        max_id = int(pd.read_sql_query(max_id_query, target_engine).values)
        print ('max id')
        print (max_id)
        school_year_dim['DimSchoolYearId'] = range(max_id + 1, max_id + len(school_year_dim) + 1)

        school_year_dim.to_sql(
            'RDS.DimSchoolYears',
            target_engine,
            if_exists='replace',
            index=False,
            chunksize=500,
            dtype={
                "SchoolYear": Integer,
                "SessionBeginDate": DateTime,
                "SessionEndDate": DateTime
            }
        )

        # print (school_year_dim)
        return school_year_dim
        
    finally:
        target_engine.execute('unlock tables')
