<#-----------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
<DESCRIPTION> Upgrade Windows 10 to 22H2 via Enablement Package
-------------------------------------------------------------------------------------------------------------
    > Queries Windows 10 Version [ReleaseID] and saves it to $OSVersion
    > Checks which updates and dependencies are missing, then sets variables to result
    > Downloads and installs Service Stack Update if variable $SSU_Installed = $false
    > Downloads and installs Feature Update if variable $FU_Installed = $false, reboots
    > Downloads and installed Cumulative Update if variable $CU_Installed = $false, reboots
    > Downloads and installs .NET Cumulative Update if variable $DOTNET_Installed = $false, reboots
-------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------#>
clear-host
function Print-Middle( $Message, $Color = "White" )
{
    Write-Host ( " " * [System.Math]::Floor( ( [System.Console]::BufferWidth / 2 ) - ( $Message.Length / 2 ) ) ) -NoNewline;
    Write-Host -ForegroundColor $Color $Message;
}
# Print Script Title
#################################
$Padding = ("=" * [System.Console]::BufferWidth);
Write-Host -ForegroundColor "Red" $Padding -NoNewline;
Print-Middle "MITS - Windows 10 22H2 Upgrade Helper"
Write-Host -ForegroundColor DarkRed "                                                      version 0.0.5";

Write-Host -ForegroundColor "Red" $Padding;
Write-Host `n


#-Variables [Global]
$VerbosePreference = "Continue"
$EA_Silent         = @{ErrorAction = "SilentlyContinue"}
$TempDir           = "C:\Temp\WU\"
$Release           = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ReleaseId @EA_Silent).ReleaseId
$Ver               = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name DisplayVersion @EA_Silent).DisplayVersion
$OSVersion         = if ($Release -eq '2009') {$Ver} else {$Release}

#-Variables [Updates]
$DOTNET            = "KB5033909"
$CU                = "KB5034122"
$FU                = "KB5015684"
$SSU_2004          = "KB5005260"
$SSU_20H2          = "KB5014032"
$SSU_21H1          = "KB5014032"
$SSU_21H2          = "KB5031539"
$URL_DOTNET        = "https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/secu/2023/12/windows10.0-kb5033909-x64-ndp48_ae6d65030ae80a9661685579932305f66be1907a.msu"
$URL_CU            = "https://catalog.s.download.windowsupdate.com/d/msdownload/update/software/secu/2024/01/windows10.0-kb5034122-x64_de14dfac8817c1d0765b899125c63dc7b581958b.msu"
$URL_FU            = "https://catalog.s.download.windowsupdate.com/c/upgr/2022/07/windows10.0-kb5015684-x64_523c039b86ca98f2d818c4e6706e2cc94b634c4a.msu"
$URL_SSU_2004      = "https://catalog.s.download.windowsupdate.com/d/msdownload/update/software/secu/2021/08/ssu-19041.1161-x64_e7e052f5cbe97d708ee5f56a8b575262d02cfaa4.msu"
$URL_SSU_20H2      = "https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/secu/2022/05/ssu-19041.1704-x64_70e350118b85fdae082ab7fde8165a947341ba1a.msu"
$URL_SSU_21H1      = "https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/secu/2022/05/ssu-19041.1704-x64_70e350118b85fdae082ab7fde8165a947341ba1a.msu"
$URL_SSU_21H2      = "https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/secu/2023/10/ssu-19041.3562-x64_de23c91f483b2e609cec3e4a995639d13205f867.msu"

<#-----------------------------------------------------------------------------------------------------------
SCRIPT:FUNCTIONS
-----------------------------------------------------------------------------------------------------------#>

##--Queries Windows 10 Version [ReleaseID] and saves it to $OSVersion
function Test-Version {
    if ($OSVersion -lt "2004") {
        Write-Verbose "Windows 10 is on Version $OSVersion and cannot be updated to 22H2 using this script. Must use full ISO script."
        exit
    } else {
        Write-Verbose "Windows 10 is on Version $OSVersion"
    }
}

##--Checks which updates and dependencies are missing, then sets variables to result
function Test-KB {
    if ($OSVersion -eq "2004") {
        if (Get-HotFix -ID $SSU_2004 @EA_Silent) {
            $script:SSU_Installed = $true
            Write-Verbose "Service Stack Update $SSU_2004 is installed"
        } else {
            $script:SSU_Installed = $false
            Write-Verbose "Service Stack Update $SSU_2004 is not installed"
        }
    } elseif ($OSVersion -eq "20H2") {
        if (Get-HotFix -ID $SSU_20H2 @EA_Silent) {
            $script:SSU_Installed = $true
            Write-Verbose "Service Stack Update $SSU_20H2 is installed"
        } else {
            $script:SSU_Installed = $false
            Write-Verbose "Service Stack Update $SSU_20H2 is not installed"
        }
    } elseif ($OSVersion -eq "21H1") {
        if (Get-HotFix -ID $SSU_21H1 @EA_Silent) {
            $script:SSU_Installed = $true
            Write-Verbose "Service Stack Update $SSU_21H1 is installed"
        } else {
            $script:SSU_Installed = $false
            Write-Verbose "Service Stack Update $SSU_21H1 is not installed"
        }
    } elseif ($OSVersion -eq "21H2") {
        if (Get-HotFix -ID $SSU_21H2 @EA_Silent) {
            $script:SSU_Installed = $true
            Write-Verbose "Service Stack Update $SSU_21H2 is installed"
        } else {
            $script:SSU_Installed = $false
            Write-Verbose "Service Stack Update $SSU_21H2 is not installed"
        }
    }
    if (Get-HotFix -ID $FU @EA_Silent) {
        $script:FU_Installed = $true
        Write-Verbose "Feature Update $FU is installed"
    } else {
        $script:FU_Installed = $false
        Write-Verbose "Feature Update $FU is not installed"
    }
    if (Get-HotFix -ID $CU @EA_Silent) {
        $script:CU_Installed = $true
        Write-Verbose "Cumulative Update $CU is installed"
    } else {
        $script:CU_Installed = $false
        Write-Verbose "Cumulative Update $CU is not installed" 
    }
    if (Get-HotFix -ID $DOTNET @EA_Silent) {
        $script:DOTNET_Installed = $true
        Write-Verbose ".NET Update $DOTNET is installed"
    } else {
        $script:DOTNET_Installed = $false
        Write-Verbose ".NET Update $DOTNET is not installed"
    }
    if ($FU_Installed -and $CU_Installed -and $DOTNET_Installed) {
        Write-Verbose "All applicable updates are applied. Terminating script."
        exit
    }
}

##--Downloads and installs Service Stack Update
function Get-SSU {
    if ($SSU_Installed -eq $false -and $FU_Installed -eq $false) {
        if ($OSVersion -eq "2004") {
            $TempDir_SSU_2004 = "$TempDir\$SSU_2004"
            $File_SSU_2004    = "$TempDir_SSU_2004\windows10.0-$SSU_2004-x64.msu"
            Write-Verbose "Starting download for Service Stack Update $SSU_2004"
            if (Test-Path $TempDir_SSU_2004 -PathType Container) {
                if (Test-Path $File_SSU_2004 -PathType Leaf) {
                } else {
                    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls, ssl3"
                    Invoke-WebRequest -Uri $URL_SSU_2004 -OutFile $File_SSU_2004
                }
            } else {
                New-Item -Path $TempDir_SSU_2004 -ItemType Directory > $null
                [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls, ssl3"
                Invoke-WebRequest -Uri $URL_SSU_2004 -OutFile $File_SSU_2004
            }
            try {
                Write-Verbose "Installing Service Stack Update $SSU_2004."
                $process = Start-Process -FilePath "wusa.exe" -ArgumentList "$File_SSU_2004 /quiet /norestart" -PassThru -NoNewWindow -Wait
                if ($process.ExitCode -ne 0) {
                    throw "wusa.exe process failed with exit code $($process.ExitCode)."
                }
            } catch {
                Write-Warning "An error occurred: $_"
            }
        } elseif ($OSVersion -eq "20H2") {
            $TempDir_SSU_20H2 = "$TempDir\$SSU_20H2"
            $File_SSU_20H2    = "$TempDir_SSU_20H2\windows10.0-$SSU_20H2-x64.msu"
            Write-Verbose "Starting download for Service Stack Update $SSU_20H2"
            if (Test-Path $TempDir_SSU_20H2 -PathType Container) {
                if (Test-Path $File_SSU_20H2 -PathType Leaf) {
                } else {
                    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls, ssl3"
                    Invoke-WebRequest -Uri $URL_SSU_20H2 -OutFile $File_SSU_20H2
                }
            } else {
                New-Item -Path $TempDir_SSU_20H2 -ItemType Directory > $null
                [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls, ssl3"
                Invoke-WebRequest -Uri $URL_SSU_20H2 -OutFile $File_SSU_20H2
            }
            try {
                Write-Verbose "Installing Service Stack Update $SSU_20H2."
                $process = Start-Process -FilePath "wusa.exe" -ArgumentList "$File_SSU_20H2 /quiet /norestart" -PassThru -NoNewWindow -Wait
                if ($process.ExitCode -ne 0) {
                    throw "wusa.exe process failed with exit code $($process.ExitCode)."
                }
            } catch {
                Write-Warning "An error occurred: $_"
            }
            if ($process.ExitCode -eq "2359302") {
                Write-Verbose "Service Stack Update $SSU_20H2 is already installed."
            }
        } elseif ($OSVersion -eq "21H1") {
            $TempDir_SSU_21H1 = "$TempDir\$SSU_21H1"
            $File_SSU_21H1    = "$TempDir_SSU_21H1\windows10.0-$SSU_21H1-x64.msu"
            Write-Verbose "Starting download for Service Stack Update $SSU_21H1"
            if (Test-Path $TempDir_SSU_21H1 -PathType Container) {
                if (Test-Path $File_SSU_21H1 -PathType Leaf) {
                } else {
                    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls, ssl3"
                    Invoke-WebRequest -Uri $URL_SSU_21H1 -OutFile $File_SSU_21H1
                }
            } else {
                New-Item -Path $TempDir_SSU_21H1 -ItemType Directory > $null
                [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls, ssl3"
                Invoke-WebRequest -Uri $URL_SSU_21H1 -OutFile $File_SSU_21H1
            }
            try {
                Write-Verbose "Installing Service Stack Update $SSU_21H1."
                $process = Start-Process -FilePath "wusa.exe" -ArgumentList "$File_SSU_21H1 /quiet /norestart" -PassThru -NoNewWindow -Wait
                if ($process.ExitCode -ne 0) {
                    throw "wusa.exe process failed with exit code $($process.ExitCode)."
                }
            } catch {
                Write-Warning "An error occurred: $_"
            }
            if ($process.ExitCode -eq "2359302") {
                Write-Verbose "Service Stack Update $SSU_21H1 is already installed."
            }
        } elseif ($OSVersion -eq "21H2") {
            $TempDir_SSU_21H2 = "$TempDir\$SSU_21H2"
            $File_SSU_21H2    = "$TempDir_SSU_21H2\windows10.0-$SSU_21H2-x64.msu"
            Write-Verbose "Starting download for Service Stack Update $SSU_21H2"
            if (Test-Path $TempDir_SSU_21H2 -PathType Container) {
                if (Test-Path $File_SSU_21H2 -PathType Leaf) {
                } else {
                    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls, ssl3"
                    Invoke-WebRequest -Uri $URL_SSU_21H2 -OutFile $File_SSU_21H2
                }
            } else {
                New-Item -Path $TempDir_SSU_21H2 -ItemType Directory > $null
                [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls, ssl3"
                Invoke-WebRequest -Uri $URL_SSU_21H2 -OutFile $File_SSU_21H2
            }
            try {
                Write-Verbose "Installing Service Stack Update $SSU_21H2."
                $process = Start-Process -FilePath "wusa.exe" -ArgumentList "$File_SSU_21H2 /quiet /norestart" -PassThru -NoNewWindow -Wait
                if ($process.ExitCode -ne 0) {
                    throw "wusa.exe process failed with exit code $($process.ExitCode)."
                }
            } catch {
                if ($process.ExitCode -eq 1058) {
                    Write-Warning "Windows Update Service cannot be started. Check status of WUAUSERV service, if it cannot run then will need to reset windows update components."
                }
                if ($process.ExitCode -eq 1641) {
                    Write-Warning "Manual system reboot is required!"
                } 
                if ($process.ExitCode -eq 2359302) {
                    Write-Warning "Update is already installed, skipping."
                } else {
                    Write-Warning "An error occurred: $_"
                }
            }
            exit
        }
    }
}

##--Downloads and installs Feature Update
function Get-FU {
    if ($FU_Installed -eq $false) {
        $TempDir_FU = "$TempDir\$FU"
        $File_FU    = "$TempDir_FU\windows10.0-$FU-x64.msu"
        Write-Verbose "Starting download for Feature Update $FU"
        if (Test-Path $TempDir_FU -PathType Container) {
            if (Test-Path $File_FU -PathType Leaf) {
            } else {
                [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls, ssl3"
                Invoke-WebRequest -Uri $URL_FU -OutFile $File_FU
            }
        } else {
            New-Item -Path $TempDir_FU -ItemType Directory > $null
            [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls, ssl3"
            Invoke-WebRequest -Uri $URL_FU -OutFile $File_FU
        }
        try {
            Write-Verbose "Installing Feature Update $FU. System will require a manual reboot."
            $process = Start-Process -FilePath "wusa.exe" -ArgumentList "$File_FU /quiet /norestart" -Wait -PassThru -NoNewWindow
            if ($process.ExitCode -ne 0) {
                throw "wusa.exe process failed with exit code $($process.ExitCode)."
            }
        } catch {
            if ($process.ExitCode -eq 1058) {
                Write-Warning "Windows Update Service cannot be started. Check status of WUAUSERV service, if it cannot run then will need to reset windows update components."
            }
            if ($process.ExitCode -eq 1641) {
                Write-Warning "System reboot is required!."
            } 
            if ($process.ExitCode -eq 2359302) {
                Write-Warning "Update is already installed, skipping."
            } else {
                Write-Warning "An error occurred: $_"
            }
        }
        exit
    }
}

##--Downloads and installs Cumulative Update
function Get-CU {
    if ($CU_Installed -eq $false) {
        $TempDir_CU = "$TempDir\$CU"
        $File_CU    = "$TempDir_CU\windows10.0-$CU-x64.msu"
        Write-Verbose "Starting download for Cumulative Update $CU"
        if (Test-Path $TempDir_CU -PathType Container) {
            if (Test-Path $File_CU -PathType Leaf) {
            } else {
                [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls, ssl3"
                Invoke-WebRequest -Uri $URL_CU -OutFile $File_CU
            }
        } else {
            New-Item -Path $TempDir_CU -ItemType Directory > $null
            [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls, ssl3"
            Invoke-WebRequest -Uri $URL_CU -OutFile $File_CU
        }
        try {
            Write-Verbose "Installing Cumulative Update $CU. Manual system reboot is required!"
            $process = Start-Process -FilePath "wusa.exe" -ArgumentList "$File_CU /quiet /norestart" -Wait -PassThru -NoNewWindow
            if ($process.ExitCode -ne 0) {
                throw "wusa.exe process failed with exit code $($process.ExitCode)."
            }
        } catch {
            if ($process.ExitCode -eq 1058) {
                Write-Warning "Windows Update Service cannot be started. Check status of WUAUSERV service, if it cannot run then will need to reset windows update components."
            }
            if ($process.ExitCode -eq 1641) {
                Write-Warning "Manual system reboot is required!"
            } 
            if ($process.ExitCode -eq 2359302) {
                Write-Warning "Update is already installed, skipping."
            } else {
                Write-Warning "An error occurred: $_"
            }
        }
        exit
    }
}

##--Downloads and installs .NET Cumulative Update
function Get-DOTNET {
    if ($DOTNET_Installed -eq $false) {
        $TempDir_DOTNET = "$TempDir\$DOTNET"
        $File_DOTNET    = "$TempDir_DOTNET\windows10.0-$DOTNET-x64.msu"
        Write-Verbose "Starting download for .NET Update $DOTNET"
        if (Test-Path $TempDir_DOTNET -PathType Container) {
            if (Test-Path $File_DOTNET -PathType Leaf) {
            } else {
                [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls, ssl3"
                Invoke-WebRequest -Uri $URL_DOTNET -OutFile $File_DOTNET
            }
        } else {
            New-Item -Path $TempDir_DOTNET -ItemType Directory > $null
            [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls, ssl3"
            Invoke-WebRequest -Uri $URL_DOTNET -OutFile $File_DOTNET
        }
        try {
            Write-Verbose "Installng .NET Update $DOTNET. Manual reboot of the system is required!."
            $process = Start-Process -FilePath "wusa.exe" -ArgumentList "$File_DOTNET /quiet /norestart" -Wait -PassThru -NoNewWindow
            if ($process.ExitCode -ne 0) {
                throw "wusa.exe process failed with exit code $($process.ExitCode)."
            }
        } catch {
            if ($process.ExitCode -eq 1058) {
                Write-Warning "Windows Update Service cannot be started. Check status of WUAUSERV service, if it cannot run then will need to reset windows update components."
            }
            if ($process.ExitCode -eq 1641) {
                Write-Warning "Manual system reboot is required!"
            } 
            if ($process.ExitCode -eq 2359302) {
                Write-Warning "Update is already installed, skipping."
            } else {
                Write-Warning "An error occurred: $_"
            }
        }
        exit
    }
}

<#-----------------------------------------------------------------------------------------------------------
SCRIPT:EXECUTIONS
-----------------------------------------------------------------------------------------------------------#>

Test-Version
Test-KB
Get-SSU
Get-FU
Get-CU
Get-DOTNET