Invoke-Expression (&starship init powershell)
$Env:SHELL = "pwsh.exe"
$Env:EDITOR = "code --wait"

function Connect-itvc {
    Connect-Keeper
    $l = Get-KeeperRecord  -Uid zHgtYS9mnRlCOFVj10fvuA
    Connect-VIServer it-vc.corp.qumulo.com -User dmills -Password $(($l.fields | Where-Object { $_.fieldName -eq "password" }).values)
}