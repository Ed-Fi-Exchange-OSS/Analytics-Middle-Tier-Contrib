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
	Invoke-Sqlcmd -Query $query -ConnectionString $connectionString | Export-Csv "C:\temp\testsResults\MSSQL\test_${name}_actualresult.csv" -Delimiter "," -NoTypeInformation
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
    
    # psql $connectionStringURL -d dbname -t -A -F"," -c $query > "C:\temp\testsResults\PostgreSQL\test_${name}_actualresult.csv"

    # $query | psql $connectionStringURL | ConvertFrom-Csv   
    # $query | psql --csv $connectionStringURL | ConvertFrom-Csv | Export-Csv "C:\temp\testsResults\PostgreSQL\test_${name}_actualresult.csv" -Delimiter "," -NoTypeInformation
    $query | psql "-A" "-F," $connectionStringURL | Out-File -FilePath "C:\temp\testsResults\PostgreSQL\test_${name}_actualresult.csv" # -Delimiter "," -NoTypeInformation
    # $query | psql $connectionStringURL | Out-File -FilePath "C:\temp\testsResults\PostgreSQL\test_${name}_actualresult.csv"
}

Export-ModuleMember Submit-TestMSSQL, Submit-TestPostgreSQL