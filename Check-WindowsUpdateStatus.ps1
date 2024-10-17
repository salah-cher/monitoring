param(
    [string]$ServerListFile = ".\list-all-srv.txt"
)

# Define the current date and time for output file naming
$currentDate = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
#$outputFile = ".\Check-WindowsUpdateStatus_$currentDate.txt"

# Ensure the server list file exists
if (-Not (Test-Path $ServerListFile)) {
    Write-Error "Server list file '$ServerListFile' not found!"
    exit 1
}

# Read the server list
$servers = Get-Content -Path $ServerListFile

# Check Windows Update status for each server
foreach ($server in $servers) {
    try {
        $wuStatus = Invoke-Command -ComputerName $server -ScriptBlock {
            (Get-Service -Name wuauserv).Status
        }
        if ($wuStatus -eq 'Running') {
            Write-Output "${server}: Windows Update service is running" | Tee-Object -FilePath $outputFile -Append
        } else {
            Write-Warning "${server}: Windows Update service is not running" | Tee-Object -FilePath $outputFile -Append
        }
    } catch {
        Write-Warning "${server}: Failed to retrieve Windows Update status" | Tee-Object -FilePath $outputFile -Append
    }
}

#Write-Output "Results saved to: $outputFile"
