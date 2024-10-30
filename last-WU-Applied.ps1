param (
    [string]$serverListPath = "list-all-srv.txt",
    [switch]$VerboseOutput  = $true
)

# Define the list of servers
$servers = Get-Content -Path $serverListPath

# Define the default credentials
$defaultU = "aaaaa"
$defaultP = "aaaaaaaaaaaaaaa"

# Define the specific credentials for certain servers
$specificC = @{
    "srv111" = "aaaaaaaaaaaaa"
    "PP0000" = "aaaaaaaaaaaaaaaaaaaa"
}

# Function to check if a server is online
function Test-ServerOnline {
    param (
        [string]$server
    )
    Test-Connection -ComputerName $server -Count 1 -Quiet
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
        if ($specificC.ContainsKey($server)) {
            $Pd = $specificC[$server]
        } else {
            $Pd = $defaultP
        }
        $lastUpdate = Get-LastUpdateTime -server $server -UsrN $defaultU -Pd $Pd
        if ($lastUpdate) {
            Write-Output "${server}: Last update applied on $($lastUpdate.InstalledOn)"
        }
    } else {
        Write-Output "$server is offline, skipping..."
    }
}
