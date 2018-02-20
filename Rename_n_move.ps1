#StampMe.ps1
param( [string] $fileName)

# Check the file exists
if (-not(Test-Path $fileName)) {break}

# Display the original name
#"Original filename: $fileName"

$fileObj = get-item $fileName

# Get the date
$DateStamp = get-date -uformat "%Y-%m-%d@%H-%M-%S"

$extOnly = $fileObj.extension


if ($extOnly.length -eq 0) {
   $nameOnly = $fileObj.Name
   rename-item "$fileObj" "$nameOnly-$DateStamp"
   }
else {
   $nameOnly = $fileObj.Name.Replace( $fileObj.Extension,'')
   rename-item "$fileName" "$nameOnly-$DateStamp$extOnly"
   }

# Display the new name
#"New filename: $nameOnly-$DateStamp$extOnly"

# Move backup file to backup folder
move *.xlsx C:\SPG_Excel\Backup_SPG

# Copy new file from SAN\Standard_Products to the SPG_Excel folder
copy "\\san\Standard_Products\SPG - Sourcing Information (Refresh Data) - Rev 8.xlsx" C:\SPG_Excel\