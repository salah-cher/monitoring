param (
    [string]$ServerListFile = ".\list-bk-srv.txt",
    [string]$CredentialsPath = "credentials.json"
)

# Read the JSON file
$jsonContent = Get-Content -Raw -Path $CredentialsPath
$credentials = $jsonContent | ConvertFrom-Json

# Function to get credentials for a server
function Get-Credentials {
    param (
        [string]$server
    )
    $credential = $credentials.credentials | Where-Object { $_.server -eq $server }
    if (-not $credential) {
        $credential = $credentials.credentials | Where-Object { $_.server -eq "default" }
    }
    return $credential
}

# Read the list of servers from the file
$servers = Get-Content -Path $ServerListFile

# Get yesterday's date in the format used in the file names
$yesterdayDate = (Get-Date).AddDays(-1).ToString("yyyyMMdd")

# Loop through each server
foreach ($server in $servers) {
    Write-Host "Checking server: $server"

    # Adjust the log path for srv021 and srv111
    $backupLogDirectory = if ($server -eq "srv021.htipbcs2.local" -or $server -eq "srv111.htipbcs11.local" -or $server -eq "srv14.htipbcs1.local") {
        "C$\GD\HTI\PBCS\20_ProdSys\23_RMAN\Log"
    } else {
        "C$\GD\HTI\PBCS\20_ProdSys\23_RMAN\log"
    }

    # Check if the server is online
    if (Test-Connection -ComputerName $server -Count 1 -Quiet) {
        Write-Host "$server is online. Attempting to access the backup folder..."

        # Define the network path
        $networkPath = "\\$server\$backupLogDirectory"

        # Get the credentials for the current server
        $credential = Get-Credentials -server $server
        $Usr = $credential.username
        $Psw = $credential.password
        $securePsw = ConvertTo-SecureString $Psw -AsPlainText -Force
        $currentCredential = New-Object System.Management.Automation.PSCredential($Usr, $securePsw)

        # Try to map the network path with credentials
        Try {
            New-PSDrive -Name "BKDrive" -PSProvider FileSystem -Root $networkPath -Credential $currentCredential -ErrorAction Stop

            # Define file patterns for yesterday's date
            $filePatterns = @(
                "*_BACKUP_DISK_DAILY_${yesterdayDate}_*.log",
                "*_BACKUP_TAPE_DAILY_${yesterdayDate}_*.log",
                "*_BACKUP_TAPE_WEEKLY_*.log"
            )

            $foundFiles = $false

            # Loop through each pattern to list the last 3 files if found
            foreach ($pattern in $filePatterns) {
                $files = Get-ChildItem "BKDrive:\" -Filter $pattern | Sort-Object LastWriteTime -Descending | Select-Object -First 3

                if ($files) {
                    Write-Host "${server}: Backup files matching pattern '$pattern':"
                    $files | ForEach-Object {
                        Write-Host $_.Name
                    }
                    $foundFiles = $true
                }
            }

            # If no files were found with any of the patterns
            if (-not $foundFiles) {
                Write-Warning "${server}: No matching backup files found for yesterday. Checking for the most recent backup file..."

                # Check for the most recent backup file with the pattern *_BACKUP_DISK_DAILY_*.log
                $recentFilePattern = "*_BACKUP_DISK_DAILY_*.log"
                $recentFiles = Get-ChildItem "BKDrive:\" -Filter $recentFilePattern | Sort-Object LastWriteTime -Descending | Select-Object -First 1

                if ($recentFiles) {
                    Write-Host "${server}: Most recent backup file:"
                    $recentFiles | ForEach-Object {
                        Write-Host $_.Name
                    }
                } else {
                    Write-Warning "${server}: No backup files found."
                }
            }

            # Remove the PSDrive after use
            Remove-PSDrive -Name "BKDrive"
        }
        Catch {
            Write-Error "${server}: Failed to access the backup folder. Error: $_"
        }
    } else {
        Write-Warning "$server is offline."
    }
}

# New section: Check disk usage
Write-Host "###############################################################################"
Write-Host "###                           Section 2 - Checking Disk Usage               ###"
Write-Host "###############################################################################"

function Check-DiskUsage {
    param (
        [string]$server,
        [string]$Usr,
        [string]$Psw
    )
    $securePsw = ConvertTo-SecureString $Psw -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential ($Usr, $securePsw)
    try {
        $disks = Invoke-Command -ComputerName $server -Credential $credential -ScriptBlock {
            Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3" | Where-Object { $_.DriveType -eq 3 } | Select-Object DeviceID, Size, FreeSpace
        } -ErrorAction Stop

        foreach ($disk in $disks) {
            $usedSpace = [math]::round((($disk.Size - $disk.FreeSpace) / $disk.Size) * 100, 2)
            $freeSpace = [math]::round(($disk.FreeSpace / $disk.Size) * 100, 2)
            $class = if ($usedSpace -lt 80) { "ok" } elseif ($usedSpace -ge 80 -and $usedSpace -lt 90) { "warning" } else { "critical" }
            Write-Output "<div class='$class'>$server - $($disk.DeviceID): Used Space: $usedSpace%, Free Space: $freeSpace%</div>"
        }
    } catch {
        Write-Output "<div class='error'>${server}: Error - Cannot list disks</div>"
    }
}

# Loop through each server to check disk usage
foreach ($server in $servers) {
    if (Test-Connection -ComputerName $server -Count 1 -Quiet) {
        $credential = Get-Credentials -server $server
        $Usr = $credential.username
        $Psw = $credential.password
        Check-DiskUsage -server $server -Usr $Usr -Psw $Psw
    } else {
        Write-Output "<div class='warning'>$server is offline. Skipping disk usage check.</div>"
    }
}
