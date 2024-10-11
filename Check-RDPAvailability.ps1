# List of servers
$servers = @("srv1", "srv2", "srv3", "srv4")

# Check if Windows Update is enabled or disabled for each server
foreach ($server in $servers) {
    if (Test-Connection -ComputerName $server -Count 1 -Quiet) {
        $service = Get-Service -ComputerName $server -Name "wuauserv" -ErrorAction SilentlyContinue
        if ($service.Status -eq 'Running') {
            Write-Host "${server}: Windows Updates are enabled"
        } else {
            Write-Host "${server}: Windows Updates are disabled"
        }
    } else {
        Write-Host "${server} is offline"
    }
}
