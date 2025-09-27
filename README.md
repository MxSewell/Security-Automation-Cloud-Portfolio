<<<<<<< HEAD
# Entra Graph Remediation Toolkit

Modular PowerShell scripts for automating common Microsoft Entra ID remediation tasks using the [Microsoft Graph PowerShell SDK](https://learn.microsoft.com/en-us/powershell/microsoftgraph/overview).  
Designed as a **living portfolio** of practical utilities that can be adapted to any environment.

---

## Scripts
-  **Revoke-Sessions.ps1**
    Invalidate refresh tokens and revoke user sign-in sessions.
-  **Remove-Authenticator.ps1**
    Lists a user's Microsoft Authenticator methods and prompts script operator to choose which method(s) to remove.
-  **Reset-Password.ps1**
    Generates and assigns a strong/complex temporary password (>=16 chars).

## 🚧 Roadmap

Planned utilities to extend the toolkit:
- Disable-User.ps1 → Disable compromised accounts
- Clear-AuthMethods.ps1 → Remove MFA methods to force re-registration
- Remove-From-Group.ps1 → Remove user from sensitive groups (e.g., “MFA” group)
- Get-SignInLogs.ps1 → Pull last 24h sign-ins for a given user

## 🛠️ Requirements

Microsoft Graph PowerShell SDK v2
Install if missing:
- Install-Module Microsoft.Graph -Scope CurrentUser -Force
Recommended scopes (grant once via Connect-MgGraph):
- User.ReadWrite.All
- AuditLog.Read.All (if using sign-in log utilities later)

## 📜 Disclaimer

These scripts are provided for educational and demo purposes.
Always test in a non-production tenant before adapting for production use.

## ⭐ Portfolio Note

This repo is maintained as a living showcase of cloud security automation skills.
Each script is modular, environment-agnostic, and designed to demonstrate:
- Microsoft Graph API automation
- Incident response workflows
- Identity & Access Management best practices
- PowerShell development with safe defaults (-WhatIf, encrypted output, no hard-coded values)
 
## Usage Examples
-    .\Revoke-Sessions.ps1 -Users johndoe@contoso.com
-    .\Remove-Authenticator.ps1 -Users janedoe@fabrikam.com
=======
# Security-Automation-Cloud-Portfolio
This is my life's work...
>>>>>>> f2db618d18aa61a39b0052e064783996880ec16b
