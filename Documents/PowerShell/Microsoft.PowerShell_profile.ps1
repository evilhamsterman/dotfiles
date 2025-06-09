Invoke-Expression (&starship init powershell)
$Env:SHELL = "pwsh.exe"
$Env:EDITOR = "code --wait"
$Env:Path += ";$HOME\.local\bin"

function Test-CommandExists {
    param (
        [string]$command
    )
    $commandExists = Get-Command -Name $command -ErrorAction SilentlyContinue
    return [bool]($commandExists)
}

function Connect-itvc {
    if ($Global:Credentials -eq $null) {
        $Global:Credentials = Get-Credential -User dmills
    }
    Connect-VIServer it-vc.corp.qumulo.com -Credential $Global:Credentials
}

if (Test-CommandExists "kubectl") {
    Set-Alias k kubectl
}

if (Test-CommandExists "talosctl") {
    Set-Alias t talosctl
}

if (Test-CommandExists "flux") {
    Set-Alias f flux
}