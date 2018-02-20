$sqlquery1=Invoke-Sqlcmd -Query "SELECT * FROM [MHS_SEPM].[dbo].[LAN_DEVICE_DETECTED];" -ServerInstance "MHSDB1"
$sqlquery2=Invoke-Sqlcmd -Query "SELECT * FROM [MHS_SEPM].[dbo].[SEM_COMPUTER];" -ServerInstance "MHSDB1"

$MAC=$sqlquery1.MAC_ADDRESS
$MAC2=$sqlquery2.MAC_ADDR1

$MAC=$MAC | Select -Unique
$MAC2=$MAC2 | Select -Unique

Compare-Object $MAC $MAC2 | Where-Object { $_.SideIndicator -eq '<=' } | Select-Object InputObject | Out-GridView

$Comparison=Compare-Object $MAC $MAC2 | Where-Object { $_.SideIndicator -eq '<=' } | Select-Object InputObject

foreach($SQLiteRow in $Comparison)
{
.\sqlite3.exe "\\VIAPP6\c$\ProgramData\Admin Arsenal\PDQ Inventory\Database.db" "SELECT Name FROM Computers WHERE MacAddress='$SQLiteRow';"
}