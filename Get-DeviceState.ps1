# dsregcmd commands to collect device join state information.


# Get AzureAD Join
$ErrorActionPreference = "SilentlyContinue"
$AzureADJoined = ((dsregcmd /status | select-string -Pattern "AzureAdJoined").Line).Trim()
$AzureADJoinedValue = if ($AzureADJoined) {
    ($AzureADJoined -split ":")[-1].Trim()
} else {
    'Value not found'
}
$AzureADJoinedValue



# Get Domain Join
$ErrorActionPreference = "SilentlyContinue"
$DomainJoined = ((dsregcmd /status | select-string -Pattern "DomainJoined").Line).Trim()
$DomainJoinedValue = if ($DomainJoined) {
    ($DomainJoined -split ":")[-1].Trim()
} else {
    'Value not found'
}
$DomainJoinedValue


# Get Enterprise Join
$ErrorActionPreference = "SilentlyContinue"
$EnterpriseADJoined = ((dsregcmd /status | select-string -Pattern "EnterpriseJoined").Line).Trim()
$EnterpriseADJoinedValue = if ($EnterpriseADJoined) {
    ($EnterpriseADJoined -split ":")[-1].Trim()
} else {
    'Value not found'
}
$EnterpriseADJoinedValue


# Get Virtual Desktop
$ErrorActionPreference = "SilentlyContinue"
$VirtualDesktop = ((dsregcmd /status | select-string -Pattern "Virtual Desktop").Line).Trim()
$VirtualDesktopValue = if ($VirtualDesktop) {
    ($VirtualDesktop -split ":")[-1].Trim()
} else {
    'Value not found'
}
$VirtualDesktopValue 


# Get Device ID
$ErrorActionPreference = "SilentlyContinue"
$DeviceId = ((dsregcmd /status | select-string -Pattern "DeviceId").Line).Trim()
$DeviceIdValue = if ($DeviceId) {
    ($DeviceId -split ":")[-1].Trim()
} else {
    'Value not found'
}
$DeviceIdValue


# Get TPM Protection Status
$ErrorActionPreference = "SilentlyContinue"
$TPMProtected = ((dsregcmd /status | select-string -Pattern "TpmProtected").Line).Trim()
$TPMProtectedValue = if ($TPMProtected) {
    ($TPMProtected -split ":")[-1].Trim()
} else {
    'Value not found'
}
$TPMProtectedValue 


# Get Device Auth Status
$ErrorActionPreference = "SilentlyContinue"
$DeviceAuthStatus = ((dsregcmd /status | select-string -Pattern "DeviceAuthStatus").Line).Trim()
$DeviceAuthStatusValue = if ($DeviceAuthStatus) {
    ($DeviceAuthStatus -split ":")[-1].Trim()
} else {
    'Value not found'
}
$DeviceAuthStatusValue


