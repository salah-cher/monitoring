# Parameters
param (
    [string]$serverListFile = "list-srv.txt"  # Ensure the file is in the current directory
)

# Read the list of servers from the file
if (Test-Path $ServerListFile) {
    $servers = Get-Content -Path $ServerListFile
} else {
    Write-Error "Server list file '$ServerListFile' not found!"
    exit 1
}

# Iterate over each server and check if it's online
foreach ($server in $servers) {
    $pingResult = Test-Connection -ComputerName $server -Count 2 -Quiet
    if ($pingResult) {
        $status = "$server is online"
        Write-Output $status
    } else {
        $status = "$server is offline"
        Write-Warning $status
    }
}
