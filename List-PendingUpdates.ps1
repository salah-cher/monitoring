param(
    [string]$ServerListFile = ".\list-all-srv.txt"
)

# Define the current date and time for output file naming
$currentDate = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$outputFile = ".\List-PendingUpdates_$currentDate.txt"

# Ensure the server list file exists
if (-Not (Test-Path $ServerListFile)) {
    Write-Error "Server list file '$ServerListFile' not found!"
    exit 1
}

# Read the server list
$servers = Get-Content -Path $ServerListFile

# List pending updates for each server
foreach ($server in $servers) {
    try {
        $updates = Invoke-Command -ComputerName $server -ScriptBlock {
            Get-WindowsUpdate -KBArticleID | Select-Object -ExpandProperty KBArticleID
        }
        if ($updates) {
            Write-Output "${server}: Pending updates: $($updates -join ', ')" | Tee-Object -FilePath $outputFile -Append
        } else {
            Write-Warning "${server}: No updates available" | Tee-Object -FilePath $outputFile -Append
        }
    } catch {
        Write-Warning "${server}: Failed to retrieve updates" | Tee-Object -FilePath $outputFile -Append
    }
}

Write-Output "Results saved to: $outputFile"
