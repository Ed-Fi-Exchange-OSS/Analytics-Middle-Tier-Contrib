# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

# Here we need to find the unit tests, call the other modules to execute them.

#Requires -RunAsAdministrator
param(
    [parameter(Position=0,Mandatory=$true)][Hashtable]$configuration
)

$ErrorActionPreference = "Stop"

function Find-Tests () {
    
    # With this line we create an array with the path to the xml test files.
    return @(Get-ChildItem -Path $configuration.TestsLocation -Name -Include *.xml)
}

function Extract-TestData () {
    Param (
        [string] [Parameter(Mandatory=$true)] $testFileNames
    )
    # Input
    #     The content of the test json file.

    # Output
    #     An object with the different components of the test: Name, query, result.

    $testCases = @($null) * $testFileNames.Length

    for ($i = 0; $i -le ($testFileNames.Length - 1); $i += 1) {
        [xml]$XmlDocument = Get-Content -Path (Join-Path $configuration.TestsLocation $testFileNames[$i])
    
        $testCases[$i].Name = $XmlDocument.Test.Name
        $testCases[$i].Query = $XmlDocument.Test.Query
        $testCases[$i].Result = $XmlDocument.Test.Result
    }

    return @testCases
}

@testFileNames = Find-Tests
@testCases = Extract-TestData @testFileNames

# Find-Test
# Foreach test in the list
#   Extract-TestData: Name, query, result.
#   Call Execute-Test from TestRunner
#   Compare the results. 
#   Store the results. 

# Output the results.

# Some notes:
# Maybe somehting like
    # $query = "select * from [Ed-Fi-Glendale-3.1.0].edfi.School;"
    # $data = Invoke-Sqlcmd -ServerInstance "localhost" -Query "select * from [Ed-Fi-Glendale-3.1.0].edfi.School;"
    # $data | Export-Csv -Append -Path "C:\GAP\somefile.csv" -NoTypeInformation

# Jose Leiva recommends not using odbc if possible, for postgres, because it can be very problematic.

# Manage SQL Server on Linux with PowerShell Core
# https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-manage-powershell-core?view=sql-server-ver15
