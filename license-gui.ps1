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
    return Get-Content $JsonPath -Raw | ConvertFrom-Json
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

# --- Visual Theme Palette ---
$cBg = [System.Drawing.Color]::FromArgb(15, 23, 42)          # Slate 900
$cCard = [System.Drawing.Color]::FromArgb(30, 41, 59)        # Slate 800
$cCardBorder = [System.Drawing.Color]::FromArgb(51, 65, 85)  # Slate 700
$cInput = [System.Drawing.Color]::FromArgb(30, 41, 59)       # Slate 800
$cTextPrimary = [System.Drawing.Color]::FromArgb(248, 250, 252)
$cTextMuted = [System.Drawing.Color]::FromArgb(148, 163, 184)
$cAccentBlue = [System.Drawing.Color]::FromArgb(56, 189, 248) # Sky 400
$cGreen = [System.Drawing.Color]::FromArgb(16, 185, 129)     # Emerald 500
$cGreenDark = [System.Drawing.Color]::FromArgb(5, 150, 105)
$cRed = [System.Drawing.Color]::FromArgb(239, 68, 68)        # Rose 500
$cAmber = [System.Drawing.Color]::FromArgb(245, 158, 11)     # Amber 500
$cPurple = [System.Drawing.Color]::FromArgb(139, 92, 246)    # Violet 500

# --- Fonts ---
$fontTitle = New-Object System.Drawing.Font("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
$fontSubtitle = New-Object System.Drawing.Font("Segoe UI", 9)
$fontSection = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$fontBold = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
$fontNormal = New-Object System.Drawing.Font("Segoe UI", 9.5)
$fontMono = New-Object System.Drawing.Font("Consolas", 10.5)

# --- Main Window Form ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "GhostTrace Cloud License & Access Center - Krishna Mittal"
$form.Size = New-Object System.Drawing.Size(620, 800)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = $cBg
$icoFile = "$PSScriptRoot\ghosttrace.ico"
if (Test-Path $icoFile) {
    $form.Icon = New-Object System.Drawing.Icon($icoFile)
}

# --- Header Panel ---
$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.Location = New-Object System.Drawing.Point(0, 0)
$headerPanel.Size = New-Object System.Drawing.Size(620, 75)
$headerPanel.BackColor = [System.Drawing.Color]::FromArgb(10, 15, 30)
$form.Controls.Add($headerPanel)

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "GhostTrace Cloud Security & Licensing"
$lblTitle.Font = $fontTitle
$lblTitle.ForeColor = $cAccentBlue
$lblTitle.Location = New-Object System.Drawing.Point(22, 12)
$lblTitle.Size = New-Object System.Drawing.Size(420, 30)
$headerPanel.Controls.Add($lblTitle)

$lblAuthor = New-Object System.Windows.Forms.Label
$lblAuthor.Text = "Developed by Krishna Mittal • Lead Developer • All Rights Reserved"
$lblAuthor.Font = $fontSubtitle
$lblAuthor.ForeColor = $cTextMuted
$lblAuthor.Location = New-Object System.Drawing.Point(24, 44)
$lblAuthor.Size = New-Object System.Drawing.Size(420, 20)
$headerPanel.Controls.Add($lblAuthor)

$lblCloudPill = New-Object System.Windows.Forms.Label
$lblCloudPill.Text = "● Cloud Synced"
$lblCloudPill.Font = $fontBold
$lblCloudPill.ForeColor = $cGreen
$lblCloudPill.Location = New-Object System.Drawing.Point(460, 25)
$lblCloudPill.Size = New-Object System.Drawing.Size(125, 25)
$lblCloudPill.TextAlign = "MiddleRight"
$headerPanel.Controls.Add($lblCloudPill)

# ==============================================================================
# CARD 1: GATEKEEPER SHIELD (Enforced vs Public Access Mode)
# ==============================================================================
$cardGate = New-Object System.Windows.Forms.Panel
$cardGate.Location = New-Object System.Drawing.Point(22, 90)
$cardGate.Size = New-Object System.Drawing.Size(560, 82)
$cardGate.BackColor = $cCard
$form.Controls.Add($cardGate)

$lblGateTitle = New-Object System.Windows.Forms.Label
$lblGateTitle.Text = "GATEKEEPER ACCESS MODE"
$lblGateTitle.Font = $fontSection
$lblGateTitle.ForeColor = $cTextPrimary
$lblGateTitle.Location = New-Object System.Drawing.Point(16, 12)
$lblGateTitle.Size = New-Object System.Drawing.Size(320, 20)
$cardGate.Controls.Add($lblGateTitle)

$lblGateDesc = New-Object System.Windows.Forms.Label
$lblGateDesc.Font = $fontSubtitle
$lblGateDesc.ForeColor = $cTextMuted
$lblGateDesc.Location = New-Object System.Drawing.Point(16, 34)
$lblGateDesc.Size = New-Object System.Drawing.Size(340, 40)
$cardGate.Controls.Add($lblGateDesc)

$btnGateToggle = New-Object System.Windows.Forms.Button
$btnGateToggle.Location = New-Object System.Drawing.Point(365, 18)
$btnGateToggle.Size = New-Object System.Drawing.Size(180, 44)
$btnGateToggle.Font = $fontBold
$btnGateToggle.FlatStyle = "Flat"
$btnGateToggle.FlatAppearance.BorderSize = 0
$cardGate.Controls.Add($btnGateToggle)

# ==============================================================================
# CARD 2: EMERGENCY GLOBAL KILL-SWITCH
# ==============================================================================
$cardKill = New-Object System.Windows.Forms.Panel
$cardKill.Location = New-Object System.Drawing.Point(22, 182)
$cardKill.Size = New-Object System.Drawing.Size(560, 68)
$cardKill.BackColor = $cCard
$form.Controls.Add($cardKill)

$lblKillText = New-Object System.Windows.Forms.Label
$lblKillText.Text = "EMERGENCY GLOBAL KILL-SWITCH"
$lblKillText.Font = $fontSection
$lblKillText.ForeColor = $cTextPrimary
$lblKillText.Location = New-Object System.Drawing.Point(16, 12)
$lblKillText.Size = New-Object System.Drawing.Size(320, 20)
$cardKill.Controls.Add($lblKillText)

$lblKillSub = New-Object System.Windows.Forms.Label
$lblKillSub.Font = $fontSubtitle
$lblKillSub.Location = New-Object System.Drawing.Point(16, 35)
$lblKillSub.Size = New-Object System.Drawing.Size(340, 25)
$cardKill.Controls.Add($lblKillSub)

$btnKillToggle = New-Object System.Windows.Forms.Button
$btnKillToggle.Location = New-Object System.Drawing.Point(365, 14)
$btnKillToggle.Size = New-Object System.Drawing.Size(180, 40)
$btnKillToggle.Font = $fontBold
$btnKillToggle.FlatStyle = "Flat"
$btnKillToggle.FlatAppearance.BorderSize = 0
$cardKill.Controls.Add($btnKillToggle)

# ==============================================================================
# AUTHORIZED SERVERS SECTION
# ==============================================================================
$lblListHeader = New-Object System.Windows.Forms.Label
$lblListHeader.Text = "AUTHORIZED SERVER BINDINGS"
$lblListHeader.Font = $fontSection
$lblListHeader.ForeColor = $cTextPrimary
$lblListHeader.Location = New-Object System.Drawing.Point(22, 262)
$lblListHeader.Size = New-Object System.Drawing.Size(350, 22)
$form.Controls.Add($lblListHeader)

$lblCount = New-Object System.Windows.Forms.Label
$lblCount.Text = "(0 active)"
$lblCount.Font = $fontSubtitle
$lblCount.ForeColor = $cAccentBlue
$lblCount.Location = New-Object System.Drawing.Point(450, 262)
$lblCount.Size = New-Object System.Drawing.Size(130, 22)
$lblCount.TextAlign = "MiddleRight"
$form.Controls.Add($lblCount)

# ListBox container panel
$listPanel = New-Object System.Windows.Forms.Panel
$listPanel.Location = New-Object System.Drawing.Point(22, 288)
$listPanel.Size = New-Object System.Drawing.Size(560, 190)
$listPanel.BackColor = $cCard
$form.Controls.Add($listPanel)

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(8, 8)
$listBox.Size = New-Object System.Drawing.Size(544, 172)
$listBox.BackColor = $cCard
$listBox.ForeColor = $cTextPrimary
$listBox.Font = $fontMono
$listBox.BorderStyle = "None"
$listPanel.Controls.Add($listBox)

# ==============================================================================
# INPUT & EDITING TOOLBAR
# ==============================================================================
$txtIp = New-Object System.Windows.Forms.TextBox
$txtIp.Location = New-Object System.Drawing.Point(22, 490)
$txtIp.Size = New-Object System.Drawing.Size(380, 32)
$txtIp.Font = $fontMono
$txtIp.BackColor = $cCard
$txtIp.ForeColor = $cTextPrimary
$txtIp.BorderStyle = "FixedSingle"
$form.Controls.Add($txtIp)

$btnAdd = New-Object System.Windows.Forms.Button
$btnAdd.Text = "+ Add Server"
$btnAdd.Location = New-Object System.Drawing.Point(412, 488)
$btnAdd.Size = New-Object System.Drawing.Size(170, 32)
$btnAdd.Font = $fontBold
$btnAdd.BackColor = $cGreen
$btnAdd.ForeColor = [System.Drawing.Color]::White
$btnAdd.FlatStyle = "Flat"
$btnAdd.FlatAppearance.BorderSize = 0
$form.Controls.Add($btnAdd)

# Secondary Buttons Row 1: Edit & Rebind
$btnEdit = New-Object System.Windows.Forms.Button
$btnEdit.Text = "✏️ Edit Selected"
$btnEdit.Location = New-Object System.Drawing.Point(22, 532)
$btnEdit.Size = New-Object System.Drawing.Size(175, 36)
$btnEdit.Font = $fontBold
$btnEdit.BackColor = $cPurple
$btnEdit.ForeColor = [System.Drawing.Color]::White
$btnEdit.FlatStyle = "Flat"
$btnEdit.FlatAppearance.BorderSize = 0
$form.Controls.Add($btnEdit)

$btnRebind = New-Object System.Windows.Forms.Button
$btnRebind.Text = "🔄 Rebind Host"
$btnRebind.Location = New-Object System.Drawing.Point(207, 532)
$btnRebind.Size = New-Object System.Drawing.Size(190, 36)
$btnRebind.Font = $fontBold
$btnRebind.BackColor = $cAmber
$btnRebind.ForeColor = [System.Drawing.Color]::White
$btnRebind.FlatStyle = "Flat"
$btnRebind.FlatAppearance.BorderSize = 0
$form.Controls.Add($btnRebind)

$btnRevoke = New-Object System.Windows.Forms.Button
$btnRevoke.Text = "🗑️ Revoke Selected"
$btnRevoke.Location = New-Object System.Drawing.Point(407, 532)
$btnRevoke.Size = New-Object System.Drawing.Size(175, 36)
$btnRevoke.Font = $fontBold
$btnRevoke.BackColor = $cRed
$btnRevoke.ForeColor = [System.Drawing.Color]::White
$btnRevoke.FlatStyle = "Flat"
$btnRevoke.FlatAppearance.BorderSize = 0
$form.Controls.Add($btnRevoke)

# Secondary Buttons Row 2: Copy & Refresh
$btnCopy = New-Object System.Windows.Forms.Button
$btnCopy.Text = "📋 Copy Address"
$btnCopy.Location = New-Object System.Drawing.Point(22, 578)
$btnCopy.Size = New-Object System.Drawing.Size(265, 36)
$btnCopy.Font = $fontBold
$btnCopy.BackColor = [System.Drawing.Color]::FromArgb(71, 85, 105) # Slate 600
$btnCopy.ForeColor = [System.Drawing.Color]::White
$btnCopy.FlatStyle = "Flat"
$btnCopy.FlatAppearance.BorderSize = 0
$form.Controls.Add($btnCopy)

$btnRefresh = New-Object System.Windows.Forms.Button
$btnRefresh.Text = "🔁 Sync from Cloud"
$btnRefresh.Location = New-Object System.Drawing.Point(297, 578)
$btnRefresh.Size = New-Object System.Drawing.Size(285, 36)
$btnRefresh.Font = $fontBold
$btnRefresh.BackColor = [System.Drawing.Color]::FromArgb(37, 99, 235) # Blue 600
$btnRefresh.ForeColor = [System.Drawing.Color]::White
$btnRefresh.FlatStyle = "Flat"
$btnRefresh.FlatAppearance.BorderSize = 0
$form.Controls.Add($btnRefresh)

# Edit mode tracking state
$editingTarget = $null

# Status Card Panel
$statusPanel = New-Object System.Windows.Forms.Panel
$statusPanel.Location = New-Object System.Drawing.Point(22, 626)
$statusPanel.Size = New-Object System.Drawing.Size(560, 60)
$statusPanel.BackColor = [System.Drawing.Color]::FromArgb(10, 15, 30)
$form.Controls.Add($statusPanel)

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Location = New-Object System.Drawing.Point(12, 10)
$lblStatus.Size = New-Object System.Drawing.Size(536, 40)
$lblStatus.Font = $fontSubtitle
$lblStatus.ForeColor = $cAccentBlue
$lblStatus.Text = "Ready. Connected to Krishna's Cloud Gist."
$statusPanel.Controls.Add($lblStatus)

function Refresh-UI {
    $data = Read-LicenseData
    $listBox.Items.Clear()
    $servers = if ($data.allowed_servers) { $data.allowed_servers } else { $data.allowed_ips }
    foreach ($srv in $servers) {
        $listBox.Items.Add($srv) | Out-Null
    }
    $lblCount.Text = "($($servers.Count) authorized)"

    # 1. Gatekeeper Mode State
    $enforce = if ($null -ne $data.enforce_ip_lock) { $data.enforce_ip_lock } else { $true }
    if ($enforce) {
        $lblGateTitle.Text = "GATEKEEPER: ENFORCED (PRIVATE)"
        $lblGateTitle.ForeColor = $cAmber
        $lblGateDesc.Text = "Strict Mode Active: Only authorized IP:Port addresses are permitted to run GhostTrace."
        $btnGateToggle.Text = "🌐 Unlock for Everyone"
        $btnGateToggle.BackColor = $cGreen
        $btnGateToggle.ForeColor = [System.Drawing.Color]::White
    } else {
        $lblGateTitle.Text = "GATEKEEPER: PUBLIC ACCESS (FREE)"
        $lblGateTitle.ForeColor = $cGreen
        $lblGateDesc.Text = "Public Mode Active: Anyone in the world can run GhostTrace freely without IP checks."
        $btnGateToggle.Text = "🛡️ Enforce Whitelist"
        $btnGateToggle.BackColor = $cPurple
        $btnGateToggle.ForeColor = [System.Drawing.Color]::White
    }

    # 2. Emergency Kill-Switch State
    if ($data.kill_switch) {
        $lblKillSub.Text = "ALL SERVERS ARE BLOCKED (Emergency Shutdown)"
        $lblKillSub.ForeColor = $cRed
        $btnKillToggle.Text = "Deactivate Killswitch"
        $btnKillToggle.BackColor = $cGreen
        $btnKillToggle.ForeColor = [System.Drawing.Color]::White
    } else {
        $lblKillSub.Text = "Normal Operation (No Global Block Active)"
        $lblKillSub.ForeColor = $cGreen
        $btnKillToggle.Text = "ACTIVATE KILLSWITCH"
        $btnKillToggle.BackColor = $cRed
        $btnKillToggle.ForeColor = [System.Drawing.Color]::White
    }
}

# --- Event Handlers ---

# Gatekeeper Toggle Click
$btnGateToggle.Add_Click({
    $data = Read-LicenseData
    $current = if ($null -ne $data.enforce_ip_lock) { $data.enforce_ip_lock } else { $true }
    $data.enforce_ip_lock = -not $current
    $newMode = if ($data.enforce_ip_lock) { "Strict IP Whitelist" } else { "Global Public Access" }
    $lblStatus.Text = "Syncing Gatekeeper Access Mode ($newMode) to Cloud..."
    $form.Update()
    Save-And-Push $data "Toggle GhostTrace Gatekeeper mode: $newMode"
    Refresh-UI
    $lblStatus.Text = "Access Mode updated: $newMode is now ACTIVE in Cloud!"
})

# Kill-Switch Toggle Click
$btnKillToggle.Add_Click({
    $data = Read-LicenseData
    $data.kill_switch = -not $data.kill_switch
    $lblStatus.Text = "Updating Global Kill-Switch..."
    $form.Update()
    Save-And-Push $data "Toggle GhostTrace Kill-Switch via GUI"
    Refresh-UI
    $lblStatus.Text = "Kill-Switch status updated successfully in Cloud!"
})

# Add / Save Edit Button Click
$btnAdd.Add_Click({
    $inputRaw = $txtIp.Text.Trim()
    if (-not $inputRaw) { return }
    $newEntry = Normalize-Addr $inputRaw

    $data = Read-LicenseData
    $servers = [System.Collections.ArrayList]@($data.allowed_servers)

    if ($editingTarget) {
        # Saving an edit on an existing entry
        if ($servers -contains $editingTarget) {
            $servers.Remove($editingTarget)
        }
        if (-not ($servers -contains $newEntry)) {
            $servers.Add($newEntry) | Out-Null
        }
        $data.allowed_servers = $servers
        $lblStatus.Text = "Saving edit '$editingTarget' -> '$newEntry' in Cloud..."
        $form.Update()
        Save-And-Push $data "Edit GhostTrace server from $editingTarget to $newEntry via GUI"
        $script:editingTarget = $null
        $btnAdd.Text = "+ Add Server"
        $btnAdd.BackColor = $cGreen
        $txtIp.Clear()
        Refresh-UI
        $lblStatus.Text = "Successfully updated server to '$newEntry'!"
    } else {
        # Adding a fresh new server
        if ($servers -contains $newEntry) {
            [System.Windows.Forms.MessageBox]::Show("Server '$newEntry' is already authorized.", "Notice")
            return
        }
        $servers.Add($newEntry) | Out-Null
        $data.allowed_servers = $servers
        $lblStatus.Text = "Authorizing '$newEntry' in Cloud..."
        $form.Update()
        Save-And-Push $data "Authorize GhostTrace $newEntry via GUI"
        $txtIp.Clear()
        Refresh-UI
        $lblStatus.Text = "Server '$newEntry' successfully authorized!"
    }
})

# Edit Selected Button Click
$btnEdit.Add_Click({
    $selected = $listBox.SelectedItem
    if (-not $selected) {
        [System.Windows.Forms.MessageBox]::Show("Please select an authorized server from the list to edit.", "Select a Server")
        return
    }
    $script:editingTarget = $selected
    $txtIp.Text = $selected
    $btnAdd.Text = "💾 Save Edit"
    $btnAdd.BackColor = $cPurple
    $txtIp.Focus()
    $lblStatus.Text = "Editing '$selected'. Modify the IP/Port above and click 'Save Edit'."
})

# Rebind Host Button Click
$btnRebind.Add_Click({
    $selected = $listBox.SelectedItem
    $inputRaw = $txtIp.Text.Trim()
    if (-not $selected) {
        [System.Windows.Forms.MessageBox]::Show("Please select an existing server from the list to rebind.", "Select a Server")
        return
    }
    if (-not $inputRaw) {
        [System.Windows.Forms.MessageBox]::Show("Please type the customer's new IP:Port in the input box.", "Enter New Address")
        return
    }
    $newEntry = Normalize-Addr $inputRaw
    $data = Read-LicenseData
    $servers = [System.Collections.ArrayList]@($data.allowed_servers)
    $servers.Remove($selected)
    $servers.Add($newEntry) | Out-Null
    $data.allowed_servers = $servers
    $lblStatus.Text = "Rebinding '$selected' to '$newEntry'..."
    $form.Update()
    Save-And-Push $data "Rebind GhostTrace $selected to $newEntry via GUI"
    $txtIp.Clear()
    Refresh-UI
    $lblStatus.Text = "Successfully rebound host from '$selected' to '$newEntry'!"
})

# Revoke Selected Button Click
$btnRevoke.Add_Click({
    $selected = $listBox.SelectedItem
    if (-not $selected) {
        [System.Windows.Forms.MessageBox]::Show("Please select an authorized server to revoke.", "Select a Server")
        return
    }
    $confirm = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to revoke authorization for '$selected'?", "Confirm Revoke", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)
    if ($confirm -ne [System.Windows.Forms.DialogResult]::Yes) { return }

    $data = Read-LicenseData
    $servers = [System.Collections.ArrayList]@($data.allowed_servers)
    $servers.Remove($selected)
    $data.allowed_servers = $servers
    $lblStatus.Text = "Revoking '$selected' from Cloud..."
    $form.Update()
    Save-And-Push $data "Revoke GhostTrace $selected via GUI"
    Refresh-UI
    $lblStatus.Text = "Server '$selected' revoked successfully!"
})

# Copy Address Button Click
$btnCopy.Add_Click({
    $selected = $listBox.SelectedItem
    if (-not $selected) {
        [System.Windows.Forms.MessageBox]::Show("Select an address from the list to copy.", "Notice")
        return
    }
    [System.Windows.Forms.Clipboard]::SetText($selected)
    $lblStatus.Text = "Copied '$selected' to clipboard!"
})

# Refresh Button Click
$btnRefresh.Add_Click({
    $lblStatus.Text = "Pulling latest data from Cloud Gist..."
    $form.Update()
    Push-Location $GistDir
    try { git pull origin main | Out-Null } finally { Pop-Location }
    Refresh-UI
    $lblStatus.Text = "Synced cleanly with Cloud."
})

Refresh-UI
$form.ShowDialog() | Out-Null
