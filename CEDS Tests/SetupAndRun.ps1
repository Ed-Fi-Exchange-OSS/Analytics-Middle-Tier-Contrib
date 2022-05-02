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
Import-Module -Force "$PSScriptRoot\confighelper.psm1"

Write-Host "Initializing Setup..." -ForegroundColor Cyan
& "$PSScriptRoot\scripts\setup.ps1" $configuration

Write-Host "Installing Ceds Views..." -ForegroundColor Cyan
& $PSScriptRoot+"\scripts\install.ps1" $configuration

Write-Host "running Ceds tests..." -ForegroundColor Cyan
& $PSScriptRoot+"\scripts\run.ps1" $configuration
