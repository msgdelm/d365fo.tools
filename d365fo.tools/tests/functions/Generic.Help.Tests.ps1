﻿$excludeCommands = @("Get-D365PackageLabelFile"
    , "Get-D365AOTObject"
    , "Get-D365DotNetClass"
    , "Get-D365DotNetMethod"
    , "Get-D365Label"
    , "Get-D365PackageBundleDetail"
    , "Get-D365ProductInformation"
    , "Get-D365TableSequence"
    , "Import-D365AadUser"
    , "Invoke-D365AzureStorageDownload"
    , "Invoke-D365AzureStorageUpload"
    , "Invoke-D365LogicApp"
    , "Invoke-D365SCDPBundleInstall"
    , "New-D365TopologyFile"
    , "Remove-D365User"
)

$commandsRaw = Get-Command -Module d365fo.tools

$commands = $commandsRaw | Select-String -Pattern $excludeCommands -SimpleMatch -NotMatch

foreach ( $commandName in $commands) {
    # command to be tested
    #$commandName = 'New-D365Bacpac'
    #$commandName = 'Get-D365PackageLabelFile'
    # get all examples from the help
    $examples = Get-Help $commandName -Examples


    # make a describe block that will contain tests for this 
    Describe "Examples from $commandName" {
        $examples.Examples.Example | foreach { 
            # examples have different format, 
            # at least the ones I used that MS provided
            # so you need to either standardize them,
            # or provide some hints about what to do
            # such as putting the code first
            # followed by 
            #   #output: the desired output

            # here I am simply taking the first line and removing 'PS C:\>' 
            # which makes some of the tests fail
            $example = $_.Code -replace "`n.*" -replace "PS C:\\>" 

            # for every example we want a single It block
            It "Example - $example" {
                # mock the tested command so we don't actually do anything
                # because it can be unsafe and we don't have the environment setup
                # (so the only thing we are testing is that the code is semantically
                # correct and provides all the needed params)
                Mock $commandName { 
                    # I am returning true here,
                    # but some of the examples drill down to the returned object
                    # so in strict mode we would fail
                    $true 
                }
	  
	  

                # here simply invoke the example
                $result = Invoke-Expression $example
                # and check that we got result from the mock
                $result | Should -BeTrue
            }
        }
    }
}