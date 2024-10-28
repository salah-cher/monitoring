# Define the output file paths with a timestamp for uniqueness
$outputFile = "Combined-Results_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
$htmlOutputFile = "Combined-Results_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"

# Write a header to the output file
"--- Combined Results - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ---" | Out-File -FilePath $outputFile

# Initialize the HTML file with basic
@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='UTF-8'>
    <title>Combined Results - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</title>
    <style>
        body { font-family: Arial, sans-serif; }
        h1 { color: #333; }
        pre { background-color: #f4f4f4; padding: 10px; border: 1px solid #ddd; }
        .section { margin-bottom: 20px; }
    </style>
</head>
<body>
    <h1>Combined Results - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</h1>
"@ | Out-File -FilePath $htmlOutputFile -Encoding utf8

# Function to append script output to both text and HTML files
function Append-Output {
    param (
        [string]$sectionTitle,
        [string]$scriptPath,
        [string]$serverListFile
    )

    $banner = "###############################################################################"
    $header = "###                           $sectionTitle                           ###"
    
    # Append to text file
    $banner | Tee-Object -FilePath $outputFile -Append
    $header | Tee-Object -FilePath $outputFile -Append
    $banner | Tee-Object -FilePath $outputFile -Append
    & $scriptPath -ServerListFile $serverListFile *>&1 | Tee-Object -FilePath $outputFile -Append

    # Append to HTML file
    @"
    <div class='section'>
        <h2>$sectionTitle</h2>
        <pre>
"@ | Out-File -FilePath $htmlOutputFile -Append -Encoding utf8
    & $scriptPath -ServerListFile $serverListFile *>&1 | Out-File -FilePath $htmlOutputFile -Append -Encoding utf8
    "</pre></div>" | Out-File -FilePath $htmlOutputFile -Append -Encoding utf8
}

# Define the server list file
$serverListFile = ".\list-all-srv.txt"

# Run each script and append both output and errors to the files with banners for separation
Try {
    Write-Host "Running Check-ServerStatus..."
    Append-Output -sectionTitle "SERVER STATUS CHECK" -scriptPath ".\Check-ServerStatus.ps1" -serverListFile $serverListFile

    Write-Host "Running Check-RDPAvailability..."
    Append-Output -sectionTitle "RDP AVAILABILITY CHECK" -scriptPath ".\Check-RDPAvailability.ps1" -serverListFile $serverListFile

    Write-Host "Running List-PendingUpdates..."
    Append-Output -sectionTitle "LIST PENDING UPDATES" -scriptPath ".\List-PendingUpdates.ps1" -serverListFile $serverListFile

    # Uncomment the following lines if you want to include Check-WindowsUpdateStatus
    # Write-Host "Running Check-WindowsUpdateStatus..."
    # Append-Output -sectionTitle "WINDOWS UPDATE STATUS CHECK" -scriptPath ".\Check-WindowsUpdateStatus.ps1" -serverListFile $serverListFile

    Write-Host "All scripts executed successfully. Results are saved in $outputFile and $htmlOutputFile."
}
Catch {
    Write-Host "An error occurred: $_" | Tee-Object -FilePath $outputFile -Append
    @"
    <div class='section'>
        <h2>Error</h2>
        <pre>$_</pre>
    </div>
"@ | Out-File -FilePath $htmlOutputFile -Append -Encoding utf8
}

# Close the HTML file
"</body></html>" | Out-File -FilePath $htmlOutputFile -Append -Encoding utf8
