# GhostTrace 🛡️ (Flagship Network Anti-Cheat & Courtroom Suite)

**GhostTrace** is an enterprise-grade **100% server-side** client mod, launcher, and payload inspector anti-cheat designed for Minecraft servers across versions **1.20 through 1.21+ and future 26.x releases**.

It combines **DonutSMP-style active translation probing (MC-265322)** with a **Case Decider Courtroom UI**, allowing staff to review detected client mods and make deliberate rulings without automatic false-positive kicks or movement lag.

---

## ⚡ Flagship Features

1. **DonutSMP-Style Active Mod Detection (MC-265322)**:
   * Probes clients using translatable components to force-reveal hidden Fabric cheats, radar mods, and utilities even when the client never registers a custom channel or Forge handshake.
   * Probes for: **Meteor Client**, **Wurst**, **Aristois**, **LiquidBounce**, **Advanced X-Ray**, **Freecam**, **Xaero's WorldMap/MiniMap**, **JourneyMap**, **SeedCrackerX**, **Baritone**, **Litematica**, and shaders.
   * On-demand scan via `/gt probe <player>`, automated join probes, or one-click scans from the Decider UI.

2. **Case Decider Courtroom UI (`/gt cases` & `/gt decide <player>`)**:
   * **Zero Automatic Disconnects**: Discovered mods create formal case dossiers instead of kicking players without permission.
   * Interactive Courtroom Actions:
     * **[✔ APPROVE / DISMISS]**: Clears case for this session.
     * **[⚠ WARN PLAYER]**: Delivers a private security warning with the list of detected mods.
     * **[✕ KICK]**: Ejects player with an official staff ruling reason.
     * **[⛔ BAN]**: Permanent server ban with recorded incident ID.
     * **[🔍 RUN ACTIVE SCAN NOW]**: Real-time packet probe query.

3. **🕒 Multi-Timezone System (Primary Standard: IST)**:
   * Native multi-timezone engine with **IST (`Asia/Kolkata`, UTC+05:30)** as primary standard.
   * Interactive GUI switcher supporting **IST**, **UTC**, **EST**, **CST**, **PST**, **GMT**, **CET**, **JST**, and **AEST**.

4. **Multi-Java Architecture (Java 17 & Java 21)**:
   * Compiled and optimized separately for both **Java 17** (Paper 1.20 - 1.20.4) and **Java 21** (Paper 1.20.5+ through 26.x).

5. **Mod Version Enforcer & Remote Disabler**:
   * Block outdated mod versions or disable specific mods remotely via semantic version comparison.

6. **Repeated Attempts IP-Ban Condition**:
   * Configurable threshold (default 20 attempts) to automatically ban IPs that persistently attempt connections with prohibited software.

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
| `/gt probe <player>` | Launches active MC-265322 translation probe on suspect. | `ghosttrace.admin` |
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

Pre-compiled release JARs are available in the repository `releases/` directory:

* **Java 17 Target** (Paper/Purpur 1.20 - 1.20.4): `releases/GhostTrace-1.0.3-Java17.jar`
* **Java 21 Target** (Paper/Purpur 1.20.5 - 26.x+): `releases/GhostTrace-1.0.3-Java21.jar`

Copy the corresponding JAR to your server's `plugins/` directory and restart.
