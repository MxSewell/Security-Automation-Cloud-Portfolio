

# Reset-Password.ps1
param(
  [Parameter(Mandatory=$true)]
  [string[]]$Users,                          # UPNs or Object IDs
  [ValidateRange(16,128)]
  [int]$Length = 20,                         # >=16 (default 20)
  [switch]$CopyToClipboard,                  # Windows-only convenience
  [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'

# --- Ensure modules (Graph v2) ---
if (-not (Get-Module Microsoft.Graph.Authentication -ListAvailable)) {
  Install-Module Microsoft.Graph.Authentication -Scope CurrentUser -Force
}
if (-not (Get-Module Microsoft.Graph.Users -ListAvailable)) {
  Install-Module Microsoft.Graph.Users -Scope CurrentUser -Force
}
Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Users

# --- Connect once (needs User.ReadWrite.All) ---
if (-not (Get-MgContext)) {
  Connect-MgGraph -Scopes "User.ReadWrite.All"
}

# --- Password generator (complexity + length) ---
function New-StrongPassword {
  param([ValidateRange(16,128)][int]$Len = 20)

  $symbols = '!@#$%^&*()-_=+[]{}|;:,.?'
  $upper   = (1..2 | % { [char](Get-Random -Minimum 65 -Maximum 91) })
  $lower   = (1..4 | % { [char](Get-Random -Minimum 97 -Maximum 123) })
  $digit   = (1..2 | % { [char](Get-Random -Minimum 48 -Maximum 58) })
  $sym     = (1..2 | % { $symbols[(Get-Random -Min 0 -Max $symbols.Length)] })
  $need    = $Len - ($upper.Count + $lower.Count + $digit.Count + $sym.Count)
  $pool    = ((33..126 | % {[char]$_}) | ? { $_ -ne ' ' })

  $rest = (1..$need | % { $pool[(Get-Random -Min 0 -Max $pool.Count)] })
  $chars = @($upper + $lower + $digit + $sym + $rest) | Sort-Object {Get-Random}

  [string]::Join('', $chars)
}

foreach ($User in $Users) {
  try {
    # Resolve user by Id or UPN
    try { $u = Get-MgUser -UserId $User -ErrorAction Stop } catch {
      $u = Get-MgUser -Filter "userPrincipalName eq '$User'" -All | Select-Object -First 1
    }
    if (-not $u) { Write-Host "User '$User' not found." -ForegroundColor Red; continue }

    Write-Host "Resetting password for $($u.DisplayName) <$($u.UserPrincipalName)> ..." -ForegroundColor Cyan

    $tempPw = New-StrongPassword -Len $Length

    if ($WhatIf) {
      Write-Host "WhatIf: Update-MgUser -UserId $($u.Id) -PasswordProfile <temp+forceChange>" -ForegroundColor DarkGray
    } else {
      # Prefer MFA-at-next-sign-in if supported by your SDK/tenant (ignored otherwise)
      $updated = $false
      try {
        Update-MgUser -UserId $u.Id -PasswordProfile @{
          password = $tempPw
          forceChangePasswordNextSignIn        = $true
          forceChangePasswordNextSignInWithMfa = $true
        } -ErrorAction Stop
        $updated = $true
      } catch {
        # Fallback without WithMfa
        Update-MgUser -UserId $u.Id -PasswordProfile @{
          password = $tempPw
          forceChangePasswordNextSignIn = $true
        } -ErrorAction Stop
        $updated = $true
      }

      if ($updated) {
        # Store password securely (DPAPI) per user
        $outPath = Join-Path $env:TEMP "TempPassword-$($u.UserPrincipalName)-$(Get-Date -Format 'yyyyMMdd-HHmmss').clixml"
        ConvertTo-SecureString $tempPw -AsPlainText -Force | Export-Clixml -Path $outPath
        Write-Host "Temporary password saved (DPAPI-encrypted) to: $outPath" -ForegroundColor Yellow

        if ($CopyToClipboard) {
          try {
            if (Get-Command Set-Clipboard -ErrorAction SilentlyContinue) {
              $tempPw | Set-Clipboard
              Write-Host "Temporary password copied to clipboard (use with care)." -ForegroundColor Yellow
            } else {
              Write-Host "Set-Clipboard not available on this host; skipped." -ForegroundColor DarkYellow
            }
          } catch {
            Write-Host "Clipboard copy failed: $($_.Exception.Message)" -ForegroundColor DarkYellow
          }
        }
      }
    }

    Write-Host "✔ Password reset complete (force change at next sign-in)." -ForegroundColor Green
  } catch {
    Write-Host "✘ Failed for $User — $($_.Exception.Message)" -ForegroundColor Red
  }
}