# Define the list of servers file and set a default value
param (
    [string]$ServerListFile = ".\list-bk-srv.txt",
    [string]$U = "u", # Replace with your u
    [string]$P = "p"  # Replace with your p
)

# Convert password to a secure string and create a PSCredential object
$sp = ConvertTo-SecureString $P -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($U, $sp)

# Read the list of servers from the file
$servers = Get-Content -Path $ServerListFile

# Get yesterday's date in the format used in the file names
$yesterdayDate = (Get-Date).AddDays(-1).ToString("yyyyMMdd")

# Loop through each server
foreach ($server in $servers) {
    Write-Host "Checking server: $server"

    # Adjust the log path for srv021
    $backupLogDirectory = if ($server -eq "srv021") {
        "C$\GD\HTI\PBCS\20_ProdSys\23_RMAN\log"
    } else {
        "C$\GD\HTI\PBCS\20_ProdSys\23_RMAN\Log"
    }

    # Check if the server is online
    if (Test-Connection -ComputerName $server -Count 1 -Quiet) {
        Write-Host "$server is online. Attempting to access the backup folder..."

        # Define the network path
        $networkPath = "\\$server\$backupLogDirectory"

        # Try to map the network path with credentials
        Try {
            New-PSDrive -Name "BKDrive" -PSProvider FileSystem -Root $networkPath -Credential $credential -ErrorAction Stop

            # Define file patterns for yesterday's date
            $filePatterns = @(
                "DB1P_BACKUP_DISK_DAILY_${yesterdayDate}_*.log",
                "DB2_BACKUP_DISK_DAILY_${yesterdayDate}_*.log",
                "DB2_BACKUP_TAPE_DAILY_${yesterdayDate}_*.log",
                "DB2_BACKUP_TAPE_WEEKLY_${yesterdayDate}_*.log"
            )

            $foundFiles = $false

            # Loop through each pattern to list the last 3 files if found
            foreach ($pattern in $filePatterns) {
                $files = Get-ChildItem "BKDrive:\" -Filter $pattern | Sort-Object LastWriteTime -Descending | Select-Object -First 3

                if ($files) {
                    Write-Host "$server: Backup files matching pattern '$pattern':"
                    $files | ForEach-Object {
                        Write-Host $_.Name
                    }
                    $foundFiles = $true
                }
            }

            # If no files were found with any of the patterns
            if (-not $foundFiles) {
                Write-Host "$server: No matching backup files found for yesterday."
            }

            # Remove the PSDrive after use
            Remove-PSDrive -Name "BKDrive"
        }
        Catch {
            Write-Host "$server: Failed to access the backup folder. Error: $_"
        }
    } else {
        Write-Host "$server is offline."
    }
}
