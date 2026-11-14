Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$GistDir = "$PSScriptRoot\gist-control"
$JsonPath = "$GistDir\ghosttrace_licenses.json"

function Ensure-GistRepo {
    if (-not (Test-Path $JsonPath)) {
        git clone https://gist.github.com/d1fa6935003ce9f9438c5b4cfd672cdd.git $GistDir
    }
}
Ensure-GistRepo

function Read-LicenseData {
    $raw = Get-Content $JsonPath -Raw | ConvertFrom-Json
    if ($null -eq $raw.server_labels) {
        $raw | Add-Member -MemberType NoteProperty -Name "server_labels" -Value ([PSCustomObject]@{}) -Force
    }
    return $raw
}

function Save-And-Push ($data, $message) {
    $data | ConvertTo-Json -Depth 5 | Set-Content $JsonPath -Encoding UTF8
    Push-Location $GistDir
    try {
        git add ghosttrace_licenses.json
        git commit -m $message
        git push origin main
    } finally {
        Pop-Location
    }
}

function Normalize-Addr ($addr) {
    $clean = $addr.Trim()
    if ($clean -notmatch ":") {
        return "$($clean):*"
    }
    return $clean
}

function New-ServerEntry([string]$address, [string]$name) {
    $obj = [PSCustomObject]@{
        Address = $address
        Name = $name
    }
    $obj | Add-Member -MemberType ScriptMethod -Name "ToString" -Value {
        $disp = if ([string]::IsNullOrWhiteSpace($this.Name)) { "Unnamed Server" } else { $this.Name }
        if ($disp.Length -gt 28) { $disp = $disp.Substring(0, 25) + "..." }
        return "  " + $disp.PadRight(30) + " │  " + $this.Address
    } -Force
    return $obj
}

# --- Visual Theme Palette ---
$cBg = [System.Drawing.Color]::FromArgb(15, 23, 42)          # Slate 900
$cCard = [System.Drawing.Color]::FromArgb(30, 41, 59)        # Slate 800
$cCardDark = [System.Drawing.Color]::FromArgb(20, 30, 48)    # Slate 850
$cHeaderBg = [System.Drawing.Color]::FromArgb(10, 15, 30)    # Slate 950
$cTextPrimary = [System.Drawing.Color]::FromArgb(248, 250, 252)
$cTextMuted = [System.Drawing.Color]::FromArgb(148, 163, 184)
$cAccentBlue = [System.Drawing.Color]::FromArgb(56, 189, 248) # Sky 400
$cGreen = [System.Drawing.Color]::FromArgb(16, 185, 129)     # Emerald 500
$cRed = [System.Drawing.Color]::FromArgb(239, 68, 68)        # Rose 500
$cAmber = [System.Drawing.Color]::FromArgb(245, 158, 11)     # Amber 500
$cPurple = [System.Drawing.Color]::FromArgb(139, 92, 246)    # Violet 500
$cSlateBtn = [System.Drawing.Color]::FromArgb(71, 85, 105)   # Slate 600
$cBlueBtn = [System.Drawing.Color]::FromArgb(37, 99, 235)    # Blue 600

# --- Fonts ---
$fontTitle = New-Object System.Drawing.Font("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
$fontSubtitle = New-Object System.Drawing.Font("Segoe UI", 9)
$fontSection = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$fontSectionSmall = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
$fontBold = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
$fontNormal = New-Object System.Drawing.Font("Segoe UI", 9.5)
$fontMono = New-Object System.Drawing.Font("Consolas", 10)
$fontMonoHeader = New-Object System.Drawing.Font("Consolas", 9, [System.Drawing.FontStyle]::Bold)
$fontSmall = New-Object System.Drawing.Font("Segoe UI", 8)

# --- Main Window Form ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "GhostTrace Cloud License & Access Center - Krishna Mittal"
$form.Size = New-Object System.Drawing.Size(650, 855)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = $cBg

$icoPath = "$PSScriptRoot\ghosttrace.ico"
if (Test-Path $icoPath) {
    try {
        $form.Icon = New-Object System.Drawing.Icon($icoPath)
    } catch {}
}

# --- Header Panel ---
$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.Location = New-Object System.Drawing.Point(0, 0)
$headerPanel.Size = New-Object System.Drawing.Size(650, 75)
$headerPanel.BackColor = $cHeaderBg
$form.Controls.Add($headerPanel)

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "GhostTrace Cloud Security & Licensing"
$lblTitle.Font = $fontTitle
$lblTitle.ForeColor = $cAccentBlue
$lblTitle.Location = New-Object System.Drawing.Point(22, 12)
$lblTitle.Size = New-Object System.Drawing.Size(430, 30)
$headerPanel.Controls.Add($lblTitle)

$lblAuthor = New-Object System.Windows.Forms.Label
$lblAuthor.Text = "Developed by Krishna Mittal • Lead Developer • All Rights Reserved"
$lblAuthor.Font = $fontSubtitle
$lblAuthor.ForeColor = $cTextMuted
$lblAuthor.Location = New-Object System.Drawing.Point(24, 44)
$lblAuthor.Size = New-Object System.Drawing.Size(430, 20)
$headerPanel.Controls.Add($lblAuthor)

$lblCloudPill = New-Object System.Windows.Forms.Label
$lblCloudPill.Text = "● Cloud Synced"
$lblCloudPill.Font = $fontBold
$lblCloudPill.ForeColor = $cGreen
$lblCloudPill.Location = New-Object System.Drawing.Point(490, 25)
$lblCloudPill.Size = New-Object System.Drawing.Size(125, 25)
$lblCloudPill.TextAlign = "MiddleRight"
$headerPanel.Controls.Add($lblCloudPill)

# ==============================================================================
# CARD 1: GATEKEEPER SHIELD (Enforced vs Public Access Mode)
# ==============================================================================
$cardGate = New-Object System.Windows.Forms.Panel
$cardGate.Location = New-Object System.Drawing.Point(22, 85)
$cardGate.Size = New-Object System.Drawing.Size(590, 76)
$cardGate.BackColor = $cCard
$form.Controls.Add($cardGate)

$lblGateTitle = New-Object System.Windows.Forms.Label
$lblGateTitle.Text = "GATEKEEPER ACCESS MODE"
$lblGateTitle.Font = $fontSection
$lblGateTitle.ForeColor = $cTextPrimary
$lblGateTitle.Location = New-Object System.Drawing.Point(14, 10)
$lblGateTitle.Size = New-Object System.Drawing.Size(350, 18)
$cardGate.Controls.Add($lblGateTitle)

$lblGateDesc = New-Object System.Windows.Forms.Label
$lblGateDesc.Font = $fontSubtitle
$lblGateDesc.ForeColor = $cTextMuted
$lblGateDesc.Location = New-Object System.Drawing.Point(14, 30)
$lblGateDesc.Size = New-Object System.Drawing.Size(370, 36)
$cardGate.Controls.Add($lblGateDesc)

$btnGateToggle = New-Object System.Windows.Forms.Button
$btnGateToggle.Location = New-Object System.Drawing.Point(395, 16)
$btnGateToggle.Size = New-Object System.Drawing.Size(180, 42)
$btnGateToggle.Font = $fontBold
$btnGateToggle.FlatStyle = "Flat"
$btnGateToggle.FlatAppearance.BorderSize = 0
$cardGate.Controls.Add($btnGateToggle)

# ==============================================================================
# CARD 2: EMERGENCY GLOBAL KILL-SWITCH
# ==============================================================================
$cardKill = New-Object System.Windows.Forms.Panel
$cardKill.Location = New-Object System.Drawing.Point(22, 171)
$cardKill.Size = New-Object System.Drawing.Size(590, 72)
$cardKill.BackColor = $cCard
$form.Controls.Add($cardKill)

$lblKillText = New-Object System.Windows.Forms.Label
$lblKillText.Text = "EMERGENCY GLOBAL KILL-SWITCH"
$lblKillText.Font = $fontSection
$lblKillText.ForeColor = $cTextPrimary
$lblKillText.Location = New-Object System.Drawing.Point(14, 10)
$lblKillText.Size = New-Object System.Drawing.Size(350, 18)
$cardKill.Controls.Add($lblKillText)

$lblKillSub = New-Object System.Windows.Forms.Label
$lblKillSub.Font = $fontSubtitle
$lblKillSub.Location = New-Object System.Drawing.Point(14, 32)
$lblKillSub.Size = New-Object System.Drawing.Size(370, 30)
$cardKill.Controls.Add($lblKillSub)

$btnKillToggle = New-Object System.Windows.Forms.Button
$btnKillToggle.Location = New-Object System.Drawing.Point(395, 15)
$btnKillToggle.Size = New-Object System.Drawing.Size(180, 42)
$btnKillToggle.Font = $fontBold
$btnKillToggle.FlatStyle = "Flat"
$btnKillToggle.FlatAppearance.BorderSize = 0
$cardKill.Controls.Add($btnKillToggle)

# ==============================================================================
# AUTHORIZED SERVERS DIRECTORY SECTION
# ==============================================================================
$lblListHeader = New-Object System.Windows.Forms.Label
$lblListHeader.Text = "AUTHORIZED SERVER DIRECTORY"
$lblListHeader.Font = $fontSection
$lblListHeader.ForeColor = $cTextPrimary
$lblListHeader.Location = New-Object System.Drawing.Point(22, 256)
$lblListHeader.Size = New-Object System.Drawing.Size(350, 20)
$form.Controls.Add($lblListHeader)

$lblCount = New-Object System.Windows.Forms.Label
$lblCount.Text = "(0 registered)"
$lblCount.Font = $fontSubtitle
$lblCount.ForeColor = $cAccentBlue
$lblCount.Location = New-Object System.Drawing.Point(482, 256)
$lblCount.Size = New-Object System.Drawing.Size(130, 20)
$lblCount.TextAlign = "MiddleRight"
$form.Controls.Add($lblCount)

# Column Header Bar
$colHeader = New-Object System.Windows.Forms.Panel
$colHeader.Location = New-Object System.Drawing.Point(22, 280)
$colHeader.Size = New-Object System.Drawing.Size(590, 24)
$colHeader.BackColor = $cCardDark
$form.Controls.Add($colHeader)

$lblCol1 = New-Object System.Windows.Forms.Label
$lblCol1.Text = "  SERVER / OWNER NAME             │  IP:PORT ADDRESS"
$lblCol1.Font = $fontMonoHeader
$lblCol1.ForeColor = $cAccentBlue
$lblCol1.Location = New-Object System.Drawing.Point(0, 4)
$lblCol1.Size = New-Object System.Drawing.Size(580, 16)
$colHeader.Controls.Add($lblCol1)

# ListBox container panel
$listPanel = New-Object System.Windows.Forms.Panel
$listPanel.Location = New-Object System.Drawing.Point(22, 304)
$listPanel.Size = New-Object System.Drawing.Size(590, 175)
$listPanel.BackColor = $cCard
$form.Controls.Add($listPanel)

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(6, 6)
$listBox.Size = New-Object System.Drawing.Size(578, 163)
$listBox.BackColor = $cCard
$listBox.ForeColor = $cTextPrimary
$listBox.Font = $fontMono
$listBox.BorderStyle = "None"
$listPanel.Controls.Add($listBox)

# ==============================================================================
# SERVER DETAILS (ADD / EDIT) CARD
# ==============================================================================
$cardInput = New-Object System.Windows.Forms.Panel
$cardInput.Location = New-Object System.Drawing.Point(22, 488)
$cardInput.Size = New-Object System.Drawing.Size(590, 118)
$cardInput.BackColor = $cCard
$form.Controls.Add($cardInput)

$lblInputTitle = New-Object System.Windows.Forms.Label
$lblInputTitle.Text = "SERVER REGISTRATION & EDITING"
$lblInputTitle.Font = $fontSectionSmall
$lblInputTitle.ForeColor = $cAccentBlue
$lblInputTitle.Location = New-Object System.Drawing.Point(14, 8)
$lblInputTitle.Size = New-Object System.Drawing.Size(300, 16)
$cardInput.Controls.Add($lblInputTitle)

# Name Input
$lblNameLabel = New-Object System.Windows.Forms.Label
$lblNameLabel.Text = "Server / Customer Name:"
$lblNameLabel.Font = $fontSubtitle
$lblNameLabel.ForeColor = $cTextMuted
$lblNameLabel.Location = New-Object System.Drawing.Point(14, 28)
$lblNameLabel.Size = New-Object System.Drawing.Size(250, 18)
$cardInput.Controls.Add($lblNameLabel)

$txtName = New-Object System.Windows.Forms.TextBox
$txtName.Location = New-Object System.Drawing.Point(14, 48)
$txtName.Size = New-Object System.Drawing.Size(250, 26)
$txtName.Font = $fontNormal
$txtName.BackColor = $cCardDark
$txtName.ForeColor = $cTextPrimary
$txtName.BorderStyle = "FixedSingle"
$cardInput.Controls.Add($txtName)

# IP Input
$lblIpLabel = New-Object System.Windows.Forms.Label
$lblIpLabel.Text = "Server Address (IP:Port):"
$lblIpLabel.Font = $fontSubtitle
$lblIpLabel.ForeColor = $cTextMuted
$lblIpLabel.Location = New-Object System.Drawing.Point(276, 28)
$lblIpLabel.Size = New-Object System.Drawing.Size(180, 18)
$cardInput.Controls.Add($lblIpLabel)

$txtIp = New-Object System.Windows.Forms.TextBox
$txtIp.Location = New-Object System.Drawing.Point(276, 48)
$txtIp.Size = New-Object System.Drawing.Size(180, 26)
$txtIp.Font = $fontMono
$txtIp.BackColor = $cCardDark
$txtIp.ForeColor = $cTextPrimary
$txtIp.BorderStyle = "FixedSingle"
$cardInput.Controls.Add($txtIp)

# Action Buttons inside Input Card
$btnAdd = New-Object System.Windows.Forms.Button
$btnAdd.Text = "➕ Add Server"
$btnAdd.Location = New-Object System.Drawing.Point(468, 45)
$btnAdd.Size = New-Object System.Drawing.Size(110, 32)
$btnAdd.Font = $fontBold
$btnAdd.BackColor = $cGreen
$btnAdd.ForeColor = [System.Drawing.Color]::White
$btnAdd.FlatStyle = "Flat"
$btnAdd.FlatAppearance.BorderSize = 0
$cardInput.Controls.Add($btnAdd)

$btnClear = New-Object System.Windows.Forms.Button
$btnClear.Text = "✖ Clear / Reset"
$btnClear.Location = New-Object System.Drawing.Point(468, 81)
$btnClear.Size = New-Object System.Drawing.Size(110, 26)
$btnClear.Font = $fontSubtitle
$btnClear.BackColor = $cSlateBtn
$btnClear.ForeColor = [System.Drawing.Color]::White
$btnClear.FlatStyle = "Flat"
$btnClear.FlatAppearance.BorderSize = 0
$cardInput.Controls.Add($btnClear)

$lblInputHint = New-Object System.Windows.Forms.Label
$lblInputHint.Text = "💡 Tip: Port is optional (defaults to :*). Add a friendly name to easily identify clients."
$lblInputHint.Font = $fontSmall
$lblInputHint.ForeColor = $cTextMuted
$lblInputHint.Location = New-Object System.Drawing.Point(14, 84)
$lblInputHint.Size = New-Object System.Drawing.Size(440, 22)
$cardInput.Controls.Add($lblInputHint)

# ==============================================================================
# ACTION TOOLBAR BUTTONS
# ==============================================================================
# Row 1: Edit, Rebind, Revoke
$btnEdit = New-Object System.Windows.Forms.Button
$btnEdit.Text = "✏️ Edit Selected"
$btnEdit.Location = New-Object System.Drawing.Point(22, 616)
$btnEdit.Size = New-Object System.Drawing.Size(186, 36)
$btnEdit.Font = $fontBold
$btnEdit.BackColor = $cPurple
$btnEdit.ForeColor = [System.Drawing.Color]::White
$btnEdit.FlatStyle = "Flat"
$btnEdit.FlatAppearance.BorderSize = 0
$form.Controls.Add($btnEdit)

$btnRebind = New-Object System.Windows.Forms.Button
$btnRebind.Text = "🔄 Rebind Host"
$btnRebind.Location = New-Object System.Drawing.Point(224, 616)
$btnRebind.Size = New-Object System.Drawing.Size(186, 36)
$btnRebind.Font = $fontBold
$btnRebind.BackColor = $cAmber
$btnRebind.ForeColor = [System.Drawing.Color]::White
$btnRebind.FlatStyle = "Flat"
$btnRebind.FlatAppearance.BorderSize = 0
$form.Controls.Add($btnRebind)

$btnRevoke = New-Object System.Windows.Forms.Button
$btnRevoke.Text = "🗑️ Revoke Selected"
$btnRevoke.Location = New-Object System.Drawing.Point(426, 616)
$btnRevoke.Size = New-Object System.Drawing.Size(186, 36)
$btnRevoke.Font = $fontBold
$btnRevoke.BackColor = $cRed
$btnRevoke.ForeColor = [System.Drawing.Color]::White
$btnRevoke.FlatStyle = "Flat"
$btnRevoke.FlatAppearance.BorderSize = 0
$form.Controls.Add($btnRevoke)

# Row 2: Copy IP & Sync Cloud
$btnCopy = New-Object System.Windows.Forms.Button
$btnCopy.Text = "📋 Copy Address (IP:Port)"
$btnCopy.Location = New-Object System.Drawing.Point(22, 660)
$btnCopy.Size = New-Object System.Drawing.Size(288, 36)
$btnCopy.Font = $fontBold
$btnCopy.BackColor = $cSlateBtn
$btnCopy.ForeColor = [System.Drawing.Color]::White
$btnCopy.FlatStyle = "Flat"
$btnCopy.FlatAppearance.BorderSize = 0
$form.Controls.Add($btnCopy)

$btnRefresh = New-Object System.Windows.Forms.Button
$btnRefresh.Text = "🔁 Sync from Cloud Gist"
$btnRefresh.Location = New-Object System.Drawing.Point(324, 660)
$btnRefresh.Size = New-Object System.Drawing.Size(288, 36)
$btnRefresh.Font = $fontBold
$btnRefresh.BackColor = $cBlueBtn
$btnRefresh.ForeColor = [System.Drawing.Color]::White
$btnRefresh.FlatStyle = "Flat"
$btnRefresh.FlatAppearance.BorderSize = 0
$form.Controls.Add($btnRefresh)

# Edit mode tracking state
$editingTargetAddress = $null

# Status Card Panel
$statusPanel = New-Object System.Windows.Forms.Panel
$statusPanel.Location = New-Object System.Drawing.Point(22, 706)
$statusPanel.Size = New-Object System.Drawing.Size(590, 56)
$statusPanel.BackColor = $cHeaderBg
$form.Controls.Add($statusPanel)

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Location = New-Object System.Drawing.Point(12, 8)
$lblStatus.Size = New-Object System.Drawing.Size(566, 38)
$lblStatus.Font = $fontSubtitle
$lblStatus.ForeColor = $cAccentBlue
$lblStatus.Text = "Ready. Connected to Krishna's Cloud Gist."
$statusPanel.Controls.Add($lblStatus)

$lblFooter = New-Object System.Windows.Forms.Label
$lblFooter.Location = New-Object System.Drawing.Point(22, 770)
$lblFooter.Size = New-Object System.Drawing.Size(590, 20)
$lblFooter.Font = $fontSmall
$lblFooter.ForeColor = $cTextMuted
$lblFooter.TextAlign = "MiddleCenter"
$lblFooter.Text = "Protected by GhostTrace Cloud Node-Locking • Krishna Mittal • All Rights Reserved"
$form.Controls.Add($lblFooter)

function Reset-InputState {
    $script:editingTargetAddress = $null
    $txtName.Clear()
    $txtIp.Clear()
    $btnAdd.Text = "➕ Add Server"
    $btnAdd.BackColor = $cGreen
    $lblInputTitle.Text = "SERVER REGISTRATION & EDITING"
    $lblInputTitle.ForeColor = $cAccentBlue
}

function Refresh-UI {
    $data = Read-LicenseData
    $listBox.Items.Clear()
    $servers = if ($data.allowed_servers) { $data.allowed_servers } else { $data.allowed_ips }
    
    if ($servers) {
        foreach ($srv in $servers) {
            $label = if ($data.server_labels.PSObject.Properties[$srv]) { $data.server_labels.PSObject.Properties[$srv].Value } else { "Unnamed Server" }
            $entry = New-ServerEntry -address $srv -name $label
            $listBox.Items.Add($entry) | Out-Null
        }
        $lblCount.Text = "($($servers.Count) registered)"
    } else {
        $lblCount.Text = "(0 registered)"
    }

    # 1. Gatekeeper Mode State
    $enforce = if ($null -ne $data.enforce_ip_lock) { $data.enforce_ip_lock } else { $true }
    if ($enforce) {
        $lblGateTitle.Text = "GATEKEEPER: ENFORCED (STRICT)"
        $lblGateTitle.ForeColor = $cAmber
        $lblGateDesc.Text = "Strict Whitelist Active: Only authorized IP:Port addresses are permitted to run GhostTrace."
        $btnGateToggle.Text = "🌐 Unlock for Everyone"
        $btnGateToggle.BackColor = $cGreen
        $btnGateToggle.ForeColor = [System.Drawing.Color]::White
    } else {
        $lblGateTitle.Text = "GATEKEEPER: PUBLIC ACCESS (OPEN)"
        $lblGateTitle.ForeColor = $cGreen
        $lblGateDesc.Text = "Public Access Active: Anyone in the world can run GhostTrace freely without IP checks."
        $btnGateToggle.Text = "🛡️ Enforce Whitelist"
        $btnGateToggle.BackColor = $cPurple
        $btnGateToggle.ForeColor = [System.Drawing.Color]::White
    }

    # 2. Emergency Kill-Switch State
    if ($data.kill_switch) {
        $lblKillSub.Text = "ALL SERVERS ARE BLOCKED (Emergency Shutdown Active)"
        $lblKillSub.ForeColor = $cRed
        $btnKillToggle.Text = "Deactivate Killswitch"
        $btnKillToggle.BackColor = $cGreen
        $btnKillToggle.ForeColor = [System.Drawing.Color]::White
    } else {
        $lblKillSub.Text = "Normal Operation (No Global Shutdown Active)"
        $lblKillSub.ForeColor = $cGreen
        $btnKillToggle.Text = "ACTIVATE KILLSWITCH"
        $btnKillToggle.BackColor = $cRed
        $btnKillToggle.ForeColor = [System.Drawing.Color]::White
    }
}

# --- Event Handlers ---

# List selection auto-populates fields
$listBox.Add_SelectedIndexChanged({
    $selected = $listBox.SelectedItem
    if ($selected) {
        $txtName.Text = $selected.Name
        $txtIp.Text = $selected.Address
        $lblStatus.Text = "Selected: '$($selected.Name)' ($($selected.Address))"
    }
})

# Clear Button Click
$btnClear.Add_Click({
    Reset-InputState
    $listBox.ClearSelected()
    $lblStatus.Text = "Inputs cleared. Ready to add a new server."
})

# Gatekeeper Toggle Click
$btnGateToggle.Add_Click({
    $data = Read-LicenseData
    $current = if ($null -ne $data.enforce_ip_lock) { $data.enforce_ip_lock } else { $true }
    $data.enforce_ip_lock = -not $current
    $newMode = if ($data.enforce_ip_lock) { "Strict IP Whitelist" } else { "Global Public Access" }
    $lblStatus.Text = "Syncing Gatekeeper Access Mode ($newMode) to Cloud..."
    $form.Update()
    Save-And-Push $data "Toggle Gatekeeper mode: $newMode"
    Refresh-UI
    $lblStatus.Text = "Access Mode updated: $newMode is now LIVE in Cloud!"
})

# Kill-Switch Toggle Click
$btnKillToggle.Add_Click({
    $data = Read-LicenseData
    $data.kill_switch = -not $data.kill_switch
    $lblStatus.Text = "Updating Global Emergency Kill-Switch..."
    $form.Update()
    Save-And-Push $data "Toggle Kill-Switch via GUI"
    Refresh-UI
    $lblStatus.Text = "Kill-Switch status updated successfully in Cloud!"
})

# Add / Save Changes Button Click
$btnAdd.Add_Click({
    $ipRaw = $txtIp.Text.Trim()
    if (-not $ipRaw) {
        [System.Windows.Forms.MessageBox]::Show("Please enter a valid Server Address (IP:Port or IP).", "Missing Address")
        $txtIp.Focus()
        return
    }
    $newEntry = Normalize-Addr $ipRaw
    $serverName = if ($txtName.Text.Trim()) { $txtName.Text.Trim() } else { "Authorized Server" }

    $data = Read-LicenseData
    $servers = [System.Collections.ArrayList]@($data.allowed_servers)

    if ($script:editingTargetAddress) {
        # Saving an edit
        $oldAddr = $script:editingTargetAddress
        if ($servers -contains $oldAddr) {
            $servers.Remove($oldAddr)
        }
        if (-not ($servers -contains $newEntry)) {
            $servers.Add($newEntry) | Out-Null
        }
        $data.allowed_servers = $servers

        # Update label mapping
        if ($data.server_labels.PSObject.Properties[$oldAddr]) {
            $data.server_labels.PSObject.Properties.Remove($oldAddr)
        }
        $data.server_labels | Add-Member -MemberType NoteProperty -Name $newEntry -Value $serverName -Force

        $lblStatus.Text = "Saving edit '$serverName' ($newEntry) to Cloud..."
        $form.Update()
        Save-And-Push $data "Edit server $oldAddr -> $newEntry [$serverName] via GUI"
        Reset-InputState
        Refresh-UI
        $lblStatus.Text = "Successfully saved changes for '$serverName' ($newEntry)!"
    } else {
        # Adding a new server
        if ($servers -contains $newEntry) {
            [System.Windows.Forms.MessageBox]::Show("Server '$newEntry' is already authorized.", "Notice")
            return
        }
        $servers.Add($newEntry) | Out-Null
        $data.allowed_servers = $servers
        $data.server_labels | Add-Member -MemberType NoteProperty -Name $newEntry -Value $serverName -Force

        $lblStatus.Text = "Authorizing '$serverName' ($newEntry) in Cloud..."
        $form.Update()
        Save-And-Push $data "Authorize $newEntry [$serverName] via GUI"
        Reset-InputState
        Refresh-UI
        $lblStatus.Text = "Server '$serverName' ($newEntry) successfully authorized!"
    }
})

# Edit Selected Button Click
$btnEdit.Add_Click({
    $selected = $listBox.SelectedItem
    if (-not $selected) {
        [System.Windows.Forms.MessageBox]::Show("Please select an authorized server from the directory list to edit.", "Select a Server")
        return
    }
    $script:editingTargetAddress = $selected.Address
    $txtName.Text = $selected.Name
    $txtIp.Text = $selected.Address
    $btnAdd.Text = "💾 Save Edit"
    $btnAdd.BackColor = $cPurple
    $lblInputTitle.Text = "EDITING: $($selected.Name) ($($selected.Address))"
    $lblInputTitle.ForeColor = $cPurple
    $txtName.Focus()
    $lblStatus.Text = "Editing '$($selected.Name)'. Modify Name or Address and click 'Save Edit'."
})

# Rebind Host Button Click
$btnRebind.Add_Click({
    $selected = $listBox.SelectedItem
    if (-not $selected) {
        [System.Windows.Forms.MessageBox]::Show("Please select an existing server from the directory to rebind.", "Select a Server")
        return
    }
    $ipRaw = $txtIp.Text.Trim()
    if (-not $ipRaw) {
        [System.Windows.Forms.MessageBox]::Show("Please enter the customer's new IP:Port in the Address box.", "Enter New Address")
        $txtIp.Focus()
        return
    }
    $newEntry = Normalize-Addr $ipRaw
    if ($newEntry -eq $selected.Address) {
        [System.Windows.Forms.MessageBox]::Show("The address entered is identical to the current address.", "Notice")
        return
    }

    $data = Read-LicenseData
    $servers = [System.Collections.ArrayList]@($data.allowed_servers)
    $servers.Remove($selected.Address)
    if (-not ($servers -contains $newEntry)) {
        $servers.Add($newEntry) | Out-Null
    }
    $data.allowed_servers = $servers

    # Transfer label
    $serverName = if ($txtName.Text.Trim()) { $txtName.Text.Trim() } else { $selected.Name }
    if ($data.server_labels.PSObject.Properties[$selected.Address]) {
        $data.server_labels.PSObject.Properties.Remove($selected.Address)
    }
    $data.server_labels | Add-Member -MemberType NoteProperty -Name $newEntry -Value $serverName -Force

    $lblStatus.Text = "Rebinding '$serverName' from $($selected.Address) to $newEntry..."
    $form.Update()
    Save-And-Push $data "Rebind $serverName from $($selected.Address) to $newEntry via GUI"
    Reset-InputState
    Refresh-UI
    $lblStatus.Text = "Successfully rebound host for '$serverName' to $newEntry!"
})

# Revoke Selected Button Click
$btnRevoke.Add_Click({
    $selected = $listBox.SelectedItem
    if (-not $selected) {
        [System.Windows.Forms.MessageBox]::Show("Please select an authorized server from the directory to revoke.", "Select a Server")
        return
    }
    $msg = "Are you sure you want to revoke authorization for:`n`nName: $($selected.Name)`nAddress: $($selected.Address)`n`nThis server will be immediately blocked from running GhostTrace."
    $confirm = [System.Windows.Forms.MessageBox]::Show($msg, "Confirm Revoke", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)
    if ($confirm -ne [System.Windows.Forms.DialogResult]::Yes) { return }

    $data = Read-LicenseData
    $servers = [System.Collections.ArrayList]@($data.allowed_servers)
    $servers.Remove($selected.Address)
    $data.allowed_servers = $servers

    if ($data.server_labels.PSObject.Properties[$selected.Address]) {
        $data.server_labels.PSObject.Properties.Remove($selected.Address)
    }

    $lblStatus.Text = "Revoking '$($selected.Name)' from Cloud..."
    $form.Update()
    Save-And-Push $data "Revoke $($selected.Address) [$($selected.Name)] via GUI"
    Reset-InputState
    Refresh-UI
    $lblStatus.Text = "Server '$($selected.Name)' ($($selected.Address)) revoked successfully!"
})

# Copy Address Button Click
$btnCopy.Add_Click({
    $selected = $listBox.SelectedItem
    $addr = if ($selected) { $selected.Address } elseif ($txtIp.Text.Trim()) { $txtIp.Text.Trim() } else { $null }
    if (-not $addr) {
        [System.Windows.Forms.MessageBox]::Show("Please select a server or enter an address to copy.", "Notice")
        return
    }
    [System.Windows.Forms.Clipboard]::SetText($addr)
    $lblStatus.Text = "Copied address '$addr' to clipboard!"
})

# Refresh Button Click
$btnRefresh.Add_Click({
    $lblStatus.Text = "Pulling latest data from Cloud Gist..."
    $form.Update()
    Push-Location $GistDir
    try { git pull origin main | Out-Null } finally { Pop-Location }
    Refresh-UI
    $lblStatus.Text = "Synced cleanly with Cloud Gist."
})

Refresh-UI
$form.ShowDialog() | Out-Null
