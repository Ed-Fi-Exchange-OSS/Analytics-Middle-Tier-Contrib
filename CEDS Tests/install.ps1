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
Import-Module -Force "$PSScriptRoot\scripts\MigratorModules\SqlDatabaseModuleWrapper.psm1"
Import-Module -Force "$PSScriptRoot\scripts\Utilities.psm1"

$configuration = Format-ConfigurationFileToHashTable $configPath

# MSSQL
$connectionStringParams = @{
    host = $configuration.SQLServerConfig.ConnectionString.Host
    database = $configuration.SQLServerConfig.ConnectionString.Database
    username = $configuration.SQLServerConfig.ConnectionString.Username
    password = $configuration.SQLServerConfig.ConnectionString.Password
    integratedSecurity = $configuration.SQLServerConfig.ConnectionString.IntegratedSecurity
}

$connectionString = Get-ConnectionStringMSSQL @connectionStringParams

Install-Views $connectionString "$PSScriptRoot\..\CEDS\MSSQL\"

# PostgreSQL
$connectionStringParams = @{
    host = $configuration.PostgreSQLConfig.ConnectionString.Host
    database = $configuration.PostgreSQLConfig.ConnectionString.Database
    username = $configuration.PostgreSQLConfig.ConnectionString.Username
    password = $configuration.PostgreSQLConfig.ConnectionString.Password
    port = $configuration.PostgreSQLConfig.ConnectionString.Port
}

$connectionString = Get-ConnectionStringPostgreSQL @connectionStringParams

Install-Views $connectionString "$PSScriptRoot\..\CEDS\PostgreSQL\"

# Second step
# Install the CEDS views.

# ToDo: (This is not really a ToDo. Just be aware of)
#   There is a situation we have to review here. 
#       Since in the Ceds views we use the analytics_config.DescriptorMap table (specifically this script 0009-View-IeuDim-Create.sql), 
#       this means that the AMT is a requirement for the Ceds collection. Because this table is created by the AMT.
