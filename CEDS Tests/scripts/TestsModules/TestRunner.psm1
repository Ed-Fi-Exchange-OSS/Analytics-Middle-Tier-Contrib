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
        [string] $query,
		[Parameter(Mandatory = $true)]
        [string] $executionResultsPath
    )
    
	Invoke-Sqlcmd -Query $query -ConnectionString $connectionString | Export-Csv "$executionResultsPath\MSSQL\test_${name}_actualresult.csv" -Delimiter "," -NoTypeInformation
}

function Submit-TestPostgreSQL {
	Param (
        [Parameter(Mandatory = $true)]
        [string] $connectionStringURL,
        [Parameter(Mandatory = $true)]
        [string] $name,
		[Parameter(Mandatory = $true)]
        [string] $query,
		[Parameter(Mandatory = $true)]
        [string] $executionResultsPath
    )
    
    $query | psql "-A" "-F," $connectionStringURL | Out-File -FilePath "$executionResultsPath\PostgreSQL\test_${name}_actualresult.csv"
}

Export-ModuleMember Submit-TestMSSQL, Submit-TestPostgreSQL