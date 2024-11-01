param (
    [string]$serverListFile = "",
    [string]$credentialsPath = "credentials.json",
    [switch]$VerboseOutput
)

# Define the list of servers
$servers = Get-Content -Path $serverListFile

# Read the JSON file
$jsonContent = Get-Content -Raw -Path $credentialsPath
$credentials = $jsonContent | ConvertFrom-Json

# Function to get credentials for a server
function Get-Credentials {
    param (
        [string]$server
    )
    $credential = $credentials.credentials | Where-Object { $_.server -eq $server }
    if (-not $credential) {
        $credential = $credentials.credentials | Where-Object { $_.server -eq "default" }
    }
    return $credential
}

# Function to check if a server is online
function Test-ServerOnline {
    param (
        [string]$server
    )
    Test-Connection -ComputerName $server -Count 1 -Quiet
}

# Function to check Windows Update service status
function Get-WindowsUpdateServiceStatus {
    param (
        [string]$server,
        [string]$UsrN,
        [string]$Pd
    )
    $securePd = ConvertTo-SecureString $Pd -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential ($UsrN, $securePd)
    
    try {
        $serviceStatus = Invoke-Command -ComputerName $server -Credential $credential -ScriptBlock {
            # Get Windows Update service details
            $service = Get-Service -Name "wuauserv" -ErrorAction Stop
            
            # Return service details as a hashtable
            @{
                ServiceName = $service.Name
                Status = $service.Status.ToString()
                StartType = $service.StartType.ToString()
                DisplayName = $service.DisplayName
            }
        } -ErrorAction Stop
        
        return $serviceStatus
    } catch {
        if ($VerboseOutput) {
            Write-Warning "${server}: Error checking Windows Update service - $_"
        }
        return $null
    }
}

# Loop through each server and check Windows Update service status
foreach ($server in $servers) {
    if (Test-ServerOnline -server $server) {
        $credential = Get-Credentials -server $server
        $UsrN = $credential.username
        $Pd = $credential.password
        
        $serviceStatus = Get-WindowsUpdateServiceStatus -server $server -UsrN $UsrN -Pd $Pd
        
        if ($serviceStatus) {
            Write-Output "${server}: Windows Update Service Status"
            Write-Output "  Name: $($serviceStatus.ServiceName)"
            Write-Output "  Status: $($serviceStatus.Status)"
            Write-Output "  Start Type: $($serviceStatus.StartType)"
            Write-Output "  Display Name: $($serviceStatus.DisplayName)"
        } else {
            Write-Output "${server}: Unable to retrieve Windows Update service status"
        }
    } else {
        Write-Output "$server is offline, skipping..."
    }
}
