$cert = Get-Item Cert:\CurrentUser\My\7EB85200CA7C6E030A158660115DF379B08BB25C

Set-AuthenticodeSignature -FilePath "<FILE>" -Certificate $cert