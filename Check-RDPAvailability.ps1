param(
    [string]$ServerListFile = ".\list-all-srv.txt"
)

# Ensure the server list file exists
if (-Not (Test-Path $ServerListFile)) {
    Write-Error "Server list file '$ServerListFile' not found!"
    exit 1
}

# Read the server list
$servers = Get-Content -Path $ServerListFile

# Check RDP availability for each server
foreach ($server in $servers) {
    # Test if the server is online
    if (Test-Connection -ComputerName $server -Count 1 -Quiet) {
        # If the server is online, test the RDP connection
        $rdpTest = Test-NetConnection -ComputerName $server -Port 3389 -InformationLevel Quiet
        if ($rdpTest) {
            Write-Output "${server}: RDP is available"
        } else {
            Write-Warning "${server}: RDP is not available"
        }
    } else {
        # If the server is offline, output a message indicating no RDP connection
        Write-Warning "${server}: Server is offline - NO RDP connection"
    }
}
