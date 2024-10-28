# Monitoring Scripts

This repository contains PowerShell scripts for monitoring Windows-based workstations and servers. The scripts perform various checks such as server status, RDP availability, and pending updates. The results are output to both text and HTML files for easy viewing.

## Scripts

### Check-ServerStatus.ps1

This script checks the status of servers listed in a specified file.

#### Parameters

- `ServerListFile`: Path to the file containing the list of servers. Default is `.\list-srv.txt`.

#### Usage

```powershell
.\Check-ServerStatus.ps1 -ServerListFile .\list-all-srv.txt
```

### Check-RDPAvailability.ps1

This script checks the RDP availability of servers listed in a specified file.

#### Parameters

- `ServerListFile`: Path to the file containing the list of servers. Default is `.\list-srv.txt`.

#### Usage

```powershell
.\Check-RDPAvailability.ps1 -ServerListFile .\list-all-srv.txt
```

### List-PendingUpdates.ps1

This script lists the pending updates for servers listed in a specified file.

#### Parameters

- `ServerListFile`: Path to the file containing the list of servers. Default is `.\list-srv.txt`.

#### Usage

```powershell
.\List-PendingUpdates.ps1 -ServerListFile .\list-all-srv.txt
```

### Combined-Results.ps1

This script runs the above scripts and outputs the results to both a text file and an HTML file.

#### Parameters

- `ServerListFile`: Path to the file containing the list of servers. Default is `.\list-all-srv.txt`.

#### Usage

```powershell
.\Combined-Results.ps1 -ServerListFile .\list-all-srv.txt
```

## Output

The results are saved in two formats:

1. **Text File**: A timestamped text file containing the combined results of all checks.
2. **HTML File**: A timestamped HTML file with sections for each check. Errors and warnings are highlighted in red and yellow, respectively.

### Example Output

- `Combined-Results_YYYYMMDD_HHMMSS.txt`
- `Combined-Results_YYYYMMDD_HHMMSS.html`

## Example

To run the combined results script with a specific server list file:

```powershell
.\Combined-Results.ps1 -ServerListFile .\list-all-srv.txt
```

## Notes

- Ensure that the server list files are correctly formatted and accessible.
- Run the scripts with appropriate permissions to access the servers and perform the checks.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
