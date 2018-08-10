<#
.SYNOPSIS
Get installed hotfix

.DESCRIPTION
Get all relevant details for installed hotfix

.PARAMETER Path
Path to the PackagesLocalDirectory

Default path is the same as the aos service packageslocaldirectory 

.PARAMETER Model
Name of the model that you want to work against

Accepts wildcards for searching. E.g. -Model "*Retail*"

Default value is "*" which will search for all models

.PARAMETER Name
Name of the hotfix that you are looking for

Accepts wildcards for searching. E.g. -Name "7045*"

Default value is "*" which will search for all hotfixes

.PARAMETER KB
KB number of the hotfix that you are looking for

Accepts wildcards for searching. E.g. -KB "4045*"

Default value is "*" which will search for all KB's

.EXAMPLE
Get-D365InstalledHotfix

This will display all installed hotfixes found on this machine

.EXAMPLE
Get-D365InstalledHotfix -Model "*retail*"

This will display all installed hotfixes found for all models that matches the 
search for "*retail*" found on this machine

.EXAMPLE
Get-D365InstalledHotfix -Model "*retail*" -KB "*43*"

This will display all installed hotfixes found for all models that matches the 
search for "*retail*" and only with KB's that matches the search for "*43*"
 found on this machine

.NOTES
This cmdlet is inspired by the work of "Ievgen Miroshnikov" (twitter: @IevgenMir)

All credits goes to him for showing how to extract these informations

His blog can be found here:
https://ievgensaxblog.wordpress.com

The specific blog post that we based this cmdlet on can be found here:
https://ievgensaxblog.wordpress.com/2017/11/17/d365foe-get-list-of-installed-metadata-hotfixes-using-metadata-api/

#>
function Get-D365InstalledHotfix {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [Parameter(Mandatory = $false, ParameterSetName = 'Default', Position = 1 )]
        [string] $BinPath = "$Script:BinDir\bin",

        [Parameter(Mandatory = $false, ParameterSetName = 'Default', Position = 2 )]
        [string] $PackageDirectory = $Script:PackageDirectory,

        [Parameter(Mandatory = $false, ParameterSetName = 'Default', Position = 3 )] 
        [string] $Model = "*",

        [Parameter(Mandatory = $false, ParameterSetName = 'Default', Position = 4 )] 
        [string] $Name = "*",

        [Parameter(Mandatory = $false, ParameterSetName = 'Default', Position = 5 )] 
        [string] $KB = "*"

    )

    begin {
    }

    process {
        $StorageAssembly = Join-Path $BinPath "Microsoft.Dynamics.AX.Metadata.Storage.dll"
        $InstrumentationAssembly = Join-Path $BinPath "Microsoft.Dynamics.ApplicationPlatform.XppServices.Instrumentation.dll"

        Write-PSFMessage -Level Verbose -Message "Testing if the path exists or not." -Target $StorageAssembly
        if (Test-Path -Path $StorageAssembly -PathType Leaf) {
            Write-PSFMessage -Level Verbose -Message "Loading assembly" -Target $StorageAssembly
            Add-Type -Path $StorageAssembly
        }
        else {
            Write-PSFMessage -Level Host -Message "Unable to <c=`"red`">load necessary assembly</c>. Please ensure that the <c=`"red`">BinPath</c> exists and you have permissions to access it."
            Stop-PSFFunction -Message "Stopping because of missing assembly"
            return            
        }

        Write-PSFMessage -Level Verbose -Message "Testing if the path exists or not." -Target $InstrumentationAssembly
        if (Test-Path -Path $InstrumentationAssembly -PathType Leaf) {
            Add-Type -Path $InstrumentationAssembly
        }
        else {
            Write-PSFMessage -Level Host -Message "Unable to <c=`"red`">load necessary assembly</c>. Please ensure that the <c=`"red`">BinPath</c> exists and you have permissions to access it."
            Stop-PSFFunction -Message "Stopping because of missing assembly"
            return 
        }

        Write-PSFMessage -Level Verbose -Message "Testing if the cmdlet is running on a OneBox or not." -Target $Script:IsOnebox
        if ($Script:IsOnebox) {
            Write-PSFMessage -Level Verbose -Message "Machine is onebox. Will continue with DiskProvider."

            $diskProviderConfiguration = New-Object Microsoft.Dynamics.AX.Metadata.Storage.DiskProvider.DiskProviderConfiguration
            $diskProviderConfiguration.AddMetadataPath($PackageDirectory)
            $metadataProviderFactory = New-Object Microsoft.Dynamics.AX.Metadata.Storage.MetadataProviderFactory
            $metadataProvider = $metadataProviderFactory.CreateDiskProvider($diskProviderConfiguration)

            Write-PSFMessage -Level Verbose -Message "MetadataProvider initialized." -Target $metadataProvider
        }
        else {
            Write-PSFMessage -Level Verbose -Message "Machine is NOT onebox. Will continue with RuntimeProvider."

            $runtimeProviderConfiguration = New-Object Microsoft.Dynamics.AX.Metadata.Storage.Runtime.RuntimeProviderConfiguration -ArgumentList $Script:PackageDirectory
            $metadataProviderFactory = New-Object Microsoft.Dynamics.AX.Metadata.Storage.MetadataProviderFactory
            $metadataProvider = $metadataProviderFactory.CreateRuntimeProvider($runtimeProviderConfiguration)

            Write-PSFMessage -Level Verbose -Message "MetadataProvider initialized." -Target $metadataProvider
        }

        Write-PSFMessage -Level Verbose -Message "Initializing the UpdateProvider from the MetadataProvider."
        $updateProvider = $metadataProvider.Updates

        Write-PSFMessage -Level Verbose -Message "Looping through all modules from the MetadataProvider."
        foreach ($obj in $metadataProvider.ModelManifest.ListModules()) {
            Write-PSFMessage -Level Verbose -Message "Filtering out all modules that doesn't match the model search." -Target $obj
            if ($obj.Name -NotLike $Model) {continue}

            Write-PSFMessage -Level Verbose -Message "Looping through all hotfixes for the module from the UpdateProvider." -Target $obj
            foreach ($objUpdate in $updateProvider.ListObjects($obj.Name)) {
                Write-PSFMessage -Level Verbose -Message "Reading all details for the hotfix through UpdateProvider." -Target $objUpdate
                
                $axUpdateObject = $updateProvider.Read($objUpdate)

                Write-PSFMessage -Level Verbose -Message "Filtering out all hotfixes that doesn't match the name search." -Target $axUpdateObject
                if ($axUpdateObject.Name -NotLike $Name) {continue}

                Write-PSFMessage -Level Verbose -Message "Filtering out all hotfixes that doesn't match the KB search." -Target $axUpdateObject
                if ($axUpdateObject.KBNumbers -NotLike $KB) {continue}

                [PSCustomObject]@{
                    Model   = $obj.Name
                    Hotfix  = $axUpdateObject.Name
                    Applied = $axUpdateObject.AppliedDateTime
                    KBs     = $axUpdateObject.KBNumbers
                }            
            }
        }
    }

    end {
    }
}