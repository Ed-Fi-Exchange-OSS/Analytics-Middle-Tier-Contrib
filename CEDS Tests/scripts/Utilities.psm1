# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

#Requires -RunAsAdministrator

function Get-ConnectionStringMSSQL {
    param (
        [Parameter(Mandatory = $true)]
        [string] $host,
        [Parameter(Mandatory = $true)]
        [string] $database,
        [Parameter(Mandatory = $false)]
        [string] $username,
        [Parameter(Mandatory = $false)]
        [string] $password,
        [Parameter(Mandatory = $false)]
        [string] $integratedSecurity = "true"
    )

    if ($integratedSecurity.ToLower() -eq "true"){
        return "Data Source=$host;Initial Catalog=$database;Integrated Security=$integratedSecurity;"
    }
    else {
        return "Data Source=$host;Initial Catalog=$database;User=$username;Password=$password;"
    }
}

function Get-ConnectionStringPostgreSQL() {
    param (
        [Parameter(Mandatory = $true)]
        [string] $host,
        [Parameter(Mandatory = $true)]
        [string] $database,
        [Parameter(Mandatory = $true)]
        [string] $username,
        [Parameter(Mandatory = $true)]
        [string] $password
    )

    return "Host=$host;Database=$database;User ID=$username;password=$password;Pooling=false;"
}

Export-ModuleMember Get-ConnectionStringMSSQL, Get-ConnectionStringPostgreSQL
