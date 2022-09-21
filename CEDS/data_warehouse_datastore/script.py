# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

import pyodbc 
import json
import pandas as pd

from factK12_program_participation import factK12_program_participation
from factK12_student_enrollment import factK12_student_enrollment

# Databases connection string
def get_configuration():
    with open('./configuration.json', "r") as file:
        configuration = json.load(file)
    return configuration

# List of views
def get_views() -> list:
    with open('./views.json', "r") as file:
        views = json.load(file)
    return views

# Inserts dummy values into the data warehouse
def insert_dummy_values(config):
    conn_target = pyodbc.Connection
    try:
        print("Inserting dummy values...", end = '')
        conn_target = pyodbc.connect(
            f'Driver={"SQL Server"};Server={config["Target"]["Server"]};Database={config["Target"]["Database"]};Trusted_Connection={config["Target"]["Trusted_Connection"]};')
        
        with open('./dummy_values_inserts.sql','r') as file:
            sql_script = file.read()
            conn_target.execute(sql_script)
            conn_target.commit()
            conn_target.close()

        print ("Done!")

    except Exception as error:
        print (error)

def question_marks_for_insert(text = str)-> str:
    x = text.split(",")
    str_values = ''.join(['?,' for n in x])
    return str_values[:len(str_values) - 1]

# Transfer data
def transfer_data(view_info, config) -> pd.DataFrame:
    conn_source = pyodbc.Connection
    conn_target = pyodbc.Connection
    try:
        conn_source = pyodbc.connect(
            f'Driver={"SQL Server"};Server={config["Source"]["Server"]};Database={config["Source"]["Database"]};Trusted_Connection={config["Source"]["Trusted_Connection"]};')
        
        conn_target = pyodbc.connect(
            f'Driver={"SQL Server"};Server={config["Target"]["Server"]};Database={config["Target"]["Database"]};Trusted_Connection={config["Target"]["Trusted_Connection"]};')

        data = pd.read_sql(f"SELECT {view_info['select']} FROM {view_info['source_view']};", conn_source)
        
        cursor_target = conn_target.cursor()
        
        for index, row in data.iterrows():
            row_insert = row[1:]

            if not view_info['target_fields']:
                view_info['target_fields'] = view_info['select']
            
            question_marks = question_marks_for_insert(view_info['target_fields'])

            cursor_target.execute(f"INSERT INTO {view_info['target_view']}({view_info['target_fields']}) VALUES ({question_marks});", *row_insert)
            identity = cursor_target.execute(f"SELECT @@IDENTITY AS id;").fetchone()[0]
            data.at[index,'id'] = int(identity)

        conn_target.commit()
        return data

    except Exception as error:
        print (error)
        
    finally:
        conn_source.close()
        conn_target.close()

if __name__ == "__main__":
    dataFrames = {}
    config = get_configuration()
    insert_dummy_values(config)
    views = get_views()
    for view in views:
        data = transfer_data(view, config)
        dataFrames[view["source_view"]] = data

    # fact tables:
    factK12_program_participation(dataFrames, views, config)
    factK12_student_enrollment(dataFrames, views, config)