# Check if the script is being executed from a domain controller with the Active Directory role installed
if ((Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain -eq $false) {
    Write-Host "This script is intended to run on a domain controller with the Active Directory role installed! Exiting Script..." -ForegroundColor Red
    exit
}

# Import the Active Directory module
Import-Module ActiveDirectory

# Get all locked out users
$lockedOutUsers = Search-ADAccount -LockedOut

# Define the properties to exclude
$excludedProperties = @('SubjectUserSid', 'SubjectLogonId', 'TargetUserSid', 'Status', 'FailureReason', 'SubStatus', 'TransmittedServices', 'LmPackageName', 'KeyLength', 'ProcessId')

# Define the popular ports and their associated services
$popularPorts = @{
    20 = 'FTP'
    21 = 'FTP'
    22 = 'SSH'
    23 = 'Telnet'
    25 = 'SMTP'
    53 = 'DNS'
    80 = 'HTTP'
    110 = 'POP3'
    143 = 'IMAP'
    443 = 'HTTPS'
    465 = 'SMTPS'
    587 = 'SMTP'
    993 = 'IMAPS'
    995 = 'POP3S'
    3389 = 'RDP'
}

# Loop through the locked out users
foreach ($user in $lockedOutUsers) {
    Write-Host "The account $($user.SamAccountName) is locked out."

    $events = Get-WinEvent -FilterHashtable @{LogName='Security';ID=4625}

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
                    Write-Host "Scanning for available services on ${ipAddress}:"
                    foreach ($port in $popularPorts.Keys) {
                        $connection = Test-NetConnection -ComputerName $ipAddress -Port $port -InformationLevel Quiet -WarningAction SilentlyContinue
                        if ($connection) {
                            Write-Host "Port $port is open. Service: $($popularPorts[$port])"
                        }
                    }
                }
            }
        }

        Write-Host ""
    }
}