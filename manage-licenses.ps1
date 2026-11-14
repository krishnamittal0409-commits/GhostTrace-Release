# ==============================================================================
# GhostTrace - License & Cloud Anti-Piracy Manager (IP:Port Node-Locked)
# Author: Krishna Mittal • All Rights Reserved
# ==============================================================================

param (
    [Parameter(Position=0)]
    [string]$Action,

    [Parameter(Position=1)]
    [string]$Target,

    [Parameter(Position=2)]
    [string]$Param2
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

function Ensure-LabelsObject ($data) {
    if ($null -eq $data.server_labels) {
        $data | Add-Member -MemberType NoteProperty -Name "server_labels" -Value ([PSCustomObject]@{}) -Force
    }
}

switch ($Action.ToLower()) {
    "list" {
        $data = Get-Content $JsonPath -Raw | ConvertFrom-Json
        Ensure-LabelsObject $data
        Write-Host "==============================================" -ForegroundColor Cyan
        Write-Host "     GHOSTTRACE IP:PORT NODE-LOCKED CLOUD     " -ForegroundColor Cyan
        Write-Host "==============================================" -ForegroundColor Cyan
        $killStatus = if ($data.kill_switch) { "ACTIVE (ALL SERVERS BLOCKED)" } else { "OFF (NORMAL)" }
        $killColor = if ($data.kill_switch) { "Red" } else { "Green" }
        Write-Host "Emergency Kill-Switch : " -NoNewline
        Write-Host $killStatus -ForegroundColor $killColor

        $gateMode = if ($null -ne $data.enforce_ip_lock) { $data.enforce_ip_lock } else { $true }
        $gateStatus = if ($gateMode) { "STRICT (Only authorized IPs can run)" } else { "PUBLIC ACCESS (Unlocked globally)" }
        $gateColor = if ($gateMode) { "Yellow" } else { "Green" }
        Write-Host "Gatekeeper Shield     : " -NoNewline
        Write-Host $gateStatus -ForegroundColor $gateColor

        Write-Host "`nAuthorized Server Bindings & Owners:" -ForegroundColor Yellow
        $servers = if ($data.allowed_servers) { $data.allowed_servers } else { $data.allowed_ips }
        if (-not $servers -or $servers.Count -eq 0) {
            Write-Host "  (No servers authorized yet)" -ForegroundColor Gray
        } else {
            foreach ($srv in $servers) {
                $label = if ($data.server_labels.PSObject.Properties[$srv]) { $data.server_labels.PSObject.Properties[$srv].Value } else { "Unnamed Server" }
                $paddedLabel = "[$label]".PadRight(28)
                Write-Host "  - " -NoNewline -ForegroundColor Gray
                Write-Host $paddedLabel -NoNewline -ForegroundColor Cyan
                Write-Host " -> $srv" -ForegroundColor White
            }
        }
        Write-Host "==============================================" -ForegroundColor Cyan
    }

    "add" {
        if (-not $Target) {
            Write-Host "Usage: .\manage-licenses.ps1 add <IP:Port or IP> [ServerName]" -ForegroundColor Red
            return
        }
        $formatted = Normalize-Address $Target
        $serverName = if ($Param2) { $Param2.Trim() } else { "Authorized Server" }
        $data = Get-Content $JsonPath -Raw | ConvertFrom-Json
        Ensure-LabelsObject $data

        $servers = [System.Collections.ArrayList]@($data.allowed_servers)
        if ($servers -contains $formatted) {
            Write-Host "[!] Address '$formatted' is already authorized." -ForegroundColor Yellow
            return
        }
        $servers.Add($formatted) | Out-Null
        $data.allowed_servers = $servers
        $data.server_labels | Add-Member -MemberType NoteProperty -Name $formatted -Value $serverName -Force

        $data | ConvertTo-Json -Depth 5 | Set-Content $JsonPath -Encoding UTF8
        Write-Host "[+] Added '$formatted' [$serverName] to authorized servers." -ForegroundColor Green
        Push-Changes "Authorize GhostTrace server: $formatted [$serverName]"
    }

    "edit" {
        if (-not $Target -or -not $Param2) {
            Write-Host "Usage: .\manage-licenses.ps1 edit <IP:Port> <NewServerName>" -ForegroundColor Red
            return
        }
        $formatted = Normalize-Address $Target
        $newName = $Param2.Trim()
        $data = Get-Content $JsonPath -Raw | ConvertFrom-Json
        Ensure-LabelsObject $data

        $servers = [System.Collections.ArrayList]@($data.allowed_servers)
        if (-not ($servers -contains $formatted)) {
            Write-Host "[!] Address '$formatted' is not in the authorized list." -ForegroundColor Yellow
            return
        }
        $data.server_labels | Add-Member -MemberType NoteProperty -Name $formatted -Value $newName -Force
        $data | ConvertTo-Json -Depth 5 | Set-Content $JsonPath -Encoding UTF8
        Write-Host "[+] Updated label for '$formatted' to '[$newName]'." -ForegroundColor Green
        Push-Changes "Update GhostTrace label for $formatted to [$newName]"
    }

    "rebind" {
        if (-not $Target -or -not $Param2) {
            Write-Host "Usage: .\manage-licenses.ps1 rebind <Old_IP:Port> <New_IP:Port>" -ForegroundColor Red
            return
        }
        $oldFormatted = Normalize-Address $Target
        $newFormatted = Normalize-Address $Param2
        $data = Get-Content $JsonPath -Raw | ConvertFrom-Json
        Ensure-LabelsObject $data
        $servers = [System.Collections.ArrayList]@($data.allowed_servers)

        if (-not ($servers -contains $oldFormatted)) {
            Write-Host "[!] Old address '$oldFormatted' was not found." -ForegroundColor Yellow
            return
        }
        $servers.Remove($oldFormatted)
        if (-not ($servers -contains $newFormatted)) {
            $servers.Add($newFormatted) | Out-Null
        }
        $data.allowed_servers = $servers

        if ($data.server_labels.PSObject.Properties[$oldFormatted]) {
            $existingLabel = $data.server_labels.PSObject.Properties[$oldFormatted].Value
            $data.server_labels.PSObject.Properties.Remove($oldFormatted)
            $data.server_labels | Add-Member -MemberType NoteProperty -Name $newFormatted -Value $existingLabel -Force
        }

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
        Ensure-LabelsObject $data
        $servers = [System.Collections.ArrayList]@($data.allowed_servers)
        if (-not ($servers -contains $formatted)) {
            Write-Host "[!] Address '$formatted' was not found." -ForegroundColor Yellow
            return
        }
        $servers.Remove($formatted)
        $data.allowed_servers = $servers

        if ($data.server_labels.PSObject.Properties[$formatted]) {
            $data.server_labels.PSObject.Properties.Remove($formatted)
        }

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
        Write-Host "  .\manage-licenses.ps1 list                          - View all authorized servers & names"
        Write-Host "  .\manage-licenses.ps1 add <IP:Port> [ServerName]    - Authorize server with friendly owner name"
        Write-Host "  .\manage-licenses.ps1 edit <IP:Port> <NewName>      - Change owner/server name"
        Write-Host "  .\manage-licenses.ps1 rebind <OldAddr> <NewAddr>    - Transfer license to customer's new host"
        Write-Host "  .\manage-licenses.ps1 remove <IP:Port>              - Revoke server authorization"
        Write-Host "  .\manage-licenses.ps1 public                        - Unlock plugin for EVERYONE (Public Access Mode)"
        Write-Host "  .\manage-licenses.ps1 strict                        - Enforce whitelist (Only authorized IPs can run)"
        Write-Host "  .\manage-licenses.ps1 kill                          - Emergency shutdown of all distributed copies"
        Write-Host "  .\manage-licenses.ps1 unkill                        - Restore normal operation"
        Write-Host "==========================================================" -ForegroundColor Cyan
    }
}
