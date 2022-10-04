# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

#Requires -RunAsAdministrator

function Convert-PsObjectToHashTable {
    param (
        $objectToConvert
    )

    $hashTable = @{}

    $objectToConvert.psobject.properties | ForEach-Object { $hashTable[$_.Name] = $_.Value }

    return $hashTable
}

function Format-ConfigurationFileToHashTable {
    param (
        [string] $configPath
    )

    $configJson = Get-Content $configPath | ConvertFrom-Json

    $formattedConfig = @{
        
        ServerConfig =  Convert-PsObjectToHashTable $configJson.Server

        ODSDatabaseInstallerConfig =  Convert-PsObjectToHashTable $configJson.ODSDatabaseInstaller

        SQLServerConfig =  Convert-PsObjectToHashTable $configJson.SQLServer

        PostgreSQLConfig =  Convert-PsObjectToHashTable $configJson.PostgreSQL

        amtConfig = Convert-PsObjectToHashTable $configJson.AMT
    }

    return $formattedConfig
}

Export-ModuleMember Format-ConfigurationFileToHashTable
