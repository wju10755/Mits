# Create temp directory
if (!(Test-Path -Path C:\temp)) {
    New-Item -ItemType directory -Path C:\temp *> $null
}

$DLProcmon = "`nDownloading Process Monitor..."
foreach ($Char in $DLProcmon.ToCharArray()) {
    [Console]::Write("$Char")
    Start-Sleep -Milliseconds 40
}
$url = "https://download.sysinternals.com/files/ProcessMonitor.zip"
$filePath = "c:\temp\ProcessMonitor.zip"
$file = "c:\temp\ProcessMonitor\Procmon64.exe"
Invoke-WebRequest -Uri $url -OutFile $filePath
[Console]::ForegroundColor = [System.ConsoleColor]::Green
[Console]::Write(" done.`n")
[Console]::ResetColor()
[Console]::WriteLine() 
$Unzip = "Extracting Process Monitor..."
foreach ($Char in $Unzip.ToCharArray()) {
    [Console]::Write("$Char")
    Start-Sleep -Milliseconds 40
}
Expand-Archive $filePath -DestinationPath "c:\temp\ProcessMonitor"
[Console]::ForegroundColor = [System.ConsoleColor]::Green
[Console]::Write(" done.`n")
[Console]::ResetColor()
[Console]::WriteLine() 
$StartProcmon = "Starting Process Monitor...`n"
foreach ($Char in $StartProcmon.ToCharArray()) {
    [Console]::Write("$Char")
    Start-Sleep -Milliseconds 40
}
#Start-Process -FilePath $file -ArgumentList "/AcceptEula" -WindowStyle Normal

# Launch Procmon and enable auto-scroll
$ps = Start-Process $file -ArgumentList "/AcceptEula" -WindowStyle Normal
$wshell = New-Object -ComObject wscript.shell
Start-Sleep -Seconds 2
$wshell.SendKeys("^a")
Start-Sleep -Seconds 2
[Console]::ForegroundColor = [System.ConsoleColor]::Green
[Console]::Write(" done.`n")
[Console]::ResetColor()
[Console]::WriteLine() 

# Move Procmon left
Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class WinAPI {
        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
        [DllImport("user32.dll", SetLastError = true)]
        public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
        [StructLayout(LayoutKind.Sequential)]
        public struct RECT {
            public int Left;
            public int Top;
            public int Right;
            public int Bottom;
        }
    }
"@

function Move-ProcessWindowToTopLeft([string]$processName) {
    $process = Get-Process | Where-Object { $_.ProcessName -eq $processName } | Select-Object -First 1
    if ($null -eq $process) {
        Write-Host "Process not found."
        return
    }

    $hWnd = $process.MainWindowHandle
    if ($hWnd -eq [IntPtr]::Zero) {
        Write-Host "Window handle not found."
        return
    }

    $windowRect = New-Object WinAPI+RECT
    [WinAPI]::GetWindowRect($hWnd, [ref]$windowRect)
    $windowWidth = $windowRect.Right - $windowRect.Left
    $windowHeight = $windowRect.Bottom - $windowRect.Top

    # Set coordinates to the top left corner of the screen
    $x = 0
    $y = 0

    [WinAPI]::MoveWindow($hWnd, $x, $y, $windowWidth, $windowHeight, $true)
}

Move-ProcessWindowToTopLeft -processName "procmon64" *> $null
