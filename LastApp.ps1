$LastApp = Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class UserWindows {
        [DllImport("user32.dll")]
        public static extern IntPtr GetForegroundWindow();
    }
"@

try {
    $activeHandle = [UserWindows]::GetForegroundWindow()
    $process = Get-Process | Where-Object { $_.MainWindowHandle -eq $activeHandle }
    if ($process) {
        $process | Select-Object ProcessName, @{Name="AppTitle";Expression={$_.MainWindowTitle}}
    }
    else {
        Write-Warning "No process found with the active window handle."
    }
}
catch {
    Write-Error "Failed to get active window details. More Info: $_"
}
$LastApp | ft -HideTableHeaders