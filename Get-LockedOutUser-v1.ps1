# Import the Active Directory module
Import-Module ActiveDirectory

# Get all locked out users
$lockedOutUsers = Search-ADAccount -LockedOut

# Loop through the locked out users
foreach ($user in $lockedOutUsers) {
    Write-Host "The account $($user.SamAccountName) is locked out."

    # Define the filter hashtable
$filterHashTable = @{
    LogName = 'Security'
    Id = 4625
}

# Get the last 5 events with ID 4625
$events = Get-WinEvent -FilterHashtable $filterHashTable -MaxEvents 1

# Loop through the events and output the required information
foreach ($event in $events) {
    $xml = [xml]$event.ToXml()
    $eventData = $xml.Event.EventData.Data

    Write-Host "Event ID: $($event.Id)"
    Write-Host "Time Created: $($event.TimeCreated)"
    Write-Host "Event Data:"

    foreach ($data in $eventData) {
        Write-Host "$($data.Name): $($data.'#text')"
    }

    Write-Host ""
}