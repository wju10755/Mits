# Define the thumbprint of the certificate you're looking for
$thumbprint = "08de8ff1a8ea708098588f1cbbf4faeeac44a217"

# Search the local machine certificate store
$certificate = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object { $_.Thumbprint -eq $thumbprint }

# Print the certificate details
if ($certificate) {
    Write-Host "Certificate found: $certificate"
} else {
    Write-Host "Certificate not found"
}