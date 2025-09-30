
# Import Microsoft Graph

<# ----- Import Modules -----
Import-Module Microsoft.Graph
}#>

# Connect to Microsoft Graph
Connect-MgGraph

# ===Stwp 1: Create and read the CSV
$rows = Import-Csv "C:\Users\msewell\OneDrive - Phoebe Health\Documents\VS Code\BulkMFAUsers.csv"
$rows
$rows | Get-Member

# =====Format given phone number to be E164 compliant=====
function Clean-PhoneNumber {
    param ([string]$Number)
        if (-not $Number) { return $null }
        # Remove spaces, hyphens, and parentheses
        $clean = $Number -replace '[\s\-\(\)]',''
        if ($clean -match '^\+') { return $clean }      # already E.164-ish
        if ($clean -match '^1\d{10}$') { return '+' + $clean }      # 11 digits starting with 1
        if ($clean -match '^\d{10}$') { return '+1' + $clean }      # 10 digits -> assume US
        return $clean 
}

# =====Validate E.164=====
function Test-E164 { param ([string]$n) return $n -match '^\+\d{6,15}$' }

foreach ($r in $rows) {
    $raw = $r.PhoneNumber
    $num = Clean-PhoneNumber $raw
    "{0,-28} -> {1,-15} | E164:{2}" -f $r.UserPrincipalName, $num, (Test-E164 $num)
}

# =====Loop the CSV + add logging=====
$WhatIf = $false
$LogPath = "C:\Users\msewell\OneDrive - Phoebe Health\Documents\VS Code\PhoneMethodResults.csv"
$report = @()

foreach ($r in $rows) {
    $upn = $r.UserPrincipalName.Trim()
    $num = Clean-PhoneNumber ($r.PhoneNumber).Trim()

    $row = [PSCustomObject]@{
        UPN = $upn
        DesiredPhone = $num
        Action = $null
        Result = "Skipped"
        Detail = $null
    }
    try {
        if (-not $upn) { throw "Missing UPN" }
        if (-not $num) { throw "Missing phone" }
        if (-not (Test-E164 $num)) { throw "Not E.164: $num" }

        $methods = Get-MgUserAuthenticationPhoneMethod -UserId $upn -ErrorAction Stop
        $existing = $methods | Where-Object { $_.PhoneType -eq "mobile" }

        if ($existing) {
            $row.Action = "UpdateMobile"
            if ($WhatIf) {
                $row.Result = "DryRun"; $row.Detail = "Would update to $num"
            } else {
                Update-MgUserAuthenticationPhoneMethod -UserId $upn -PhoneAuthenticationMethodId $existing.Id -PhoneNumber $num
                $row.Result = "Success"; $row.Detail = "Updated to $num"
            }
        } else {
            $row.Action = "CreateMobile"
            if ($WhatIf) {
                $row.Result = "DryRun"; $row.Detail = "Would create $num"
            } else {
                New-MgUserAuthenticationPhoneMethod -UserId $upn -PhoneType "mobile" -PhoneNumber $num
                $row.Result = "Success"; $row.Detail = "Created $num"
            }
        }
        <# ----- Optional: Update SMS sign-in
        if ($SmsSignIn -ne 'leave' -and -not $WhatIf) {
            $targetId = if ($existing) { $existing.Id } else { (Get-MgUserAuthenticationPhoneMethod -UserId $upn | Where-Object -eq 'mobile').Id }
            Update-MgUserAuthenticationPhoneMethod -UserId $upn -PhoneAuthenticationMethodId $targetId -SmsSignInState $SmsSignIn
        }#>
        <# ----- Add to Entra Group -----
        if ($EntraGroupID) {
            try {
                $userObj = Get-MgUser -UserId $upn -ErrorAction Stop
                New-MgGroupMember -GroupId $EntraGroupId -DirectoryObjectId $userObj.Id -ErrorAction Stop
                $row.Action += " + AddToEntraGroup"
                $row.Detail += "; Added to Entra Group $EntraGroupId"
            }
            catch {
                $row.Action += " + AddtoEntraGroup"
                if ($row.Result -eq "Success") { $row.Result = "Partial" }
                $row.Detail += "; Entra group add failed: $($_.Exception.Message)"
            }
        }#>
    }
    catch {
        $row.Result = "Error"
        $row.Detail = $_.Exception.Message
    }
    $report += $row
    $row    # echo progress
}

# ----- Output -----
$report | Tee-Object -FilePath $LogPath | Format-Table -AutoSize
"Saved results to $LogPath"

Write-Host "`nScript finished. Press any key to close..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")