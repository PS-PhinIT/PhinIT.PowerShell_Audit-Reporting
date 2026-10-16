# Changelog – Application_Audit (Client Audit Tool)

Alle nennenswerten Änderungen an `Application_Audit.ps1` werden in dieser Datei dokumentiert.
Format angelehnt an [Keep a Changelog](https://keepachangelog.com/de/1.1.0/), Versionierung nach [SemVer](https://semver.org/lang/de/).

> **Hinweis zur Herkunft:** 0.0.1 ist der Stand des Repository-Imports (19.01.2026, Datum aus dem Skript-Header).
> Ab 0.0.2 entspricht jeder Eintrag einem Pull Request (siehe Verweis unter der Version).

## [0.0.4] – 14.10.2026

Pull Request: [#2](https://github.com/PS-PhinIT/PhinIT.PowerShell_Auditing-Reporting/pull/2) – zweite Audit-Runde, einheitliche Oberfläche nach Vorlage ActiveDirectory_Audit.

### GUI
- Komplett neues Layout wie ActiveDirectory_Audit: dunkle Kopfzeile mit Titel, Zählern „Categories“/„Total Results“ und den Buttons „Help“/„About“; Sidebar mit aufklappbaren Bereichen „System“, „Audit-Kategorien“ und „Filter“ sowie dem Button „▶ Audit starten“; Ergebnis-Karte mit Ansichtsauswahl, „Export“, „Clear Results“, Tabelle und Zusammenfassung; dunkle Fußzeile mit Version/Stand, Statusanzeige (grün/gelb/rot), Fortschrittsbalken und „© PhinIT | www.phinit.de“.
- Tabelle im einheitlichen Stil (Kopfzeile, Zeilenabstände, Auswahlfarbe wie ActiveDirectory_Audit).
- Export-Dialog im gleichen Stil (Farben, Schrift, Buttons aus dem Hauptfenster), Höhe passt sich dem Inhalt an.
- Mehrzeilige Statusmeldungen (z. B. Hinweise und Fehler nach dem Audit) werden in der einzeiligen Fußzeile mit „|“ zusammengefasst; der vollständige Text steht im Tooltip.
- Prefetch-Analyse ist als „(Admin)“ gekennzeichnet; ohne Administrator-Rechte erklärt ein Tooltip, dass die Kategorie übersprungen wird.

### Hinzugefügt
- Dialoge „Help“ (Kurzanleitung) und „About“ (Version, Stand, Herausgeber).
- HTML-Report mit Fußzeile „Erstellt mit Application_Audit v… · © PhinIT“.

### Geändert
- Name, Version und Stand zentral in `$script:AppName`, `$script:AppVersion`, `$script:AppDate` (Fenstertitel, Kopf-/Fußzeile, About-Dialog, HTML-Report).
- Herausgeber-Angaben vereinheitlicht: „PhinIT“ statt „PS-easyIT“ (Skript-Header, Fenstertitel).

## [0.0.3] – 14.10.2026

Pull Request: [#1](https://github.com/PS-PhinIT/PhinIT.PowerShell_Auditing-Reporting/pull/1)

### Performance
- Datensammlung läuft in einem Hintergrund-Runspace (`System.Management.Automation.PowerShell` + `RunspaceFactory`) – das Fenster friert während des Audits nicht mehr ein. Die benötigten Funktionen (`Invoke-ClientAudit`, `Get-InstalledProgramsFromRegistry`, `Test-IsWindowsProgram`) werden per `InitialSessionState`/`SessionStateFunctionEntry` übergeben.
- Array-Aufbau per `+=` vollständig entfernt: Sammlungen werden über `List[object]` bzw. `@(...)`-Pipelines aufgebaut (verbleibende `+=` sind nur noch Zeichenketten-Verkettungen).

### GUI
- Ausgewählte Kategorien/Optionen (inkl. Administrator-Status für die Prefetch-Analyse) werden vor dem Start im UI-Thread gelesen und als Parameter übergeben.
- Fortschrittsanzeige mit Prozentwert und aktuellem Schritt („Schritt x/y“) über synchronisierte Hashtable + `DispatcherTimer`.
- Während des Audits sind „Audit starten“, „Export“, „Ergebnisse löschen“, Datenansicht und Optionen deaktiviert.
- Beim Schließen des Fensters wird der Timer gestoppt, ein laufendes Audit abgebrochen und PowerShell/Runspace freigegeben.
- Dispatcher-Render-Workaround in `Update-Status` entfernt (nicht mehr nötig).
- Export-Dialog wird über dem Hauptfenster zentriert (`CenterOwner`).

### Behoben
- Hinweise (z. B. „Prefetch-Analyse erfordert Administrator-Rechte“) wurden sofort von der nächsten Statusmeldung überschrieben – sie erscheinen jetzt in der Abschlussmeldung.
- Fehler einzelner Kategorien (z. B. fehlendes `Get-AppxPackage`) werden nicht mehr stillschweigend verschluckt, sondern im Status gemeldet; Fehler aus `Streams.Error`/Ausnahmen des Runspaces werden zusätzlich als Warnung ausgegeben.
- Desktop-Verknüpfungen: tatsächliche Desktop-Ordner werden verwendet (`[Environment]::GetFolderPath('Desktop'/'CommonDesktopDirectory')`, berücksichtigt Ordnerumleitung/OneDrive) statt fest `%USERPROFILE%\Desktop`.
- Start ohne ausgewählte Kategorie wird mit Hinweis abgefangen; Zusammenfassung wird bei neuem Audit zurückgesetzt.
- Export-Dialog: doppeltes Schließen (`DialogResult` + `Close()`) entfernt.
- Option „Windows-Programme ausschließen“ (Hauptfenster) wirkt jetzt auch auf *Programm-Inventar* (wie der Export-Filter).
- HTML-Report (und CSV-Export) verwenden eine feste Kategorien-Reihenfolge – dieselbe wie in der GUI (`[ordered]`-Datenspeicher statt Hashtable).

## [0.0.2] – 14.10.2026

Pull Request: [#1](https://github.com/PS-PhinIT/PhinIT.PowerShell_Auditing-Reporting/pull/1)

Audit (Sicherheit, Performance, Funktionen, Verweise, GUI, Befehle) – Details siehe [AUDIT.md](../AUDIT.md).

### Sicherheit
- CSV-Export: Schutz vor CSV-/Formel-Injection (`ConvertTo-CsvSafeObject`) – Werte, die mit `=`, `@`, Tab, CR oder mit `+`/`-` gefolgt von Text beginnen, erhalten ein vorangestelltes `'` (Telefonnummern und negative Zahlen bleiben unverändert).
- HTML-Report: Computername, Benutzername und Kategorie-Überschriften werden mit `[System.Net.WebUtility]::HtmlEncode` kodiert (Tabellenwerte kodiert `ConvertTo-Html` bereits).
- Export-Fehler werden nicht mehr stillschweigend verschluckt, sondern als Warnung ausgegeben.

### Performance
- Registry-Uninstall-Schlüssel werden pro Audit nur noch einmal gelesen (gemeinsam für „Installierte Programme“ und „Programm-Inventar“, `Get-InstalledProgramsFromRegistry`).
- Desktop-Verknüpfungen: `+=`-Array durch `List[object]` ersetzt.

### Behoben
- Export-Option „System-Programme ausschließen“ war wirkungslos (geprüft wurden die nicht existierenden Schlüssel `InstalledPrograms`/`StoreApps` und die falsche Eigenschaft `Name`). Wirkt jetzt auf *Installierte Programme*, *Windows Store Apps* und *Programm-Inventar*.
- GUI- und Export-Filter verwenden dieselbe Logik (`Test-IsWindowsProgram`: Microsoft/Windows/Update/KB-Nummern/System32) – entspricht der README.
- Ergebnisse konsequent als Array (`@(...)`), damit `.Count` bei 0/1 Treffern stimmt.
- `ComboBox.Items.Add()` schreibt keine Indizes mehr in die Pipeline.
- Leere Kategorien werden im HTML-Report übersprungen; Tabellenfragmente sauber zusammengefügt.

### GUI
- Statusmeldungen werden während des Audits sofort neu gezeichnet (Dispatcher-Render in `Update-Status`).
- Prefetch-Analyse ohne Administrator-Rechte wird mit Hinweis übersprungen.
- Export-Dialog ist modal an das Hauptfenster gebunden (`Owner`).

### Geändert
- Exportziel ist der tatsächliche Desktop-Ordner (`[Environment]::GetFolderPath('Desktop')`, berücksichtigt Ordnerumleitung/OneDrive).
- Dateiname ohne Versionsnummer: `Application_Audit_V0.0.1.ps1` → `Application_Audit.ps1`.
- README: falscher Skriptname (`clAudit_V0.0.1.ps1`), falsche Repository-Links (`PS-easyIT/easyAuditing`) und nicht vorhandene `LICENSE` korrigiert; Beschreibung des HTML-Reports an die tatsächliche Struktur angepasst.

## [0.0.1] – 19.01.2026
### Hinzugefügt
- Initiales Release mit moderner WPF-GUI.
- 7 Audit-Kategorien: Installierte Programme, Windows Store Apps, Laufende Prozesse, Prefetch-Analyse, Programm-Inventar, Event-Logs, Desktop-Verknüpfungen.
- CSV- & HTML-Export, Filter-Optionen, interaktive Datenansicht.
