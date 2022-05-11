# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

#Requires -RunAsAdministrator

function Submit-TestMSSQL {
	Param (
        [Parameter(Mandatory = $true)]
        [string] $connectionString,
        [Parameter(Mandatory = $true)]
        [string] $name,
		[Parameter(Mandatory = $true)]
        [string] $query
    )
    
    # ToDo: The Export-Csv parameter should be configurable instead of hardcoded.
	Invoke-Sqlcmd -Query $query -ConnectionString $connectionString | Export-Csv "C:\temp\testsResults\MSSQL\test_$name.csv" -Delimiter "," -NoTypeInformation
}

function Submit-TestPostgreSQL {
	Param (
        [Parameter(Mandatory = $true)]
        [string] $connectionStringURL,
        [Parameter(Mandatory = $true)]
        [string] $name,
		[Parameter(Mandatory = $true)]
        [string] $query
    )
    
    return $query | psql $connectionStringURL | ConvertFrom-Csv
}

Export-ModuleMember Submit-TestMSSQL, Submit-TestPostgreSQL
