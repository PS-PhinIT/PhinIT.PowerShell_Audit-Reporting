# Audit-Bericht – PhinIT Auditing & Reporting Suite

**Datum:** 14.10.2026 (Audit: 0.6.5 / 0.4.3 / 0.0.2 / 0.0.5 · Behebung der offenen Befunde: 0.6.6 / 0.4.4 / 0.0.3 / 0.0.6 · [Zweite Audit-Runde & einheitliche Oberfläche](#zweite-audit-runde-14102026): 0.6.7 / 0.4.5 / 0.0.4 / 0.0.7) · **Umfang:** alle Module und die Repository-Struktur
**Prüfbereiche:** Sicherheit · Performance · Funktionen · Verweise · GUI · Befehle · Dokumentation/Struktur

| Modul | Geprüfte Version | Ergebnis-Version | Changelog |
|-------|------------------|------------------|-----------|
| ActiveDirectory_Audit | 0.6.4 (`# Beta/ActiveDirectory_Audit_v0.6.4.ps1`) | **0.6.7** – `ActiveDirectory_Audit/ActiveDirectory_Audit.ps1` | [CHANGELOG](ActiveDirectory_Audit/CHANGELOG.md) |
| WindowsServer_Audit | 0.4.2 (`WindowsServer_Audit_V0.4.2.ps1`) | **0.4.5** – `WindowsServer_Audit/WindowsServer_Audit.ps1` | [CHANGELOG](WindowsServer_Audit/CHANGELOG.md) |
| Application_Audit | 0.0.1 (`Application_Audit_V0.0.1.ps1`) | **0.0.4** – `Application_Audit/Application_Audit.ps1` | [CHANGELOG](Application_Audit/CHANGELOG.md) |
| Connections_Audit | 0.0.4 (`# Beta/Connections_Audit_V0.0.4.ps1`) | **0.0.7** – `Connections_Audit/Connections_Audit.ps1` | [CHANGELOG](Connections_Audit/CHANGELOG.md) |

## Vorgehen und Grenzen

- Manuelle Code-Review aller Skripte, Syntaxprüfung mit dem PowerShell-Parser (`[System.Management.Automation.Language.Parser]::ParseFile`) – **alle Skripte: 0 Fehler**.
- Hilfsfunktionen ohne Windows-Abhängigkeit (z. B. Filter, HTML-/CSV-Kodierung, IP-Klassifizierung) wurden unter PowerShell 7 isoliert getestet.
- **Nicht** geprüft werden konnten: GUI-Laufzeitverhalten (WPF/WinForms), Abfragen gegen Active Directory, Serverrollen (WSUS, RDS, DNS, DHCP, Hyper-V …) – diese benötigen eine Windows-Testumgebung. PSScriptAnalyzer stand in der Prüfumgebung nicht zur Verfügung.
- Alle Korrekturen sind in den Modul-Changelogs im Detail beschrieben; hier folgt die Zusammenfassung.

---

## Repository / Struktur / Dokumentation

| Bereich | Befund | Status |
|---------|--------|--------|
| Struktur | Mehrere Versionen pro Modul in `# Beta`, `# Versions`, `# Archiv`; Versionsnummern im Dateinamen | ✅ Behoben – ein Skript pro Modul ohne Versionsnummer, ältere Stände über Git-Historie |
| Sicherheit | Kompilierte EXE-Dateien und ZIP-Paket im Repository (nicht prüfbar, nicht reproduzierbar) | ✅ Entfernt, `.gitignore` ergänzt |
| Struktur | Screenshots verteilt in Modul- und `# Screenshots`-Ordnern | ✅ Entfernt |
| Dokumentation | Kein Root-CHANGELOG, keine Modul-Changelogs, kein CONTRIBUTING/SECURITY | ✅ Angelegt |
| Verweise | Root-README nannte nicht existierende Module (`phinit.de_easy…`, `easyHWAudit`) | ✅ Behoben |
| Verweise | Modul-READMEs verlinkten fremde Repositories (`PS-easyIT/easyTools`, `PS-easyIT/easyAuditing`), falsche Skriptnamen und Versionen | ✅ Behoben |
| Verweise | `LICENSE` nur in ActiveDirectory_Audit, aus anderen READMEs verlinkt | ✅ `LICENSE` im Root |
| Dokumentation | `Connections_Audit/readme.md` (Kleinschreibung) | ✅ `README.md` |
| Dokumentation | Fehlende Codeblock-Enden, nicht existierende Parameter (`-DomainController`) und Exportformate (Excel/PDF) beschrieben | ✅ Behoben |
| Sicherheit | Authenticode-Signaturen durch die Korrekturen ungültig | ⚠️ Signaturblöcke entfernt – **Neusignierung durch den Herausgeber erforderlich** |
| Sonstiges | Versehentlich eingecheckte temporäre Dateien (`audit_tmp*.ps1`) | ✅ Entfernt |

---

## ActiveDirectory_Audit

| Bereich | Behoben | Offen |
|---------|---------|-------|
| **Sicherheit** | CSV-/Formel-Injection beim Export; Hochkommas in AD-Filterwerten maskiert; BitLocker-Wiederherstellungsschlüssel standardmäßig maskiert (auch in Exporten); LAPS-Report liest keine Kennwörter | – |
| **Performance** | `-Properties *` reduziert; GPO-, Manager- und Benutzerabfragen gecacht; 413 `+=`-Array-Aufbauten (AST-basiert) durch `List[object]` ersetzt; BitLocker-Wiederherstellungsinformationen mit einer Abfrage statt je Computer | – (verbleibende `+=` sind Zähler, Zeichenketten und kleine feste Listen) |
| **Funktionen** | Fehlende `Show-QuickReport` (47 Buttons ohne Funktion); doppelte `Get-LoginTimeAnalysis`/`Get-OSSummary`; Einzeltreffer-Fehler in `Update-ResultCounters`; falscher Manager-Cache im Organigramm; falsche Configuration-DN; doppeltes `CN=`-Präfix in `Get-ACLAnalysis`; nicht aufgelöste Variable im Site-Filter; 126 Mojibake-Umlaute (u. a. deutsche Gruppennamen) | – (alle 47 Platzhalter-Reports implementiert; `Get-OSSummary` mit EOL-Status inkl. Windows 10; `Write-ADReportLog -Terminal` schreibt in die Konsole; `Get-CircularGroups` findet Zyklen) |
| **GUI** | Platzhalter-Hinweis per MessageBox; Reset-Button-Tippfehler | – (fehlende Steuerelemente ergänzt bzw. toter Code entfernt; Topologie/HeatMap/ReportBuilder im `Loaded`-Ereignis) |
| **Befehle** | AD-Filter-Syntax korrigiert | – (DFSR/FRS-Prüfung per `Get-CimInstance` mit `Get-WmiObject`-Fallback) |
| **Verweise** | Versionsangaben vereinheitlicht | Externe Links in der GUI nicht prüfbar |

## WindowsServer_Audit (WindowsServer_Audit)

| Bereich | Behoben | Offen |
|---------|---------|-------|
| **Sicherheit** | HTML-Kodierung im Berichtskopf; CSV-/Formel-Injection beim Export | – |
| **Performance** | `Win32_Product` durch Registry ersetzt; alle Array-`+=` durch Listen ersetzt; doppelte GPO-Abfrage entfernt; Audits im Hintergrund-Runspace (GUI bleibt bedienbar); WSUS nur benötigte, nicht abgelehnte Updates (max. 200) | – |
| **Funktionen** | `ShowDialog()` vor Funktionsdefinitionen (Zertifikats-/Rollen-Audits nie verfügbar); 249 Zeilen doppelter Funktionen; doppelte Tabelle im Bericht; falscher Berichtstitel; Null-Exception bei Events; sprachunabhängige Domain Admins; WDS-Pfad aus Registry | – (`Get-ADUserAccounts` liefert Benutzerübersicht, FSMO in `Get-ADFSMORoles`; NPAS eigenständig; „keine Ereignisse“ korrekt; `IssuedLicenses` aus `Win32_TSLicenseKeyPack`; DNS-Fallback, DNS-Statistik (Endlosrekursion), DNSSEC und DHCP-Autorisierung korrigiert; alle Funktionen ohne Button verdrahtet oder entfernt) |
| **GUI** | Fehlende Click-Handler der drei Zertifikats-Buttons; responsive Kopfzeile; Fortschrittsanzeige und gesperrte Buttons während eines Audits | – |
| **Befehle** | Nicht existierendes `Get-WsusComputerTargetGroup`; falsche WSUS-, KMS-, DNS-, DHCP-Eigenschaften; `Get-RDSessionHost` ohne `-CollectionName`; `Get-VMSnapshot` ohne VM | – |
| **Verweise** | Versionsangaben (0.4.0/0.4.2) vereinheitlicht; README-Skriptname | – |

## Application_Audit

| Bereich | Behoben | Offen |
|---------|---------|-------|
| **Sicherheit** | HTML-Kodierung im Report-Kopf; CSV-/Formel-Injection beim Export; Exportfehler werden gemeldet | – |
| **Performance** | Registry nur einmal pro Audit gelesen; Listen statt `+=`; Audit im Hintergrund-Runspace mit Fortschrittsanzeige | – |
| **Funktionen** | Export-Filter „System-Programme ausschließen“ wirkungslos; einheitliche Filterlogik (jetzt auch für „Programm-Inventar“); `.Count` bei 0/1 Treffern; feste Kategorien-Reihenfolge im HTML-Report | – |
| **GUI** | Statusanzeige wird während des Audits aktualisiert; Prefetch ohne Admin-Rechte übersprungen; Export-Dialog modal | – |
| **Befehle** | Desktop-Pfad über `[Environment]::GetFolderPath` (OneDrive/Umleitung) | – |
| **Verweise** | README: falscher Skriptname `clAudit_V0.0.1.ps1`, fremde Repository-Links, fehlende LICENSE | – |

## Connections_Audit

| Bereich | Behoben | Offen |
|---------|---------|-------|
| **Sicherheit** | HTML-Injection in beiden Reports; Validierung von `presets.json`; UTF-8-BOM für PS 5.1 | – |
| **Performance** | `ArrayList` statt `+=` im Timer; Hostname-Cache mit asynchronem 1-s-Timeout; HTML-Reports ohne `$html +=` je Zeile | – |
| **Funktionen** | Datenverlust bei `presets.json` unter PS 5.1 (`-AsHashtable`); falscher Log-Pfad; Fehlermeldung beim Preset-Export; Prozess-Cache; IP-Klassifizierung (APIPA, CGNAT, IPv4-mapped IPv6) | – |
| **GUI** | Timer beim Schließen gestoppt; Absturz bei Timer-Ausnahmen; Preset-Validierung; `System.Windows.Forms` nur einmal geladen | – |
| **Befehle** | Nicht existierender Typ `InputDialog`; fehlendes `Microsoft.VisualBasic`-Assembly | – |
| **Verweise** | Versionsangaben (V0.0.3/V0.0.4) vereinheitlicht; `presets.json` relativ zum Skript | – |

---

## Zweite Audit-Runde (14.10.2026)

Erneute Prüfung aller Module nach Pull Request [#1](https://github.com/PS-PhinIT/PhinIT.PowerShell_Auditing-Reporting/pull/1), zusätzlich mit XAML-Prüfung (alle Fenster werden geladen, jede per `FindName` verwendete Referenz existiert, keine undefinierten Ressourcen) und Vereinheitlichung der Oberflächen nach Vorlage **ActiveDirectory_Audit**.

| Modul | Bereich | Befund | Status |
|-------|---------|--------|--------|
| ActiveDirectory_Audit | Funktionen | Button „Circular References“ rief `Get-CircularNestedGroups` auf – ein Platzhalter, der immer „None Found“ lieferte; die echte Erkennung `Get-CircularGroups` war nicht verdrahtet | ✅ Behoben (0.6.7) |
| ActiveDirectory_Audit | Performance | `Get-CircularGroups`: Aufzählung aller Pfade (exponentielle Laufzeit), Startgruppe doppelt gezählt, unnötige Eigenschaften geladen | ✅ Behoben (0.6.7) – Tarjan-Algorithmus (lineare Laufzeit), meldet alle beteiligten Gruppen auch bei sich überschneidenden Zyklen |
| ActiveDirectory_Audit | Funktionen | Toter Code: `Get-ADGroupReportData`, `Get-ADComputerReportData`, `Get-CircularNestedGroups`, `Get-DynamicDistGroups`, `Save-ReportTemplate`/`ReportTemplate`, `Add-SafeEventHandler`, `Update-ResultVisualization`, `Initialize-ResultVisualization` | ✅ Entfernt (0.6.7) |
| ActiveDirectory_Audit | GUI/Verweise | Fußzeile mit festen Pixel-Rändern (überlappend bei kleinen Fenstern); „www.phinit.de“ nur Text, kein Link | ✅ Behoben (0.6.7) |
| WindowsServer_Audit | Funktionen | „Export CSV“ fragte per Ja/Nein-Dialog nach – Schließen des Dialogs erzeugte einen HTML-Export | ✅ Behoben (0.4.5) |
| WindowsServer_Audit | GUI | Abweichendes Design (Kopfzeile, Buttons, Statusleiste), keine Hilfe/Versionsinfo | ✅ Einheitliche Oberfläche (0.4.5) |
| Application_Audit | GUI | Abweichendes Design, Export-Dialog ohne einheitliche Styles, mehrzeilige Statusmeldungen | ✅ Einheitliche Oberfläche (0.0.4) |
| Application_Audit | Verweise | README verlinkte nicht existierende Repositories (`github.com/PS-easyIT/…`) | ✅ Durch PS-PhinIT-Repositories ersetzt |
| Connections_Audit | GUI | `DynamicResource ComboBoxToggleButtonTemplate` nicht definiert (ComboBox-Template unvollständig) | ✅ Entfernt, Standard-ComboBox im AD-Stil (0.0.7) |
| Connections_Audit | GUI | Prozess-Spalten beim Start sichtbar, obwohl „Prozessinformationen anzeigen“ deaktiviert ist; Spalten folgten der Checkbox nicht, wenn ein Preset sie setzt | ✅ Behoben (0.0.7) |
| Connections_Audit | Verweise | Versionsangabe „V0.0.6“ in Log und HTML-Reports fest codiert | ✅ Zentrale `$script:AppVersion` (0.0.7) |
| Connections_Audit | Performance | Aktualisieren und Aufzeichnungs-Timer fragen Verbindungen im UI-Thread ab – bei vielen Verbindungen kurze Hänger möglich | ⚠️ Offen – siehe Empfehlung 6 |
| Alle | Verweise | Versionsangaben an mehreren Stellen fest codiert | ✅ `$script:AppName`/`$script:AppVersion`/`$script:AppDate` je Skript |
| Repository | Dokumentation | Changelog-Einträge ohne Datum, Hinweis „keine Pull Requests“ veraltet, GUI-Vorgaben nicht dokumentiert | ✅ Daten aus der Git-Historie rekonstruiert, PR-Verweise ergänzt, GUI-Vorgaben in [CONTRIBUTING.md](CONTRIBUTING.md) |

**Prüfergebnis:** alle Skripte 0 Parserfehler, UTF-8 mit BOM; alle XAML-Definitionen fehlerfrei ladbar; keine fehlenden `FindName`-Referenzen.

---

## Empfehlungen

1. Skripte nach Prüfung **neu signieren** und kompilierte Versionen ausschließlich als **GitHub Release** veröffentlichen.
2. Funktionstest auf Windows (Domänencontroller, Mitgliedsserver, Client) mit Windows PowerShell 5.1 und PowerShell 7.
3. PSScriptAnalyzer in eine CI-Pipeline aufnehmen.
4. Neu implementierte Reports (ActiveDirectory_Audit) und korrigierte Rollen-Abfragen (WindowsServer_Audit: DHCP-Servereinstellungen, `Get-WBBackupSet`, DNS-Signaturschlüssel) gegen reale Umgebungen verifizieren – Eigenschaftsnamen konnten nur gegen Dokumentation/Mocks geprüft werden.
5. ~~Einheitliche Oberfläche für alle Module umsetzen.~~ ✅ Umgesetzt in der zweiten Audit-Runde (Vorlage: ActiveDirectory_Audit, Vorgaben in [CONTRIBUTING.md](CONTRIBUTING.md#einheitliche-oberfläche-gui)).
6. Connections_Audit: Abfrage der Verbindungen (Aktualisieren/Aufzeichnung) wie in WindowsServer_Audit/Application_Audit in einen Hintergrund-Runspace verlagern.
