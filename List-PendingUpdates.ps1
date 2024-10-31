# List of servers from file
param (
  [string]$ServerListFile = ".\list-all-srv.txt",  # Default value
  [string]$CredentialsFile = ".\credentials.json"  # Default value
)

# Read the list of servers from the file
$servers = Get-Content -Path $ServerListFile

# Timeout in seconds
$timeoutSeconds = 60

# Function to read credentials from JSON file
function Get-CredentialsFromJSON($serverName, $credentialsFile) {
  try {
    # Read JSON content
    $jsonData = Get-Content -Path $credentialsFile | ConvertFrom-Json

    # Find the matching credential
    $credential = $jsonData.credentials | Where-Object { $_.server -eq $serverName }

    if ($credential) {
      # Extract username and password
      $username = $credential.username
      $password = $credential.password

      # Convert password to secure string
      $securePassword = ConvertTo-SecureString $password -AsPlainText -Force

      # Create PSCredential object
      return New-Object System.Management.Automation.PSCredential ($username, $securePassword)
    } else {
      # No specific credential found, return null
      return $null
    }
  } catch {
    Write-Error "Error reading credentials from $credentialsFile"
    exit 1
  }
}

# Check for pending Windows updates on each server
foreach ($server in $servers) {
  if (Test-Connection -ComputerName $server -Count 1 -Quiet) {
    Write-Host "Checking updates for ${server}..."
    $startTime = [datetime]::Now
    try {
      # Get credentials from JSON
      $credentials = Get-CredentialsFromJSON $server $CredentialsFile

      if ($credentials) {
        $session = [activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Session", $server, $credentials))
      } else {
        $session = [activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Session", $server))
      }

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

      # Display the search result if not timed out and contains "KB"
      if ($searchResult -and $searchResult.Updates.Count -gt 0) {
        $kbUpdates = $searchResult.Updates | Where-Object { $_.Title -match "KB" }
        if ($kbUpdates.Count -gt 0) {
          Write-Host "${server}: Major updates (KB) available"
          foreach ($update in $kbUpdates) {
            Write-Host "$server needs update: $($update.Title)"
          }
        } else {
          Write-Host "${server}: No major (KB) updates available"
        }
      } elseif ($searchResult -and $searchResult.Updates.Count -eq 0) {
        Write-Host "${server}: No updates available"
      }

    } catch {
      Write-Host "${server}: Unable to retrieve updates"
      try {
        # Check if the server can reach an external site (e.g., google.com)
        if (Test-Connection -ComputerName "google.com" -Count 1 -Quiet) {
          Write-Host "${server}: Cannot connect to the update server, but internet is accessible."
        } else {
          Write-Host "${server}: No internet connection."
        }
      } catch {
        Write-Host "${server}: Unable to determine internet connectivity."
      }
    }
  } else {
    Write-Host "$server is offline"
  }
}
