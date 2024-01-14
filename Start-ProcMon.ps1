$DLProcmon = "Downloading Process Monitor..."
foreach ($Char in $DLProcmon.ToCharArray()) {
    [Console]::Write("$Char")
    Start-Sleep -Milliseconds 40
}
$url = "https://download.sysinternals.com/files/ProcessMonitor.zip"
$filePath = "c:\temp\ProcessMonitor.zip"
$file = "c:\ProcessMonitor\Procmon64.exe"
Invoke-WebRequest -Uri $url -OutFile $filePath
[Console]::ForegroundColor = [System.ConsoleColor]::Green
[Console]::Write(" done.`n")
[Console]::ResetColor()
[Console]::WriteLine() 
Expand-Archive $filePath -DestinationPath "c:\temp\ProcessMonitor"
$DLProcmon = "Starting Process Monitor..."
foreach ($Char in $DLProcmon.ToCharArray()) {
    [Console]::Write("$Char")
    Start-Sleep -Milliseconds 40
}
Start-Process -FilePath $filePath -ArgumentList "/AcceptEula" -WindowStyle Normal
