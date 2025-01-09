
# Load the JSON configuration file
$config = Get-Content -Path "c:\users\administrator\desktop\sch_db_scripts\oracle_log_config.json" -Raw | ConvertFrom-Json

# Function to search for the first 10 keywords in a log file and save results to a file
function Search-LogFile {
    param (
        [string]$LogFilePath,
        [array]$Keywords,
        [string]$OutputFilePath
    )

    if (Test-Path $LogFilePath) {
        $logContent = Get-Content -Path $LogFilePath
        $oneWeekAgo = (Get-Date).AddDays(-7)
        $foundCount = 0

        foreach ($keyword in $Keywords) {
            $matches = $logContent | Select-String -Pattern $keyword
            foreach ($match in $matches) {
                # Check if the log entry has a timestamp and is within the last week
                if ($match.Line -match '\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}') {
                    $timestamp = [datetime]::ParseExact($matches.Matches[0].Value, 'yyyy-MM-dd HH:mm:ss', $null)
                    if ($timestamp -ge $oneWeekAgo) {
                        Add-Content -Path $OutputFilePath -Value "Found '$keyword' in $LogFilePath on $timestamp:`n$($match.Line)`n"
                        $foundCount++
                    }
                } else {
                    # If no timestamp, assume the entry is recent
                    Add-Content -Path $OutputFilePath -Value "Found '$keyword' in $LogFilePath:`n$($match.Line)`n"
                    $foundCount++
                }

                # Stop searching if we have found 10 entries
                if ($foundCount -ge 10) {
                    return
                }
            }
        }
    } else {
        Add-Content -Path $OutputFilePath -Value "Log file not found: $LogFilePath`n"
    }
}

# Get current date and time for naming the output file
$currentDateTime = Get-Date -Format "yyyy-MM-dd_HH-mm"

# Loop through the log files and search for errors and warnings within the last week, saving results to a file
foreach ($logFile in $config.log_files) {
    Write-Output "Checking log file: $($logFile.name)"
    $outputFileName = "$($logFile.name)_$currentDateTime.txt"
    Search-LogFile -LogFilePath $logFile.path -Keywords $config.keywords.errors -OutputFilePath $outputFileName
    Search-LogFile -LogFilePath $logFile.path -Keywords $config.keywords.warnings -OutputFilePath $outputFileName
}

Write-Output "Log file check completed."
