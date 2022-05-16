# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

#Requires -RunAsAdministrator

param (
    [string] $configPath = "$PSScriptRoot\configuration.json",
    [string][Alias('e')]$engine="all"
)

$ErrorActionPreference = "Stop"

#--- IMPORT MODULES ---
Import-Module -Force "$PSScriptRoot\confighelper.psm1"
$configuration = Format-ConfigurationFileToHashTable $configPath
Import-Module -Force "$PSScriptRoot\scripts\Utilities.psm1" -ArgumentList $configuration
Import-Module -Force "$PSScriptRoot\scripts\TestsModules\TestRunner.psm1"

$testsLocation = "$PSScriptRoot\testCases\"

function Find-Tests () {
    # With this line we create an array with the path to the xml test files.
    return @(Get-ChildItem -Path "$testsLocation" -Name -Include *.xml -Recurse -Force)
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
            ResultFile = $XmlDocument.Test.ResultFile
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
        [string] $expectedResultFile,
        [Parameter(Mandatory=$true)]
        [string] $connectionString
    )

    Submit-TestMSSQL $connectionString $name $query

    # Check if expected result file exists.
    if ((Test-Path -Path "$($testsLocation)results\MSSQL\$expectedResultFile" -PathType leaf) -eq $true) {
        $diff = (&git diff "$($configuration.TestsConfig.ExecutionResultsPath)MSSQL\test_${name}_actualresult.csv" ".\testCases\results\MSSQL\$expectedResultFile")
    }
    else {
        return $false;
    }

    return [string]::IsNullOrEmpty($diff)
}

function Submit-TestsPostgreSQL {
    Param (
        [Parameter(Mandatory=$true)]
        [string] $name,
        [Parameter(Mandatory=$true)]
        [string] $query,
        [Parameter(Mandatory=$true)]
        [string] $expectedResultFile,
        [Parameter(Mandatory=$true)]
        [string] $connectionString
    )
    
    Submit-TestPostgreSQL $connectionString $name $query

    if ((Test-Path -Path "$($testsLocation)results\PostgreSQL\$expectedResultFile" -PathType leaf) -eq $true) {
        $diff = (&git diff "$($configuration.TestsConfig.ExecutionResultsPath)PostgreSQL\test_${name}_actualresult.csv" ".\testCases\results\PostgreSQL\$expectedResultFile")
    }
    else {
        return $false;
    }

    return [string]::IsNullOrEmpty($diff)
}

$testFileNames = Find-Tests
$testCases = Extract-TestData $testFileNames

Write-Host "These are the tests found..." -ForegroundColor Cyan
foreach ($testCase in $testCases) {
    Write-Host "    $($testCase.Name)" -ForegroundColor Cyan
}
Write-Host "... End of tests found.`n" -ForegroundColor Cyan

$numberOfTestsThatFailedMSSQL = 0
$numberOfTestsThatFailedPostgreSQL = 0

# MSSQL
if ($engine -eq "all" -or $engine -eq "mssql") {

    Write-Host "Executing tests for MSSQL..." -ForegroundColor Cyan

    foreach ($testCase in $testCases) {
        $connectionStringMSSQL = Get-ConnectionStringMSSQL
        $testPassed = Submit-TestsMSSQL $connectionStringMSSQL $testCase.Name $testCase.Query $testCase.ResultFile $configuration.TestsConfig.ExecutionResultsPath

        if ($testPassed -eq $true) {
            Write-Host "    Test with name $($testCase.Name) has been executed successfully." -ForegroundColor Green
        }
        else {
            Write-Host "    Test with name $($testCase.Name) has failed for MSSQL." -ForegroundColor Red
            $numberOfTestsThatFailedMSSQL++
        }
    }

    Write-Host "... Tests for MSSQL have been executed." -ForegroundColor Cyan
    
    Write-Host "Number of tests that failed for MSSQL is $($numberOfTestsThatFailedMSSQL).`n" -ForegroundColor Cyan
}

# PostgreSQL
if ($engine -eq "all" -or $engine -eq "postgresql") {
    
    Write-Host "Executing tests for PostgreSQL..." -ForegroundColor Cyan

    foreach ($testCase in $testCases) {
        $connectionStringPostgreSqlUrl = Get-ConnectionStringPostgreSqlUrl
        $testPassed = Submit-TestsPostgreSQL $connectionStringPostgreSqlUrl $testCase.Name $testCase.Query $testCase.ResultFile $configuration.TestsConfig.ExecutionResultsPath

        if ($testPassed -eq $true) {
            Write-Host "    Test with name $($testCase.Name) has been executed successfully." -ForegroundColor Green
        }
        else {
            Write-Host "    Test with name $($testCase.Name) has failed for PostgreSQL." -ForegroundColor Red
            $numberOfTestsThatFailedPostgreSQL++
        }
    }

    Write-Host "... Tests for PostgreSQL have been executed." -ForegroundColor Cyan

    Write-Host "Number of tests that failed for PostgreSQL is $($numberOfTestsThatFailedPostgreSQL).`n" -ForegroundColor Cyan
}

Write-Host "Total number of tests is $($testCases.Count)." -ForegroundColor Cyan
Write-Host "Number of tests that passed successfully is $($testCases.Count - $numberOfTestsThatFailed)." -ForegroundColor Cyan

if ($numberOfTestsThatFailedMSSQL -ne 0 -or $numberOfTestsThatFailedPostgreSQL -ne 0) {
    Write-Host "`nTo check why a test failed, go to $($configuration.TestsConfig.ExecutionResultsPath) and review the actual result of the query." -ForegroundColor Red
}