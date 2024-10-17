# Define the output file path with a timestamp for uniqueness
$outputFile = "Combined-Results_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

# Write a header to the output file
"--- Combined Results - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ---" | Out-File -FilePath $outputFile

# Run each script and append both output and errors to the file
Try {
    Write-Host "Running Check-ServerStatus..."
    .\Check-ServerStatus.ps1 *>&1 | Tee-Object -FilePath $outputFile -Append

    Write-Host "Running Check-RDPAvailability..."
    .\Check-RDPAvailability.ps1 *>&1 | Tee-Object -FilePath $outputFile -Append

    Write-Host "Running List-PendingUpdates..."
    .\List-PendingUpdates.ps1 *>&1 | Tee-Object -FilePath $outputFile -Append

    Write-Host "Running Check-WindowsUpdateStatus..."
    .\Check-WindowsUpdateStatus.ps1 *>&1 | Tee-Object -FilePath $outputFile -Append

    Write-Host "All scripts executed successfully. Results are saved in $outputFile."
}
Catch {
    Write-Host "An error occurred: $_" | Tee-Object -FilePath $outputFile -Append
}
