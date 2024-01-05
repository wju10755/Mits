# Function to check if the OS is Windows 11
function Test-Win11 {
    $osInfo = Get-WmiObject -Class Win32_OperatingSystem
    $osVersion = $osInfo.Version
    $osProduct = $osInfo.Caption

    # Check for Windows 11
    return $osVersion -ge "10.0.22000" -and $osProduct -like "*Windows 11*"
}

# Enable Offline Files on Windows 11
if (Test-Win11) {
    try {
        # Set the path of the Offline Files registry key
        $registryPath = "HKLM:\System\CurrentControlSet\Services\CSC\Parameters"
        # Check if the registry path exists, if not, create it
        if (-not (Test-Path -Path $registryPath)) {
            New-Item -Path $registryPath -Force
        }

        # Set the value to enable Offline Files
        Set-ItemProperty -Path $registryPath -Name "Start" -Value 3

        # Output the result
        Write-Host "Offline Files has been enabled on Windows 11. A system restart may be required for changes to take effect."
    }
    catch {
        Write-Error "An error occurred: $($Error[0].Exception.Message)"
    }
}
else {
    Write-Host "This script is intended to run only on Windows 10."
}
