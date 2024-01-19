# Define Duo Directory 
$LTPkg = "c:\windows\ltsvc\packages\Duo"

# Check if the folder already exists
if (-not (Test-Path $LTPkg)) {
    # Create the folder
    New-Item -ItemType Directory -Path $LTPkg
}

# Define the URL for the Duo installer
$duoUrl = "https://advancestuff.hostedrmm.com/labtech/transfer/installers/Duo-4.2.2.zip"

# Define the path to download the Duo installer
$DuoPackage = "C:\Windows\LTSvc\packages\Duo"
$DuoMSI = "DuoWindowsLogon64.msi"
$duoInstallerPath = "$DuoPackage\$DuoMSI"
$DuoZIP = "Duo-4.2.2.zip"
$DuoZipPath = "$DuoPackage\$DuoZip"


# Download the Duo installer
if (-not (Test-Path $duoZipPath)) {
    Write-Host "Downloading Duo 4.2.2 installation file, Please Wait..." -NoNewline
    Invoke-WebRequest -Uri $duoUrl -OutFile "$DuoPackage\$DuoZIP"
    Write-Host " done."
} else {
    Write-Host "Existing Duo 4.2.2 installation file found!"
}

Write-Host "Extracting setup files..." -NoNewline
Expand-Archive -path $DuoZipPath -DestinationPath $DuoPackage
Write-Host " done."

$msiPath = "$duoInstallerPath"
$startParams = @{
    FilePath = 'msiexec.exe'
    ArgumentList = "/i `"$msiPath`" IKEY=`"DIGANY1TZKE7PFQQ36SD`" SKEY=`"eiZdeqRmaWueibj1PZSEEAz74dvEskaebE7f07y0`" HOST=`"api-5c6d3fe8.duosecurity.com`" /qn"
    Wait = $true
}
Start-Process @startParams
Start-Sleep -seconds 5
Write-Output " "
Write-Output "Verifying Duo Authentication for Windows x64 is installed..."
Write-Output " "
$DuoDLL = "C:\Program Files\Duo Security\WindowsLogon\DuoCredProv.dll"
if (Test-Path $DuoDLL) {
    Write-Host -ForegroundColor Green "Duo has been installed successfully!"
} else {
    Write-Warning "Duo does not appear to be installed."
}
Write-Output " "
