Clear-Host
# Check if the script is being executed from a domain controller with the Active Directory role installed
if ((Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain -eq $false) {
    Write-Host -ForegroundColor Red "This script is intended to run on a domain controller with the Active Directory role installed! Exiting Script..."
    Start-Sleep -seconds 10
    exit
}

# Set console formatting
function Print-Middle($Message, $Color = "White") {
    Write-Host (" " * [System.Math]::Floor(([System.Console]::BufferWidth / 2) - ($Message.Length / 2))) -NoNewline;
    Write-Host -ForegroundColor $Color $Message;
}

# Print Script Title
#################################
$Padding = ("=" * [System.Console]::BufferWidth);
Write-Host -ForegroundColor "Red" $Padding -NoNewline;
Print-Middle "MITS - Account Lockout Investigation Script";
Write-Host -ForegroundColor Cyan "                                                   version 0.1.3";
Write-Host -ForegroundColor "Red" -NoNewline $Padding; 
Write-Host "  "
$ErrorActionPreference = "SilentlyContinue"
# Import the Active Directory module
Import-Module ActiveDirectory

# Get all domain controllers
$domainControllers = Get-ADDomainController -Filter * | Out-Null

# Define the properties to exclude
$excludedProperties = @('SubjectUserSid', 'SubjectLogonId', 'TargetUserSid', 'Status', 'FailureReason', 'SubStatus', 'TransmittedServices', 'LmPackageName', 'KeyLength', 'ProcessId', 'IpPort')

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

# Loop through the domain controllers
foreach ($dc in $domainControllers) {
    Write-Host "Checking domain controller $($dc.HostName)..."

    # Get all locked out users
    $lockedOutUsers = Search-ADAccount -LockedOut -Server $dc.HostName

    # Check if there are locked out users
    if ($lockedOutUsers.Count -eq 0) {
        Write-Host -ForegroundColor Green "No account lockout events found on $($dc.HostName).`n"
        continue
    }

    # Loop through the locked out users
    foreach ($user in $lockedOutUsers) {
        Write-Host "The account $($user.SamAccountName) is locked out."

        # Get the last event with ID 4625 for this user
        $filterHashTable = @{
            LogName = 'Security'
            Id = 4625
        }
        $events = Get-WinEvent -FilterHashtable $filterHashTable -MaxEvents 1 -ComputerName $dc.HostName -ErrorAction SilentlyContinue

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
            Write-Host " "
        }
    }
}