# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

import pyodbc
import os


def insert_dummy_values(config):
    conn_target = pyodbc.Connection
    try:
        print("Inserting dummy values... ", end='')
        conn_target = pyodbc.connect(
            f'Driver={"SQL Server"};Server={config["Target"]["Server"]};Database={config["Target"]["Database"]};Trusted_Connection={config["Target"]["Trusted_Connection"]};')

        with open(f'{os.getcwd()}/dummy_values/dummy_values_inserts.sql', 'r') as file:
            sql_script = file.read()
            conn_target.execute(sql_script)
            conn_target.commit()
            conn_target.close()

        print("Done!")

    except Exception as error:
        print(error)
