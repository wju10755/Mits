$policies = Get-AzureADMSConditionalAccessPolicy

# Retrieve policy by ID - [All cloud apps] GRANT: Require MFA for all users
$policy1 = Get-AzureADMSConditionalAccessPolicy | where {$_.Id -eq 'd3101fe1-2445-4180-9575-662e4f98a813'} | select Id

# Retrieve policy by ID - M365 Lighthouse - Require MFA for Users
$policy2 = Get-AzureADMSConditionalAccessPolicy | where {$_.Id -eq '91b04ea1-f0ed-45e6-acfd-7451b539b222'} | select Id

# Convert the policies to JSON for easier comparison
$jsonPolicy1 = $policy1 | ConvertTo-Json
$jsonPolicy2 = $policy2 | ConvertTo-Json

$diff = Compare-Object $policy1 $policy2 -Property Name, State, Conditions, GrantControls, SessionControls, ClientAppIds, CreatedDateTime, ModifiedDateTime

if ($diff) {
    Write-Host "The following differences were found between the two policies:"
    $diff | Format-Table -AutoSize
} else {
    Write-Host "The two policies are identical."
}