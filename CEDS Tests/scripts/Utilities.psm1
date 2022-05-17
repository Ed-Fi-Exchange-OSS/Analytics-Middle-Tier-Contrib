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

    $mssqlConnectionStringIntegrated="Data Source={0};Initial Catalog={1};Integrated Security=SSPI;"
    $mssqlConnectionString="Data Source={0};Initial Catalog={1};User={2};Password={3};"

    if($configurationMSSQL.UseIntegratedSecurity){
        return $mssqlConnectionStringIntegrated -f $configurationMSSQL.host, $configurationMSSQL.database
    }
    else {
        return $mssqlConnectionString -f $configurationMSSQL.host, $configurationMSSQL.database, $configurationMSSQL.username, $configurationMSSQL.password
    }
}

function Get-ConnectionStringPostgreSQL {
    $configurationPostgreSQL = $configuration.PostgreSQLConfig.ConnectionString

    $postgresqlConnectionString="host={0};Database={1};user id={2};Password={3};port={4}"

    return $postgresqlConnectionString -f $configurationPostgreSQL.host, $configurationPostgreSQL.database, $configurationPostgreSQL.username, $configurationPostgreSQL.password, $configurationPostgreSQL.port
}

function Get-ConnectionStringPostgreSqlUrl {
    param (
        [bool] $UsePostgresDatabase = $false
    )

    $configurationPostgreSQL = $configuration.PostgreSQLConfig.ConnectionString

    $databaseURL = "postgresql://{0}:{1}@{2}:{3}/{4}"

    if ($UsePostgresDatabase) {
        return $databaseURL -f $configurationPostgreSQL.username, $configurationPostgreSQL.password, $configurationPostgreSQL.host, $configurationPostgreSQL.port, "postgres"
    }
    else {
        return $databaseURL -f $configurationPostgreSQL.username, $configurationPostgreSQL.password, $configurationPostgreSQL.host, $configurationPostgreSQL.port, $configurationPostgreSQL.database
    }
}

Export-ModuleMember Get-ConnectionStringMSSQL, Get-ConnectionStringPostgreSQL, Get-ConnectionStringPostgreSqlUrl