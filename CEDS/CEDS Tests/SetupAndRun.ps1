# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

#Requires -RunAsAdministrator

param (
    [string] $configPath = "$PSScriptRoot\configuration.json",
    [string][Alias('e')]$engine="all"
)

Write-Host "Initializing Setup..." -ForegroundColor Cyan
Invoke-Expression ".\setup.ps1"
Write-Host "... Setup Completed." -ForegroundColor Cyan

Write-Host "Installing Ceds Views..." -ForegroundColor Cyan
Invoke-Expression ".\install.ps1"
Write-Host "... Ceds views installed." -ForegroundColor Cyan

Write-Host "Running Ceds tests..." -ForegroundColor Cyan
Invoke-Expression ".\run.ps1"
Write-Host "... All Tests Executed." -ForegroundColor Cyan