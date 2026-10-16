# WindowsServer_Audit – WindowsServer_Audit (Windows Server Audit)

![Version](https://img.shields.io/badge/Version-0.4.5-blue)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-green)
![OS](https://img.shields.io/badge/OS-Windows%20Server-blue)

> Skript: [`WindowsServer_Audit.ps1`](WindowsServer_Audit.ps1) · Änderungen: [CHANGELOG.md](CHANGELOG.md) · Lizenz: [LICENSE](../LICENSE)
>
> Die Version steht nicht im Dateinamen, sondern im Skript-Header, im Fenstertitel und in der [CHANGELOG.md](CHANGELOG.md).
>
> **Aktuelle Version:** 0.4.5 – 14.10.2026

## 🚀 WindowsServer_Audit - Windows Server Audit

### ✅ Über 120 Audit-Befehle

#### 🌐 Verbindungsaudit (v0.2.3)
*   **50+ spezialisierte Netzwerk-Audit-Befehle** für erweiterte Verbindungsanalysen
*   **Echtzeitanalyse aktiver TCP/UDP-Verbindungen** mit Prozess-Zuordnung
*   **Netzwerk-Topologie-Mapping** mit automatischer Geräte-Erkennung
*   **DRAW.IO-Export** für professionelle Netzwerk-Diagramme
*   **Sicherheitsanalyse** mit Blacklist-Checking und Bedrohungserkennung
*   **ARP-Cache und MAC-Adressen-Analyse** für lokale Netzwerk-Discovery


#### 📊 System-Audits (v0.0.12)
*   Lokale Administratoren & Guest Accounts
*   Shared Folders & User Profiles
*   Windows Firewall & Power Management
*   Credential Manager & Audit Policy
*   Group Policy Results & Environment Variables
*   Installierte Software (Registry-basiert)

#### 🔐 Active Directory (v0.0.12)
*   **ADFS (5 Audits):** Relying Party Trusts, Claims Provider, Certificates, Endpoints
*   **ADLDS (2 Audits):** Instances & Configuration
*   **ADRMS (3 Audits):** Cluster Info, Server Info, Templates

#### 🩺 AD Health Check (v0.1.9)
*   AD DHCP Server Discovery in Active Directory
*   AD Service Dependencies Health (DNS, DFS, Kerberos, etc.)
*   AD DC Diagnostics (dcdiag)
*   AD Time Sync Status & Sysvol Replication

#### 🛡️ Sicherheit & Compliance (v0.0.12)
*   **Device Health Attestation (1 Audit):** Encryption/Signing Certificates
*   **Volume Activation (2 Audits):** KMS Server/Client Status
*   **Windows Defender (3 Audits):** Status, Preferences, Threat Detection
*   **Host Guardian Service (2 Audits):** HGS Info & Attestation Policies

#### 💾 Backup & Storage (v0.1.9)
*   **Windows Server Backup (3 Audits):** Policies, Jobs, Disks
*   **Storage Management (4 Audits):** Storage Pools, Virtual Disks, Storage Spaces
*   **Windows Internal Database (2 Audits):** SQL Express Instances

#### 🌐 Netzwerk & Zugriff (v0.1.9)
*   **NPAS/NPS (4 Audits):** Network Policies, RADIUS Clients, Connection Policies
*   **Remote Access (3 Audits):** DirectAccess, VPN, Routing Table

#### ⚙️ System Services (v0.0.12)
*   **Windows Process Activation Service (2 Audits):** WAS Status & App Pools
*   **Windows Search Service (2 Audits):** Search Status & Indexer
*   **Windows Server Essentials (2 Audits):** Dashboard & Backup
*   **Migration Services (1 Audit):** Migration Tools
*   **Windows Identity Foundation (1 Audit):** Identity Features


### 🎯 Kernfunktionen im Überblick
*   **Über 120 verschiedene Audit-Befehle:** Umfassende Abdeckung für tiefgreifende Analysen.
*   **Automatische Rollen-Erkennung:** Identifiziert zuverlässig installierte Windows Server Rollen.
*   **20+ Audit-Kategorien:** Sorgt für eine übersichtliche Struktur und Navigation in der GUI.
*   **CMD + PowerShell Unterstützung:** Bietet Flexibilität bei der Ausführung von Audit-Befehlen.
*   **Professionelle HTML-Reports:** Ermöglicht eine einfache Analyse durch Tab-Navigation und klare Darstellung.
*   **Live-Fortschrittsanzeige:** Erlaubt die Verfolgung des Audit-Prozesses für alle Befehle in Echtzeit.

### 🖥️ Oberfläche
Einheitliches PhinIT-Design (Vorlage: ActiveDirectory_Audit):
*   **Kopfzeile:** Titel mit Version, Ergebniszähler „Results“, Buttons „Help“ (Kurzanleitung) und „About“ (Version/Stand).
*   **Sidebar (links):** Audit-Kategorien als aufklappbare Bereiche.
*   **Ergebnis-Karte (rechts):** Tabelle der Ergebnisse mit den Buttons „Export CSV“, „Export HTML“ und „Clear Results“.
*   **Fußzeile:** Version/Stand, Statusanzeige (grün = bereit, gelb = Audit läuft, rot = Fehler), Fortschrittsbalken und Link zu www.phinit.de.


## 📋 Systemanforderungen
- **Windows Server 2016/2019/2022**
- **PowerShell 5.1** oder höher
- **Administrator-Rechte** für vollständige Audit-Funktionalität
- **.NET Framework 4.7.2** oder höher (für WPF-GUI)

## 🚀 Installation & Verwendung

### Schnellstart
```powershell
# 1. Script herunterladen
# 2. PowerShell als Administrator starten
# 3. Ausführungsrichtlinie temporär ändern (falls erforderlich)
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# 4. Script ausführen
.\WindowsServer_Audit.ps1
```


### Tipps für beste Ergebnisse
- **Führen Sie das Tool als Domain Administrator aus** für vollständige AD-Audits
- **Prüfen Sie bei Problemen die Ausgabe im Output-Bereich** der GUI – Fehler einzelner Audit-Befehle werden dort protokolliert
- **Audits laufen im Hintergrund** – die GUI bleibt bedienbar; während eines Audits sind die Audit-Buttons gesperrt, die Fußzeile zeigt Status, Fortschritt und Laufzeit
- **Exportieren Sie Berichte als HTML** für bessere Lesbarkeit und Archivierung

## 📄 Changelog
Alle Änderungen sind in der [CHANGELOG.md](CHANGELOG.md) dokumentiert.
