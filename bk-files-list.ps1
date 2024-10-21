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

# Define the path to the backup log directory
$backupLogDirectory = "C$\GD\HTI\PBCS\20_ProdSys\23_RMAN\Log"

# Loop through each server
foreach ($server in $servers) {
    Write-Host "Checking server: $server"

    # Check if the server is online
    if (Test-Connection -ComputerName $server -Count 1 -Quiet) {
        Write-Host "$server is online. Attempting to access the backup folder..."

        # Define the network path
        $networkPath = "\\$server\$backupLogDirectory"

        # Try to map the network path with credentials
        Try {
            New-PSDrive -Name "BKDrive" -PSProvider FileSystem -Root $networkPath -Credential $credential -ErrorAction Stop

            # List the last 3 files in the folder, sorted by creation time descending
            $lastThreeFiles = Get-ChildItem "BKDrive:\" | Sort-Object LastWriteTime -Descending | Select-Object -First 3

            if ($lastThreeFiles) {
                Write-Host "$server: Last 3 backup files in $backupLogDirectory:"
                $lastThreeFiles | ForEach-Object {
                    Write-Host $_.Name
                }
            } else {
                Write-Host "$server: No backup files found in $backupLogDirectory."
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