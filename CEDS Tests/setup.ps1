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
Import-Module -Force "$PSScriptRoot\scripts\Utilities.psm1"

$configuration = Format-ConfigurationFileToHashTable $configPath

function Install-SqlDatabaseModule {
    Write-Host "Installing the SqlDatabase Module from the PowerShell Gallery." -ForegroundColor Cyan

    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Install-Module -Name SqlDatabase
}

function Install-SqlServerModule {
    Write-Host "Installing the SqlServer Module from the PowerShell Gallery." -ForegroundColor Cyan

    Install-Module -Name SqlServer
    Import-Module SqlServer
}

# $connectionStringParams = @{
#     host = $configuration.SQLServerConfig.ConnectionString.Host
#     database = $configuration.SQLServerConfig.ConnectionString.Database
#     username = $configuration.SQLServerConfig.ConnectionString.Username
#     password = $configuration.SQLServerConfig.ConnectionString.Password
#     integratedSecurity = $configuration.SQLServerConfig.ConnectionString.IntegratedSecurity
# }

# $connectionString = Get-ConnectionStringMSSQL @connectionStringParams

# if ($null -ne (Get-SqlDatabase -ConnectionString $connectionString)) {
#     Write-Host "MSSQL datatabase ${connectionStringParams.database} already exists. Skipping."
# } else {
#     Write-Host "Installing ODS for MSSQL." -ForegroundColor Cyan
#     $paramsMSSQL = @{
#         packageName = $configuration.ODSDatabaseInstallerConfig.MSSQL.packageDetails.packageName
#         packageVersion = $configuration.ODSDatabaseInstallerConfig.MSSQL.packageDetails.version
#         downloadLocation = $configuration.ODSDatabaseInstallerConfig.DownloadLocation
#         serverInstance = $configuration.SQLServerConfig.ConnectionString.Host
#         database = $configuration.SQLServerConfig.ConnectionString.Database
#     }

#     Deploy-MSSQL @paramsMSSQL
# }

# # PostgreSQL
# $connectionStringParams = @{
#     host = $configuration.PostgreSQLConfig.ConnectionString.Host
#     database = $configuration.PostgreSQLConfig.ConnectionString.Database
#     username = $configuration.PostgreSQLConfig.ConnectionString.Username
#     password = $configuration.PostgreSQLConfig.ConnectionString.Password
#     port = $configuration.PostgreSQLConfig.ConnectionString.Port
# }

# $connectionStringAlt = Get-ConnectionStringPostgreSQLAlt @connectionStringParams

# if ("select exists(select datname from pg_database where datname = '${connectionStringParams.database}');" | psql $connectionStringAlt | ConvertFrom-Csv) {
#     Write-Host "PostgreSQL datatabase ${connectionStringParams.database} already exists. Skipping."
# } else {
#     Write-Host "Installing ODS for PostgreSQL." -ForegroundColor Cyan

#     $paramsPostgreSQL = @{
#         packageName = $configuration.ODSDatabaseInstallerConfig.PostgreSQL.packageDetails.packageName
#         packageVersion = $configuration.ODSDatabaseInstallerConfig.PostgreSQL.packageDetails.version
#         downloadLocation = $configuration.ODSDatabaseInstallerConfig.DownloadLocation
#         serverInstance = $configuration.PostgreSQLConfig.ConnectionString.Host
#         database = $configuration.PostgreSQLConfig.ConnectionString.Database
#         post = $configuration.PostgreSQLConfig.ConnectionString.Port
#         user = $configuration.PostgreSQLConfig.ConnectionString.Username
#         password = $configuration.PostgreSQLConfig.ConnectionString.Password
#     }

#     Deploy-PostgreSQL @paramsPostgreSQL
# }


Install-SqlDatabaseModule
Install-SqlServerModule