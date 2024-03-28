# Import the module
#Import-Module AzureAD

# Connect to your Azure AD
#Connect-AzureAD

# Function to get disabled accounts
function Get-DisabledAccounts {
    $users = Get-AzureADUser -All $true | Where-Object {$_.AccountEnabled -eq $false}
    return $users
}

# Monitor for disabled accounts every 5 minutes
while ($true) {
    $disabledAccounts = Get-DisabledAccounts
    if ($disabledAccounts) {
        Write-Output "Disabled accounts:"
        $disabledAccounts | Format-Table UserPrincipalName, DisplayName
    } else {
        Write-Output "No disabled accounts found."
    }
    Start-Sleep -Seconds 60
}