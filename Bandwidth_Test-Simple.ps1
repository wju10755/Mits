$url = 'https://advancestuff.hostedrmm.com/labtech/transfer/installers/CRRuntime_32bit_13_0_25.msi'
$outfile = 'c:\temp\CRRuntime_32bit_13_0_25.msi'

if (-not (Test-Path (Split-Path -Parent $outfile))) {
    Write-Host "Output directory does not exist." -ForegroundColor Red
    return
}

try {
    $downloadTime = Measure-Command {
        Invoke-WebRequest $url -outfile $outfile -ErrorAction Stop | Out-Null
    }
    $downloadSpeed = (10 / $downloadTime.TotalSeconds) * 8
    "{0:N2} Mbit/sec" -f $downloadSpeed
} catch {
    Write-Host "Failed to download file. Error: $_" -ForegroundColor Red
} finally {
    if (Test-Path $outfile) {
        Remove-Item $outfile -ErrorAction SilentlyContinue
    }
}