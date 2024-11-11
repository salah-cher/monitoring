param(
    [string]$serverListFile = "list-bk-srv.txt",
    [string]$credentialsPath = "credentials.json",
    [int]$WarningThreshold = 80,
    [int]$ErrorThreshold = 95,
    [switch]$VerboseOutput
)

# Ensure the server list file exists
if (-Not (Test-Path $serverListFile)) {
    Write-Error "Server list file '$serverListFile' not found!"
    exit 1
}

# Read the server list
$servers = Get-Content -Path $serverListFile

# Read the JSON file for credentials
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
        [string]$username,
        [string]$password
    )
    $securepassword = ConvertTo-SecureString $password -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential ($username, $securepassword)
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

# New function to get the list of hard drives on a server and their usage
function Get-DisksInfo {
    param (
        [string]$server,
        [string]$username,
        [string]$password
    )
    $securepassword = ConvertTo-SecureString $password -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential ($username, $securepassword)
    try {
        $result = Invoke-Command -ComputerName $server -Credential $credential -ScriptBlock {
            Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } | # DriveType 3 = Local Disk
            Select-Object DeviceID, VolumeName, @{Name="Size(GB)";Expression={[math]::round($_.Size / 1GB, 2)}}, 
            @{Name="FreeSpace(GB)";Expression={[math]::round($_.FreeSpace / 1GB, 2)}}
        } -ErrorAction Stop
        return $result
    } catch {
        if ($VerboseOutput) {
            Write-Warning "${server}: Error retrieving disk information - $_"
        }
        return $null
    }
}

# Loop through each server and check disk info
foreach ($server in $servers) {
    if (Test-ServerOnline -server $server) {
        $credential = Get-Credentials -server $server
        $username = $credential.username
        $password = $credential.password

        if (Test-InternetConnectivity -server $server -username $username -password $password) {
            $disksInfo = Get-DisksInfo -server $server -username $username -password $password
            if ($disksInfo) {
                Write-Output "${server}: Disk Information"
                $disksInfo | ForEach-Object {
                    $usagePercent = [math]::round((($_.'Size(GB)' - $_.'FreeSpace(GB)') / $_.'Size(GB)') * 100, 2)
                    if ($usagePercent -ge $ErrorThreshold) {
                        Write-Host " - Drive: $($_.DeviceID), Volume: $($_.VolumeName), Size: $($_.'Size(GB)') GB, Free Space: $($_.'FreeSpace(GB)') GB, Usage: $usagePercent%" -ForegroundColor Red
                    } elseif ($usagePercent -ge $WarningThreshold) {
                        Write-Host " - Drive: $($_.DeviceID), Volume: $($_.VolumeName), Size: $($_.'Size(GB)') GB, Free Space: $($_.'FreeSpace(GB)') GB, Usage: $usagePercent%" -ForegroundColor Yellow
                    } else {
                        Write-Host " - Drive: $($_.DeviceID), Volume: $($_.VolumeName), Size: $($_.'Size(GB)') GB, Free Space: $($_.'FreeSpace(GB)') GB, Usage: $usagePercent%"
                    }
                }
            }
        } else {
            Write-Output "${server}: Online but NO internet connectivity"
        }
    } else {
        Write-Output "$server is offline, skipping..."
    }
}
