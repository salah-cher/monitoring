
---

### Updated **CHANGELOG.md**:

```markdown
# Changelog

---

## Version 1.0.1 - 2024-10-11
- Fixed variable reference issues:
  - Wrapped `$server` variable in curly braces `${}` in all **Write-Host** statements to prevent parser errors in **Check-WindowsUpdateStatus.ps1** and **List-PendingUpdates.ps1**.

---

## Version 1.0.0 - 2024-10-11
- **Initial Release:**
  - **Check-ServerStatus.ps1**: Checks if specified servers are online.
  - **Check-RDPAvailability.ps1**: Checks if RDP (port 3389) is available on servers.
  - **Check-WindowsUpdateStatus.ps1**: Checks if Windows Update service (`wuauserv`) is enabled or disabled on each server.
  - **List-PendingUpdates.ps1**: Lists pending Windows updates for each server that is online.
