# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

#Requires -RunAsAdministrator

$packageSource = 'https://www.myget.org/F/ed-fi/'

function Install-MSSQLODS {
    param (
        [String] $packageName = "EdFi.Suite3.Ods.Minimal.Template",
        [String] $packageVersion = "5.4.114",
        [String] $downloadLocation = "C:\temp\downloads\",
        [String] $serverInstance  = "localhost",
        [String] $database = "EdFi_Ods_Ceds"
    )

    nuget install $packageName -source $packageSource -Version $packageVersion -outputDirectory $downloadLocation -ConfigFile "$PSScriptRoot\nuget.config" | Out-Host

    $bakFilePath = Join-Path $downloadLocation "$packageName.$packageVersion"
    $bakFileName = Get-ChildItem -Path $bakFilePath -Name  -Include *.bak

    $RelocateData = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("EdFi_Ods_Populated_Template_Test", "$bakFilePath\EdFi_Ods_Populated_Template_Test.mdf")
    $RelocateLog = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("EdFi_Ods_Populated_Template_Test_Log", "$bakFilePath\EdFi_Ods_Populated_Template_Test_Log.ldf")

    Restore-SqlDatabase -ServerInstance $serverInstance -Database $database -BackupFile "$bakFilePath\$bakFileName" -RelocateFile @($RelocateData,$RelocateLog)
}

function Install-PostgreSQLODS {
    param (
        $packageName = "EdFi.Suite3.Ods.Minimal.Template.PostgreSQL",
        $packageVersion = "5.4.99",
        $downloadLocation = "C:\temp\downloads\",
        $host = "localhost",
        $port = "5432",
        $database = "edfi_ods_ceds",
        $user = "postgres",
        $connectionStringPostgreSqlUrl = ""
    )

    nuget install $packageName -source $packageSource -Version $packageVersion -outputDirectory $downloadLocation -ConfigFile "$PSScriptRoot\nuget.config" | Out-Host

    $bakFilePath = Join-Path $downloadLocation "$packageName.$packageVersion"
    $bakFileName = Get-ChildItem -Path $bakFilePath -Name -Include *.sql

    $database = $database.ToLower()
    $createDatabase = "CREATE DATABASE " + $database +";"

    $createDatabase | psql $connectionStringPostgreSqlUrl

    psql -d $database -h $host -p $port -U $user -f "$bakFilePath\$bakFileName"
}

Export-ModuleMember Install-MSSQLODS, Install-PostgreSQLODS