# Changelog – PhinIT Auditing & Reporting Suite

Repository-weite Änderungen. Modulspezifische Änderungen stehen in der jeweiligen `CHANGELOG.md`:

| Modul | Aktuelle Version | Changelog |
|-------|------------------|-----------|
| ActiveDirectory_Audit | 0.6.8 | [ActiveDirectory_Audit/CHANGELOG.md](ActiveDirectory_Audit/CHANGELOG.md) |
| WindowsServer_Audit (WindowsServer_Audit) | 0.4.5 | [WindowsServer_Audit/CHANGELOG.md](WindowsServer_Audit/CHANGELOG.md) |
| Application_Audit | 0.0.4 | [Application_Audit/CHANGELOG.md](Application_Audit/CHANGELOG.md) |
| Connections_Audit | 0.0.7 | [Connections_Audit/CHANGELOG.md](Connections_Audit/CHANGELOG.md) |

Format angelehnt an [Keep a Changelog](https://keepachangelog.com/de/1.1.0/). Repository-Einträge sind nach Datum und Pull Request benannt.
Grundlage sind die [Pull Requests](https://github.com/PS-PhinIT/PhinIT.PowerShell_Auditing-Reporting/pulls?q=is%3Apr) des Repositorys; der Stand vor dem ersten Pull Request (Erstimport) wurde aus der Git-Historie rekonstruiert.

## 2026-10-14 – Pull Request [#3](https://github.com/PS-PhinIT/PhinIT.PowerShell_Auditing-Reporting/pull/3): ActiveDirectory_Audit – Korrekturen aus dem Konsolen-Log

### Behoben
- **ActiveDirectory_Audit 0.6.8:** Mehrfach vergebene Risikostufen (fehlendes `break` in überlappenden `switch`-Blöcken) verfälschten Risikostatistiken; einzelne AD-Objekte wurden nicht gezählt (z. B. „No AD Replication Sites found.“ bei genau einem Standort); Delegierungsanalyse fand nie delegierte Objekte; fehlende bzw. falsche Konsolenmeldungen (Failed Authentication, Users by Manager, Honey Tokens). Details: [ActiveDirectory_Audit/CHANGELOG.md](ActiveDirectory_Audit/CHANGELOG.md).

## 2026-10-14 – Pull Request [#2](https://github.com/PS-PhinIT/PhinIT.PowerShell_Auditing-Reporting/pull/2): Zweite Audit-Runde & einheitliche Oberfläche

Zweite Audit-Runde über alle Module (Ergebnisse in [AUDIT.md](AUDIT.md#zweite-audit-runde-14102026)); alle Befunde behoben.

### GUI
- **Einheitliche Oberfläche nach Vorlage ActiveDirectory_Audit** (modern, schlicht) für alle Module: dunkle Kopfzeile mit Zähler-Kacheln und „Help“/„About“, Sidebar mit aufklappbaren Bereichen, Ergebnis-Karte, einheitliche Buttons/Tabellen und Fußzeile mit Version, Statusanzeige (grün/gelb/rot) und „© PhinIT | www.phinit.de“.
  - **WindowsServer_Audit 0.4.5**, **Application_Audit 0.0.4**, **Connections_Audit 0.0.7:** Oberfläche vollständig auf das Design umgestellt.
  - **ActiveDirectory_Audit 0.6.7:** Fußzeile responsiv (statt fester Pixel-Ränder), Link zu www.phinit.de.
- Version, Name und Stand werden in allen Skripten zentral über `$script:AppName`, `$script:AppVersion` und `$script:AppDate` gepflegt (Fenstertitel, Kopf-/Fußzeile, About, HTML-Reports).

### Behoben
- **ActiveDirectory_Audit 0.6.7:** Button „Circular References“ rief die falsche Funktion auf; Zyklen wurden doppelt gezählt; jetzt werden alle an zirkulären Verschachtelungen beteiligten Gruppen gemeldet.
- **WindowsServer_Audit 0.4.5:** „Export CSV“ erzeugte beim Schließen der Rückfrage einen HTML-Export – exportiert jetzt direkt als CSV.
- **Connections_Audit 0.0.7:** nicht definierte Ressource `ComboBoxToggleButtonTemplate` entfernt; Prozess-Spalten beim Start bzw. nach dem Laden eines Presets passend zur Option ein-/ausgeblendet; mehrzeilige Statusmeldungen; fest codierte Versionsangabe „V0.0.6“ in Log und HTML-Reports.

### Performance
- **ActiveDirectory_Audit 0.6.7:** Erkennung zirkulärer Gruppen mit linearer Laufzeit (Tarjan-Algorithmus statt Aufzählung aller Pfade, nur `MemberOf` geladen).

### Entfernt
- **ActiveDirectory_Audit 0.6.7:** nicht verwendeter Code (u. a. `Get-ADGroupReportData`, `Get-ADComputerReportData`, `Get-CircularNestedGroups`, `Get-DynamicDistGroups`, `Save-ReportTemplate`/`ReportTemplate`).
- `.gitignore`: veraltete Einträge für versionierte Markdown-Dateien (`*_v0.3.0.md`); neu `*.log`.

### Dokumentation
- Modul-Changelogs: jede Version mit Datum (aus den alten Skriptständen der Git-Historie rekonstruiert bzw. eingegrenzt) und Verweis auf den Pull Request.
- Modul-READMEs: Versionen, Abschnitt zur Oberfläche; Application_Audit: nicht existierende Links (`github.com/PS-easyIT`) durch PS-PhinIT-Repositories ersetzt.
- [CONTRIBUTING.md](CONTRIBUTING.md): verbindliche GUI-Vorgaben; [SECURITY.md](SECURITY.md): unterstützte Versionen.

### Sicherheit
- Die geänderten Skripte sind unsigniert und **müssen vom Herausgeber neu signiert werden** (`Set-AuthenticodeSignature`).

## 2026-10-14 – Pull Request [#1](https://github.com/PS-PhinIT/PhinIT.PowerShell_Auditing-Reporting/pull/1) (Teil 2): Behebung der offenen Audit-Befunde

Alle in [AUDIT.md](AUDIT.md) als offen geführten Punkte wurden behoben (Details in den Modul-Changelogs):

### Geändert
- **ActiveDirectory_Audit 0.6.6:** alle 47 Platzhalter-Reports als echte Auswertungen implementiert; fehlende Steuerelemente ergänzt bzw. toter GUI-Code entfernt; Topologie/HeatMap/Report-Builder im `Loaded`-Ereignis; 413 `+=`-Array-Aufbauten durch Listen ersetzt; BitLocker-Abfrage gebündelt; BitLocker-Wiederherstellungsschlüssel standardmäßig maskiert; OS-Übersicht mit EOL-Status.
- **WindowsServer_Audit 0.4.4:** Audits laufen im Hintergrund-Runspace (GUI bleibt bedienbar); WSUS-Abfrage begrenzt; falsch benannte/fehlerhafte AD-, NPAS-, RDS-, DNS- und DHCP-Funktionen korrigiert; ungenutzte Funktionen verdrahtet oder entfernt; responsive Kopfzeile.
- **Application_Audit 0.0.3:** Audit im Hintergrund-Runspace mit Fortschrittsanzeige; Filter auch für das Programm-Inventar; feste Kategorien-Reihenfolge im HTML-Report.
- **Connections_Audit 0.0.6:** `System.Windows.Forms` nur einmal geladen; HTML-Reports ohne zeilenweises `+=`.

## 2026-10-14 – Pull Request [#1](https://github.com/PS-PhinIT/PhinIT.PowerShell_Auditing-Reporting/pull/1) (Teil 1): Audit & Neustrukturierung

### Hinzugefügt
- [AUDIT.md](AUDIT.md) mit den Ergebnissen des Code-Audits (Sicherheit, Performance, Funktionen, Verweise, GUI, Befehle) für alle Module.
- `CHANGELOG.md` im Repository-Root und in jedem Modul; die Historie wurde aus den bisherigen Skriptständen rekonstruiert.
- [CONTRIBUTING.md](CONTRIBUTING.md) und [SECURITY.md](SECURITY.md).
- [LICENSE](LICENSE) (MIT) im Repository-Root – bisher nur unter `ActiveDirectory_Audit/LICENSE` vorhanden, gilt jetzt für alle Module.

### Geändert
- **Skript-Dateinamen ohne Versionsnummer:** `ActiveDirectory_Audit.ps1`, `WindowsServer_Audit.ps1`, `Application_Audit.ps1`, `Connections_Audit.ps1`. Die Version wird über Skript-Header, GUI, README und CHANGELOG ausgewiesen.
- Neue, flache Ordnerstruktur: je Modul nur Skript, `README.md`, `CHANGELOG.md` (plus modulspezifische Dateien wie `presets.json`, `WIKISITE.md`).
- Die bisherigen Beta-Stände wurden zur aktuellen Version: ActiveDirectory_Audit 0.6.4 → 0.6.5, Connections_Audit 0.0.4 → 0.0.5.
- Root-README: nicht existierende Modulnamen (`phinit.de_easy…`) und das nicht vorhandene Modul `easyHWAudit` entfernt, Beschreibung von `Connections_Audit` (Verbindungs-Monitor statt Port-Scan) korrigiert, Modulübersicht und Ordnerstruktur ergänzt, verwaisten Codeblock entfernt.
- `Connections_Audit/readme.md` → `Connections_Audit/README.md`.
- Alle Modul-READMEs: falsche Repository-Links (`PS-easyIT/easyTools`, `PS-easyIT/easyAuditing`), falsche Skriptnamen/Versionen, nicht existierende Parameter (`-DomainController`) und Export-Formate (Excel/PDF) korrigiert.
- `.gitignore`: `*.exe` und `*.zip` werden nicht mehr versioniert.

### Entfernt
- Alle kompilierten EXE-Dateien.
- Alle alten Skriptversionen (`# Versions`, `# Beta`, `# Archiv`) inkl. ZIP-Paket – weiterhin über die Git-Historie abrufbar.
- Alle Screenshots (`# Screenshots`, Screenshots in Modulordnern).
- Versehentlich eingecheckte temporäre Audit-Hilfsskripte (`audit_tmp*.ps1`).

### Sicherheit
- Die geänderten Skripte enthalten keine (durch die Korrekturen ungültig gewordene) Authenticode-Signatur mehr und **müssen vom Herausgeber neu signiert werden** (`Set-AuthenticodeSignature`).

## 2026-01-19 – Erstimport (vor dem ersten Pull Request)
### Hinzugefügt
- Repository angelegt, README überarbeitet.
- Import der Module ActiveDirectory_Audit, WindowsServer_Audit, Application_Audit und Connections_Audit inkl. älterer Versionen, EXE-Dateien und Screenshots.
