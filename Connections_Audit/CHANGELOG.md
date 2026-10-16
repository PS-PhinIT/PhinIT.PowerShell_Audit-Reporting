# Changelog – Connections_Audit

Alle nennenswerten Änderungen an `Connections_Audit.ps1` werden in dieser Datei dokumentiert.
Format angelehnt an [Keep a Changelog](https://keepachangelog.com/de/1.1.0/), Versionierung nach [SemVer](https://semver.org/lang/de/).

> **Hinweis zur Herkunft:** Ab 0.0.5 entspricht jeder Eintrag einem Pull Request (siehe Verweis unter der Version).
> Bis zum Import-Commit (19.01.2026) gab es keine Pull Requests – die Einträge bis 0.0.4 wurden aus den früher in `# Archiv` / `# Beta`
> abgelegten Skriptständen und der README rekonstruiert. Diese Skriptstände enthielten keine Datumsangaben; angegeben ist daher das
> Datum des Repository-Imports (19.01.2026), an dem alle Stände gemeinsam eingecheckt wurden.

## [0.0.8] – 15.10.2026

Pull Request: siehe [Pull Requests zu Connections_Audit](https://github.com/PS-PhinIT/PhinIT.PowerShell_Auditing-Reporting/pulls?q=is%3Apr+Connections_Audit).

### Geändert
- Aufzeichnung: genau eine Zeile je Remote-IP, unabhängig von wechselnden Client-Ports, lokalen Service-Ports und Diensten; Anzahl neu beobachteter TCP-Sockets, erste/letzte Sichtung und Port-/Dienstmengen in Tabelle und HTML.
- TCP-Zählung anhand des vorherigen Snapshots einschließlich `CreationTime`, soweit verfügbar; persistente Sockets und Status-/PID-Wechsel erhöhen den Zähler nicht. Nach einem fehlenden Snapshot wird erneut gezählt.
- UDP wird getrennt als lokaler Adresse-/Port-Endpunkt ohne Remote-Clientdaten und ohne Verbindungszähler ausgewiesen. TCP-Listener ohne Gegenstelle entfallen aus der Aufzeichnung.
- Report und Hilfe erklären Polling-Grenzen: keine Mail-/Request-Zählung, kurzlebige Verbindungen können fehlen; Dienste werden nur aus Ports abgeleitet.

### Hinzugefügt
- Service-Filter „SMTP 25 + POP3S 995“ für die gemeinsame Auswertung lokaler Ports 25/995 bei Richtung „Eingehend“; Exchange-Beispiel in README und Hilfe.
- Explizite Ressourcenlimits: 10.000 IP-/Endpunktzeilen und 50.000 aktuelle TCP-Socketidentitäten. Überschreitung oder Abfragefehler stoppt mit rotem Fehlerstatus; letzter vollständiger Snapshot bleibt exportierbar. HTML nennt einen vorzeitigen Stopp.

### Performance
- Hashbasierte Aktualisierung derselben Aggregate statt historischer Einzelverbindungen; nur vorheriger TCP-Snapshot, begrenzte Port-/Dienstmengen und eine Tabellenaktualisierung pro Tick.
- Port-Historie auf die ersten 64 verschiedenen Ports je Zeile und Seite begrenzt; weitere Ports werden in Tabelle/HTML als ausgelassen markiert, die Anzahl betroffener Zeilen steht im Report. TCP-Zählung und Diensterkennung laufen für alle Ports weiter. Tabelle mit bis zu 16 Vorschauwerten, HTML mit allen gespeicherten Werten.
- Keine DNS-/Prozessabfragen während der Aufzeichnung; Live-Hostname-Cache auf 10.000 Einträge begrenzt.

### GUI
- Aufzeichnungsfilter beim Start fixiert und während der Aufnahme gesperrt. Zusammenfassung bleibt nach dem Stoppen und bei Aktualisieren/Filterwechsel erhalten; expliziter Button „Live-Ansicht laden“ kehrt zur normalen Ansicht zurück.
- „HTML Export“ exportiert je nach Ansicht Live-Daten oder die IP-Zusammenfassung, auch nach einem Ressourcenstopp ohne rekursiven Exportdialog im Timer.

### Behoben
- TCP-/UDP-Reportzähler auch bei null oder genau einer Zeile unter Windows PowerShell 5.1 korrekt; Aufzeichnungsende bleibt bei späterem Export unverändert.

## [0.0.7] – 14.10.2026

Pull Request: [#2](https://github.com/PS-PhinIT/PhinIT.PowerShell_Auditing-Reporting/pull/2) – zweite Audit-Runde, einheitliche Oberfläche nach Vorlage ActiveDirectory_Audit.

### GUI
- Komplett neues Layout wie ActiveDirectory_Audit: dunkle Kopfzeile mit Titel, Zählern „Connections“/„Recorded“ und den Buttons „Help“/„About“; Sidebar mit aufklappbaren Bereichen „Aktionen“ (Aktualisieren, Aufzeichnung, HTML-Export), „Filter“ (Netzwerk, Protokoll, Richtung, Kategorie, Service, Prozessinfo) und „Presets“ (Laden/Speichern/Löschen); Ergebnis-Karte mit der Verbindungstabelle; dunkle Fußzeile mit Version/Stand, Statusanzeige und „© PhinIT | www.phinit.de“ (vorher „Powered by Andreas Hepp“).
- Die Filterleiste mit horizontalem Scrollen und die feste Mindestbreite von 1300 px entfallen – das Fenster lässt sich bis 1100 × 650 verkleinern.
- Aufzeichnungs-Button wechselt zwischen „⏺ Aufzeichnung starten“ (Standard-Stil) und „⏹ Aufzeichnung stoppen“ (rot) statt der Systemfarben Rot/Grün; die Statusanzeige ist während der Aufzeichnung gelb.
- Statusmeldungen der Aufzeichnung einzeilig (vorher Zeilenumbruch in der Statuszeile); vollständiger Text im Tooltip.
- Tabelle im einheitlichen Stil; ausgewählte Zeilen sind trotz Kategorie-Farbe erkennbar.

### Hinzugefügt
- Dialoge „Help“ (Kurzanleitung) und „About“ (Version, Stand, Herausgeber).
- `Update-StatusBar` (Statuszeile + Statusanzeige) und `Update-ConnectionCounters` (Zähler in der Kopfzeile).

### Behoben
- Die ComboBox-Vorlage verwies auf die nicht definierte Ressource `ComboBoxToggleButtonTemplate` – die Aufklapp-Schaltfläche der Auswahlfelder wurde ohne Vorlage (kein Pfeil, keine sichtbare Schaltfläche) erzeugt. Die fehlerhaften Sondervorlagen für ComboBox und CheckBox wurden entfernt (Standard-Steuerelemente wie in ActiveDirectory_Audit).
- Die Spalten „Prozess ID“/„Prozess Name“ waren beim Start sichtbar, obwohl „Prozessinfo“ deaktiviert ist – die Sichtbarkeit wird jetzt beim Start aus der Checkbox übernommen und folgt der Checkbox über `Checked`/`Unchecked` (statt `Click`), also auch beim Laden eines Presets.
- Ladefehler beim Aktualisieren werden zusätzlich in der Statuszeile (rot) angezeigt.

### Geändert
- Name, Version und Stand zentral in `$script:AppName`, `$script:AppVersion`, `$script:AppDate` (Fenstertitel, Kopf-/Fußzeile, About-Dialog, Log, HTML-Reports – vorher fest „V0.0.6“ im Code).

## [0.0.6] – 14.10.2026

Pull Request: [#1](https://github.com/PS-PhinIT/PhinIT.PowerShell_Auditing-Reporting/pull/1)

Behebung der offenen Punkte aus [AUDIT.md](../AUDIT.md).

### Behoben
- `System.Windows.Forms` wurde zweimal per `Add-Type` geladen (einmal mit unterdrückten Fehlern) – wird jetzt nur einmal vor `EnableVisualStyles()` geladen; ein Ladefehler wird nicht mehr verschluckt.

### Performance
- HTML-Reports (Live und Aufzeichnung): Tabellenzeilen werden gesammelt und einmal zusammengefügt statt per `$html +=` je Verbindung (bei langen Aufzeichnungen quadratischer Aufwand).
- Kategorie-Filter: Port-Liste ohne `+=`-Array-Aufbau.

## [0.0.5] – 14.10.2026

Pull Request: [#1](https://github.com/PS-PhinIT/PhinIT.PowerShell_Auditing-Reporting/pull/1)

Audit (Sicherheit, Performance, Funktionen, Verweise, GUI, Befehle) – Details siehe [AUDIT.md](../AUDIT.md).

### Sicherheit
- HTML-Injection in beiden HTML-Reports behoben: alle Tabellenwerte (Hostnamen aus Reverse-DNS, Prozessnamen, Adressen) und Kopfzeilen werden über `ConvertTo-HtmlSafe` (`[System.Net.WebUtility]::HtmlEncode`) kodiert.
- Inhalt von `presets.json` wird validiert – nur Einträge vom Typ Objekt werden übernommen.
- Ungültig gewordene Authenticode-Signatur entfernt – das Skript muss vom Herausgeber neu signiert werden.
- Datei als UTF-8 mit BOM gespeichert, damit Windows PowerShell 5.1 Umlaute/Emojis korrekt liest.

### Performance
- Aufzeichnung: `$Global:RecordedConnections +=` im 3-Sekunden-Timer durch `ArrayList.Add()` ersetzt.
- Hostname-Auflösung mit Cache (`$Global:HostnameCache`) und asynchroner Auflösung mit 1 s Timeout statt synchronem `GetHostEntry` bei jedem Tick (blockierte die GUI). Langsam auflösende Hosts erscheinen als IP.

### Behoben
- `$Global:LogFile` wurde gesetzt, bevor `ScriptRoot` ermittelt war (Log im Laufwerksstamm).
- `ConvertFrom-Json -AsHashtable` (erst ab PS 6) schlug unter Windows PowerShell 5.1/PS2EXE immer fehl, wodurch `presets.json` mit den Standard-Presets überschrieben wurde (**Datenverlust**). Einlesen jetzt 5.1-kompatibel; eine defekte Datei bleibt unverändert.
- `Export-FilterPresets` meldete auch bei Fehlern „Erfolg“ – jetzt mit Fehlerbehandlung, Rückgabewert, `-Depth 5` und `-LiteralPath`.
- Prozessnamen-Cache wird pro Abfrage neu aufgebaut (falsche Namen nach PID-Wiederverwendung).
- Ausnahmen im Timer-Tick beenden die Anwendung nicht mehr.
- Nicht existierender Typ `[System.Windows.Input.InputDialog]` entfernt – „Preset speichern“ brach dadurch immer ab.
- `Add-Type -AssemblyName Microsoft.VisualBasic` für `InputBox` ergänzt.
- `Test-IsPrivateIP`: Link-local/APIPA (169.254.0.0/16), Carrier-Grade-NAT (100.64.0.0/10) und IPv4-mapped IPv6 (`::ffff:a.b.c.d`) werden nicht mehr als öffentliche Adressen eingestuft.

### GUI
- Aufzeichnungs-Timer wird beim Schließen des Fensters gestoppt.
- Null-Prüfung für das ausgewählte Preset.
- Preset-Name „-- Neues Preset --“ wird beim Speichern abgewiesen.

### Geändert
- Versionsangaben im Skript vereinheitlicht (zuvor teils V0.0.3 in der Datei V0.0.4).
- Pfad zu `presets.json` per `Join-Path` relativ zum Skript-Ordner; die mitgelieferte `presets.json` liegt jetzt direkt neben dem Skript.
- Dateiname ohne Versionsnummer: `Connections_Audit_V0.0.4.ps1` → `Connections_Audit.ps1`.
- `readme.md` → `README.md`.

### Entfernt
- Kompilierte EXE-Datei, alte Skriptversionen (`# Archiv`, `# Beta`) und Screenshots aus dem Repository.

## [0.0.4] – 19.01.2026

Beta-Stand (im Skript-Header noch „V0.0.3“); als 0.0.5 veröffentlicht.

### Geändert
- Überarbeitung der Filter-Presets (Speichern/Laden/Löschen in `presets.json`) und der Lazy-Loading-Logik.

## [0.0.3] – 19.01.2026
### Hinzugefügt
- Checkbox „Prozessinfo anzeigen“ mit dynamischen DataGrid-Spalten (`Update-ProcessColumnsVisibility`).
- Farbcodierte Dienst-Kategorien (`Get-CategoryAndColor`), Unterscheidung privater/öffentlicher Netze (`Test-IsPrivateIP`).
- Aufzeichnung über einen Zeitraum mit HTML-Recording-Report (`Start-/Stop-ConnectionRecording`, `Export-RecordingReportHTML`).
- Erste Filter-Presets (`Import-/Export-FilterPresets`), optionales Logging (`Write-Log`).
### Geändert
- 30–40 % schnellerer Start ohne Prozessinformationen (Lazy Loading).
### Entfernt
- Paketmitschnitt-Funktionen der 0.0.1/0.0.2 (`Capture-Packets`, `Start-/Stop-ContinuousCapture`).

## [0.0.2] – 19.01.2026
### Hinzugefügt
- Gecachte Prozessnamen (`Get-ProcessNameCached`) und schnelle Hostname-Auflösung (`Get-HostnameFast`).

## [0.0.1] – 19.01.2026
### Hinzugefügt
- Initial Release: Verbindungsüberwachung (TCP/UDP), Protokoll-Filterung, kontinuierlicher Mitschnitt und HTML-Export.
