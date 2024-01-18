# Define the registry path and key name
$registryPath = 'HKLM:\SOFTWARE\Bluebeam Software\21\Revu'
$keyName = 'DisableInAppUpdates'

# Attempt to get the registry key value
try {
    $keyValue = Get-ItemProperty -Path $registryPath -Name $keyName

    # Check if the value is 0 and update it to 1
    if ($keyValue.$keyName -eq 0) {
        Write-Host "Disabling in-app updates..."
        Set-ItemProperty -Path $registryPath -Name $keyName -Value 1
        Write-Host "Bluebeam in app update notifications have been disabled"
    }
    # If the value is already 1, output the disabled message
    elseif ($keyValue.$keyName -eq 1) {
        Write-Host "Bluebeam application updates are already disabled."
    }
    else {
        Write-Host "Unable to locate the Bluebeam DisableInAppUpdates registry key."
    }
} catch {
    Write-Host "Failed to retrieve or update the registry key. Error: $_"
}
