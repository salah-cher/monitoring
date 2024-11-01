# Monitoring Scripts

This repository contains PowerShell scripts for monitoring and maintaining Windows-based workstations and servers. The scripts perform checks on server status, RDP availability, pending updates, and more. Results are output to text and HTML files for easy review.

## Table of Contents
- [Scripts](#scripts)
  - [Check-ServerStatus.ps1](#check-serverstatusps1)
  - [Check-RDPAvailability.ps1](#check-rdpavailabilityps1)
  - [Check-PendingUpdates.ps1](#check-pendingupdatesps1)
  - [Last-WindowsUpdate.ps1 / last-WU-Applied.ps1](#last-windowsupdateps1--last-wu-appliedps1)
  - [Run-MonitoringTasks.ps1](#run-monitoringtasksps1)
- [Notes](#notes)
- [License](#license)

## Scripts

### Check-ServerStatus.ps1
Checks the online status of servers listed in a file.

- **Parameters**:
  - `ServerListFile`: Path to the file containing server names. Default is `.\list-srv.txt`.
- **Usage**:
  ```powershell
  .\Check-ServerStatus.ps1 -ServerListFile .\list-srv.txt
  ```

### Check-RDPAvailability.ps1
Checks Remote Desktop Protocol (RDP) availability for servers.

- **Parameters**:
  - `ServerListFile`: Path to the file containing server names. Default is `.\list-srv.txt`.
- **Usage**:
  ```powershell
  .\Check-RDPAvailability.ps1 -ServerListFile .\list-srv.txt
  ```

### Check-PendingUpdates.ps1
Identifies any pending Windows updates on servers.

- **Parameters**:
  - `ServerListFile`: Path to the file with server names. Default is `.\list-srv.txt`.
- **Usage**:
  ```powershell
  .\Check-PendingUpdates.ps1 -ServerListFile .\list-srv.txt
  ```

### Last-WindowsUpdate.ps1 / last-WU-Applied.ps1
Displays the last Windows Update installation date for servers. *(Note: These scripts are redundant; consider consolidating.)*

- **Parameters**:
  - `ServerListFile`: Path to the server list file. Default is `.\list-srv.txt`.
- **Usage**:
  ```powershell
  .\Last-WindowsUpdate.ps1 -ServerListFile .\list-srv.txt
  ```

### Run-MonitoringTasks.ps1
Executes all monitoring scripts sequentially, compiles their output, and organizes results.

- **Functionality**:
  - Creates a timestamped folder named after the execution time.
  - Outputs both a text file and an HTML file containing the combined results from all scripts.
  - Runs each script in sequence, aggregating server status, RDP availability, pending updates, and update history.
- **Parameters**:
  - `ServerListFile`: Path to the file containing server names. Default is `.\list-srv.txt`.
- **Usage**:
  ```powershell
  .\Run-MonitoringTasks.ps1 -ServerListFile .\list-srv.txt
  ```

## Notes
- Ensure appropriate permissions for accessing network shares.
- Modify scripts to fit your environment.

## License
MIT License. See LICENSE file for details.
