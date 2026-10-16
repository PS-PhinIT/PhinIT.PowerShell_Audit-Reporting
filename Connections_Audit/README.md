# Connections_Audit - Network Connections Monitor
## Admin Edition mit WPF GUI

![Version](https://img.shields.io/badge/Version-0.0.8-blue)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%20%7C%207.x-green)
![OS](https://img.shields.io/badge/OS-Windows-blue)
![Status](https://img.shields.io/badge/Status-Active-brightgreen)

> Skript: [`Connections_Audit.ps1`](Connections_Audit.ps1) · Beispiel-Presets: [`presets.json`](presets.json) · Änderungen: [CHANGELOG.md](CHANGELOG.md) · Lizenz: [LICENSE](../LICENSE)
>
> Die Version steht nicht im Dateinamen, sondern im Skript-Header, im Fenstertitel, in der Fußzeile und in der [CHANGELOG.md](CHANGELOG.md).
>
> **Aktuelle Version:** 0.0.8 – 15.10.2026

---

## 📋 Beschreibung

**Connections_Audit** ist ein leistungsstarkes PowerShell-Tool mit grafischer WPF-Benutzeroberfläche zur Überwachung und Analyse von Netzwerkverbindungen in Echtzeit. Das Tool wurde für fortgeschrittene Netzwerk-Diagnosen und Sicherheitsüberwachung entwickelt.

### Hauptmerkmale
- ✅ **Echtzeit-Überwachung** von TCP und UDP Verbindungen
- ✅ **Farbcodierte Kategorisierung** nach Dienstart (Web, Email, Datenbank, etc.)
- ✅ **Lazy Loading** für schnelle Startzeiten
- ✅ **Aufzeichnung pro Remote-IP** mit Anzahl neu beobachteter TCP-Sockets, Ports und erster/letzter Sichtung
- ✅ **HTML-Export** für Reports und Dokumentation
- ✅ **Optionale Prozessinformationen** für detaillierte Analyse
- ✅ **Erweiterte Filterung** nach Protokoll, Richtung und Kategorie
- ✅ **Performance-optimiert** - nur ~2-3 Sekunden Startzeit

### 🖥️ Oberfläche
Einheitliches PhinIT-Design (Vorlage: ActiveDirectory_Audit):
- **Kopfzeile:** Titel mit Version, Zähler „Connections“ (angezeigt) und „Recorded“ (aufgezeichnet), „Help“ (Kurzanleitung) und „About“ (Version/Stand).
- **Sidebar (links)**, aufklappbar:
  - **Aktionen:** „🔄 Aktualisieren“, „⏺ Aufzeichnung starten/stoppen“, „📊 HTML Export“
  - **Filter:** Netzwerk, Protokoll (TCP/UDP), Richtung, Kategorie, Service, „Prozessinformationen anzeigen“
  - **Presets:** Auswahl sowie „Laden“, „Speichern“, „Löschen“
- **Ergebnis-Karte (rechts):** Verbindungstabelle, Zeilenfarbe = Kategorie.
- **Fußzeile:** Version/Stand, Statusanzeige (grün = bereit, gelb = Aufzeichnung läuft, rot = Fehler) mit einzeiliger Statusmeldung (vollständiger Text im Tooltip), Link zu www.phinit.de.

---

## 🎯 Features (seit Version 0.0.3)

### Neue Features
| Feature | Beschreibung |
|---------|-------------|
| **Checkbox "Prozessinfo anzeigen"** | Prozess-ID und Name nur bei Bedarf anzeigen |
| **Dynamische Spalten** | DataGrid-Spalten werden je nach Einstellung angezeigt/verborgen |
| **Verbesserte Performance** | 30-40% schneller bei First Load ohne Prozessinformationen |
| **Intelligente Prozess-Auflösung** | Nur bei Bedarf geladen, reduziert Systemlast |

### Farbcodierte Kategorien
```
🔵 Web Services        (Blau)      → HTTP, HTTPS
🟠 Email Services      (Orange)    → SMTP, POP3, IMAP, Exchange
🟢 Database Services   (Grün)      → SQL Server, MySQL, PostgreSQL, Oracle, MongoDB, Redis
🟣 Directory Services  (Violett)   → LDAP, LDAPS, AD Replication, Kerberos
🔴 Remote Access       (Rot)       → SSH, Telnet, RDP, VNC, TeamViewer, WinRM
🟡 File Services       (Gelb)      → FTP, FTPS, SMB/CIFS, NFS, NetBIOS
⚫ Monitoring          (Grau)      → SNMP, Syslog, NTP
🔷 Virtualization      (Türkis)    → Hyper-V, VMware
```

---

## 📊 Unterstützte Protokolle

### Web Services
```
HTTP (80, 8080, 8008, 8000)
HTTPS (443, 8443, 8444)
```

### Email Services
```
SMTP (25, 587, 465)
POP3 (110, 995)
IMAP (143, 993)
Exchange (25, 80, 110, 143, 443, 993, 995, 587, 465)
```

### Database Services
```
SQL Server (1433, 1434)
MySQL (3306)
PostgreSQL (5432)
Oracle (1521, 1522)
MongoDB (27017, 27018, 27019)
Redis (6379)
```

### Directory Services
```
LDAP (389)
LDAPS (636)
AD Replication (135, 389, 636, 3268, 3269, 53, 88, 445)
Kerberos (88, 464)
```

### Remote Access
```
SSH (22)
Telnet (23)
RDP (3389)
VNC (5900-5905)
TeamViewer (5938)
WinRM (5985, 5986)
PowerShell (5985, 5986)
```

### File Services
```
FTP (21, 20)
FTPS (990, 989)
SMB/CIFS (445, 139, 137, 138)
NFS (2049, 111)
NetBIOS (137, 138, 139)
```

### Monitoring
```
SNMP (161, 162)
Syslog (514)
NTP (123)
DNS (53)
DHCP (67, 68)
RADIUS (1812, 1813)
TACACS+ (49)
```

### Virtualization
```
Hyper-V (2179, 5985, 5986)
VMware (443, 902, 903, 8080, 8443)
```

---

## 🎬 Aufzeichnungsfunktion

Die Aufzeichnung fragt alle **3 Sekunden** (zuzüglich Abfragedauer) die gefilterten
Verbindungen ab. In Tabelle und HTML erscheint **genau eine Zeile je Remote-IP**:
wechselnde Client-Ports, lokale Service-Ports und Dienste erzeugen keine weiteren
IP-Zeilen. Beobachtete lokale/entfernte Ports und aus Ports abgeleitete Dienste werden
als Mengen gesammelt. Dies ist keine Protokollanalyse.

**Anzahl TCP** zählt neu **beobachtete TCP-Sockets**, nicht Polling-Durchläufe:
Ein Socket in aufeinanderfolgenden Snapshots zählt einmal, auch bei Status-/PID-Wechsel.
Nach einem Snapshot ohne diesen Socket zählt eine erneute Sichtung wieder.
`CreationTime` unterscheidet wiederverwendete Endpunkte, soweit Windows sie liefert;
fehlt sie, bleiben nur die Endpunktdaten zur Unterscheidung.
TCP-Listener ohne Gegenstelle werden ausgelassen.

**Keine Mail-/Request-Zählung:** Eine TCP-Verbindung kann viele Nachrichten/Requests
transportieren. Kurzlebige Verbindungen zwischen Abfragen können vollständig fehlen.
Erste/letzte Sichtung sind Beobachtungszeiten, keine exakten Verbindungszeiten.
UDP liefert keine Remote-Clientdaten: separate, eindeutig beschriftete Zeilen je
**lokaler Adresse/Port**, mit Anzahl `N/A`, nicht eine gemeinsame Remote-IP „N/A“.

### Verwendung
1. **Gewünschte Filter einstellen**
2. Für die Aufzeichnung werden **keine DNS-/Prozessabfragen** ausgeführt; diese Optionen gelten weiterhin für die Live-Ansicht.
3. **"Aufzeichnung starten" klicken** 
   - Button wird rot („⏹ Aufzeichnung stoppen“), Statusanzeige in der Fußzeile gelb
   - Filter werden beim Start festgehalten und während der Aufzeichnung gesperrt.
   - „Recorded“ zählt IP-/UDP-Endpunktzeilen, nicht TCP-Sockets; „Anzahl TCP“ steht je IP in der Tabelle.
4. **Gewünschte Zeit warten**
5. **"Aufzeichnung stoppen" klicken**
   - Automatischer Export-Dialog öffnet sich
   - Report wird als HTML gespeichert
   - Zusammenfassung bleibt auch bei „Aktualisieren“ oder Preset-/Filterwechsel sichtbar.
   - Erst **„Live-Ansicht laden“** wechselt zurück zur normalen Verbindungsliste.
   - „HTML Export“ sichert die Zusammenfassung auch später oder als Zwischenstand.
   - Ein neuer Aufzeichnungsstart setzt die bisherige Aufzeichnung vollständig zurück.

### Beispiel: Clients eines alten Exchange-Servers finden
Auf dem Exchange-Server **„Nur TCP“**, **„Eingehend“**, **„Alle Kategorien“** und
Service **„SMTP 25 + POP3S 995“** wählen, dann die Aufzeichnung mehrere Stunden
laufen lassen. Der Service filtert in dieser Richtung **ausschließlich lokale Ports
25 und 995**. Ein Client, der beide Dienste mit wechselnden Quellports nutzt, bleibt
eine IP-Zeile mit gemeinsamem TCP-Zähler. Das allgemeine Service-Filter „Exchange“
umfasst dagegen weitere Ports. Adressen hinter NAT erscheinen als gemeinsame IP.

### Ressourcen und Fehler
- Höchstens **10.000 IP-/UDP-Endpunktzeilen** und **50.000 aktuelle TCP-Socketidentitäten**.
- Wird eine Grenze überschritten oder schlägt eine Abfrage fehl, stoppt die
  Aufzeichnung ausdrücklich mit **roter Fehlermeldung**. Der letzte vollständige
  Snapshot bleibt erhalten, der fehlgeschlagene wird nicht teilweise übernommen.
  Kein automatischer Exportdialog im Timer; über „HTML Export“ sichern.
- Der HTML-Bericht nennt den Stoppgrund und kennzeichnet den unvollständigen Zeitraum.
- Nur der vorherige TCP-Snapshot wird gespeichert, keine historische Socketliste.
  Aggregate werden per Hash nachgeschlagen und direkt aktualisiert; die Tabelle
  wird einmal pro Tick aktualisiert. Gespeichert werden höchstens die ersten
  **64 verschiedenen gültigen Ports (0–65535) je Zeile und Seite**; Dienstmengen
  sind auf die festen Port-Zuordnungen begrenzt.
- Weitere Ports werden nicht gespeichert und mit **„weitere Ports nicht
  gespeichert“** in Tabelle und HTML markiert. Der HTML-Bericht nennt zusätzlich
  die Anzahl betroffener Zeilen. **TCP-Zählung und Diensterkennung laufen für alle
  beobachteten Sockets/Ports weiter**; diese Port-Historiengrenze stoppt die
  Aufzeichnung nicht und verändert keine Verbindungszähler.
- Lange Portlisten zeigen in der Tabelle eine Vorschau (bis 16 Werte) mit
  Portanzahl bzw. Auslassungshinweis, damit der Aufwand pro Tick nicht mit der Port-Historie wächst.
  **Der HTML-Bericht enthält alle bis zu 64 gespeicherten Ports je Seite**,
  nicht nur die Vorschau; ausgelassene weitere Ports werden ausdrücklich benannt.
- Der Hostname-Cache der Live-Ansicht enthält maximal **10.000 Einträge**;
  danach wird für neue Adressen ohne DNS-Abfrage die IP angezeigt.
  Ein neuer Aufzeichnungsstart leert auch diesen Cache.

### Export-Report enthält
- Zeitstempel (Start/Ende)
- Erfassungsdauer
- TCP-Remote-IP-/UDP-Endpunktzahlen und Summe neu beobachteter TCP-Sockets
- Je IP: Anzahl TCP, erste/letzte Sichtung, lokale/entfernte Ports und Dienste
- Klar getrennte lokale UDP-Endpunkte ohne vorgetäuschte Remote-Clientdaten
- Zählweise, Polling-Grenzen, Erfassungsstatus und gegebenenfalls Stoppgrund
- System-Informationen (Computer, Benutzer)
- Kategorie-Filter Information


---

## 🧩 Filter-Presets

Das Tool unterstützt gespeicherte Filter-Kombinationen:

- Presets werden in einer `presets.json` **im selben Ordner wie das Skript bzw. die EXE** gespeichert.
- Fehlt die Datei, wird sie beim Start mit den 7 Standard-Presets angelegt.
- Eigene Presets ergänzen bzw. überschreiben die Standard-Presets ("Preset speichern" / "Preset löschen").
- Eine beschädigte `presets.json` wird **nicht** überschrieben – es werden dann nur die Standard-Presets verwendet.
- Die mitgelieferte [`presets.json`](presets.json) enthält Beispiel-Presets und wird direkt verwendet.
- Das Skript läuft unter **Windows PowerShell 5.1** (auch als PS2EXE-Kompilat) und **PowerShell 7.x**.

### Starten
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\Connections_Audit.ps1
```

> Hinweis: Das Skript ist aktuell nicht Authenticode-signiert (siehe [CHANGELOG.md](CHANGELOG.md)).

---

### Verwendete Libraries
```powershell
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName Microsoft.VisualBasic   # ab V0.0.5 (InputBox für Preset-Namen)
```

### Hauptfunktionen
| Funktion | Zweck |
|----------|-------|
| `Get-NetworkConnections()` | Ruft TCP/UDP-Verbindungen ab und filtert diese |
| `Get-ProcessNameCached()` | Resolves Process Names mit Caching |
| `Get-HostnameFast()` | Live-Hostname-Auflösung mit 1 s Timeout und maximal 10.000 Cache-Einträgen |
| `ConvertTo-HtmlSafe()` | HTML-Kodierung aller Report-Werte (ab V0.0.5) |
| `Get-CategoryAndColor()` | Bestimmt Service-Kategorie basierend auf Port |
| `Update-ProcessColumnsVisibility()` | Toggles Prozess-Spalten (beim Start, per Checkbox und beim Laden eines Presets) |
| `Update-StatusBar()` | Statuszeile und Statusanzeige in der Fußzeile (ab V0.0.7) |
| `Update-ConnectionCounters()` | Zähler „Connections“/„Recorded“ in der Kopfzeile (ab V0.0.7) |
| `Start-ConnectionRecording()` | Startet kontinuierliche Aufzeichnung |
| `Stop-ConnectionRecording()` | Beendet Aufzeichnung und exportiert |
| `Update-RecordingData()` | Aktualisiert IP-/Endpunktaggregate anhand des vorherigen TCP-Snapshots |
| `Reset-RecordingData()` | Setzt Aggregate, Snapshot und Aufzeichnungsstatus zurück |
| `Get-RecordingReportHTML()` | Erstellt HTML ohne GUI-/Dateizugriff |
| `Export-RecordingReportHTML()` | Generiert HTML-Report |
| `Export-HTMLReport()` | Exportiert aktuelle Daten als HTML |

### Global Variables
```powershell
$Global:RecordingActive           # Status der Aufzeichnung
$Global:RecordingTimer            # Timer für Aufzeichnung
$Global:RecordedConnections       # ArrayList mit IP-/UDP-Endpunktaggregaten
$Global:RecordedConnectionsHash   # Hash mit Referenzen auf dieselben Aggregate
$Global:PreviousRecordingSockets  # Nur TCP-Identitäten des letzten Snapshots
$Global:ProcessCache              # Prozessname-Cache
$Global:HostnameCache             # Hostname-Cache (ab V0.0.5)
$Global:RecordingStartTime        # Startzeitpunkt
$Global:RecordingCategory         # Aufgezeichnete Kategorie
```

---

## 📋 Changelog

Alle Änderungen sind in der [CHANGELOG.md](CHANGELOG.md) dokumentiert.
