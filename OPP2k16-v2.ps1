# Download and install Office 2016 for Saiontz and Kirk

# Check if the file exists
if (Test-Path -Path 'c:\temp\O2k16pp.zip') {
    Write-Host "The file already exists."
}
else {
    # Create the destination folder if it does not exist
    if (-not (Test-Path -Path 'c:\temp')) {
        New-Item -Path 'c:\temp' -ItemType Directory
    }
    # Download the file using Invoke-WebRequest
    $url = 'https://skgeneralstorage.blob.core.windows.net/o2k16pp/O2k16pp.zip'
    $destination = 'c:\temp\O2k16pp.zip'
    Invoke-WebRequest -Uri $url -OutFile $destination
    Write-Host "The file has been downloaded."
}


try {
    $OfficeInstaller = "C:\temp\Office2016_ProPlus\setup.exe"
    $OfficeArguments = "/adminfile .\SLaddInstallOffice.msp"
    Set-Location -path 'C:\temp\Office2016_ProPlus\'
    Start-Process -FilePath $OfficeInstaller -ArgumentList $OfficeArguments -Wait
}
catch {
    Write-Error "An error occurred while installing Office Professional Plus 2016: $_"
}
finally {
    Write-Host "The installation process complete."
}
