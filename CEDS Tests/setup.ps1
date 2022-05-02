# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

#Requires -RunAsAdministrator

param (
    [string] $configPath = "$PSScriptRoot\configuration.json"
)

$configuration = Format-ConfigurationFileToHashTable $configPath

#--- IMPORT MODULES ---
Import-Module -Force "$PSScriptRoot\SetupModules\ODSDatabaseInstaller.psm1"

function Install-SqlDatabaseModule() {
    Write-Host "Installing the SqlDatabase Module from the PowerShell Gallery." -ForegroundColor Cyan

    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Install-Module -Name SqlDatabase
}

function Install-SqlServerModule {
    Write-Host "Installing the SqlServer Module from the PowerShell Gallery." -ForegroundColor Cyan

    Install-Module -Name SqlServer
    Import-Module SqlServer
}

Write-Host "Installing ODS for MSSQL." -ForegroundColor Cyan
$paramsMSSQL = @{
    packageName = $configuration.ODSDatabaseInstallerConfig.MSSQL.packageDetails.packageName
    packageVersion = $configuration.ODSDatabaseInstallerConfig.MSSQL.packageDetails.version
    downloadLocation = $configuration.ODSDatabaseInstallerConfig.DownloadLocation
    serverInstance = $configuration.SQLServerConfig.ConnectionString.Host
    database = $configuration.SQLServerConfig.ConnectionString.Database
}

Deploy-MSSQL @paramsMSSQL

Write-Host "Installing ODS for PostgreSQL."
$paramsPostgreSQL = @{
    packageName = $configuration.ODSDatabaseInstallerConfig.PostgreSQL.packageDetails.packageName
    packageVersion = $configuration.ODSDatabaseInstallerConfig.PostgreSQL.packageDetails.version
    downloadLocation = $configuration.ODSDatabaseInstallerConfig.DownloadLocation
    serverInstance = $configuration.SQLServerConfig.ConnectionString.Host
    database = $configuration.SQLServerConfig.ConnectionString.Database
    post = $configuration.SQLServerConfig.ConnectionString.Port
    user = $configuration.SQLServerConfig.ConnectionString.Username
    password = $configuration.SQLServerConfig.ConnectionString.Password
}

Deploy-PostgreSQL @paramsPostgreSQL

Export-ModuleMember Deploy-ODSDatabase
