# Monitoring Scripts

This repository contains PowerShell scripts for monitoring Windows-based servers and workstations. Each script performs specific checks, with results saved to both text and HTML files. The main script, `all.ps1`, calls individual scripts for streamlined monitoring.

## Table of Contents
- [Scripts Overview](#scripts-overview)
  - [Check-ServerStatus.ps1](#check-serverstatusps1)
  - [Check-RDPAvailability.ps1](#check-rdpavailabilityps1)
  - [List-PendingUpdates.ps1](#list-pendingupdatesps1)
  - [Check-WindowsUpdateStatus.ps1](#check-windowsupdatestatusps1)
  - [last-WU-Applied.ps1](#last-wu-appliedps1)
  - [Last-WindowsUpdate.ps1](#last-windowsupdateps1) *(Note: Duplicate of last-WU-Applied.ps1)*
- [Caller Script](#caller-script)
- [Notes](#notes)
- [License](#license)

## Scripts Overview

### Check-ServerStatus.ps1
Checks if each server listed in a specified file is online.

- **Parameters**:
  - `ServerListFile` (string): Path to the file containing server names (default: `.\list-all-srv.txt`).
- **Usage**:
  ```powershell
  .\Check-ServerStatus.ps1 -ServerListFile .\list-all-srv.txt
  ```

### Check-RDPAvailability.ps1
Verifies if Remote Desktop Protocol (RDP) is available for each server.

- **Parameters**:
  - `ServerListFile` (string): Path to the server list (default: `.\list-rdp-srv.txt`).
- **Usage**:
  ```powershell
  .\Check-RDPAvailability.ps1 -ServerListFile .\list-rdp-srv.txt
  ```

### List-PendingUpdates.ps1
Lists major pending updates (identified by “KB” numbers) for each server.

- **Parameters**:
  - `ServerListFile` (string): Path to the server list.
  - `OutputFile` (string, optional): Destination file for the output.
- **Usage**:
  ```powershell
  .\List-PendingUpdates.ps1 -ServerListFile .\list-update-srv.txt
  ```

### Check-WindowsUpdateStatus.ps1
Checks for any Windows updates on specified servers and outputs a status report.

- **Parameters**:
  - `ServerListFile` (string): Path to the server list.
- **Usage**:
  ```powershell
  .\Check-WindowsUpdateStatus.ps1 -ServerListFile .\list-all-srv.txt
  ```

### last-WU-Applied.ps1
Displays the last Windows Update applied on each server from a specified list.

- **Parameters**:
  - `ServerListFile` (string): Path to the server list.
- **Usage**:
  ```powershell
  .\last-WU-Applied.ps1 -ServerListFile .\list-wu-srv.txt
  ```

### Last-WindowsUpdate.ps1
**(Note: This script is a duplicate of last-WU-Applied.ps1. Consider removing or consolidating.)**

## Caller Script

### all.ps1
Combines all scripts in this repository, executing them sequentially and saving output to `combined_output.txt` and `combined_output.html`.

- **Usage**:
  ```powershell
  .\all.ps1
  ```

## Notes
- Ensure each script runs with appropriate permissions, especially for network or remote monitoring tasks.
- If using across domains, update credentials in the respective scripts.

## License
This repository is licensed under the MIT License.

--- 

Let me know if you’d like further customization!
