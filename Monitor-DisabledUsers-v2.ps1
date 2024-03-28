# Import the module
#Import-Module AzureAD

# Connect to your Azure AD
#Connect-AzureAD

# Function to get disabled accounts
function Get-DisabledAccounts {
    $users = Get-AzureADUser -All $true | Where-Object {$_.AccountEnabled -eq $false}
    return $users
}

# Keep track of previously disabled accounts
$previousDisabledAccounts = Get-DisabledAccounts | ForEach-Object { $_.ObjectId }

# Monitor for disabled accounts every 5 minutes
while ($true) {
    $disabledAccounts = Get-DisabledAccounts
    $newDisabledAccounts = $disabledAccounts | Where-Object { $_.ObjectId -notin $previousDisabledAccounts }

    if ($newDisabledAccounts) {
        Write-Output "Newly disabled accounts:"
        $newDisabledAccounts | Format-Table UserPrincipalName, DisplayName

        # Update the list of previously disabled accounts
        $previousDisabledAccounts = $disabledAccounts | ForEach-Object { $_.ObjectId }
    } else {
        Write-Output "No new disabled accounts found."
    }

    Start-Sleep -Seconds 60
}