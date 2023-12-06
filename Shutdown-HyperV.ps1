# PowerShell script to shut down Hyper-V services

# Check if the script is running with administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Please run this script as an Administrator!"
    break
}

# Stopping Hyper-V Virtual Machine Management service
Stop-Service -Name 'vmms' -Force -ErrorAction SilentlyContinue
Write-Host "Hyper-V Virtual Machine Management service stopped."

# Stopping Hyper-V Host Compute Service
Stop-Service -Name 'vmcompute' -Force -ErrorAction SilentlyContinue
Write-Host "Hyper-V Host Compute Service stopped."

# Optional: Disable the services to prevent them from starting automatically
Set-Service -Name 'vmms' -StartupType Disabled
Set-Service -Name 'vmcompute' -StartupType Disabled
Write-Host "Hyper-V services set to disabled."

# Script end
Write-Host "Hyper-V services shutdown script completed."
