# GhostTrace 🛡️ (Flagship Network Anti-Cheat & Courtroom Suite)

**GhostTrace** is an enterprise-grade **100% server-side** client mod, launcher, and payload inspector anti-cheat designed for Minecraft servers across versions **1.20 through 1.21+ and future 26.x releases**.

It combines **DonutSMP-style silent translation probing (MC-265322)** with the **Hypixel Disallowed Modifications Standard** and a **Case Decider Courtroom UI**, allowing staff to review detected client mods and make deliberate rulings without automatic false-positive kicks or movement lag.

---

## ⚡ Flagship Features (v1.0.5)

1. **🛡️ 4-Stage Hypixel Disallowed Modifications Audit Pipeline**:
   * Organizes silent translation probes strictly matching Hypixel's official Disallowed Modification policy:
     * **Stage 1 (Visual Intel & X-Ray)**: Freecam (`key.freecam.toggle`, `text.freecam.title`), Advanced X-Ray (`key.xray.toggle`, `xray.title`), Cave Finders.
     * **Stage 2 (Radars & Minimaps)**: Xaero's Minimap (`gui.xaero_minimap`, `xaerominimap.title`), Xaero's WorldMap (`gui.xaeroworldmap.title`), JourneyMap entity radar (`jm.common.title`).
     * **Stage 3 (Combat Cheats & Hacked Clients)**: Meteor Client (`key.meteor-client.open-gui`, `title.meteor-client.modules`), Wurst (`key.wurst.open`), Aristois (`aristois.gui.title`), LiquidBounce, Vape.
     * **Stage 4 (Macros & Automation)**: Baritone (`baritone.title`), AutoClicker (`key.autoclicker.toggle`), SeedCrackerX (`seedcrackerx.gui`), Litematica Printer (`litematica.gui.button.config_gui`).
   * **Live Action Bar Progress**: Broadcasts real-time audit progress `[HYPIXEL AUDIT X/4]` to online staff.
   * **Persistent Storage**: All Hypixel audit breakdowns are saved directly into `history.yml` under each player's session archive.

2. **🛡️ Hypixel Compliance Matrix GUI Card**:
   * Embedded directly in `PlayerInspectGui` and `CaseDeciderGui` (Slot 28).
   * Displays the 4-category breakdown with green/red status pills (`✔ PASSED` vs `✖ FLAGGED [ModName]`) and exact rule summaries.

3. **Case Decider Courtroom UI (`/gt cases` & `/gt decide <player>`)**:
   * **Zero Automatic Disconnects**: Discovered mods create formal case dossiers instead of kicking players without permission.
   * Interactive Courtroom Actions:
     * **[✔ APPROVE / DISMISS]**: Clears case for this session.
     * **[⚠ WARN PLAYER]**: Delivers a private security warning with the list of detected mods.
     * **[✕ KICK]**: Ejects player with an official staff ruling reason.
     * **[⛔ BAN]**: Permanent server ban with recorded incident ID (Shift-Click confirmation).
     * **[🔍 RUN ACTIVE AUDIT]**: Launches the 4-stage Hypixel audit pipeline in real time.

4. **🕒 Multi-Timezone System (Primary Standard: IST)**:
   * Native multi-timezone engine with **IST (`Asia/Kolkata`, UTC+05:30)** as primary standard.
   * Interactive GUI switcher supporting **IST**, **UTC**, **EST**, **CST**, **PST**, **GMT**, **CET**, **JST**, and **AEST**.

5. **Multi-Java Architecture (Java 17 & Java 21)**:
   * Compiled and optimized separately for both **Java 17** (Paper 1.20 - 1.20.4) and **Java 21** (Paper 1.20.5+ through 26.x).

---

## 🌐 Server Platform & Version Compatibility

| Platform | Support | Notes |
| :--- | :---: | :--- |
| **Paper / Purpur** | **Native** | Optimal performance; utilizes Paper client brand detection and Adventure components. |
| **Spigot / CraftBukkit** | **Native** | Fully compatible; uses fallback channel brand listener. |
| **Fabric** | **Native via Hybrid** | Compatible on Fabric servers running **Arclight (Fabric)** or **Cardboard**. |
| **Forge / NeoForge** | **Native via Hybrid** | Compatible on Forge/NeoForge servers running **Mohist**, **Arclight**, or **Magma**. |
| **Versions** | **1.20 → 26.x** | Built strictly without volatile NMS imports to guarantee upward and downward version compatibility. |

---

## 🛠️ Commands & Permissions

| Command | Description | Permission |
| :--- | :--- | :--- |
| `/gt` or `/gt gui` | Opens the modern flagship control dashboard. | `ghosttrace.gui` |
| `/gt cases` | Opens the interactive Courtroom & Case Decider queue. | `ghosttrace.admin` |
| `/gt decide [player]` | Opens Case Decision dossier for suspect with evidence cards. | `ghosttrace.admin` |
| `/gt probe <player>` | Launches 4-stage Hypixel MC-265322 translation audit on suspect. | `ghosttrace.admin` |
| `/gt timezone` | Opens interactive timezone selector (Primary: IST). | `ghosttrace.gui` |
| `/gt players` | Opens online player radar scanner. | `ghosttrace.gui` |
| `/gt inspect <player>` | Opens deep telemetry dossier for online or offline player. | `ghosttrace.admin` |
| `/gt versions` | Opens Version Enforcer GUI. | `ghosttrace.admin` |
| `/gt logs` | Historical session timeline with exact mod dumps. | `ghosttrace.admin` |
| `/gt bypass <add\|remove> <id>` | Manages tracking bypass list. | `ghosttrace.admin` |
| `/gt reload` | Hot-reloads configuration and storage. | `ghosttrace.admin` |

### Permissions
* `ghosttrace.admin` - Full access to all commands and administrative actions (default: `op`).
* `ghosttrace.gui` - Permission to open and navigate the GhostTrace GUI (default: `op`).
* `ghosttrace.alerts` - Receives real-time broadcast alerts on illegal joins (default: `op`).
* `ghosttrace.bypass` - Exempts player from client brand and mod enforcement checks.

---

## 📦 Downloads & Releases

Pre-compiled release JARs are available in the repository `releases/` directory and in your `Downloads` folder:

* **Java 17 Target** (Paper/Purpur 1.20 - 1.20.4): `releases/GhostTrace-1.0.5-Java17.jar`
* **Java 21 Target** (Paper/Purpur 1.20.5 - 26.x+): `releases/GhostTrace-1.0.5-Java21.jar`

Copy the corresponding JAR to your server's `plugins/` directory and restart.
