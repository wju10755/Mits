clear-host
function Print-Middle( $Message, $Color = "White" )
{
    Write-Host ( " " * [System.Math]::Floor( ( [System.Console]::BufferWidth / 2 ) - ( $Message.Length / 2 ) ) ) -NoNewline;
    Write-Host -ForegroundColor $Color $Message;
}
# Print Script Title
#################################
$Padding = ("=" * [System.Console]::BufferWidth);
Write-Host -ForegroundColor "Red" $Padding -NoNewline;
Print-Middle "MITS - Immybot Provisioning Package Tool"
Write-Host -ForegroundColor DarkRed "                                                      version 0.0.5";

Write-Host -ForegroundColor "Red" $Padding;
Write-Host `n

Write-Host ""

# Check for temp directory and create if not exist
$tmp = "c:\temp"
if (-not (Test-Path $tmp)) {
    Write-Host "Creating temp directory."
    mkdir c:\temp | Out-Null
}

Write-Host -ForegroundColor Yellow "Make a selection below:"
Write-Host `n
# Prompt the user for their choice
Write-Host "1) Provision an existing device with Immybot`n `nor`n `n2) Wipe and provision device with Immybot"
Write-Host `n
Write-Host -ForegroundColor Yellow "Enter 1 or 2: " -NoNewline
$UserChoice = Read-Host

# Based on the user's choice, download the appropriate file
switch ($UserChoice) {
    "1" {
        $output = "c:\temp\EXISTING-mitsdev-ImmyAgentInstaller.ppkg"
        if (-not (Test-Path $output)) {
            $url = "https://advancestuff.hostedrmm.com/labtech/transfer/installers/EXISTING-mitsdev-ImmyAgentInstaller.ppkg"
            Invoke-WebRequest -Uri $url -OutFile $output
            Write-Host -ForegroundColor Green "Provisioning package download completed successfully!"
        } else {
            Write-Host -ForegroundColor Yellow "File already exists, skipping download."
        }
        Invoke-Item $output
    }
    "2" {
        $output = "c:\temp\WIPE-ImmyAgent_Installer.ppkg"
        if (-not (Test-Path $output)) {
            $url = "https://advancestuff.hostedrmm.com/labtech/transfer/installers/WIPE-ImmyAgent_Installer.ppkg"
            Invoke-WebRequest -Uri $url -OutFile $output
            Write-Host -ForegroundColor Green "Provisioning package download completed successfully!"
        } else {
            Write-Host -ForegroundColor Yellow "File already exists, skipping download."
        }
        Invoke-Item $output
    }
    default {
        Write-Output "Invalid choice. Please enter 1 or 2."
    }
}

Write-Host " "

# Pause the script
Write-Host "Press Enter to exit"
Read-Host