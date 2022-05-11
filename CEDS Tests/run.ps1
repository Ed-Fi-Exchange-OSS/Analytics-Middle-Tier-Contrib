# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

#Requires -RunAsAdministrator

param (
    [string] $configPath = "$PSScriptRoot\configuration.json"
)

$ErrorActionPreference = "Stop"

#--- IMPORT MODULES ---
Import-Module -Force "$PSScriptRoot\confighelper.psm1"
Import-Module -Force "$PSScriptRoot\scripts\Utilities.psm1"
Import-Module -Force "$PSScriptRoot\scripts\TestsModules\TestRunner.psm1"

$configuration = Format-ConfigurationFileToHashTable $configPath
$testsLocation = "$PSScriptRoot\testCases\"

function Find-Tests () {
    
    # With this line we create an array with the path to the xml test files.
    return @(Get-ChildItem -Path "$testsLocation" -Name -Include *.xml)
}

function Extract-TestData () {
    Param (
        [System.Collections.ArrayList] [Parameter(Mandatory=$true)] $testFileNames
    )

    $testCases = [pscustomobject]@()

    foreach ($testFileName in $testFileNames) {
        [xml]$XmlDocument = Get-Content -Path (Join-Path $testsLocation $testFileName)

        $testCaseObject = [PSCustomObject]@{
            Name = $XmlDocument.Test.Name
            Query = $XmlDocument.Test.Query
            Result = $XmlDocument.Test.Result
        }

        $testCases += $testCaseObject
    }

    return $testCases
}

function Submit-TestsMSSQL {
    Param (
        [Parameter(Mandatory=$true)]
        [string] $name,
        [Parameter(Mandatory=$true)]
        [string] $query,
        [Parameter(Mandatory=$true)]
        [string ] $expectedResult
    )
    
    $connectionStringParams = @{
        host = $configuration.SQLServerConfig.ConnectionString.Host
        database = $configuration.SQLServerConfig.ConnectionString.Database
        username = $configuration.SQLServerConfig.ConnectionString.Username
        password = $configuration.SQLServerConfig.ConnectionString.Password
        integratedSecurity = $configuration.SQLServerConfig.ConnectionString.IntegratedSecurity
    }

    $connectionString = Get-ConnectionStringMSSQL @connectionStringParams
    Submit-TestMSSQL $connectionString $name $query

    # ToDo: This path should be configurable instead of hardcoded. In this file we have the result of the execution of the query.
    $actualResult = (Get-Content -Path "C:\temp\testsResults\MSSQL\test_$name.csv")

    Write-Host "actualResult: $actualResult"
    Write-Host "expectedResult: $expectedResult"

    $objects = @{
        ReferenceObject = $actualResult
        DifferenceObject = $expectedResult
    }

    # The idea here is to compare the actual result of the tests against the expected result.
    #   https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/compare-object?view=powershell-7.2
    $comparison = Compare-Object @objects # | Set-Content "C:\temp\testsResults\MSSQL\result_$name.txt"

    Write-Host "comparison: $comparison"

    # And then find the differences. 
    # If this filter results something, then the actual result and the expected result are different, and the test is failing.
    $differences = $comparison | Where-Object {$_.SideIndicator -eq "=>" -or $_.SideIndicator -eq "<="}

    Write-Host "differences: $differences"
}

# ToDo: Everything related to executing the tests for Postgres is pending.
function Submit-TestsPostgreSQL {
    Param (
        [Parameter(Mandatory=$true)]
        [string] $name,
        [Parameter(Mandatory=$true)]
        [string] $query,
        [Parameter(Mandatory=$true)]
        [string] $result
    )
    
    $connectionStringParams = @{
        host = $configuration.PostgreSQLConfig.ConnectionString.Host
        port = $configuration.PostgreSQLConfig.ConnectionString.Port
        database = $configuration.PostgreSQLConfig.ConnectionString.Database
        username = $configuration.PostgreSQLConfig.ConnectionString.Username
        password = $configuration.PostgreSQLConfig.ConnectionString.Password
    }

    $connectionStringPostgreSqlUrl = Get-ConnectionStringPostgreSqlUrl @connectionStringParams
    Submit-TestPostgreSQL $connectionStringPostgreSqlUrl $name $query

    # Compare results.

}

$testFileNames = Find-Tests
$testCases = Extract-TestData $testFileNames

foreach ($testCase in $testCases) {
    $testResult = Submit-TestsMSSQL $testCase.Name $testCase.Query $testCase.Result
}

# Third step
# Execute the tests.

# Jose Leiva recommends not using odbc if possible, for postgres, because it can be very problematic.

# Manage SQL Server on Linux with PowerShell Core
# https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-manage-powershell-core?view=sql-server-ver15
