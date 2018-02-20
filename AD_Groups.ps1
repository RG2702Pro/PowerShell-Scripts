param([String]$user)


(Get-ADUser -Identity $user + "CN=MHS Users,OU=MtHolly,DC=vectron,DC=com" -Properties memberOf).MemberOf | export-csv -Path ($user + '.csv')

#Get-ADPrincipalGroupMembership $user | select name | export-csv -Path ($user + '.csv')