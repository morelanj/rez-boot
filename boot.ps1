# rez public loader. THIS FILE IS PUBLIC: no secrets, no private details beyond the GitHub username.
#
# On a fresh machine, in PowerShell (no admin needed):
#   irm rez.248167.xyz|iex           asks which profile to set up
#   irm rez.248167.xyz/ai|iex        goes straight to a profile (lite, ai, full)
# rez.248167.xyz redirects (Cloudflare) to this file, or to <profile>.ps1 next to it, which sets $RezArgs and loads this.
#
# What it does:
#   1. asks where to install (default %USERPROFILE%\rez)
#   2. installs Scoop, Git and the GitHub CLI if missing
#   3. GitHub sign-in in the browser (needed to reach the private rez repo)
#   4. clones rez and runs: rez up <$RezArgs>  (no args: rez shows a profile menu)

# Everything runs inside a script block so nothing leaks into your session and 'return' is safe under iex.
& {
    $Owner = 'morelanj'
    $Repo = 'rez'
    $argv = @(if ($RezArgs) { $RezArgs })

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $ProgressPreference = 'SilentlyContinue'

    function Refresh-Path {
        $env:Path = @([Environment]::GetEnvironmentVariable('Path', 'Machine'), [Environment]::GetEnvironmentVariable('Path', 'User'), $env:Path) -join ';'
    }
    function Has([string]$name) { [bool](Get-Command $name -ErrorAction SilentlyContinue) }

    # Scripts (Scoop, your profile) need at least RemoteSigned; for the current user that needs no admin.
    $saved = 'Restricted'
    foreach ($s in 'MachinePolicy', 'UserPolicy', 'CurrentUser', 'LocalMachine') {
        if ("$(Get-ExecutionPolicy -Scope $s)" -ne 'Undefined') { $saved = "$(Get-ExecutionPolicy -Scope $s)"; break }
    }
    if (@('Restricted', 'AllSigned') -contains $saved) {
        try { Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force -ErrorAction Stop }
        catch { Write-Host "Script policy is locked on this machine ($saved); setup cannot continue." -ForegroundColor Red; return }
    }

    # Install folder: remembered in %USERPROFILE%\.rez\config.json, which rez reads too.
    $cfgDir = Join-Path $env:USERPROFILE '.rez'
    $cfgFile = Join-Path $cfgDir 'config.json'
    $cfg = if (Test-Path $cfgFile) { Get-Content $cfgFile -Raw | ConvertFrom-Json } else { New-Object psobject }
    $ri = [array]::IndexOf(@($argv | ForEach-Object { "$_".ToLower() }), '-root')
    if ($ri -ge 0 -and $ri + 1 -lt $argv.Count) { $root = "$($argv[$ri + 1])" }
    elseif ($cfg.Root) { $root = $cfg.Root }
    else {
        $root = Join-Path $env:USERPROFILE 'rez'
        Write-Host "Where should tools, apps and repos be installed? Free space:"
        Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Free -gt 0 } | ForEach-Object { Write-Host ("  {0}:  {1,8:N1} GB free" -f $_.Name, ($_.Free / 1GB)) }
        $r = Read-Host "Install folder [$root]"
        if ($r) { $root = $r.Trim().Trim('"') }
    }
    New-Item -ItemType Directory -Force $root, $cfgDir | Out-Null
    $cfg | Add-Member -NotePropertyName Root -NotePropertyValue $root -Force
    $cfg | ConvertTo-Json -Depth 5 | Set-Content -Encoding UTF8 $cfgFile

    if (-not (Has scoop)) {
        Write-Host "Installing Scoop..."
        $dir = Join-Path $root 'scoop'
        [Environment]::SetEnvironmentVariable('SCOOP', $dir, 'User'); $env:SCOOP = $dir
        $f = Join-Path $cfgDir 'install-scoop.ps1'
        Invoke-WebRequest 'https://get.scoop.sh' -OutFile $f -UseBasicParsing
        $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if ($isAdmin) { & $f -ScoopDir $dir -RunAsAdmin } else { & $f -ScoopDir $dir }
        Refresh-Path
    }
    if (-not (Has git)) { Write-Host "Installing Git..."; scoop install git; Refresh-Path }
    if (-not (Has gh)) { Write-Host "Installing GitHub CLI..."; scoop install gh; Refresh-Path }

    cmd /c "gh auth status -h github.com >nul 2>&1"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "`nSign in to GitHub (a browser opens; enter the code shown here):" -ForegroundColor Cyan
        gh auth login -h github.com --web --git-protocol https
        gh auth setup-git
    }

    $repoDir = Join-Path $root $Repo
    if (Test-Path (Join-Path $repoDir '.git')) { git -C $repoDir pull --ff-only }
    else { gh repo clone "$Owner/$Repo" $repoDir }
    if (-not (Test-Path (Join-Path $repoDir 'rez.ps1'))) { Write-Host "Could not get $Owner/$Repo." -ForegroundColor Red; return }

    & (Join-Path $repoDir 'rez.ps1') up @argv
}
