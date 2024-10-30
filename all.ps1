param (
    [string]$serverListPath = "list-all-srv.txt",
    [string]$csvFilePath = "scripts-config.csv",
    [switch]$VerboseOutput
)

# Define the timestamp for folder and file names
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$outputFolder = "Results_$timestamp"

# Create the output folder
New-Item -ItemType Directory -Path $outputFolder

# Define the output file paths with the timestamp for uniqueness
$outputFile = "$outputFolder/Combined-Results_$timestamp.txt"
$htmlOutputFile = "$outputFolder/Combined-Results_$timestamp.html"

# Write a header to the output file
"--- Combined Results - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ---" | Out-File -FilePath $outputFile

# HTML file
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
        .error { color: red; font-weight: bold; }
        .warning { color: orange; font-weight: bold; }
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
        [string]$serverListFile,
        [bool]$fileOutput,
        [bool]$htmlOutput
    )

    $banner = "###############################################################################"
    $header = "###                           $sectionTitle                           ###"
    
    if ($fileOutput) {
        # Append to text file
        $banner | Tee-Object -FilePath $outputFile -Append
        $header | Tee-Object -FilePath $outputFile -Append
        $banner | Tee-Object -FilePath $outputFile -Append
        & $scriptPath -ServerListFile $serverListFile *>&1 | Tee-Object -FilePath $outputFile -Append
    }

    if ($htmlOutput) {
        # Append to HTML file
        @"
        <div class='section'>
            <h2>$sectionTitle</h2>
            <pre>
"@ | Out-File -FilePath $htmlOutputFile -Append -Encoding utf8

        $output = & $scriptPath -ServerListFile $serverListFile *>&1
        foreach ($line in $output) {
            if ($line -match "offline" -or $line -match "RDP is not available" -or $line -match "Unable to retrieve updates") {
                "<span class='error'>$line</span>" | Out-File -FilePath $htmlOutputFile -Append -Encoding utf8
            } elseif ($line -match "No updates available") {
                "<span class='warning'>$line</span>" | Out-File -FilePath $htmlOutputFile -Append -Encoding utf8
            } else {
                "$line" | Out-File -FilePath $htmlOutputFile -Append -Encoding utf8
            }
        }

        "</pre></div>" | Out-File -FilePath $htmlOutputFile -Append -Encoding utf8
    }
}

# Function to append error or warning messages to HTML file
function Append-ErrorOrWarning {
    param (
        [string]$message,
        [string]$type  # "error" or "warning"
    )

    $class = if ($type -eq "error") { "error" } else { "warning" }

    @"
    <div class='$class'>
        <pre>$message</pre>
    </div>
"@ | Out-File -FilePath $htmlOutputFile -Append -Encoding utf8
}

# Define the server list file
$serverListFile = $serverListPath

# Read the CSV file
$scripts = Import-Csv -Path $csvFilePath

# Run each script and append both output and errors to the files with banners for separation
foreach ($script in $scripts) {
    $scriptName = $script.'Script Name'
    $scriptDescription = $script.'Script Description'
    $fileOutput = [bool]::Parse($script.'File output')
    $htmlOutput = [bool]::Parse($script.'HTML output')

    Try {
        Write-Host "Running $scriptDescription..."
        Append-Output -sectionTitle $scriptDescription -scriptPath ".\$scriptName" -serverListFile $serverListFile -fileOutput $fileOutput -htmlOutput $htmlOutput
    }
    Catch {
        Write-Host "An error occurred while running ${scriptName}: $_" | Tee-Object -FilePath $outputFile -Append
        Append-ErrorOrWarning -message $_ -type "error"
    }
}

# Close the HTML file
"</body></html>" | Out-File -FilePath $htmlOutputFile -Append -Encoding utf8

Write-Host "All scripts executed successfully. Results are saved in $outputFile and $htmlOutputFile."
