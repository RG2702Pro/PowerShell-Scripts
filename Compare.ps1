$RSmith = Get-Content 'C:\Users\RGRIGSBY\Documents\PowerShell Command\Txt Compare\RSmith.txt'
$RYingst = Get-Content 'C:\Users\RGRIGSBY\Documents\PowerShell Command\Txt Compare\RYingst.txt'

$Comparison = Compare-Object $RSmith $RYingst | Where-Object { $_.SideIndicator -eq '<=' } | Select-Object InputObject
$Comparison | Export-Csv 'C:\Users\RGRIGSBY\Documents\PowerShell Command\Txt Compare\Comparison.csv' -noType