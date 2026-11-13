# ==============================================================================
# GhostTrace - License & Cloud Anti-Piracy Manager (IP:Port Node-Locked)
# Author: Krishna Mittal
# ==============================================================================

param (
    [Parameter(Position=0)]
    [string]$Action,

    [Parameter(Position=1)]
    [string]$Target,

    [Parameter(Position=2)]
    [string]$NewTarget
)

$GistDir = "$PSScriptRoot\gist-control"
$JsonPath = "$GistDir\ghosttrace_licenses.json"

function Ensure-GistRepo {
    if (-not (Test-Path $JsonPath)) {
        Write-Host "[!] Cloning Gist repository..." -ForegroundColor Yellow
        git clone https://gist.github.com/d1fa6935003ce9f9438c5b4cfd672cdd.git $GistDir
    }
}

function Push-Changes ($CommitMsg) {
    Push-Location $GistDir
    try {
        git add ghosttrace_licenses.json
        git commit -m $CommitMsg
        git push origin main
        Write-Host "[+] Successfully synced to Krishna's Cloud Gist!" -ForegroundColor Green
    } catch {
        Write-Host "[-] Git push failed: $_" -ForegroundColor Red
    } finally {
        Pop-Location
    }
}

Ensure-GistRepo

function Normalize-Address ($addr) {
    $clean = $addr.Trim()
    if ($clean -notmatch ":") {
        return "$($clean):*"
    }
    return $clean
}

switch ($Action.ToLower()) {
    "list" {
        $data = Get-Content $JsonPath -Raw | ConvertFrom-Json
        Write-Host "==============================================" -ForegroundColor Cyan
        Write-Host "     GHOSTTRACE IP:PORT NODE-LOCKED CLOUD     " -ForegroundColor Cyan
        Write-Host "==============================================" -ForegroundColor Cyan
        $killStatus = if ($data.kill_switch) { "ACTIVE (ALL SERVERS BLOCKED)" } else { "OFF (NORMAL)" }
        $killColor = if ($data.kill_switch) { "Red" } else { "Green" }
        Write-Host "Emergency Kill-Switch : " -NoNewline
        Write-Host $killStatus -ForegroundColor $killColor

        $gateMode = if ($null -ne $data.enforce_ip_lock -and -not $data.enforce_ip_lock) { "PUBLIC ACCESS (ALL ALLOWED)" } else { "STRICT (WHITELIST ENFORCED)" }
        $gateColor = if ($data.enforce_ip_lock -eq $false) { "Green" } else { "Yellow" }
        Write-Host "Gatekeeper Mode       : " -NoNewline
        Write-Host $gateMode -ForegroundColor $gateColor

        Write-Host "`nAuthorized Server Addresses (IP:Port):" -ForegroundColor Yellow
        $servers = if ($data.allowed_servers) { $data.allowed_servers } else { $data.allowed_ips }
        foreach ($srv in $servers) {
            Write-Host "  - $srv" -ForegroundColor White
        }
        Write-Host "==============================================" -ForegroundColor Cyan
    }

    "add" {
        if (-not $Target) {
            Write-Host "Usage: .\manage-licenses.ps1 add <IP:Port or IP>" -ForegroundColor Red
            return
        }
        $formatted = Normalize-Address $Target
        $data = Get-Content $JsonPath -Raw | ConvertFrom-Json
        $servers = [System.Collections.ArrayList]@($data.allowed_servers)
        if ($servers -contains $formatted) {
            Write-Host "[!] Address '$formatted' is already authorized." -ForegroundColor Yellow
            return
        }
        $servers.Add($formatted) | Out-Null
        $data.allowed_servers = $servers
        $data | ConvertTo-Json -Depth 5 | Set-Content $JsonPath -Encoding UTF8
        Write-Host "[+] Added '$formatted' to authorized servers." -ForegroundColor Green
        Push-Changes "Authorize GhostTrace server: $formatted"
    }

    "rebind" {
        if (-not $Target -or -not $NewTarget) {
            Write-Host "Usage: .\manage-licenses.ps1 rebind <Old_IP:Port> <New_IP:Port>" -ForegroundColor Red
            return
        }
        $oldFormatted = Normalize-Address $Target
        $newFormatted = Normalize-Address $NewTarget
        $data = Get-Content $JsonPath -Raw | ConvertFrom-Json
        $servers = [System.Collections.ArrayList]@($data.allowed_servers)

        if (-not ($servers -contains $oldFormatted)) {
            Write-Host "[!] Old address '$oldFormatted' was not found." -ForegroundColor Yellow
            return
        }
        $servers.Remove($oldFormatted)
        $servers.Add($newFormatted) | Out-Null
        $data.allowed_servers = $servers
        $data | ConvertTo-Json -Depth 5 | Set-Content $JsonPath -Encoding UTF8
        Write-Host "[+] Successfully rebound host from '$oldFormatted' to '$newFormatted'!" -ForegroundColor Green
        Push-Changes "Rebind GhostTrace server from $oldFormatted to $newFormatted"
    }

    "remove" {
        if (-not $Target) {
            Write-Host "Usage: .\manage-licenses.ps1 remove <IP:Port or IP>" -ForegroundColor Red
            return
        }
        $formatted = Normalize-Address $Target
        $data = Get-Content $JsonPath -Raw | ConvertFrom-Json
        $servers = [System.Collections.ArrayList]@($data.allowed_servers)
        if (-not ($servers -contains $formatted)) {
            Write-Host "[!] Address '$formatted' was not found." -ForegroundColor Yellow
            return
        }
        $servers.Remove($formatted)
        $data.allowed_servers = $servers
        $data | ConvertTo-Json -Depth 5 | Set-Content $JsonPath -Encoding UTF8
        Write-Host "[-] Removed '$formatted' from authorized servers." -ForegroundColor Yellow
        Push-Changes "Revoke GhostTrace server: $formatted"
    }

    "kill" {
        $data = Get-Content $JsonPath -Raw | ConvertFrom-Json
        $data.kill_switch = $true
        $data | ConvertTo-Json -Depth 5 | Set-Content $JsonPath -Encoding UTF8
        Write-Host "[!] EMERGENCY KILL-SWITCH ACTIVATED! ALL COPIES WILL SHUT DOWN." -ForegroundColor Red
        Push-Changes "Activate GhostTrace global emergency kill-switch"
    }

    "unkill" {
        $data = Get-Content $JsonPath -Raw | ConvertFrom-Json
        $data.kill_switch = $false
        $data | ConvertTo-Json -Depth 5 | Set-Content $JsonPath -Encoding UTF8
        Write-Host "[+] Kill-switch deactivated. Normal operations resumed." -ForegroundColor Green
        Push-Changes "Deactivate GhostTrace emergency kill-switch"
    }

    "public" {
        $data = Get-Content $JsonPath -Raw | ConvertFrom-Json
        $data.enforce_ip_lock = $false
        $data | ConvertTo-Json -Depth 5 | Set-Content $JsonPath -Encoding UTF8
        Write-Host "[+] PUBLIC ACCESS MODE ACTIVATED! Anyone can run GhostTrace without IP checks." -ForegroundColor Green
        Push-Changes "Set GhostTrace Gatekeeper mode to Public Access"
    }

    "strict" {
        $data = Get-Content $JsonPath -Raw | ConvertFrom-Json
        $data.enforce_ip_lock = $true
        $data | ConvertTo-Json -Depth 5 | Set-Content $JsonPath -Encoding UTF8
        Write-Host "[+] STRICT NODE-LOCK MODE ACTIVATED! Only authorized IP:Port servers can run GhostTrace." -ForegroundColor Yellow
        Push-Changes "Set GhostTrace Gatekeeper mode to Strict IP Whitelist"
    }

    default {
        Write-Host "==========================================================" -ForegroundColor Cyan
        Write-Host "   GhostTrace IP:Port Node-Locked License Manager        " -ForegroundColor Cyan
        Write-Host "   Author: Krishna Mittal • All Rights Reserved          " -ForegroundColor Cyan
        Write-Host "==========================================================" -ForegroundColor Cyan
        Write-Host "Commands:"
        Write-Host "  .\manage-licenses.ps1 list                          - View all authorized server addresses"
        Write-Host "  .\manage-licenses.ps1 add <IP:Port>                 - Authorize a server (e.g. 62.141.62.25:25597)"
        Write-Host "  .\manage-licenses.ps1 rebind <OldAddr> <NewAddr>    - Transfer license to customer's new host"
        Write-Host "  .\manage-licenses.ps1 remove <IP:Port>              - Revoke an unauthorized server"
        Write-Host "  .\manage-licenses.ps1 public                        - Unlock plugin for EVERYONE (Public Access Mode)"
        Write-Host "  .\manage-licenses.ps1 strict                        - Enforce whitelist (Only authorized IPs can run)"
        Write-Host "  .\manage-licenses.ps1 kill                          - Emergency shutdown of all distributed copies"
        Write-Host "  .\manage-licenses.ps1 unkill                        - Restore normal operation"
        Write-Host "==========================================================" -ForegroundColor Cyan
    }
}
