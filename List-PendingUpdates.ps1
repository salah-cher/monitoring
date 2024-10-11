# List of servers
$servers = @("srv1", "srv2", "srv3", "srv4")

# Check for pending Windows updates on each server
foreach ($server in $servers) {
    if (Test-Connection -ComputerName $server -Count 1 -Quiet) {
        try {
            $session = [activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Session",$server))
            $updateSearcher = $session.CreateUpdateSearcher()
            $searchResult = $updateSearcher.Search("IsInstalled=0")
            if ($searchResult.Updates.Count -eq 0) {
                Write-Host "${server}: No updates available"
            } else {
                Write-Host "${server}: Updates available"
                foreach ($update in $searchResult.Updates) {
                    Write-Host "${server} needs update: $($update.Title)"
                }
            }
        } catch {
            Write-Host "${server}: Unable to retrieve updates"
        }
    } else {
        Write-Host "${server} is offline"
    }
}
