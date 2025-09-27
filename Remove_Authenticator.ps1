
<# This script will strip a specified user of any registered Authenticator devices
#>

Connect-MgGraph
$User = Read-Host "Enter the UPN of the target user"

$auth = Get-MgUserAuthenticationMethod -UserId $User | Where-Object {
    $_.AdditionalProperties["@odata.type"] -eq "#microsoft.graph.microsoftAuthenticatorAuthenticationMethod"
}
if (-not $auth) { Write-Host "No Microsoft Authenticator methods found for $User." }

$idx = 0; $list = $auth | ForEach-Object {
    [pscustomobject]@{
        Index=$idx++
        Id=$_.Id
        Device=$_.AdditionalProperties["displayName"]
        Added=$_.AdditionalProperties["createdDateTime"]
    }
}
$list | Format-Table -Autosize

$choice = Read-Host "Enter index to remove, 'all' to remove all, or press Enter to cancel"
if ([string]::IsNullOrWhiteSpace($choice)) { Write-Host "Cancelled." }
$targets = if ($choice -eq 'all') { $auth } else { $auth[[int]$choice] }

$targets | ForEach-Object {
    Remove-MgUserAuthenticationMethod -UserId $User -AuthenticationMethodId $_.Id -Confirm:$true
}