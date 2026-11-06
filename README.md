# GhostTrace 🛡️ (Public Release Distribution)

**GhostTrace** is an enterprise-grade, **100% server-side** client mod, launcher, and payload inspector anti-cheat for Paper, Bukkit, Purpur, and Hybrid modded servers (Arclight, Mohist, Magma, Cardboard) across Minecraft **1.20 through 1.21+ and future releases (26.x)**.

Unlike traditional anti-cheats that produce false-positive jump or fly kicks during latency spikes, **GhostTrace does zero movement checks**. It strictly inspects client connection metadata, Forge/NeoForge mod handshakes, and registered custom payload channels.

---

## 📥 Downloads (Multi-Java Releases)

Download the JAR build corresponding to your server's Java runtime:

| Release Artifact | Target Java | Compatible Minecraft Versions | Description |
| :--- | :---: | :---: | :--- |
| [**`GhostTrace-1.0.0-Java17.jar`**](releases/GhostTrace-1.0.0-Java17.jar) | **Java 17** | Minecraft **1.20.0 – 1.20.4** | For servers operating on Java 17 LTS runtimes. |
| [**`GhostTrace-1.0.0-Java21.jar`**](releases/GhostTrace-1.0.0-Java21.jar) | **Java 21+** | Minecraft **1.20.5 – 1.21.x & 26.x** | Optimized for modern servers requiring Java 21 LTS+. |

---

## ⚡ Core Features

* **Zero Movement Checks**: Pure client-environment verification eliminates 100% of lag-induced movement false kicks.
* **Launcher & Brand Detection**: Inspects `minecraft:brand` to reveal Vanilla, Fabric, Forge, NeoForge, Feather, Lunar, Badlion, or cheat clients (Meteor, Aristois, LiquidBounce, etc.).
* **Handshake Mod List Extraction**: Decodes Forge & NeoForge `fml:handshake` / `forge:handshake` packets to uncover every active client mod ID and version.
* **Channel Fingerprinting**: Captures stealth mods that register channels via `PlayerRegisterChannelEvent` (Baritone, Freecam, Wurst, SeedCracker, Radars, and Iris shader configs).
* **⚡ Mod Version Enforcer & Remote Disabler**: Enforce minimum versions (e.g. `simple-voice-chat:2.5.0`, `sodium:0.5.8`) or force-disable specific mods (`:DISABLED`). Outdated clients are prompted to update with customizable join messages.
* **🚫 Configurable 20-Attempt IP-Ban**: Optional security trigger that automatically IP-bans repeat offenders attempting to connect with blacklisted software.
* **🎨 Modern Sidebar Dashboard GUI**: Flagship Lunar/Badlion-style sidebar dock interface with real-time radar, audit logs, and settings toggles.
* **🔑 LuckPerms Integration**: Automatic synchronization with LuckPerms 5.4+ displaying player primary ranks and prefixes in alerts and GUI cards.
* **📜 Historical Session Logs**: Permanent tracking of exact connection timestamps, loaded mods, IP addresses, and brand signatures for online and offline players.

---

## 🚀 Quick Start Guide

1. Download the appropriate JAR file for your server from the [`releases/`](releases/) folder:
   * **Java 17**: `GhostTrace-1.0.0-Java17.jar`
   * **Java 21**: `GhostTrace-1.0.0-Java21.jar`
2. Drop the JAR into your server's `plugins/` directory.
3. Start or restart your server.
4. Customize rules and messages in `plugins/GhostTrace/config.yml`.
5. Run `/gt gui` in-game to access the dashboard.

---

## 🛠️ Commands & Permissions

| Command | Description | Permission |
| :--- | :--- | :--- |
| `/gt` or `/gt gui` | Opens the modern interactive control dashboard. | `ghosttrace.gui` |
| `/gt players` | Opens the live online player radar. | `ghosttrace.gui` |
| `/gt versions` | Opens the Mod Version Enforcer & Disabler tab. | `ghosttrace.admin` |
| `/gt logs` | Opens the historical session audit timeline. | `ghosttrace.admin` |
| `/gt inspect <player>` | Inspects live or offline player dossier. | `ghosttrace.admin` |
| `/gt bypass <add\|remove> <id>` | Adds/removes a player or UUID from tracking bypass. | `ghosttrace.admin` |
| `/gt reload` | Hot-reloads configuration and database. | `ghosttrace.admin` |

### Permissions
* `ghosttrace.admin` – Full administrative control.
* `ghosttrace.gui` – Permission to open the control panel.
* `ghosttrace.alerts` – In-game real-time broadcast alerts on illegal mod discoveries.
* `ghosttrace.bypass` – Complete exemption from all mod and brand verification checks.

---

## 📄 License & Distribution

Distributed as public releases. For private enterprise inquiries or source code repository access, contact the repository maintainer.
