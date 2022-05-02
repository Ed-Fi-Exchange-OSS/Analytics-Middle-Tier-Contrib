# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

#Requires -RunAsAdministrator

param (
    [string] $configPath = "$PSScriptRoot\configuration.json"
)

$configuration = Format-ConfigurationFileToHashTable $configPath

$ErrorActionPreference = "Stop"

#--- IMPORT MODULES ---
Import-Module -Force "$PSScriptRoot\MigratorModules\SqlDatabaseModuleWrapper.psm1"
Import-Module -Force "$PSScriptRoot\Utilities.psm1"

# MSSQL
$connectionStringParams = @{
    host = $configuration.SQLServerConfig.ConnectionString.Host
    database = $configuration.SQLServerConfig.ConnectionString.Database
    username = $configuration.SQLServerConfig.ConnectionString.Username
    password = $configuration.SQLServerConfig.ConnectionString.Password
    integratedSecurity = $configuration.SQLServerConfig.ConnectionString.IntegratedSecurity
}

$connectionString = Get-ConnectionStringMSSQL @connectionStringParams

Install-Views $connectionString "$PSScriptRoot\..\..\CEDS\MSSQL\"

# PostgreSQL
$connectionStringParams = @{
    host = $configuration.PostgreSQLConfig.ConnectionString.Host
    database = $configuration.PostgreSQLConfig.ConnectionString.Database
    username = $configuration.PostgreSQLConfig.ConnectionString.Username
    password = $configuration.PostgreSQLConfig.ConnectionString.Password
}

$connectionString = Get-ConnectionStringPostgreSQL @connectionStringParams

Install-Views $connectionString "$PSScriptRoot\..\..\CEDS\PostgreSQL\"

Export-ModuleMember Install-CedsViews