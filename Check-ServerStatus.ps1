# List of servers
$servers = @("srv1", "srv2", "srv3", "srv4")

# Check if each server is online
foreach ($server in $servers) {
    if (Test-Connection -ComputerName $server -Count 1 -Quiet) {
        Write-Host "$server is online"
    } else {
        Write-Host "$server is offline"
    }
}
