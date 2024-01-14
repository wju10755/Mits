$flagFile = "C:\path\to\flag.txt"
$targetDateTime = Get-Date "1/12/2024 1:00am"
$currentDateTime = Get-Date

if (Test-Path $flagFile) {
    # Read the last reboot time from the flag file
    $lastRebootTime = Get-Content $flagFile | Get-Date

    # Check if the machine has rebooted since the last time the script ran
    $uptimeOutput = (Get-Uptime).LastBootUpTime
    $currentRebootTime = [Management.ManagementDateTimeConverter]::ToDateTime($uptimeOutput)
    if ($currentRebootTime -le $lastRebootTime) {
        # Create a scheduled task to reboot the machine the next day at 1:00 am
        $action = New-ScheduledTaskAction -Execute "shutdown.exe" -Argument "/r"
        $trigger = New-ScheduledTaskTrigger -Daily -At "1:00am"
        Register-ScheduledTask -TaskName "Reboot" -Action $action -Trigger $trigger
    }
} else {
    # Create the flag file and record the current time
    $currentDateTime | Out-File $flagFile
}