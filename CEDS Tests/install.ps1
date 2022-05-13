# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

#Requires -RunAsAdministrator

param (
    [string] $configPath = "$PSScriptRoot\configuration.json"
)

$ErrorActionPreference = "Stop"

$configuration = Format-ConfigurationFileToHashTable $configPath

#--- IMPORT MODULES ---
Import-Module -Force "$PSScriptRoot\confighelper.psm1"
Import-Module -Force "$PSScriptRoot\scripts\MigratorModules\SqlDatabaseModuleWrapper.psm1"
Import-Module -Force "$PSScriptRoot\scripts\Utilities.psm1" -ArgumentList $configuration

$connectionString = Get-ConnectionStringMSSQL

Install-Views $connectionString "$PSScriptRoot\..\CEDS\MSSQL\"

# PostgreSQL

$connectionString = Get-ConnectionStringPostgreSQL

Install-Views $connectionString "$PSScriptRoot\..\CEDS\PostgreSQL\"

# Second step
# Install the CEDS views.

# ToDo: (This is not really a ToDo. Just be aware of)
#   There is a situation we have to review here. 
#       Since in the Ceds views we use the analytics_config.DescriptorMap table (specifically this script 0009-View-IeuDim-Create.sql), 
#       this means that the AMT is a requirement for the Ceds collection. Because this table is created by the AMT.
