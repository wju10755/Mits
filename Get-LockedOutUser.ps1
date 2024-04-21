# Import the Active Directory module
Import-Module ActiveDirectory

# Get the user
$user = Get-ADUser -Identity "username" -Properties LockedOut

# Check if the user is locked out
if ($user.LockedOut -eq $true) {
    Write-Host "The account is locked out."

    # Define the filter hashtable
    $filterHashTable = @{
        LogName = 'Security'
        Id = 4740
        StartTime = (Get-Date).AddDays(-1)
    }

    # Get the events
    $events = Get-WinEvent -FilterHashtable $filterHashTable -ComputerName "YourDomainController"

    # Loop through the events and output the required information
    foreach ($event in $events) {
        $xml = [xml]$event.ToXml()
        $eventData = $xml.Event.EventData.Data

        $targetAccountName = $eventData | Where-Object { $_.Name -eq 'TargetUserName' } | Select-Object -ExpandProperty '#text'

        # Check if the event is related to the locked out user
        if ($targetAccountName -eq $user.SamAccountName) {
            $subjectAccountName = $eventData | Where-Object { $_.Name -eq 'SubjectUserName' } | Select-Object -ExpandProperty '#text'
            $subjectAccountDomain = $eventData | Where-Object { $_.Name -eq 'SubjectDomainName' } | Select-Object -ExpandProperty '#text'
            $targetSecurityId = $eventData | Where-Object { $_.Name -eq 'TargetSid' } | Select-Object -ExpandProperty '#text'
            $targetComputer = $eventData | Where-Object { $_.Name -eq 'WorkstationName' } | Select-Object -ExpandProperty '#text'

            Write-Host "Subject: Account Name: $subjectAccountName, Account Domain: $subjectAccountDomain"
            Write-Host "Account that was locked out: Security ID: $targetSecurityId, Account Name: $targetAccountName, Computer: $targetComputer"
        }
    }
} else {
    Write-Host "The account is not locked out."
}