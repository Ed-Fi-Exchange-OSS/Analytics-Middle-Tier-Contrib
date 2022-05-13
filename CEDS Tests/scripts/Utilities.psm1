# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

#Requires -RunAsAdministrator
param(
    [parameter(Position=0,Mandatory=$true)][Hashtable]$configuration
)

$ErrorActionPreference = "Stop"

function Get-ConnectionStringMSSQL {
    $configurationMSSQL = $configuration.SQLServerConfig.ConnectionString

    if ($configurationMSSQL.IntegratedSecurity.ToLower() -eq "true"){

        # Write-Host "(database) $($configurationMSSQL.database)"
        # Write-Host "(integratedSecurity) $($configurationMSSQL.integratedSecurity)"

        return "Data Source=$($configurationMSSQL.host);Initial Catalog=$($configurationMSSQL.database);Integrated Security=$($configurationMSSQL.IntegratedSecurity);"
    }
    else {
        return "Data Source=$($configurationMSSQL.host);Initial Catalog=$($configurationMSSQL.database);User=$($configurationMSSQL.username);Password=$($configurationMSSQL.password);"
    }
}

function Get-ConnectionStringPostgreSQL {
    $configurationPostgreSQL = $configuration.PostgreSQLConfig.ConnectionString

    return "Host=$($configurationPostgreSQL.host);Database=$($configurationPostgreSQL.database);User ID=$($configurationPostgreSQL.username);password=$($configurationPostgreSQL.password);Port=$($configurationPostgreSQL.port);Pooling=false;"
}

function Get-ConnectionStringPostgreSqlUrl {
    $configurationPostgreSQL = $configuration.PostgreSQLConfig.ConnectionString

    return "postgresql://$($configurationPostgreSQL.username):$($configurationPostgreSQL.password)@$($configurationPostgreSQL.host):$($configurationPostgreSQL.port)/$($configurationPostgreSQL.database)"
}

Export-ModuleMember Get-ConnectionStringMSSQL, Get-ConnectionStringPostgreSQL, Get-ConnectionStringPostgreSqlUrl