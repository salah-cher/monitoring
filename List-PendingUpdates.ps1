# Define parameter for server list with a default value
param (
    [string]$ServerListFile = ".\list-all-srv.txt"
)

# Read the list of servers from the file
$servers = Get-Content -Path $ServerListFile

# Timeout in seconds
$timeoutSeconds = 180

# Check for pending Windows updates on each server
foreach ($server in $servers) {
    if (Test-Connection -ComputerName $server -Count 1 -Quiet) {
        Write-Host "Checking updates for ${server}..."
        $startTime = [datetime]::Now
        try {
            # Create update session and searcher
            $session = [activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Session", $server))
            $updateSearcher = $session.CreateUpdateSearcher()

            # Perform update search with timeout check
            $searchResult = $null
            while (-Not $searchResult) {
                $searchResult = $updateSearcher.Search("IsInstalled=0")

                # Check if the operation exceeds the timeout limit
                $elapsedTime = [datetime]::Now - $startTime
                if ($elapsedTime.TotalSeconds -ge $timeoutSeconds) {
                    Write-Host "${server}: Timeout reached while checking for updates."
                    break
                }
            }

            # Display only updates with titles starting with "KB"
            if ($searchResult -and $searchResult.Updates.Count -gt 0) {
                $kbUpdates = $searchResult.Updates | Where-Object { $_.Title -match "^KB" }
                
                if ($kbUpdates.Count -gt 0) {
                    Write-Host "${server}: Major updates available"
                    foreach ($update in $kbUpdates) {
                        Write-Host "$server needs update: $($update.Title)"
                    }
                } else {
                    Write-Host "${server}: No major updates (KB...) available"
                }
            } elseif ($searchResult -and $searchResult.Updates.Count -eq 0) {
                Write-Host "${server}: No updates available"
            }

        } catch {
            Write-Host "${server}: Unable to retrieve updates"
        }
    } else {
        Write-Host "$server is offline"
    }
}
