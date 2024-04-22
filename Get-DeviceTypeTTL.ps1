function Get-DeviceTypeByTTL {
    param (
        [Parameter(Mandatory=$true)]
        [string]$IPAddress
    )

    # Ping the IP address
    $ping = Test-Connection -ComputerName $IPAddress -Count 1

    # Check the TTL value
    if ($ping) {
        $ttl = $ping.Ttl

        # Determine the type of machine based on the TTL value
        switch ($ttl) {
            { $_ -le 64 } { $deviceType = "Linux/Unix" }
            { $_ -gt 64 -and $_ -le 128 } { $deviceType = "Windows" }
            { $_ -gt 128 -and $_ -le 255 } { $deviceType = "Cisco or Linux" }
            default { $deviceType = "Unknown" }
        }

        Write-Host "The device at IP address $IPAddress has a TTL of $ttl, which suggests it might be a $deviceType machine."
    } else {
        Write-Host "Unable to ping the device at IP address $IPAddress."
    }
}

# Use the function
Get-DeviceTypeByTTL -IPAddress "192.168.1.51"
