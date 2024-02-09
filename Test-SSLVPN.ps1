# Get the network connection profile for the specific network adapter
$connectionProfile = Get-NetConnectionProfile -InterfaceAlias "Sonicwall NetExtender"

# Check if the network adapter is connected to a network
if ($connectionProfile) {
    Write-Host "The 'Sonicwall NetExtender' adapter is connected to the SSLVPN."
} else {
    Write-Host "The 'Sonicwall NetExtender' adapter is not connected to the SSLVPN."
}