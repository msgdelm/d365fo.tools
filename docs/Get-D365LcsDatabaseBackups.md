﻿---
external help file: d365fo.tools-help.xml
Module Name: d365fo.tools
online version:
schema: 2.0.0
---

# Get-D365LcsDatabaseBackups

## SYNOPSIS
Get database backups from LCS project

## SYNTAX

```
Get-D365LcsDatabaseBackups [[-ProjectId] <Int32>] [[-BearerToken] <String>] [[-LcsApiUri] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Get the available database backups from the Asset Library in LCS project

## EXAMPLES

### EXAMPLE 1
```
Get-D365LcsDatabaseBackups -ProjectId 123456789 -BearerToken "JldjfafLJdfjlfsalfd..." -LcsApiUri "https://lcsapi.lcs.dynamics.com"
```

This will get all available database backups from the Asset Library inside LCS.
The LCS project is identified by the ProjectId 123456789, which can be obtained in the LCS portal.
The request will authenticate with the BearerToken "Bearer JldjfafLJdfjlfsalfd...".
The http request will be going to the LcsApiUri "https://lcsapi.lcs.dynamics.com" (NON-EUROPE).

### EXAMPLE 2
```
Get-D365LcsDatabaseBackups
```

This will get all available database backups from the Asset Library inside LCS.
It will use default values for all parameters.

All default values will come from the configuration available from Get-D365LcsApiConfig.

The default values can be configured using Set-D365LcsApiConfig.

## PARAMETERS

### -ProjectId
The project id for the Dynamics 365 for Finance & Operations project inside LCS

Default value can be configured using Set-D365LcsApiConfig

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $Script:LcsApiProjectId
Accept pipeline input: False
Accept wildcard characters: False
```

### -BearerToken
The token you want to use when working against the LCS api

Default value can be configured using Set-D365LcsApiConfig

```yaml
Type: String
Parameter Sets: (All)
Aliases: Token

Required: False
Position: 2
Default value: $Script:LcsApiBearerToken
Accept pipeline input: False
Accept wildcard characters: False
```

### -LcsApiUri
URI / URL to the LCS API you want to use

Depending on whether your LCS project is located in europe or not, there is 2 valid URI's / URL's

Valid options:
"https://lcsapi.lcs.dynamics.com"
"https://lcsapi.eu.lcs.dynamics.com"

Default value can be configured using Set-D365LcsApiConfig

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: $Script:LcsApiLcsApiUri
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Mötz Jensen (@Splaxi)

## RELATED LINKS

[Get-D365LcsApiConfig]()

[Get-D365LcsApiToken]()

[Invoke-D365LcsApiRefreshToken]()

[Set-D365LcsApiConfig]()
