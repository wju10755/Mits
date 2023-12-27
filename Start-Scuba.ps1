# Define the URL for the latest release of ScubaGear
$scubaGearUrl = "https://advancestuff.hostedrmm.com/labtech/transfer/installers/scuba.zip"

# Define the URL for the OPA download
$opaUrl = "https://openpolicyagent.org/downloads/v0.60.0/opa_windows_amd64.exe"

# Define the path to the ScubaGear installation directory
$tmp = "c:\temp"

$scubaDir = "C:\temp\scuba"

$scubafile = "$tmp\scuba.zip"

$setup = "c:\temp\scuba\setup.ps1"

$opaFile = "$scubaDir\opa.exe"

$null = Set-ExecutionPolicy Bypass -Scope Process -Force 
clear-host
function Print-Middle( $Message, $Color = "White" )
{
    Write-Host ( " " * [System.Math]::Floor( ( [System.Console]::BufferWidth / 2 ) - ( $Message.Length / 2 ) ) ) -NoNewline;
    Write-Host -ForegroundColor $Color $Message;
}
# Print Script Title
#################################
$Padding = ("=" * [System.Console]::BufferWidth);
Write-Host -ForegroundColor "Blue" $Padding -NoNewline;
Print-Middle "CISA - Security Baseline Conformance Reports"
Write-Host -ForegroundColor "Blue" $Padding;
Write-Host `n


# Create the ScubaGear installation directory if it doesn't exist
if (-not (Test-Path $scubaDir)) {
    New-Item -ItemType Directory -Path $scubaDir | Out-Null
}

# Download the latest release of ScubaGear and extract it to the installation directory
if (!(Test-Path $scubafile)) {
    Invoke-WebRequest -Uri $scubaGearUrl -OutFile "c:\temp\scuba.zip"
}

$RequiredModulesPath = Join-Path -Path $PSScriptRoot -ChildPath "PowerShell\ScubaGear\RequiredVersions.ps1"
if (Test-Path -Path $RequiredModulesPath) {
  . $RequiredModulesPath
}

if (-not (Test-Path $setup)) {
    Expand-Archive -Path $scubafile -DestinationPath $scubaDir -Force 
}

# Install the required modules
Set-Location $scubaDir

if (-not(Test-Path $RequiredModulesPath)) {
    .\setup.ps1
}


# Download OPA and save it to the installation directory
if (-not(Test-Path $opaFile)) {
    Invoke-WebRequest -Uri $opaUrl -OutFile "$scubaDir\opa.exe"    
}

# Import the ScubaGear module
Import-Module "$scubaDir\powershell\scubagear\ScubaGear.psd1"
# Run Invoke-SCuBA
Invoke-SCuBA

# Run Invoke-SCuBA and wait for it to completee
#Start-Process powershell.exe "-Command Invoke-SCuBA" -Wait -NoNewWindow


# Get the list of directories in the Scuba directory that include "M365BaselineConformance"
$reportDirs = Get-ChildItem -Path "$scubaDir\M365BaselineConformance*" -Directory

# Sort the directories by creation time in descending order
$sortedDirs = $reportDirs | Sort-Object -Property CreationTime -Descending

# Get the most recent directory
$mostRecentDir = $sortedDirs[0]

# Save the path to the most recent directory as the $ScubaReport variable
$ScubaReport = $mostRecentDir.FullName

# Launch SCuBA Report
Invoke-Item "$ScubaReport\baselinereports.html"

