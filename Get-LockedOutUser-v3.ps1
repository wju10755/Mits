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
        StartTime = (Get-Date).AddDays(-1)
    }

    # Get the events
    $events = Get-WinEvent -FilterHashtable $filterHashTable -ComputerName "CCG-DC-04"

    # Loop through the events and output the required information
    foreach ($event in $events) {
        $xml = [xml]$event.ToXml()
        $eventData = $xml.Event.EventData.Data

        $targetAccountName = $eventData | Where-Object { $_.Name -eq 'TargetUserName' } | Select-Object -ExpandProperty '#text'

        # Check if the event is related to the locked out user
        if ($targetAccountName -eq $user.SamAccountName) {
            $subjectAccountName = $eventData | Where-Object { $_.Name -eq 'SubjectUserName' } | Select-Object -ExpandProperty '#text'
            $subjectAccountDomain = $eventData | Where-Object { $_.Name -eq 'SubjectDomainName' } | Select-Object -ExpandProperty '#text'
            $failureReason = $eventData | Where-Object { $_.Name -eq 'FailureReason' } | Select-Object -ExpandProperty '#text'
            $callerProcessName = $eventData | Where-Object { $_.Name -eq 'CallerProcessName' } | Select-Object -ExpandProperty '#text'
            $workstationName = $eventData | Where-Object { $_.Name -eq 'WorkstationName' } | Select-Object -ExpandProperty '#text'
            
            $sourceNetworkAddressData = $eventData | Where-Object { $_.Name -eq 'SourceNetworkAddress' }
            if ($sourceNetworkAddressData) {
                $sourceNetworkAddress = $sourceNetworkAddressData | Select-Object -ExpandProperty '#text'
                Write-Host "Source Network Address: $sourceNetworkAddress"
            } else {
                Write-Host "Source Network Address: Not available"
            }

            $sourcePort = $eventData | Where-Object { $_.Name -eq 'SourcePort' } | Select-Object -ExpandProperty '#text'
            $logonProcess = $eventData | Where-Object { $_.Name -eq 'LogonProcess' } | Select-Object -ExpandProperty '#text'
            $authenticationPackage = $eventData | Where-Object { $_.Name -eq 'AuthenticationPackageName' } | Select-Object -ExpandProperty '#text'

            Write-Host "Subject: Account Name: $subjectAccountName, Account Domain: $subjectAccountDomain"
            Write-Host "Failure Reason: $failureReason"
            Write-Host "Caller Process Name: $callerProcessName"
            Write-Host "Workstation Name: $workstationName"
            Write-Host "Source Port: $sourcePort"
            Write-Host "Logon Process: $logonProcess"
            Write-Host "Authentication Package: $authenticationPackage"
        }
    }
}