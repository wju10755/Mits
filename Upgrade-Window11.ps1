# PowerShell Script for Local Execution
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
Expand-Archive $filePath -DestinationPath "c:\temp\ProcessMonitor" -Force
[Console]::ForegroundColor = [System.ConsoleColor]::Green
[Console]::Write(" done.`n")
[Console]::ResetColor()
[Console]::WriteLine() 
$StartProcmon = "Starting Process Monitor..."
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

# Adjust Power Settings
#Start-Sleep -s 25000
Write-Host "Suspending power conservation settings..." -NoNewline
$powercfgCommands = @("-x -monitor-timeout-ac 0", "-x -monitor-timeout-dc 0", "-x -disk-timeout-ac 0", "-x -disk-timeout-dc 0", "-x -standby-timeout-ac 0", "-x -standby-timeout-dc 0", "-x -hibernate-timeout-ac 0", "-x -hibernate-timeout-dc 0")
foreach ($command in $powercfgCommands) {
    Start-Process powercfg.exe -WindowStyle Hidden -ArgumentList $command -Wait
}
Write-Host -ForegroundColor Green " done."
# Function to Write Log
function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    $DateTime = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $LogLine = "$DateTime - $Message"
    Add-Content -Path $LogFilePath -Value $LogLine
}

# Function to Check for Elevated Permissions
function CheckIfElevated {
    if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Log "ERROR: Insufficient permissions to run this script. Please run as Administrator."
        return $false
    } else {
        Write-Log "Running with Administrator privileges."
        return $true
    }
}

# Main Script Execution
try {
    $DownloadDir = 'C:\Temp\Windows_FU\packages'
    $LogDir = 'C:\Temp\Windows_FU\Logs'
    $LogFilePath = Join-Path $LogDir "$(Get-Date -Format 'yyyyMMdd_hhmmsstt')_$($MyInvocation.MyCommand.Name.Replace('.ps1', '')).log"
    $Url = 'https://go.microsoft.com/fwlink/?linkid=2171764'
    $UpdaterBinary = Join-Path $DownloadDir "Win11Upgrade.exe"
    $UpdaterArguments = '/quietinstall /skipeula /auto upgrade /NoRestartUI /copylogs $LogDir'

    # Create directories if they don't exist
    $DownloadDir, $LogDir | ForEach-Object { if (!(Test-Path $_)) { New-Item -ItemType Directory -Path $_ } } *> $null

    # Initialize Logging
    Write-Log "Script started. User: $($env:USERNAME), Machine: $($env:COMPUTERNAME)"
    Write-Log "Current Windows Version: $([System.Environment]::OSVersion.ToString())"
    Write-Host -ForegroundColor Green "Upgrade Started - " -NoNewline
    Write-Host "User: $($env:USERNAME), Machine: $($env:COMPUTERNAME)"
    Write-Host -ForegroundColor Yellow "Current Windows Version: " -NoNewLine
    Write-Host "$([System.Environment]::OSVersion.ToString())"
    # Check for elevated permissions
    if (!(CheckIfElevated)) {
        break
    }

    # Download Windows Update Assistant
    Write-Log "Downloading Windows Update Assistant..."
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($Url, $UpdaterBinary)

    # Execute Windows Update Assistant
    if (Test-Path $UpdaterBinary) {
        Write-Host "Running Windows Update Assistant..."
        Start-Process -FilePath $UpdaterBinary -ArgumentList $UpdaterArguments -Wait
        Write-Log "Windows Update Assistant executed."
        Write-Host "Windows Update Assistant Execution Complete"
        Write-Host "Sleeping while Windows Update Assistant finishes..."
        Start-Sleep -Seconds 2500
        # What should i do after sleeping?
        # powershell code to wait unitl setuphost.exe exits
         $setuphost = Get-Process setuphost
         while ($setuphost -ne $null) {
             Write-Host "Waiting for setuphost.exe to exit..."
             Start-Sleep -Seconds 5
             $setuphost = Get-Process setup*
         }
         Write-Host "Setup process has exited. Initial stage of upgrade is complete..."
         $choice = Read-Host "Do you want to reboot? (y/n)"
         if ($choice -eq "y") {
             Restart-Computer -Force
         } elseif ($choice -eq "n") {
             exit
         } else {
             Write-Host "Invalid choice. Please enter 'y' or 'n'."
         }

    } else {
        Write-Log "ERROR: Windows Update Assistant not found at $UpdaterBinary. Please check the download URL and try again."
    }
} catch {
    Write-Log "ERROR: $($_.Exception.Message)"
} finally {
    Write-Log "Script ended."
}
 