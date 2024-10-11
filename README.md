# Server Monitoring and Windows Update Checker

This repository provides PowerShell scripts to help automate the process of checking server status, remote desktop availability, and pending Windows updates. These scripts were designed to streamline the manual process of checking multiple Windows servers for updates and online availability.

## Prerequisites
- Ensure that PowerShell remoting is enabled for all servers.
- The user running these scripts must have appropriate privileges to access the servers and retrieve Windows Update information.

## Scripts Overview:

### 1. `Check-ServerStatus.ps1`
This script checks if the specified list of servers is online using `Test-Connection`.

### 2. `Check-RDPAvailability.ps1`
This script checks whether port 3389 (RDP) is open for each server.

### 3. `Check-WindowsUpdateStatus.ps1`
This script checks if the Windows Update service (`wuauserv`) is running on each server.

### 4. `List-PendingUpdates.ps1`
This script retrieves a list of pending Windows updates for each online server.

## How to Run:
1. Open PowerShell with administrator privileges.
2. Navigate to the folder containing the scripts.
3. Execute the scripts using:
   ```powershell
   ./Check-ServerStatus.ps1
   ./Check-RDPAvailability.ps1
   ./Check-WindowsUpdateStatus.ps1
   ./List-PendingUpdates.ps1
