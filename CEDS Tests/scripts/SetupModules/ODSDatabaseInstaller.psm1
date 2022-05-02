# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

#Requires -RunAsAdministrator

$packageSource = 'https://www.myget.org/F/ed-fi/'

function Deploy-MSSQL {
    param (
        [String] $packageName = "EdFi.Suite3.Ods.Minimal.Template",
        [String] $packageVersion = "5.4.114",
        [String] $downloadLocation = "C:\temp\downloads\",
        [String] $serverInstance  = "localhost",
        [String] $database = "EdFi_OdsT1"
    )

    # ToDo: Do not hardcode this variable. It must be a parameter.
    $packageName = "EdFi.Suite3.Ods.Minimal.Template"

    nuget install $packageName -source $packageSource -Version $packageVersion -outputDirectory $downloadLocation -ConfigFile "$PSScriptRoot\nuget.config" | Out-Host

    $bakFilePath = Join-Path $downloadLocation "$packageName.$packageVersion"
    $bakFileName = Get-ChildItem -Path $bakFilePath -Name  -Include *.bak

    # ToDo: Better location for these files.
    $RelocateData = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("EdFi_Ods_Populated_Template_Test", "$bakFilePath\EdFi_Ods_Populated_Template_Test.mdf")
    $RelocateLog = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("EdFi_Ods_Populated_Template_Test_Log", "$bakFilePath\EdFi_Ods_Populated_Template_Test_Log.ldf")

    Restore-SqlDatabase -ServerInstance $serverInstance -Database $database -BackupFile "$bakFilePath\$bakFileName" -RelocateFile @($RelocateData,$RelocateLog)
}

function Deploy-PostgreSQL {
    param (
        $packageName = "EdFi.Suite3.Ods.Minimal.Template.PostgreSQL",
        $packageVersion = "5.4.99",
        $downloadLocation = "C:\temp\downloads\",
        $host = "localhost",
        $database = "EdFi_OdsT1",
        $port = "5432",
        $user = "postgres",
        $password = "gapUser123"
    )

    # ToDo: Do not hardcode this variable. It must be a parameter.
    $packageName = "EdFi.Suite3.Ods.Minimal.Template.PostgreSQL"

    # Download and install the ODS database we will use for testing purposes.
    #    https://dev.azure.com/ed-fi-alliance/Ed-Fi-Alliance-OSS/_artifacts/feed/EdFi
    #           Download the nuget package, extract it, and take the bak file. 

    # First install package with the ods we can use.
    nuget install $packageName -source $packageSource -Version $packageVersion -outputDirectory $downloadLocation -ConfigFile "$PSScriptRoot\nuget.config" | Out-Host

    $bakFilePath = Join-Path $downloadLocation "$packageName.$packageVersion"
    $bakFileName = Get-ChildItem -Path $bakFilePath -Name  -Include *.sql

    Write-Host "bakFilePath: $bakFilePath"
    Write-Host "bakFileName: $bakFileName"

    $database = $database.ToLower()
    $dropDatabase = "DROP DATABASE IF EXISTS " + $database +";"
    $createDatabase = "CREATE DATABASE " + $database +";"

    # ToDO: The password is being prompted. This is not ideal.
    Write-Host "dropping db if it exists"
    psql -h $host -p $port -U $user -c $dropDatabase
    Write-Host "creating db"
    psql -h $host -p $port -U $user -c $createDatabase
    Write-Host "Running migration on db"
    psql -d $database -h $host -p $port  -U $user -f "$bakFilePath\$bakFileName"
}

Export-ModuleMember Deploy-MSSQL,Deploy-PostgreSQL