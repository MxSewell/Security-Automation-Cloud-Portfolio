# Revokes sessions of a specified user

param(
    [Parameter(Mandatory=$true)]
    [string]$User
)
$ErrorActionPreference = 'Stop'

# Load modules (install if missing)
if (-not (Get-Module Microsoft.Graph.Authentication -ListAvailable)) {
    Install-Module Microsoft.Graph.Authentication 
}
if (-not (Get-Module Microsoft.Graph.Users -ListAvailable)) {
    Install-Module Microsoft.Graph.Users
}
Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Users
if (-not (Get-MgContext)) {
    Connect-Graph
}

# Resolve the user by Id or UPN
try {
    $u = Get-MgUser -UserId $User -ErrorAction Stop
}   catch {
    $u = Get-MgUser -Filter "userPrincipalName -eq '$User'" -All | Select-Object -First 1
}
if (-not $u) { throw "User '$User' not found." }

Write-Host "Revoking sign-in sessions for $($u.DisplayName) <$($u.UserPrincipalName)>n..." -ForegroundColor Cyan
Revoke-MgUserSignInSession -UserId $u.Id | Out-Null

Write-Host "Done. Refresh tokens invalidated; new sign-in required." -ForegroundColor Green
