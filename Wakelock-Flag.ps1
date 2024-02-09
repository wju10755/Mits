# Define the flag file path
$flagFilePath = "C:\Temp\WakeLock.flag"

# Create the WScript.Shell COM object outside the loop to avoid repeated creation
$wsh = New-Object -ComObject WScript.Shell

# Infinite loop to keep running the function at a specified interval
while ($true) {
    # Check if the flag file exists at the start of each loop iteration
    if (Test-Path $flagFilePath) {
        # If the flag file exists, log the termination message and break the loop
        #Write-Host "Flag file found. Terminating script..."
        break
    } else {
        #Write-Host "Flag file not found. Continuing to prevent sleep mode..."
    }

    # Send the Shift + F15 keystroke to prevent the system from going idle
    # F15 is a key that's unlikely to be on your keyboard, and using it with Shift avoids unintended actions
    $wsh.SendKeys('+{F15}')

    # Wait for 60 seconds before sending the keystroke again
    Start-Sleep -Seconds 60
}
