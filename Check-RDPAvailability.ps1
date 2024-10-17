param(
    [string]$ServerListFile = ".\list-all-srv.txt"
)

# Define the current date and time for output file naming
$currentDate = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
#$outputFile = ".\Check-RDPAvailability_$currentDate.txt"

# Ensure the server list file exists
if (-Not (Test-Path $ServerListFile)) {
    Write-Error "Server list file '$ServerListFile' not found!"
    exit 1
}

# Read the server list
$servers = Get-Content -Path $ServerListFile

# Check RDP availability for each server
foreach ($server in $servers) {
    $rdpTest = Test-NetConnection -ComputerName $server -Port 3389 -InformationLevel Quiet
    if ($rdpTest) {
        Write-Output "${server}: RDP is available" | Tee-Object -FilePath $outputFile -Append
    } else {
        Write-Warning "${server}: RDP is not available" | Tee-Object -FilePath $outputFile -Append
    }
}

#Write-Output "Results saved to: $outputFile"
