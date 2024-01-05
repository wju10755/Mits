# Function to set the registry key value
function Set-RegistryKeyValue {
    param (
        [string]$Path,
        [string]$Name,
        [string]$Value
    )

    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }

    Set-ItemProperty -Path $Path -Name $Name -Value $Value
}

# Registry path for the Group Policy setting
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetCache"

# Set the registry value to disable Offline File Sync
Set-RegistryKeyValue -Path $registryPath -Name "Enabled" -Value 0

# Output result
Write-Host "Offline File Sync has been disabled. Please restart the computer for changes to take effect."
