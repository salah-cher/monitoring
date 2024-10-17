# Parameters
param (
    [string]$ServerListFile = "list-all-srv.txt"  # Ensure the file is in the current directory
)

# Get the current date and time for the output file
$currentDate = Get-Date -Format "yyyyMMdd_HHmmss"
#$outputFile = ".\Check-Server-Online_$currentDate.txt"  # Output file will also be in the current directory

# Read the list of servers from the file
if (Test-Path $ServerListFile) {
    $servers = Get-Content -Path $ServerListFile
} else {
    Write-Error "Server list file '$ServerListFile' not found!"
    exit
}

# Create or clear the output file
#Out-File -FilePath $outputFile

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

    # Write the status to the output file
    $status | Out-File -FilePath $outputFile -Append
}

#Write-Output "Results have been saved to $outputFile"
