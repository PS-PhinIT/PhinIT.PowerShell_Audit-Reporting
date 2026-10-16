<div align="center">

# 🛡️ PhinIT Auditing & Reporting Suite

[![Language: German](https://img.shields.io/badge/Language-Deutsch-black?style=flat-square)](#-deutsche-version)
[![Language: English](https://img.shields.io/badge/Language-English-blue?style=flat-square)](#-english-version)

</div>

---

<a name="-deutsche-version"></a>
## 🇩🇪 Deutsche Version

**Ein zentrales Toolkit für Systemadministratoren zur Analyse, Überwachung und Dokumentation von IT-Umgebungen.**

Dieses Repository bündelt spezialisierte Module ("easy"-Serie), um Transparenz in Server-Landschaften, Active Directory Strukturen und Client-Konfigurationen zu bringen.

### 📂 Enthaltene Module & Funktionen

Das Repository ist in eigenständige Module unterteilt, die spezifische Audit-Aufgaben übernehmen:

| Modul | Zweck | Skript | Version | Doku |
|-------|-------|--------|---------|------|
| [`ActiveDirectory_Audit`](ActiveDirectory_Audit/) | Active Directory Reporting & Security-Analyse | [`ActiveDirectory_Audit.ps1`](ActiveDirectory_Audit/ActiveDirectory_Audit.ps1) | 0.6.8 | [README](ActiveDirectory_Audit/README.md) · [CHANGELOG](ActiveDirectory_Audit/CHANGELOG.md) |
| [`WindowsServer_Audit`](WindowsServer_Audit/) | Windows Server Audit | [`WindowsServer_Audit.ps1`](WindowsServer_Audit/WindowsServer_Audit.ps1) | 0.4.5 | [README](WindowsServer_Audit/README.md) · [CHANGELOG](WindowsServer_Audit/CHANGELOG.md) |
| [`Application_Audit`](Application_Audit/) | Software-/Client-Audit | [`Application_Audit.ps1`](Application_Audit/Application_Audit.ps1) | 0.0.4 | [README](Application_Audit/README.md) · [CHANGELOG](Application_Audit/CHANGELOG.md) |
| [`Connections_Audit`](Connections_Audit/) | Netzwerkverbindungs-Monitor | [`Connections_Audit.ps1`](Connections_Audit/Connections_Audit.ps1) | 0.0.8 | [README](Connections_Audit/README.md) · [CHANGELOG](Connections_Audit/CHANGELOG.md) |

> Die Skript-Dateinamen enthalten **keine Versionsnummer**. Die aktuelle Version steht im Skript-Header, in der GUI sowie in der jeweiligen `README.md`/`CHANGELOG.md`.
>
> Alle Module nutzen dieselbe schlichte, moderne Oberfläche (Vorlage: ActiveDirectory_Audit): Kopfzeile mit Kennzahlen und „Help“/„About“, Sidebar mit aufklappbaren Bereichen, Ergebnis-Karte und Fußzeile mit Version, Statusanzeige und www.phinit.de.

#### 1. `ActiveDirectory_Audit` (Active Directory)
* **User & Group Audit:** Identifiziert inaktive Nutzer, verwaiste Accounts und verschachtelte Gruppen.
* **Security:** Überprüfung von Admin-Rechten, sensitiven Gruppenmitgliedschaften und Kompromittierungs-Indikatoren.

#### 2. `WindowsServer_Audit` (Windows Server Audit)
* **Server-Check:** Über 120 Audit-Befehle mit automatischer Rollen-Erkennung.
* **AD Health, Sicherheit, Backup, Netzwerk & Dienste:** Strukturierte Audit-Kategorien in der GUI.
* **Export:** HTML-/CSV-Reports.

#### 3. `Application_Audit` (Software / Client)
* **Inventur:** Installierte Programme, Store Apps, Programm-Inventar.
* **Nutzung:** Laufende Prozesse, Prefetch-Analyse, Event-Logs, Desktop-Verknüpfungen.

#### 4. `Connections_Audit` (Netzwerk)
* **Verbindungs-Monitor:** Echtzeit-Überwachung von TCP/UDP-Verbindungen mit Prozesszuordnung.
* **Aufzeichnung & Export:** Mitschnitt über einen Zeitraum, farbcodierte Kategorien, HTML-Reports, Filter-Presets (Beta).

### 📁 Ordnerstruktur
```
/
├── README.md · CHANGELOG.md · AUDIT.md · CONTRIBUTING.md · SECURITY.md · LICENSE
├── ActiveDirectory_Audit/      ActiveDirectory_Audit.ps1 · README.md · CHANGELOG.md · WIKISITE.md
├── WindowsServer_Audit/      WindowsServer_Audit.ps1 · README.md · CHANGELOG.md
├── Application_Audit/       Application_Audit.ps1 · README.md · CHANGELOG.md
└── Connections_Audit/   Connections_Audit.ps1 · presets.json · README.md · CHANGELOG.md
```
Ältere Versionen sind über die Git-Historie verfügbar; kompilierte EXE-Dateien und Screenshots werden nicht im Repository abgelegt.

### 🛠️ Voraussetzungen
* **PowerShell Version:** Die benötigte Version (PS 5.1 oder PS Core 7+) ist in der jeweiligen **README des Moduls** vermerkt.
* **RSAT Tools:** Für das Modul `ActiveDirectory_Audit` zwingend erforderlich.
* **Berechtigungen:** Ausführungsrechte (ExecutionPolicy) müssen gesetzt sein; Leserechte (bzw. Admin-Rechte) auf den Zielsystemen sind für `SRVAudit` und `SWAudit` notwendig.

### 🔍 Audit & Änderungen
* Ergebnisse des Code-Audits (Sicherheit, Performance, Funktionen, Verweise, GUI, Befehle): [AUDIT.md](AUDIT.md)
* Repository-weite Änderungen: [CHANGELOG.md](CHANGELOG.md)
* Mitwirken: [CONTRIBUTING.md](CONTRIBUTING.md) · Sicherheitslücken melden: [SECURITY.md](SECURITY.md) · Lizenz: [LICENSE](LICENSE) (MIT)

### 🤝 Contributing
Verbesserungsvorschläge und Pull Requests sind willkommen – siehe [CONTRIBUTING.md](CONTRIBUTING.md).

---
---

<a name="-english-version"></a>
## 🇬🇧 English Version

**A central toolkit for system administrators to analyze, monitor, and document IT environments.**

This repository bundles specialized modules (the "easy" series) designed to bring transparency to Server landscapes, Active Directory structures, and Client configurations.

### 📂 Included Modules & Features

The repository is divided into standalone modules handling specific audit tasks:

| Module | Purpose | Script | Version | Docs |
|--------|---------|--------|---------|------|
| [`ActiveDirectory_Audit`](ActiveDirectory_Audit/) | Active Directory reporting & security analysis | [`ActiveDirectory_Audit.ps1`](ActiveDirectory_Audit/ActiveDirectory_Audit.ps1) | 0.6.8 | [README](ActiveDirectory_Audit/README.md) · [CHANGELOG](ActiveDirectory_Audit/CHANGELOG.md) |
| [`WindowsServer_Audit`](WindowsServer_Audit/) | Windows Server audit | [`WindowsServer_Audit.ps1`](WindowsServer_Audit/WindowsServer_Audit.ps1) | 0.4.5 | [README](WindowsServer_Audit/README.md) · [CHANGELOG](WindowsServer_Audit/CHANGELOG.md) |
| [`Application_Audit`](Application_Audit/) | Software / client audit | [`Application_Audit.ps1`](Application_Audit/Application_Audit.ps1) | 0.0.4 | [README](Application_Audit/README.md) · [CHANGELOG](Application_Audit/CHANGELOG.md) |
| [`Connections_Audit`](Connections_Audit/) | Network connections monitor | [`Connections_Audit.ps1`](Connections_Audit/Connections_Audit.ps1) | 0.0.7 | [README](Connections_Audit/README.md) · [CHANGELOG](Connections_Audit/CHANGELOG.md) |

> Script file names contain **no version number**. The current version is shown in the script header, in the GUI and in the module's `README.md`/`CHANGELOG.md`.
>
> All modules share the same clean, modern user interface (template: ActiveDirectory_Audit): header with key figures and "Help"/"About", sidebar with collapsible sections, results card and footer with version, status indicator and www.phinit.de.

#### 1. `ActiveDirectory_Audit` (Active Directory)
* **User & Group Audit:** Identify inactive users, orphaned accounts, and nested groups.
* **Security:** Review of Admin rights, sensitive group memberships, and indicators of compromise.

#### 2. `WindowsServer_Audit` (Windows Server Audit)
* **Server Check:** 120+ audit commands with automatic role detection.
* **AD health, security, backup, network & services:** Structured audit categories in the GUI.
* **Export:** HTML/CSV reports.

#### 3. `Application_Audit` (Software / Client)
* **Inventory:** Installed programs, Store apps, program inventory.
* **Usage:** Running processes, Prefetch analysis, Event Logs, desktop shortcuts.

#### 4. `Connections_Audit` (Network)
* **Connection Monitor:** Real-time monitoring of TCP/UDP connections with process mapping.
* **Recording & Export:** Capture over time, color-coded categories, HTML reports, filter presets (beta).

### 📁 Folder layout
See the tree in the German section above. Previous versions are available via the Git history; compiled EXE files and screenshots are not stored in the repository.

### 🛠️ Prerequisites
* **PowerShell Version:** The required version (PS 5.1 or PS Core 7+) is noted in the **specific README of each module**.
* **RSAT Tools:** Mandatory for the `ActiveDirectory_Audit` module.
* **Permissions:** Execution rights (ExecutionPolicy) must be set; Read permissions (or Admin rights) on target systems are required for `SRVAudit` and `SWAudit`.

### 🔍 Audit & Changes
* Code audit results (security, performance, functions, references, GUI, commands): [AUDIT.md](AUDIT.md)
* Repository-wide changes: [CHANGELOG.md](CHANGELOG.md)
* Contributing: [CONTRIBUTING.md](CONTRIBUTING.md) · Reporting vulnerabilities: [SECURITY.md](SECURITY.md) · License: [LICENSE](LICENSE) (MIT)

### 🤝 Contributing
Suggestions for improvements and Pull Requests are welcome – see [CONTRIBUTING.md](CONTRIBUTING.md).
