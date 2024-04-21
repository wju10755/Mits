# Import the Active Directory module
Import-Module ActiveDirectory

# Get all locked out users
$lockedOutUsers = Search-ADAccount -LockedOut

# Define the properties to exclude
$excludedProperties = @('SubjectUserSid', 'SubjectLogonId', 'TargetUserSid', 'Status', 'FailureReason', 'SubStatus', 'TransmittedServices', 'LmPackageName', 'KeyLength', 'ProcessId')

# Loop through the locked out users
foreach ($user in $lockedOutUsers) {
    Write-Host "The account $($user.SamAccountName) is locked out."

    # Get the last event with ID 4625 for this user
    $filterHashTable = @{
        LogName = 'Security'
        Id = 4625
    }
    $events = Get-WinEvent -FilterHashtable $filterHashTable -MaxEvents 1

    # Loop through the events and output the required information
    foreach ($event in $events) {
        $xml = [xml]$event.ToXml()
        $eventData = $xml.Event.EventData.Data

        Write-Host "Event ID: $($event.Id)"
        Write-Host "Time Created: $($event.TimeCreated)"
        Write-Host "Event Data:"

        foreach ($data in $eventData) {
            if ($data.Name -notin $excludedProperties) {
                Write-Host "$($data.Name): $($data.'#text')"
                if ($data.Name -eq 'IpAddress') {
                    $ipAddress = $data.'#text'
                    $popularPorts = @(20, 21, 22, 23, 25, 53, 80, 110, 143, 443, 465, 587, 993, 995, 3389)
                    Write-Host "Scanning for available services on ${ipAddress}:"
                    foreach ($port in $popularPorts) {
                        $connection = Test-NetConnection -ComputerName $ipAddress -Port $port -InformationLevel Quiet -WarningAction SilentlyContinue
                        if ($connection) {
                            Write-Host "Port $port is open."
                        }
                    }
                }
            }
        }

        Write-Host ""
    }
}
