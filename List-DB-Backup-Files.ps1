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
    $backupLogDirectory = if ($server -eq "srv021.htipbcs2.local" -or $server -eq "srv111.htipbcs11.local") {
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
