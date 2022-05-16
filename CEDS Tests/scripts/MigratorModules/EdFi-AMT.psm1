# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

param(
    [parameter(Position=0,Mandatory=$true)][Hashtable]$configuration
)

Import-Module -Force "$PSScriptRoot\..\Utilities.psm1" -ArgumentList $configuration

$packageDetails = @{
    packageName = $configuration.amtConfig.packageDetails.packageName
    version=$configuration.amtConfig.packageDetails.version
}

$destinationName=
If ($configuration.amtConfig.install_selfContained) 
{"$($packageDetails.packageName)-$($configuration.amtConfig.selfContainedOS)-$($packageDetails.version)"} 
Else {"$($packageDetails.packageName)-$($packageDetails.version)"} 
$amtUninstallArgumentList = "-c `"{0}`" -e {1} -u"
$amtInstallArgumentList = "-c `"{0}`" -o {1} -e {2}"
$amtConsoleApp = "EdFi.AnalyticsMiddleTier.Console.exe"
$packageUrl = "$($configuration.amtConfig.packageDetails.packageURL)/releases/download/$($packageDetails.version)/$($destinationName).zip"
function Request-amt-Files{
    param (
        $amtPath = "C:\temp\",
        $downloadPath = "C:\temp\downloads\"
    )
	$Url = $packageUrl
	
	if( -Not (Test-Path -Path $amtPath ) )
	{
        # Create the installer directory if it does not exist.
		New-Item -ItemType directory -Path $amtPath
	}
	if( -Not (Test-Path -Path $downloadPath ) )
	{
        # Create the download directory if it does not exist.
		New-Item -ItemType directory -Path $downloadPath
	}
		
	$ZipFile = Join-Path $downloadPath "$($destinationName).zip"
	
	Invoke-WebRequest -Uri $Url -OutFile $ZipFile 
	
    if ($LASTEXITCODE) {
        throw "Failed to download package $($packageDetails.packageName) $($packageDetails.version)"
    }

    return Resolve-Path $amtPath
}
function Expand-amt-Files {
    param (
        $amtPath = "C:\temp\",
        $downloadPath = "C:\temp\downloads\"
    )
    
    $amtVersionDestination = (Join-Path $amtPath $destinationName)

    $ZipFile = Join-Path $downloadPath "$($destinationName).zip"
    
    Expand-Archive -Path $ZipFile -DestinationPath $amtVersionDestination -Force
    
    if ($LASTEXITCODE) {
        throw "Failed to extract package $($packageDetails.packageName) $($packageDetails.version)"
    }
}

function Install-AMT {
    <#
    .SYNOPSIS
        Installs the Ed-Fi Analytics-Middle-Tier.

    .DESCRIPTION
        Installs the Ed-Fi Analytics-Middle-Tier using the configuration
        values provided.

    .EXAMPLE
        Installs the Analytics-Middle-Tier

        PS c:\> $amtInstallerPath = "C:/temp/tools/amt"
        PS c:\> $amtDownloadPath = "C:/temp/downloads/amt"
        PS c:\> $databasesConfig = @{}
        PS c:\> $amtOptions = "indexes rls qews ews chrab asmt"
    #>
    [CmdletBinding()]
    param (
        # Path for storing installation tools
        [string]
        [Parameter(Mandatory=$true)]
        $amtInstallerPath,

        # Path for storing downloaded packages
        [string]
        [Parameter(Mandatory=$true)]
        $amtDownloadPath,

        # Hashtable containing information about the databases and its server
        [Hashtable]
        [Parameter(Mandatory=$true)]
        $databasesConfig,

        [string]
        [Parameter(Mandatory=$true)]
        $amtOptions
    )
  
    $paths = @{
        amtPath = $amtInstallerPath
        downloadPath = $amtDownloadPath
    }
    try {
        $databaseEngine = if($databasesConfig.engine -ieq "SQLServer"){"mssql"}else{"postgres"}

        Request-amt-Files @paths

        Expand-amt-Files @paths

        $connectionString = if($databasesConfig.engine -ieq "SQLServer"){Get-ConnectionStringMSSQL}else{Get-ConnectionStringPostgreSQL}
    
        $consoleInstaller = Join-Path (Join-Path $amtInstallerPath $destinationName) $amtConsoleApp
        
        Start-Process -NoNewWindow -FilePath $consoleInstaller -ArgumentList ($amtInstallArgumentList -f $connectionString, $amtOptions, $databaseEngine)
    }
    catch {
        Write-Host $_
        throw $_
    }
}

function Uninstall-AMT {
    <#
    .SYNOPSIS
        Uninstalls the Ed-Fi Analytics Middle Tier Views.

    .DESCRIPTION
        Uninstalls the Ed-Fi Analytics Middle Tier Views using the configuration
        values provided.

    .EXAMPLE
        Uninstalls the Ed-Fi Analytics Middle Tier Views

        PS c:\> $amtInstallerPath = "C:/temp/tools/amt"
        PS c:\> $amtDownloadPath = "C:/temp/downloads/amt"
        PS c:\> $databasesConfig = @{}
        PS c:\> $amtOptions = "indexes rls qews ews chrab asmt"
    #>
    [CmdletBinding()]
    param (
        # Path for storing installation tools
        [string]
        [Parameter(Mandatory=$true)]
        $amtInstallerPath,

        # Path for storing downloaded packages
        [string]
        [Parameter(Mandatory=$true)]
        $amtDownloadPath,

        # Hashtable containing information about the databases and its server
        [Hashtable]
        [Parameter(Mandatory=$true)]
        $databasesConfig,

        [string]
        [Parameter(Mandatory=$true)]
        $amtOptions
    )
  
    $paths = @{
        amtPath = $amtInstallerPath
        downloadPath = $amtDownloadPath
    }
    try{
        $databaseEngine = if($databasesConfig.engine -ieq "SQLServer"){"mssql"}else{"postgres"}
        
        Request-amt-Files @packageDetails @paths

        Expand-amt-Files @packageDetails @paths

        $connectionString = if($databasesConfig.engine -ieq "SQLServer"){Get-ConnectionStringMSSQL}else{Get-ConnectionStringPostgreSQL}
    
        $consoleInstaller = Join-Path (Join-Path $amtInstallerPath $destinationName) $amtConsoleApp
        
        Start-Process -NoNewWindow -Wait -FilePath $consoleInstaller -ArgumentList ($amtUninstallArgumentList -f $connectionString, $databaseEngine)
    }
    catch {
        Write-Host $_
        throw $_
    }    
}

Export-ModuleMember Install-AMT, Uninstall-AMT
