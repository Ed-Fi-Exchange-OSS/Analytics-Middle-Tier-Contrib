# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

#Requires -RunAsAdministrator

param (
    [string] $configPath = "$PSScriptRoot\configuration.json"
)

#--- IMPORT MODULES ---
Import-Module -Force "$PSScriptRoot\confighelper.psm1"
Import-Module -Force "$PSScriptRoot\scripts\SetupModules\ODSDatabaseInstaller.psm1"

$configuration = Format-ConfigurationFileToHashTable $configPath

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
    serverInstance = $configuration.PostgreSQLConfig.ConnectionString.Host
    database = $configuration.PostgreSQLConfig.ConnectionString.Database
    post = $configuration.PostgreSQLConfig.ConnectionString.Port
    user = $configuration.PostgreSQLConfig.ConnectionString.Username
    password = $configuration.PostgreSQLConfig.ConnectionString.Password
}

Deploy-PostgreSQL @paramsPostgreSQL

# First step.
# Before the tests can be executed, we need to setup somethings:
#   Install SqlDatabase module.
#   Install ODS database.
# The idea is that this is done just once.

# Pending: At this point, when the database is restored for Postgres, it's necessary to enter the password. It would be nice if the user doesn't have to do this.
# Pending: Maybe check if the databases exist before, and if they do, don't try to install.