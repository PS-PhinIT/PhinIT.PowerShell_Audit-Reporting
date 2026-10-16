# ActiveDirectory_Audit

![Version](https://img.shields.io/badge/Version-0.6.9-blue?style=for-the-badge)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1-blue?style=for-the-badge&logo=powershell)

> Skript / Script: [`ActiveDirectory_Audit.ps1`](ActiveDirectory_Audit.ps1) · Änderungen / Changes: [CHANGELOG.md](CHANGELOG.md) · Security-Wiki: [WIKISITE.md](WIKISITE.md) · Lizenz / License: [LICENSE](../LICENSE)
>
> Die Version steht nicht im Dateinamen, sondern im Skript-Header, in der GUI-Statusleiste und in der [CHANGELOG.md](CHANGELOG.md). / The version is not part of the file name; see the script header, the GUI status bar and the [CHANGELOG.md](CHANGELOG.md).


## 📑 Table of Contents

- [🚀 Quick Start](#-quick-start)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [First Run](#first-run)
- [📋 Report Categories](#-report-categories)
  - [👤 User Reports](#-users-reports)
  - [👥 Group Reports](#-groups-reports)
  - [💻 Computer Reports](#-computers-reports)
  - [🔐 Security Analysis](#-security-analysis)
  - [📋 Infrastructure Reports](#-infrastructure-reports)
- [📈 Version History](#-version-history)
- [🛠️ Usage Examples](#️-usage-examples)
- [📤 Export Options](#-export-options)
- [🐛 Troubleshooting](#-troubleshooting)
- [🚧 Limitations](#-known-limitations--bekannte-einschränkungen)
- [📊 Report Reference](#-quick-report-reference)

## 📊 Overview

**ActiveDirectory_Audit** is a comprehensive PowerShell-based Active Directory reporting tool with a modern WPF GUI. It provides over 80 pre-built reports for auditing, security analysis, and compliance monitoring of your Active Directory environment.

### ✨ Key Features

- **80+ Pre-built Reports**: Comprehensive coverage of AD objects and security configurations
- **Modern WPF Interface**: Clean, intuitive Windows 11-style UI
- **Real-time Analysis**: Instant report generation without database requirements
- **Export Capabilities**: Export results to CSV or HTML
- **Advanced Filtering**: Powerful search and filter options for all reports
- **Security Focused**: Extensive security analysis and vulnerability detection
- **No Dependencies**: Works with standard PowerShell and AD modules

## 🆕 Latest Version

**Current Version**: v0.6.9 (`ActiveDirectory_Audit.ps1`) – 15.10.2026

> ActiveDirectory_Audit is the **design template** for all PhinIT tools: dark header with counters and Help/About, sidebar with expandable sections, white result card, dark footer with version, status indicator and © PhinIT link.

## 🚀 Quick Start

### Prerequisites

- Windows 10/11 or Windows Server 2016+
- PowerShell 5.1 or higher
- Active Directory PowerShell module
- Domain Administrator or appropriate read permissions
- .NET Framework 4.7.2 or higher

### Installation

1. Download the latest release from the repository
2. Copy `ActiveDirectory_Audit.ps1` to your preferred location
3. Run PowerShell as Administrator
4. Navigate to the script directory
5. Execute: `.\ActiveDirectory_Audit.ps1`

### First Run

```powershell
# Run with elevated privileges
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\ActiveDirectory_Audit.ps1
```

## 📋 Report Categories

### 👤 Users Reports
- All Users
- Disabled/Locked/Inactive Users
- Password Status (Expiring, Never Expire, Stale)
- Administrative Accounts
- Never Logged On Users
- Organization Structure (by Department, Manager)

### 👥 Groups Reports
- Security/Distribution Groups
- Empty Groups
- Nested Groups & Circular References
- Mail-Enabled Groups
- Groups without Owners

### 💻 Computers Reports
- All Computers
- Inactive Computers
- Operating System Summary
- BitLocker Status
- Duplicate Names

### 🔐 Security Analysis
- Privileged Account Analysis
- Kerberoastable/ASREPRoastable Accounts
- Weak Password Policies
- Permission Analysis
- DCSync Rights
- SID History Abuse Detection
- Compromise Indicators detection
- Authentication Protocol usage analysis
- Failed Authentication Patterns
- Advanced HoneyToken/Canary Account detection
- Service Account risk assessment

### 📋 Infrastructure Reports
- FSMO Role Holders
- Domain Controller Status
- Replication Health
- GPO Analysis
- Trust Relationships

### 🆕 Advanced Quick Reports (implemented in v0.6.6)
All former placeholder buttons now run real reports (event log queries are limited via `MaxEvents`; access errors are shown as an informative row):
- **User Security**: Kerberos Delegation (unconstrained/constrained/RBCD), Certificate Services (CAs + templates, ESC1–ESC4 indicators), LAPS coverage (legacy + Windows LAPS, no password values read), Protected Users, Authentication Policies/Silos, NTLM Audit (DC registry/GPO + event 8004), Pre-Windows 2000 Compatible Access, PAW (naming/group heuristic), Password Spray detection (4625/4771), Password Complexity (default policy + PSOs), Smart Card Required, Kerberos Encryption Types
- **Threat Indicators**: Golden Ticket (krbtgt/RODC krbtgt password age), Silver Ticket (old passwords + SPNs), Pass-the-Hash (NTLM/logon type 9 of privileged accounts on DCs), Skeleton Key (LSA protection RunAsPPL, service installs 7045)
- **Groups & Users**: Nested Group Depth (cycle-safe), Group Membership Timeline (replication metadata), UPN conflicts, Manager chain validation, Multiple email addresses, AdminCount anomalies, Naming convention violations (configurable via `$Global:EasyADNamingConvention`)
- **Computers**: Computer Trust Errors, IPv6 Readiness, Computer Lifecycle (OS support status, age, last logon), Stale Computer Passwords
- **GPO**: GPO Backup Status (optional backup folder), GPO Version Discrepancy (AD vs. SYSVOL), WMI Filters, GPO Loopback processing
- **Compliance & Audit**: Audit Policy Compliance (DC baseline), Object Access Auditing (SACLs), Privileged Operation Tracking, Account Lockout Tracking (4740 + caller computer), Login Trends, Account Creation Trends, Group Membership Changes (30 days), Password Change Frequency, PCI-DSS (PASS/FAIL)
- **DNS & Network**: Stale DNS Records, Dynamic DNS registration, Subnet assignment, Replication latency, Site link costs
- **Integration**: Exchange attributes/schema, Entra ID (Azure AD) Connect accounts, Custom attributes (extensionAttribute1–15)
- **Visualization tabs**: Network Topology, Security HeatMap and Report Builder (User/Computer/Group fields)
- Operating System Summary now flags Windows 10 end of support (14.10.2025) and EOL dates of all Windows client/server versions

## 📈 Version History

> Detailed changes: [CHANGELOG.md](CHANGELOG.md)

### v0.6.9
- Security HeatMap counts filtered AD users reliably, including single matches; fixes the `ADPropertyValueCollection` / `op_Division` error in password security and account activity.

### v0.6.8
- Risk levels are no longer assigned multiple times (missing `break` in overlapping `switch` blocks) – risk statistics and department risks are correct again
- Single AD objects are counted correctly (e.g. domains with exactly one site, Schema Admins with one member)
- Delegation analysis detects unconstrained/constrained delegation again (LDAP `userAccountControl` filter); domain controllers and RODCs are shown as "Info"
- Clearer console messages (privileged accounts in English, users by manager, honey tokens, failed authentication)

### v0.6.7
- "Circular References" quick report now runs the real cycle detection (linear-time Tarjan algorithm, lists all groups of each circular nesting, no double counting)
- Responsive footer with status indicator and working www.phinit.de link; unused legacy functions removed

### v0.6.6
- All 47 placeholder quick reports implemented (see list above)
- Help/About buttons, result counters and visualization tabs added to the GUI
- OS end-of-life status, faster BitLocker report, CIM with WMI fallback, console logging fixed
- BitLocker recovery passwords are masked by default (also in exports); list-based result building for better performance

### v0.5.X Series
- Added comprehensive Security Dashboard with risk metrics
- Implemented Compromise Indicators detection
- Added Authentication Protocol Analysis
- Introduced HoneyToken detection capabilities
- Enhanced Failed Authentication Pattern analysis
- Added Service Account security assessment
- Improved risk scoring algorithms
- Performance optimizations and stability improvements

### v0.4.X Series
- Stabilized all existing features
- Performance improvements
- Bug fixes and UI enhancements
- Enhanced export functionality
- Added Computer by OS report
- Improved UI responsiveness
- Enhanced filtering capabilities

### v0.3.x Series
- Added GPO analysis reports
- Enhanced group membership analysis
- Added circular group detection
- Improved performance for large domains

### v0.2.x Series
- Added infrastructure reports
- Introduced export to CSV/HTML

### v0.1.x Series
- Added security analysis reports
- Enhanced user reports
- Added computer reports
- Initial group reports

### v0.0.x Series (Early Development)
- Added advanced filtering
- Implemented export functionality
- Enhanced UI design
- Added basic group reports
- Implemented user reports
- Initial release with basic functionality

## 🛠️ Usage Examples

### Basic Report Generation

1. Launch the application
2. Select a report from the sidebar
3. Click the report button
4. View results in the main grid
5. Export if needed

### Advanced Filtering

```
# Filter examples in the search box:
Name -like "*admin*"
Department -eq "IT"
LastLogonDate -lt (Get-Date).AddDays(-90)
```

### Bulk Operations

The tool supports multi-select for:
- Exporting multiple objects
- Comparing user/group memberships
- Batch analysis

## 📤 Export Options

- **CSV**: For Excel analysis
- **HTML**: For web viewing and sharing

## 🐛 Troubleshooting

### Common Issues

1. **"Access Denied" Error**
   - Ensure you have appropriate AD read permissions
   - Run PowerShell as Administrator

2. **"Module Not Found" Error**
   - Install RSAT tools: `Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0`

3. **Performance Issues**
   - Limit result size in settings
   - Use specific OUs instead of entire domain

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

# ActiveDirectory_Audit (Deutsch)

## 📊 Übersicht

**ActiveDirectory_Audit** ist ein umfassendes PowerShell-basiertes Active Directory Reporting-Tool mit moderner WPF-Oberfläche. Es bietet über 80 vorgefertigte Berichte für Auditing, Sicherheitsanalyse und Compliance-Überwachung Ihrer Active Directory-Umgebung.

### ✨ Hauptfunktionen

- **80+ Vorgefertigte Berichte**: Umfassende Abdeckung von AD-Objekten und Sicherheitskonfigurationen
- **Moderne WPF-Oberfläche**: Saubere, intuitive Windows 11-Style Benutzeroberfläche
- **Echtzeit-Analyse**: Sofortige Berichtserstellung ohne Datenbankanforderungen
- **Export-Funktionen**: Export der Ergebnisse nach CSV oder HTML
- **Erweiterte Filterung**: Leistungsstarke Such- und Filteroptionen für alle Berichte
- **Sicherheitsfokussiert**: Umfangreiche Sicherheitsanalyse und Schwachstellenerkennung
- **Keine Abhängigkeiten**: Funktioniert mit Standard PowerShell und AD-Modulen

## 🆕 Neueste Version

**Aktuelle Version**: v0.6.9 (`ActiveDirectory_Audit.ps1`) – 15.10.2026

> ActiveDirectory_Audit ist die **Design-Vorlage** für alle PhinIT-Tools: dunkle Kopfzeile mit Zählern und Help/About, Sidebar mit aufklappbaren Bereichen, weiße Ergebnis-Karte, dunkle Fußzeile mit Version, Statusanzeige und © PhinIT-Link.

## 🚀 Schnellstart

### Voraussetzungen

- Windows 10/11 oder Windows Server 2016+
- PowerShell 5.1 oder höher
- Active Directory PowerShell-Modul
- Domänenadministrator oder entsprechende Leseberechtigungen
- .NET Framework 4.7.2 oder höher

### Installation

1. Laden Sie die neueste Version aus dem Repository herunter
2. Kopieren Sie `ActiveDirectory_Audit.ps1` an Ihren bevorzugten Speicherort
3. Führen Sie PowerShell als Administrator aus
4. Navigieren Sie zum Skriptverzeichnis
5. Ausführen: `.\ActiveDirectory_Audit.ps1`

### Erster Start

```powershell
# Mit erhöhten Rechten ausführen
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\ActiveDirectory_Audit.ps1
```

## 📋 Berichtskategorien

### 👤 Benutzerberichte
- Alle Benutzer
- Deaktivierte/Gesperrte/Inaktive Benutzer
- Passwortstatus (Ablaufend, Nie ablaufend, Veraltet)
- Administrative Konten
- Nie angemeldete Benutzer
- Organisationsstruktur (nach Abteilung, Manager)

### 👥 Gruppenberichte
- Sicherheits-/Verteilergruppen
- Leere Gruppen
- Verschachtelte Gruppen & Zirkelbezüge
- Mail-aktivierte Gruppen
- Gruppen ohne Besitzer

### 💻 Computerberichte
- Alle Computer
- Inaktive Computer
- Betriebssystem-Zusammenfassung
- BitLocker-Status
- Doppelte Namen

### 🔐 Sicherheitsanalyse
- Privilegierte Kontenanalyse
- Kerberoastbare/ASREPRoastbare Konten
- Schwache Passwortrichtlinien
- Berechtigungsanalyse
- DCSync-Rechte
- SID-Verlauf Missbrauchserkennung
- Security Dashboard mit Bewertungssystem
- Erkennung von Kompromittierungsindikatoren
- Analyse der Authentifizierungsprotokoll-Nutzung
- Fehlgeschlagene Authentifizierungsmuster
- Erweiterte HoneyToken/Canary-Konto-Erkennung
- Risikobewertung von Dienstkonten

### 📋 Infrastrukturberichte
- FSMO-Rolleninhaber
- Domänencontroller-Status
- Replikationsintegrität
- GPO-Analyse
- Vertrauensstellungen

### 🆕 Erweiterte Quick-Reports (implementiert in v0.6.6)
Alle bisherigen Platzhalter-Buttons liefern jetzt echte Reports (Eventlog-Abfragen sind per `MaxEvents` begrenzt; Zugriffsfehler erscheinen als Hinweiszeile):
- **Benutzersicherheit**: Kerberos-Delegierung (unconstrained/constrained/RBCD), Zertifikatsdienste (CAs + Vorlagen, ESC1–ESC4-Indikatoren), LAPS-Abdeckung (Legacy + Windows LAPS, ohne Kennwortwerte), Protected Users, Authentifizierungsrichtlinien/-silos, NTLM-Audit (DC-Registry/GPO + Event 8004), Prä-Windows 2000 kompatibler Zugriff, PAW (Namens-/Gruppenheuristik), Password-Spray-Erkennung (4625/4771), Kennwortkomplexität (Standardrichtlinie + PSOs), Smartcard erforderlich, Kerberos-Verschlüsselungstypen
- **Angriffsindikatoren**: Golden Ticket (Kennwortalter krbtgt/RODC-krbtgt), Silver Ticket (alte Kennwörter + SPNs), Pass-the-Hash (NTLM/Logon-Typ 9 privilegierter Konten auf DCs), Skeleton Key (LSA-Schutz RunAsPPL, Dienstinstallationen 7045)
- **Gruppen & Benutzer**: Verschachtelungstiefe (zyklensicher), Mitgliedschafts-Zeitleiste (Replikationsmetadaten), UPN-Konflikte, Manager-Ketten, Mehrfache E-Mail-Adressen, AdminCount-Anomalien, Namenskonventionen (anpassbar über `$Global:EasyADNamingConvention`)
- **Computer**: Vertrauensstellungsfehler, IPv6-Bereitschaft, Computer-Lebenszyklus (OS-Supportstatus, Alter, letzte Anmeldung), Veraltete Computerkennwörter
- **GPO**: GPO-Backup-Status (optionaler Backup-Ordner), GPO-Versionsabweichungen (AD vs. SYSVOL), WMI-Filter, Loopback-Verarbeitung
- **Compliance & Audit**: Audit-Policy-Compliance (DC-Baseline), Objektzugriffsüberwachung (SACLs), Privilegierte Operationen, Kontosperrungen (4740 + Aufrufer), Anmeldetrends, Kontoerstellungstrends, Gruppenänderungen (30 Tage), Kennwortwechsel-Häufigkeit, PCI-DSS (PASS/FAIL)
- **DNS & Netzwerk**: Veraltete DNS-Einträge, Dynamische DNS-Registrierung, Subnetzzuordnung, Replikationslatenz, Standortverknüpfungskosten
- **Integration**: Exchange-Attribute/-Schema, Entra ID (Azure AD) Connect-Konten, Custom Attributes (extensionAttribute1–15)
- **Visualisierungs-Tabs**: Netzwerktopologie, Security-HeatMap und Report Builder (Benutzer-/Computer-/Gruppenfelder)
- Die Betriebssystem-Zusammenfassung markiert das Supportende von Windows 10 (14.10.2025) und die EOL-Daten aller Windows-Client-/Server-Versionen

## 📈 Versionshistorie

> Detaillierte Änderungen: [CHANGELOG.md](CHANGELOG.md)

### v0.6.9
- Security-HeatMap zählt gefilterte AD-Benutzer auch bei einzelnen Treffern zuverlässig; behebt den Fehler `ADPropertyValueCollection` / `op_Division` bei Passwortsicherheit und Kontoaktivität.

### v0.6.8
- Risikostufen werden nicht mehr mehrfach vergeben (fehlendes `break` in überlappenden `switch`-Blöcken) – Risikostatistiken und Abteilungsrisiken stimmen wieder
- Einzelne AD-Objekte werden korrekt gezählt (z. B. Domänen mit genau einem Standort, Schema Admins mit einem Mitglied)
- Delegierungsanalyse erkennt unconstrained/constrained Delegation wieder (LDAP-Filter auf `userAccountControl`); Domänencontroller und RODCs werden als „Info“ ausgewiesen
- Klarere Konsolenmeldungen (privilegierte Konten auf Englisch, Benutzer nach Manager, Honey Tokens, fehlgeschlagene Anmeldungen)

### v0.6.7
- Quick-Report „Circular References“ nutzt jetzt die echte Zykluserkennung (Tarjan-Algorithmus mit linearer Laufzeit, alle Gruppen je zirkulärer Verschachtelung, keine Doppelzählung)
- Responsive Fußzeile mit Statusanzeige und funktionierendem Link www.phinit.de; ungenutzte Altfunktionen entfernt

### v0.6.6
- Alle 47 Platzhalter-Quick-Reports implementiert (siehe Liste oben)
- Hilfe-/Info-Buttons, Ergebniszähler und Visualisierungs-Tabs in der GUI ergänzt
- OS-End-of-Life-Status, schnellerer BitLocker-Report, CIM mit WMI-Fallback, Konsolen-Logging repariert
- BitLocker-Recovery-Passwörter werden standardmäßig maskiert (auch in Exporten); Ergebnisaufbau per List für bessere Performance

### v0.5.X Serie
- Umfassendes Security Dashboard mit Risikometriken hinzugefügt
- Erkennung von Kompromittierungsindikatoren implementiert
- Authentifizierungsprotokoll-Analyse hinzugefügt
- HoneyToken-Erkennungsfunktionen eingeführt
- Erweiterte Analyse fehlgeschlagener Authentifizierungsmuster
- Sicherheitsbewertung von Dienstkonten hinzugefügt
- Verbesserte Risikobewertungsalgorithmen
- Leistungsoptimierungen und Stabilitätsverbesserungen

### v0.4.X Serie
- Alle bestehenden Funktionen stabilisiert
- Leistungsverbesserungen
- Fehlerbehebungen und UI-Verbesserungen
- Erweiterte Exportfunktionalität
- Computer nach OS-Bericht hinzugefügt
- Verbesserte UI-Reaktionsfähigkeit
- Erweiterte Filterfunktionen

### v0.3.x Serie
- GPO-Analyseberichte hinzugefügt
- Erweiterte Gruppenmitgliedschaftsanalyse
- Zirkuläre Gruppenerkennung hinzugefügt
- Verbesserte Leistung für große Domänen

### v0.2.x Serie
- Infrastrukturberichte hinzugefügt
- Export nach CSV/HTML eingeführt

### v0.1.x Serie
- Sicherheitsanalyseberichte hinzugefügt
- Erweiterte Benutzerberichte
- Computerberichte hinzugefügt
- Erste Gruppenberichte

### v0.0.x Serie
- Erweiterte Filterung hinzugefügt
- Exportfunktionalität implementiert
- UI-Design verbessert
- Grundlegende Gruppenberichte hinzugefügt
- Benutzerberichte implementiert
- Erstveröffentlichung mit Grundfunktionalität

## 🛠️ Verwendungsbeispiele

### Grundlegende Berichtserstellung

1. Starten Sie die Anwendung
2. Wählen Sie einen Bericht aus der Seitenleiste
3. Klicken Sie auf die Berichtsschaltfläche
4. Ergebnisse im Hauptraster anzeigen
5. Bei Bedarf exportieren

### Erweiterte Filterung

```
# Filterbeispiele im Suchfeld:
Name -like "*admin*"
Department -eq "IT"
LastLogonDate -lt (Get-Date).AddDays(-90)
```

### Massenoperationen

Das Tool unterstützt Mehrfachauswahl für:
- Export mehrerer Objekte
- Vergleich von Benutzer-/Gruppenmitgliedschaften
- Batch-Analyse

## 📤 Exportoptionen

- **CSV**: Für Excel-Analyse
- **HTML**: Für Webanzeige und Freigabe

## 🐛 Fehlerbehebung

### Häufige Probleme

1. **"Zugriff verweigert" Fehler**
   - Stellen Sie sicher, dass Sie entsprechende AD-Leseberechtigungen haben
   - PowerShell als Administrator ausführen

2. **"Modul nicht gefunden" Fehler**
   - RSAT-Tools installieren: `Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0`

3. **Leistungsprobleme**
   - Ergebnisgröße in den Einstellungen begrenzen
   - Spezifische OUs anstelle der gesamten Domäne verwenden

## 📄 Lizenz

Dieses Projekt ist unter der MIT-Lizenz lizenziert - siehe [LICENSE](../LICENSE)-Datei für Details.

---

## 🚧 Known Limitations / Bekannte Einschränkungen

### English
- Maximum 50,000 objects per report for performance reasons
- Some reports require Domain Admin permissions
- Export is limited to CSV and HTML
- Real-time monitoring not supported (use scheduled tasks)

### Deutsch  
- Maximal 50.000 Objekte pro Report aus Performance-Gründen
- Einige Reports benötigen Domänen-Admin-Berechtigungen
- Export ist auf CSV und HTML beschränkt
- Echtzeit-Überwachung nicht unterstützt (geplante Tasks verwenden)


---

## 📊 Quick Report Reference

### Overview of all available reports / Übersicht aller verfügbaren Berichte

| REPORT | ENG Description | DE Beschreibung |
|--------|-----------------|-----------------|
| **SECURITY DASHBOARD** | | |
| Risk Overview | Comprehensive security risk assessment | Umfassende Sicherheitsrisikobewertung |
| Security Score | Overall domain security score calculation | Berechnung des Gesamtsicherheitswerts der Domäne |
| Critical Findings | Highlights critical security issues | Hebt kritische Sicherheitsprobleme hervor |
| Remediation Priority | Prioritized list of security fixes | Priorisierte Liste von Sicherheitskorrekturen |
| Compliance Status | Shows compliance with security standards | Zeigt Compliance mit Sicherheitsstandards |
| **USER REPORTS** | | |
| All Users | Lists all user accounts in the domain | Listet alle Benutzerkonten in der Domäne auf |
| Disabled Users | Shows all disabled user accounts | Zeigt alle deaktivierten Benutzerkonten an |
| Locked Users | Displays users with locked accounts | Zeigt Benutzer mit gesperrten Konten an |
| Inactive Users | Lists users inactive for specified period | Listet inaktive Benutzer für einen bestimmten Zeitraum auf |
| Password Expiring | Shows users with expiring passwords | Zeigt Benutzer mit ablaufenden Passwörtern an |
| Password Never Expires | Lists users with non-expiring passwords | Listet Benutzer mit nicht ablaufenden Passwörtern auf |
| Stale Passwords | Shows users who haven't changed passwords recently | Zeigt Benutzer, die ihre Passwörter lange nicht geändert haben |
| Administrative Accounts | Lists all administrative user accounts | Listet alle administrativen Benutzerkonten auf |
| Never Logged On | Shows users who have never logged in | Zeigt Benutzer, die sich noch nie angemeldet haben |
| Users by Department | Groups users by their department | Gruppiert Benutzer nach ihrer Abteilung |
| Users by Manager | Shows organizational hierarchy by manager | Zeigt Organisationshierarchie nach Manager |
| **GROUP REPORTS** | | |
| All Groups | Lists all groups in the domain | Listet alle Gruppen in der Domäne auf |
| Security Groups | Shows all security groups | Zeigt alle Sicherheitsgruppen an |
| Distribution Groups | Lists all distribution groups | Listet alle Verteilergruppen auf |
| Empty Groups | Shows groups without members | Zeigt Gruppen ohne Mitglieder an |
| Nested Groups | Displays group nesting hierarchy | Zeigt verschachtelte Gruppenhierarchie an |
| Circular Group References | Detects circular group memberships | Erkennt zirkuläre Gruppenmitgliedschaften |
| Mail-Enabled Groups | Lists groups with email addresses | Listet Gruppen mit E-Mail-Adressen auf |
| Groups without Owners | Shows groups lacking designated owners | Zeigt Gruppen ohne zugewiesene Besitzer |
| **COMPUTER REPORTS** | | |
| All Computers | Lists all computer accounts | Listet alle Computerkonten auf |
| Inactive Computers | Shows computers inactive for specified period | Zeigt inaktive Computer für einen bestimmten Zeitraum |
| Operating System Summary | Groups computers by OS version | Gruppiert Computer nach Betriebssystemversion |
| BitLocker Status | Shows BitLocker encryption status | Zeigt BitLocker-Verschlüsselungsstatus an |
| Duplicate Computer Names | Detects duplicate computer names | Erkennt doppelte Computernamen |
| Computers by Location | Groups computers by physical location | Gruppiert Computer nach physischem Standort |
| **SECURITY ANALYSIS** | | |
| Privileged Accounts | Analyzes accounts with elevated privileges | Analysiert Konten mit erhöhten Berechtigungen |
| Kerberoastable Accounts | Identifies accounts vulnerable to Kerberoasting | Identifiziert für Kerberoasting anfällige Konten |
| ASREPRoastable Accounts | Lists accounts vulnerable to AS-REP roasting | Listet für AS-REP Roasting anfällige Konten auf |
| Weak Password Policies | Analyzes password policy weaknesses | Analysiert Schwächen in Passwortrichtlinien |
| Permission Analysis | Reviews object permissions and delegations | Überprüft Objektberechtigungen und Delegierungen |
| DCSync Rights | Shows accounts with DCSync permissions | Zeigt Konten mit DCSync-Berechtigungen |
| SID History Abuse | Detects potential SID history abuse | Erkennt potenziellen SID-Verlauf-Missbrauch |
| Compromise Indicators | Identifies signs of potential compromise | Identifiziert Anzeichen möglicher Kompromittierung |
| Authentication Protocols | Analyzes authentication protocol usage | Analysiert Nutzung von Authentifizierungsprotokollen |
| Failed Authentication | Shows failed authentication patterns | Zeigt fehlgeschlagene Authentifizierungsmuster |
| HoneyToken Detection | Detects canary/honeypot accounts | Erkennt Canary-/Honeypot-Konten |
| Service Account Security | Assesses service account security risks | Bewertet Sicherheitsrisiken von Dienstkonten |
| **INFRASTRUCTURE REPORTS** | | |
| FSMO Role Holders | Shows Flexible Single Master Operation roles | Zeigt Flexible Single Master Operation Rollen |
| Domain Controllers | Lists all domain controllers and status | Listet alle Domänencontroller und Status auf |
| Replication Health | Shows AD replication status and issues | Zeigt AD-Replikationsstatus und Probleme |
| GPO Analysis | Analyzes Group Policy Objects | Analysiert Gruppenrichtlinienobjekte |
| Trust Relationships | Shows domain trust configurations | Zeigt Domänen-Vertrauensstellungen |
| Sites and Subnets | Lists AD sites and subnet configurations | Listet AD-Standorte und Subnetzkonfigurationen |
| DNS Zones | Shows integrated DNS zones | Zeigt integrierte DNS-Zonen |

### Report Categories Legend / Berichtskategorien-Legende

- 👤 **User Reports** / **Benutzerberichte**: Focus on user account management / Fokus auf Benutzerkontenverwaltung
- 👥 **Group Reports** / **Gruppenberichte**: Group membership and structure analysis / Gruppenmitgliedschaft und Strukturanalyse
- 💻 **Computer Reports** / **Computerberichte**: Computer account and system information / Computerkonten und Systeminformationen
- 🔐 **Security Analysis** / **Sicherheitsanalyse**: Security vulnerabilities and risks / Sicherheitslücken und Risiken
- 📋 **Infrastructure** / **Infrastruktur**: AD infrastructure health and configuration / AD-Infrastruktur-Zustand und Konfiguration
- 🛡️ **Security Dashboard** / **Sicherheits-Dashboard**: Comprehensive security overview / Umfassende Sicherheitsübersicht
