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
Import-Module -Force "$PSScriptRoot\ConfigHelper.psm1"
$configuration = Format-ConfigurationFileToHashTable $configPath
Import-Module -Force "$PSScriptRoot\scripts\MigratorModules\EdFi-CedsViews.psm1"
Import-Module -Force "$PSScriptRoot\scripts\MigratorModules\EdFi-AMT.psm1" -ArgumentList $configuration
Import-Module -Force "$PSScriptRoot\scripts\Utilities.psm1" -ArgumentList $configuration

$server = $configuration.Server

Write-Host "Server: $server" -ForegroundColor Cyan

if ($null -eq $server) {
    $server = "SQLServer"
}

if ($server -eq "SQLServer") {
    Write-Host "Installing AMT for MSSQL..." -ForegroundColor Cyan

    $parameters = @{
        databasesConfig  = @{
            engine = "SQLServer"
        }
        amtDownloadPath  = $configuration.amtConfig.amtDownloadPath
        amtInstallerPath = $configuration.amtConfig.amtInstallerPath
        amtOptions       = $configuration.amtConfig.options
    }
    
    Install-amt @parameters
    
    Write-Host "AMT has been installed for MSSQL" -ForegroundColor Cyan

    Write-Host "Installing CEDS Collection for MSSQL..." -ForegroundColor Cyan
    
    $connectionString = Get-ConnectionStringMSSQL
    
    Install-CedsViews $connectionString "$PSScriptRoot\..\CEDS Views\MSSQL\"
    
    Write-Host "CEDS Collection has been installed for MSSQL" -ForegroundColor Cyan
}
else {
    Write-Host "Installing AMT for PostgreSQL..." -ForegroundColor Cyan
    
    $parameters = @{
        databasesConfig  = @{
            engine = "PostgreSQL"
        }
        amtDownloadPath  = $configuration.amtConfig.amtDownloadPath
        amtInstallerPath = $configuration.amtConfig.amtInstallerPath
        amtOptions       = $configuration.amtConfig.options
    }
    
    Install-amt @parameters
    
    Write-Host "AMT has been installed for PostgreSQL" -ForegroundColor Cyan
    
    Write-Host "Installing CEDS Collection for PostgreSQL..." -ForegroundColor Cyan
    
    $connectionString = Get-ConnectionStringPostgreSQL
    
    Install-CedsViews $connectionString "$PSScriptRoot\..\CEDS\CEDS Views\PostgreSQL\"
    
    Write-Host "CEDS Collection has been installed for PostgreSQL" -ForegroundColor Cyan
}
