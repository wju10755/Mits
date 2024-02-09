# Device Identification
# PCSystemType values: 1 = Desktop, 2 = Mobile, 3 = Workstation, 4 = Enterprise Server, 5 = SOHO Server, 6 = Appliance PC, 7 = Performance Server, 8 = Maximum

# Get computer system information using CIM (more efficient and modern compared to WMI)
try {
    $computerSystem = Get-CimInstance -ClassName CIM_ComputerSystem
    $pcSystemType = $computerSystem.PCSystemType

    # Check if the system is a mobile device
    if ($pcSystemType -eq 2) {
        # Mobile device detected, launching presentation settings
        Start-Process -FilePath "C:\Windows\System32\PresentationSettings.exe" -ArgumentList "/start"
    } else {
        # Wake lock logic script block
        $wakeLockScript = {
            $flagFilePath = "C:\Temp\WakeLock.flag"
            $wsh = New-Object -ComObject WScript.Shell

            while ($true) {
                if (Test-Path $flagFilePath) {
                    break
                } else {
                    $wsh.SendKeys('+{F15}')  # Prevent system sleep by simulating a key press
                    Start-Sleep -Seconds 60  # Wait for 60 seconds before the next iteration
                }
            }
        }

        # Encode the script block to Base64 to pass to PowerShell
        $encodedScript = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($wakeLockScript.ToString()))

        # Start the script block in a new hidden PowerShell process and get the PID
        $process = Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile", "-WindowStyle Hidden", "-EncodedCommand $encodedScript" -PassThru
        $IdlePID = $process.Id

        # Write the PID to the console
        Write-Host "Idle prevention process started with PID: $IdlePID"
    }
} catch {
    Write-Error "Failed to retrieve computer system information. Error: $_"
}
