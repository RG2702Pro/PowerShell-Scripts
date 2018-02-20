

#This is where we define the parameters.
#It prompts for username and the forward to email address. 
#Be sure to edit the Exchange server to match your environment. 
param([String]$username)

#Param (
#[Parameter(Mandatory=$true)]
#[string]$Username,
#[Parameter(Mandatory=$true)]
#[string]$ForwardtoEmail,
#[string]$ExchangeServer="MailServer")
#
#Here we create the connection to the exchange server.
#
#$ExchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$ExchangeServer/PowerShell
#Import-PSSession $ExchangeSession
#
#Here we import the tools to work with AD.
#
Import-Module ActiveDirectory
#
#This is where group memberships are removed.
#
$groups = Get-ADPrincipalGroupMembership -Identity $Username

# Loop through each group
foreach ($group in $groups) {

    # Exclude Domain Users group
    if ($group.name -ne "domain users") {

        # Remove user from group
		Remove-ADPrincipalGroupMembership -Identity $Username -MemberOf $group -Confirm:$False

        # Write progress to screen
        write-host "removed" $username "from" $group.name;
    }

}
#
#This is where we disabled the account
#
Disable-ADAccount -Identity $Username
#
#This is where we specify where the user will be moved in AD.
#
#Get-ADUser $Username | Move-ADObject -TargetPath 'OU=Disabled Users,DC=domain,Dc=local'
#
#This is where we set the forward to address and hide the account in Exchange. 
#
#Set-Mailbox -Identity $Username -ForwardingAddress $ForwardtoEmail -HiddenFromAddressListsEnabled $true