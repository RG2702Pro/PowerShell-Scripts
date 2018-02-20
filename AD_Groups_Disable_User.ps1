#
#This is where we define the parameters.
#
param([String]$username)

#
#This is creating a CSV of the user's current AD memberships.
#
Get-ADPrincipalGroupMembership $username | select name | export-csv -Path ($username + '.csv')

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
Get-ADUser $Username | Move-ADObject -TargetPath 'OU=Disabled Users,OU=MtHolly,DC=vectron,DC=com'