Set-Executionpolicy RemoteSigned -Force *> $null
Clear-Host
# Set console formatting
function Print-Middle($Message, $Color = "White") {
    Write-Host (" " * [System.Math]::Floor(([System.Console]::BufferWidth / 2) - ($Message.Length / 2))) -NoNewline;
    Write-Host -ForegroundColor $Color $Message;
}

# Print Script Title
#################################
$Padding = ("=" * [System.Console]::BufferWidth);
Write-Host -ForegroundColor "Red" $Padding -NoNewline;
Print-Middle "MITS - Portable Revo Uninstaller Script";
Write-Host -ForegroundColor DarkRed "                                                      version 1.0.0";
Write-Host -ForegroundColor "Red" -NoNewline $Padding;
Write-Host " "

$temp = "C:\temp"
$revoZip = "c:\temp\revo.zip"
$path = "c:\temp\revo"
$file = "c:\temp\revo\RevoUPort.exe"

if(!(Test-Path $path)) {
    new-item -Path "c:\path" -ItemType Directory -Force *> $null    
}

invoke-webrequest -uri "https://advancestuff.hostedrmm.com/labtech/transfer/installers/revo.zip" -outfile "c:\temp\revo.zip"

Expand-Archive -Path $revoZip -DestinationPath $path -Force

start $file
