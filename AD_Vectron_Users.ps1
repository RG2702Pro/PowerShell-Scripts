#Import-Module Active Directory
$ExpPath= "C:\Users\RGRIGSBY\Desktop\Vectron\vectronusers.csv"
Get-AdUser -Filter 'Enabled -eq $True' -Properties Name,SamAccountName,Enabled,CanonicalName,ipphone,Office,OfficePhone | Select-Object Name,SamAccountName,Enabled,CanonicalName,ipphone,Office,OfficePhone | Export-Csv $ExpPath -NoTypeInformation 