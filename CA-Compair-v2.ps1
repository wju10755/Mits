# Retrieve the policies from Azure AD
$policies = Get-AzureADMSConditionalAccessPolicy

# Retrieve policy by ID - [All cloud apps] GRANT: Require MFA for all users
$policy1 = $policies | Where-Object { $_.Id -eq 'd3101fe1-2445-4180-9575-662e4f98a813' }

# Retrieve policy by ID - M365 Lighthouse - Require MFA for Users
$policy2 = $policies | Where-Object { $_.Id -eq '91b04ea1-f0ed-45e6-acfd-7451b539b222' }

# Convert the policies to JSON for easier comparison
$jsonPolicy1 = $policy1 | ConvertTo-Json
$jsonPolicy2 = $policy2 | ConvertTo-Json

# Compare the policies using Compare-Object
$diff = Compare-Object ($policy1 | ConvertTo-Json -Depth 10 | ConvertFrom-Json) ($policy2 | ConvertTo-Json -Depth 10 | ConvertFrom-Json) -Property Name, State, Conditions, GrantControls, SessionControls -PassThru

if ($diff) {
    Write-Host "The following differences were found between the two policies:"
    $diff | Format-Table -AutoSize
} else {
    Write-Host "The two policies are identical."
}
