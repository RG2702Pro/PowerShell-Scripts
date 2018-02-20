# FindEmptyGroups.ps1
# PowerShell Version 2 script to find all empty groups in the domain.
# This will be groups where the member attribute is empty, and also where
# no user or computer has the group designated as their primary group.
# You can select to search for all empty groups, or only empty security groups.
# Author: Richard L. Mueller
# Version 1.0 - November 27, 2016

# Specify the supported parameters.
Param(
    [Switch]$Help,
    [Switch]$Security
)

# Script version and date.
$Version = "Version 1.0 - November 27, 2016"
$Today = Get-Date

# Flag any parameters not recognized and abort the script. Any parameters that do not match
# the supported parameters (specified by the Param statement above) will populate the $Args
# collection, an automatic variable. If all of the parameters supplied are recognized, then
# $Args will be empty.
$Abort = $False
ForEach ($Arg In $Args)
{
    If ($Arg -Like "-*")
    {
        Write-Host "Argument not recognized: $Arg" -ForegroundColor Red -BackgroundColor Black
    }
    Else
    {
        Write-Host "Value not recognized:    $Arg" -ForegroundColor Red -BackgroundColor Black
    }
    $Abort = $True
}
# Breaking out of the above ForEach would not break out of the script. Breaking out
# of the If statment will.
If ($Abort)
{
    # Display a brief help listing the supported parameters.
    Write-Host "Syntax: FindEmptyGroups.ps1 [-Security] [-Help]" `
        -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "For help use FindEmptyGroups.ps1 -Help" `
        -ForegroundColor yellow -BackgroundColor Black
    Break
}

If ($Help)
{
    # User has requested help information.
    "FindEmptyGroups.ps1"
    "$Version"
    "PowerShell script to find all empty groups in the domain."
    "This will be groups with no members, including no users or computers where the group"
    "    is designated as their ""Primary"" group."
    "Parameters"
    "    -Security: A switch, so the script only considers security groups."
    "        Otherwise, the script considers all groups, including distribution groups."
    "    -Help: A switch that outputs this help."
    "Note: The first one (or several) letters of each parameter can be used as aliases."
    "Some usage examples:"
    ".\FindEmptyGroups.ps1 > .\Report.txt"
    "    Find all empty groups in the domain. Redirect output to a text file."
    ".\FindEmptyGroups.ps1 -S"
    "    Find all empty security groups in the domain."
    "Example output:"
    "-----"
    "FindEmptyGroups.ps1"
    "$Version"
    "All empty groups:"
    "Date: 11/25/2016 09:51:55"
    "CN=Contractors,OU=Sales,OU=West,DC=MyDomain,DC=com (ContractorsWest)"
    "cn=Contractors,OU=Sales,OU=East,DC=MyDomain,DC=com (ContractorsEast)"
    "CN=WINS Users,CN=Users,DC=MyDomain,DC=com (WINS Users)"
    "CN=DnsAdmins,CN=Users,DC=MyDomain,DC=com (DnsAdmins)"
    "Total number of empty groups: 4"
    Break
}

If ($Security)
{
    # Retrieve all security groups where the member attribute is empty.
    $Groups = Get-ADGroup `
        -LDAPFilter "(&(groupType:1.2.840.113556.1.4.803:=2147483648)(!(member=*)))" `
        | Select distinguishedName, sAMAccountName, SID
}
Else
{
    # Retrieve all groups where the member attribute is empty.
    $Groups = Get-ADGroup `
        -LDAPFilter "(!(member=*))" `
        | Select distinguishedName, sAMAccountName, SID
}

# Enumerate these groups. Check if any users or computers has them designated as their
# "primary" group. This will be users or computers where the primaryGroupID attribute
$Count = 0
# equals the primaryGroupToken attribute of the group.
If ($Security) {"All empty security groups:"}
Else {"All empty groups:"}
"Date: $Today"
ForEach ($Group In $Groups)
{
    # Retrieve the primaryGroupToken (the RID) of the group.
    # This is an operational (constructed) attribute, so it is easier to parse the SID.
    $SID = [String]$Group.SID
    $RID = $SID.Split("-")[-1]

    # Check if there are any users or computers where the primaryGroupID attribute
    # equals the primaryGroupToken of this group.
    $PrimaryMembers = Get-ADObject -LDAPFilter "(primaryGroupID=$RID)"
    If (-Not $PrimaryMembers)
    {
        # This is a group with no members.
        $DN = $Group.distinguishedName
        $NTName = $Group.sAMAccountName
        # Output the group DN and sAMAccountName.
        "$DN ($NTName)" | Out-File -Append C:\filename.txt
        # Count the number of empty groups.
        $Count = $Count + 1
    }
}
"Total number of empty groups: $Count"

# SIG # Begin signature block
# MIIIHwYJKoZIhvcNAQcCoIIIEDCCCAwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUkaWDOttwU9Ue6V3fJrTeJewr
# uCigggWOMIIFijCCBHKgAwIBAgITGQAAAG9/FinRM6L+CgAAAAAAbzANBgkqhkiG
# 9w0BAQsFADBDMRMwEQYKCZImiZPyLGQBGRYDY29tMRcwFQYKCZImiZPyLGQBGRYH
# dmVjdHJvbjETMBEGA1UEAxMKVmVjdHJvbi1DQTAeFw0xNzA3MjgxODI5NTFaFw0x
# ODA3MjgxODI5NTFaMG8xEzARBgoJkiaJk/IsZAEZFgNjb20xFzAVBgoJkiaJk/Is
# ZAEZFgd2ZWN0cm9uMRAwDgYDVQQLEwdNdEhvbGx5MRIwEAYDVQQLEwlNSFMgVXNl
# cnMxGTAXBgNVBAMTEEdyaWdzYnkyLCBSb2JlcnQwggEiMA0GCSqGSIb3DQEBAQUA
# A4IBDwAwggEKAoIBAQDNKtOfIR7tFGg7zH6OM5sy50N9X9pJgMo0Zs+QY2KBAGAt
# jNUFksrGHBSHEuPO5sWz1+mIyZBZmETGoEw2FMoJq6d6kZ971wv0mRQyHQr2F0Rj
# /2GNJx1/557TGqz6UeKK1z9HIU7TYrFJiBPB8VuTMnUPluu8frnaJ8Xy2B5Z4+nC
# ApfircVQgepyx4p21kwYhzffEDH0w40cUhTrz0l5YKSsc2F3NGS18gWVI6z3IotX
# 3XSsvszkHNCiE96wa1EhyWQfY7m40OTLX5mBc3vSUAuW5qowoHj6lNyZ0UXTeMYb
# q+JvDizIVPLHeL0k0GJbmw2AxYVHqDDkGUO9gtldAgMBAAGjggJJMIICRTAlBgkr
# BgEEAYI3FAIEGB4WAEMAbwBkAGUAUwBpAGcAbgBpAG4AZzATBgNVHSUEDDAKBggr
# BgEFBQcDAzAOBgNVHQ8BAf8EBAMCB4AwHQYDVR0OBBYEFICyHyknUYUWD6nCC80s
# AhPUDpFSMB8GA1UdIwQYMBaAFPIQKbQoRxqBhzrEnedE4dBxisceMIHFBgNVHR8E
# gb0wgbowgbeggbSggbGGga5sZGFwOi8vL0NOPVZlY3Ryb24tQ0EsQ049VklDQSxD
# Tj1DRFAsQ049UHVibGljJTIwS2V5JTIwU2VydmljZXMsQ049U2VydmljZXMsQ049
# Q29uZmlndXJhdGlvbixEQz12ZWN0cm9uLERDPWNvbT9jZXJ0aWZpY2F0ZVJldm9j
# YXRpb25MaXN0P2Jhc2U/b2JqZWN0Q2xhc3M9Y1JMRGlzdHJpYnV0aW9uUG9pbnQw
# gbwGCCsGAQUFBwEBBIGvMIGsMIGpBggrBgEFBQcwAoaBnGxkYXA6Ly8vQ049VmVj
# dHJvbi1DQSxDTj1BSUEsQ049UHVibGljJTIwS2V5JTIwU2VydmljZXMsQ049U2Vy
# dmljZXMsQ049Q29uZmlndXJhdGlvbixEQz12ZWN0cm9uLERDPWNvbT9jQUNlcnRp
# ZmljYXRlP2Jhc2U/b2JqZWN0Q2xhc3M9Y2VydGlmaWNhdGlvbkF1dGhvcml0eTAw
# BgNVHREEKTAnoCUGCisGAQQBgjcUAgOgFwwVUkdyaWdzYnkyQHZlY3Ryb24uY29t
# MA0GCSqGSIb3DQEBCwUAA4IBAQAjOEqLW0zHwuexRDWOwGnr8iZjOTXXP1/ITqtP
# 69Jn5tiKnJkZ+2Z4HY2AC8Cla+ebSIfvH0nd+/OHPHAIZnNwMAEQbGA/Et/0F4V7
# 02Ib/AT2GbFtrmQ1nkw+MHEvgOdnuavz1HmQUx8q8Wva+wUP0cODRjQUjBBeOT66
# sVsKrPofKh1PjYNHnj3Bl7W9+1sbVlKWYHZVSEq0aVZ6DtE62DSl9huRlsxljrBW
# xHJrWVawwFSGGZKU+45TdDYR8HZFypc6gXw2El3RKNru2wJPuGmh2E8ZYzHapWrg
# H8/vme7tTz4jqOOqzK34r4lnfi075VjqQN0ietYzjsWkTUfsMYIB+zCCAfcCAQEw
# WjBDMRMwEQYKCZImiZPyLGQBGRYDY29tMRcwFQYKCZImiZPyLGQBGRYHdmVjdHJv
# bjETMBEGA1UEAxMKVmVjdHJvbi1DQQITGQAAAG9/FinRM6L+CgAAAAAAbzAJBgUr
# DgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMx
# DAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkq
# hkiG9w0BCQQxFgQUs9j0oOb6OHbOgdr/Px7EJ3YX/m8wDQYJKoZIhvcNAQEBBQAE
# ggEAE7Xi9hKLHAakahXwth9usOLeOk0BTrYsFAk5wg+qQicVcVkxuzAfhk63RvZN
# vS+oQpV3NtwgxhdT3LWsuVpmvrARYbsxxRW0WepztXvXzeM0sJdaDA3w7udG/TKy
# xkwmifVBeQhFw+oHWIcnXrWwgNY5qyBwZmemzQ+bWupuFz7bJh0QIMQVYOQJzghw
# nihhoEglsQ65kka4DqEQFu1GRlHZd+zeF1Ifzbn325SMD4ZyAYncmpTP7wfbm3FB
# NbSzLD7eeQ80s+521a2z5abErq+r1ojbaBUPN+wAGQ5Y2onahMIDHYu+3uu6lObT
# sS6j14NNKYvv6sgsHNSEjHJnzw==
# SIG # End signature block
