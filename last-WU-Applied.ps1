param(
    [string]$serverListFile = "list-all-srv.txt",
    [string]$credentialsPath = "credentials.json",
    [switch]$VerboseOutput
)

# Ensure the server list file exists
if (-Not (Test-Path $serverListFile)) {
    Write-Error "Server list file '$serverListFile' not found!"
    exit 1
}

# Read the server list
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

# Function to check internet connectivity
function Test-InternetConnectivity {
    param (
        [string]$server,
        [string]$UsrN,
        [string]$Pd
    )
    $securePd = ConvertTo-SecureString $Pd -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential ($UsrN, $securePd)
    try {
        $result = Invoke-Command -ComputerName $server -Credential $credential -ScriptBlock {
            Test-Connection -ComputerName "www.google.com" -Count 1 -Quiet
        } -ErrorAction Stop
        return $result
    } catch {
        if ($VerboseOutput) {
            Write-Warning "${server}: Error testing internet connectivity - $_"
        }
        return $false
    }
}

# Function to get the last time Windows updates were applied
function Get-LastUpdateTime {
    param (
        [string]$server,
        [string]$UsrN,
        [string]$Pd
    )
    $securePd = ConvertTo-SecureString $Pd -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential ($UsrN, $securePd)
    try {
        $result = Invoke-Command -ComputerName $server -Credential $credential -ScriptBlock {
            Get-HotFix | Sort-Object -Property InstalledOn -Descending | Select-Object -First 1
        } -ErrorAction Stop
        if ($result) {
            return $result
        } else {
            Write-Warning "${server}: Cannot retrieve information"
            return $null
        }
    } catch {
        if ($VerboseOutput) {
            Write-Warning "${server}: Error with WinRM - $_"
        } else {
            Write-Warning "${server}: WinRM issue, skipping..."
        }
        return $null
    }
}

# Loop through each server and check the last update time
foreach ($server in $servers) {
    if (Test-ServerOnline -server $server) {
        $credential = Get-Credentials -server $server
        $UsrN = $credential.username
        $Pd = $credential.password
        
        if (Test-InternetConnectivity -server $server -UsrN $UsrN -Pd $Pd) {
            $lastUpdate = Get-LastUpdateTime -server $server -UsrN $UsrN -Pd $Pd
            if ($lastUpdate) {
                Write-Output "${server}: Last update applied on $($lastUpdate.InstalledOn)"
            }
        } else {
            Write-Output "${server}: Online but NO internet connectivity"
        }
    } else {
        Write-Output "$server is offline, skipping..."
    }
}
