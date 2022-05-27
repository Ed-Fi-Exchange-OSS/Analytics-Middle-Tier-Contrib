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
$configuration = Format-ConfigurationFileToHashTable $configPath
Import-Module -Force "$PSScriptRoot\scripts\SetupModules\ODSDatabaseInstaller.psm1"
Import-Module -Force "$PSScriptRoot\scripts\Utilities.psm1" -ArgumentList $configuration

function Install-SqlDatabaseModule {
    if ((Get-InstalledModule -Name "SqlDatabase") -eq $null) {
        Write-Host "Installing the SqlDatabase Module from the PowerShell Gallery..." -ForegroundColor Cyan
        Install-Module -Name SqlDatabase
    }
    else {
        Write-Host "SqlDatabase Module already installed." -ForegroundColor Cyan
    }
}

function Install-SqlServerModule {
    if ((Get-InstalledModule -Name "SqlServer") -eq $null) {
        Write-Host "Installing the SqlServer Module from the PowerShell Gallery..." -ForegroundColor Cyan

        Install-Module -Name SqlServer
    }
    else {
        Write-Host "SqlServer Module already installed." -ForegroundColor Cyan
    }

    Import-Module SqlServer
}

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-SqlDatabaseModule
Install-SqlServerModule

# MSSQL
$connectionString = Get-ConnectionStringMSSQL

if ($null -ne (Get-SqlDatabase -ConnectionString $connectionString)) {
    Write-Host "MSSQL datatabase ${connectionStringParams.database} already exists. Skipping..." -ForegroundColor Cyan
} else {
    Write-Host "Installing ODS for MSSQL..." -ForegroundColor Cyan
    $paramsMSSQL = @{
        packageName = $configuration.ODSDatabaseInstallerConfig.MSSQL.packageDetails.packageName
        packageVersion = $configuration.ODSDatabaseInstallerConfig.MSSQL.packageDetails.version
        downloadLocation = $configuration.ODSDatabaseInstallerConfig.DownloadLocation
        serverInstance = $configuration.SQLServerConfig.ConnectionString.Host
        database = $configuration.SQLServerConfig.ConnectionString.Database
    }

    Install-MSSQLODS @paramsMSSQL
}

# PostgreSQL
$connectionStringPostgreSqlUrl = Get-ConnectionStringPostgreSqlUrl

if ("select exists(select datname from pg_database where datname = '${connectionStringParams.database}');" | psql $connectionStringPostgreSqlUrl | ConvertFrom-Csv) {
    Write-Host "PostgreSQL datatabase ${connectionStringParams.database} already exists. Skipping..." -ForegroundColor Cyan
} else {
    Write-Host "Installing ODS for PostgreSQL..." -ForegroundColor Cyan

    $paramsPostgreSQL = @{
        packageName = $configuration.ODSDatabaseInstallerConfig.PostgreSQL.packageDetails.packageName
        packageVersion = $configuration.ODSDatabaseInstallerConfig.PostgreSQL.packageDetails.version
        downloadLocation = $configuration.ODSDatabaseInstallerConfig.DownloadLocation
        host = $configuration.PostgreSQLConfig.ConnectionString.Host
        port = $configuration.PostgreSQLConfig.ConnectionString.Port
        database = $configuration.PostgreSQLConfig.ConnectionString.Database
        user = $configuration.PostgreSQLConfig.ConnectionString.Username
        connectionStringPostgreSqlUrl = Get-ConnectionStringPostgreSqlUrl -UsePostgresDatabase $true
    }

    Install-PostgreSQLODS @paramsPostgreSQL
}
