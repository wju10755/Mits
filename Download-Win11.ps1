# Specify the exact file size in bytes
$correctFileSize = 6812706816

# Check if the file already exists
if (Test-Path -Path $destinationPath) {
    # Get the size of the existing file
    $existingFileSize = (Get-Item -Path $destinationPath).length

    # Compare the size of the existing file with the correct file size
    if ($existingFileSize -eq $correctFileSize) {
        Write-Host "The file already exists and has the correct size. No download needed."
    } else {
        Write-Host "The existing file does not match the specified size. Downloading the correct file..."
        # Download the file
        Invoke-WebRequest -Uri $isoUrl -OutFile $destinationPath
        Write-Host "Download completed."
    }
} else {
    Write-Host "File does not exist. Downloading..."
    # Download the file
    Invoke-WebRequest -Uri $isoUrl -OutFile $destinationPath
    Write-Host "Download completed."
}