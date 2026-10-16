# Changelog – WindowsServer_Audit (WindowsServer_Audit)

Alle nennenswerten Änderungen an `WindowsServer_Audit.ps1` werden in dieser Datei dokumentiert.
Format angelehnt an [Keep a Changelog](https://keepachangelog.com/de/1.1.0/), Versionierung nach [SemVer](https://semver.org/lang/de/).

> **Hinweis zur Herkunft:** Ab 0.4.3 entspricht jeder Eintrag einem Pull Request (siehe Verweis unter der Version).
> Bis zum Import-Commit (19.01.2026) gab es keine Pull Requests – die Einträge bis 0.4.2 wurden daher aus den früher im Ordner
> `# Versions` abgelegten Skriptständen (Vergleich der enthaltenen Funktionen, Header-Angaben, beigelegte Readme der 0.2.3) und der
> README rekonstruiert. Das Datum stammt aus dem jeweiligen Skriptstand (Header bzw. Fußzeile); war dort keines hinterlegt, ist der
> Zeitraum über die benachbarten datierten Stände eingegrenzt.

## [0.4.5] – 14.10.2026

Pull Request: [#2](https://github.com/PS-PhinIT/PhinIT.PowerShell_Auditing-Reporting/pull/2) – zweite Audit-Runde, einheitliche Oberfläche nach Vorlage ActiveDirectory_Audit.

### GUI
- Einheitliches Layout wie ActiveDirectory_Audit: dunkle Kopfzeile mit Titel, Ergebniszähler „Results“ und den Buttons „Help“/„About“; dunkle Fußzeile mit Version/Stand, Statusanzeige (grün = bereit, gelb = Audit läuft, rot = Fehler), Fortschrittsbalken sowie „© PhinIT | www.phinit.de“ (Link öffnet die Website).
- „Export CSV“, „Export HTML“ und „Clear Results“ von der Sidebar in den Kopf der Ergebnis-Karte verschoben; Buttons im einheitlichen Stil (`ModernButton`, deaktiviert halbtransparent) statt grüner/roter Sonderstile.
- Name, Version und Stand zentral in `$script:AppName`, `$script:AppVersion`, `$script:AppDate` (Fenstertitel, Kopf-/Fußzeile, About-Dialog, HTML-Report).

### Hinzugefügt
- Dialoge „Help“ (Kurzanleitung) und „About“ (Version, Stand, Herausgeber).
- `Set-StatusIndicator` für die Statusanzeige; wird beim Start/Ende eines Audits, bei Fehlern und beim Leeren der Ergebnisse gesetzt.

### Behoben
- „Export CSV“ fragte per Ja/Nein-Dialog nach CSV oder HTML – „Nein“ und das Schließen des Dialogs lösten den HTML-Export aus. Der Button exportiert jetzt direkt als CSV; HTML hat einen eigenen Button.

## [0.4.4] – 14.10.2026

Pull Request: [#1](https://github.com/PS-PhinIT/PhinIT.PowerShell_Auditing-Reporting/pull/1)

### Performance
- Audits laufen nicht mehr auf dem UI-Thread: `Start-AuditJob` startet die jeweilige Datensammel-Funktion in einem eigenen Runspace (`RunspaceFactory` + `InitialSessionState` mit `SessionStateFunctionEntry` für die Audit-Funktion und die Hilfsfunktionen `Get-WDSRootPath`/`Get-AuditWinEvent`). Ein `DispatcherTimer` fragt den Abschluss ab (`Complete-AuditJob`), übernimmt das Ergebnis auf dem UI-Thread in die Tabelle und gibt PowerShell-Instanz und Runspace wieder frei (`Remove-AuditJob`). Das Fenster friert nicht mehr ein.
- WSUS (`Get-WSUSUpdates`): `GetUpdates()` lud den kompletten Update-Katalog. Jetzt mit `UpdateScope` (nicht abgelehnt, von mindestens einem Computer benötigt), Gesamtzahl über `GetUpdateCount()`, Ausgabe der neuesten 200 Updates inkl. KB-Nummer und Eingangsdatum sowie Hinweiszeile „x von y angezeigt“.
- Ergebnislisten werden nicht mehr per `$array += …` aufgebaut (jedes `+=` kopiert das komplette Array, quadratischer Aufwand bei vielen Zeilen). Alle 30 Vorkommen nutzen jetzt `[System.Collections.Generic.List[object]]` mit `.Add()` bzw. `.AddRange()` – u.a. in `Get-MemoryDetails`, `Get-StorageSummary`, `Get-NetworkConfiguration`, `Get-NetworkAdapters`, `Get-ActiveConnections`, `Get-FirewallRules`, `Get-LocalUsers`, `Get-ADReplicationStatus`, `Get-DHCPReservations`, `Get-IISBindings`, `Get-RDSActiveLicensing`, `Get-WSUSUpdates`, `Get-FileSharePermissions`, `Get-ADComputerAccounts`, `Get-ADPasswordPolicy`, `Get-ADDCServiceHealth`, `Get-DNSResourceRecords`, `Get-DNSServerStatistics`, `Get-DHCPServerLeases`, `Get-DHCPServerAuthorization`, den Zertifikatsfunktionen und `Get-DomainControllerHealth`. Die Ausgabe an Pipeline/Runspace bleibt unverändert; `Get-DHCPReservations` fügt für Scopes ohne Reservierungen keine leere Zeile mehr hinzu.

### Behoben
- `Get-ADUserAccounts` lieferte FSMO-Rollen statt Benutzerkonten. Jetzt Benutzerkonten-Übersicht (gesamt, aktiviert, deaktiviert, gesperrt, Kennwort läuft nie ab/abgelaufen/nicht erforderlich, nie angemeldet, inaktiv > 90 Tage). Die FSMO-Rollen liefert die neue Funktion `Get-ADFSMORoles`.
- Weitere AD-Funktionen, deren Inhalt nicht zum Namen passte (alle ohne Button und damit ungenutzt), korrigiert: `Get-ADGroupAccounts` (lieferte Gesamtstruktur-Infos → AD-Gruppen), `Get-ADServiceAccounts` (optionale Features → MSA/gMSA), `Get-ADComputerAccounts` (DC-Liste → Computerkonten-Übersicht inkl. Betriebssysteme), `Get-ADPasswordPolicy` (Vertrauensstellungen → Standard-Kennwortrichtlinie und FGPP), `Get-ADReplicationSites` (GPO-Liste → Standorte mit Subnetzen und DCs), `Get-ADReplicationSubnets` (DC-Dienststatus → Subnetze), `Get-ADReplicationSiteLinks` (DCs je Standort → Standortverknüpfungen). Die bisherigen eigenständigen Inhalte bleiben als `Get-ADOptionalFeatures` und `Get-ADDCServiceHealth` erhalten.
- `Get-ADDCServiceHealth`: „Reachable“ war wegen `-ErrorAction SilentlyContinue` immer „Yes“; nicht erreichbare DCs werden jetzt erkannt, fehlende Dienste als `n/a` angezeigt.
- `Get-NPASConfiguration` war eine Kopie von `Get-NASClients` (RADIUS-Clients). Jetzt NPS-Konfiguration: Dienststatus/Starttyp (IAS), Anzahl RADIUS-Clients, Netzwerkrichtlinien (`netsh nps show np`) und Verbindungsanforderungsrichtlinien (`netsh nps show crp`), sprachunabhängig aus den „Schlüssel = Wert“-Zeilen gelesen.
- Ereignisprotokolle: Der Zweig „Keine Events gefunden“ wurde nie erreicht, weil `Get-WinEvent -ErrorAction Stop` bei leerem Ergebnis eine Ausnahme wirft und stattdessen ein „Fehler“ angezeigt wurde. Neue Hilfsfunktion `Get-AuditWinEvent` behandelt `NoMatchingEventsFound` als leeres Ergebnis; betrifft `Get-SystemEvents`, `Get-ApplicationEvents`, `Get-SecurityEvents`, `Get-FailedLogons`, `Get-AccountLockouts` und `Get-PrivilegeAudit`.
- RDS-Lizenzierung (`Get-RDSActiveLicensing`): `Get-RDLicenseConfiguration` hat keine Eigenschaft `IssuedLicenses` (Spalte war immer leer). Lizenzzahlen kommen jetzt je Lizenzserver aus `Win32_TSLicenseKeyPack` (Total, Ausgestellt = `IssuedLicenses` bzw. Total − Verfügbar, Verfügbar); ohne Connection Broker wird der lokale Server abgefragt.
- DNS (`Get-DNSConfiguration`): Der Fallback über `Get-DnsServer` las nicht existierende Eigenschaften (`ComputerName`, `Version` am Gesamtobjekt). Jetzt korrekt über `ServerSetting` (ComputerName, Major-/Minor-/BuildNumber, ListeningIPAddress, RoundRobin, EnableDnsSec), `ServerRecursion.Enable`, `ServerCache.MaxTTL`, `ServerForwarder.IPAddress` und `ServerDiagnostics`. `Get-DnsServerSetting` wird mit `-All` abgefragt.
- Spaltenreihenfolge in der Ergebnistabelle war zufällig (z.B. „Value | Setting“), da die Zeilen aus ungeordneten Hashtables erzeugt wurden – jetzt `[ordered]`.
- `Get-DNSServerStatistics`: Die Funktion hieß (ohne Groß-/Kleinschreibung) wie das Cmdlet `Get-DnsServerStatistics` und rief sich selbst rekursiv auf; außerdem wurden nicht existierende Eigenschaften am Gesamtobjekt gelesen. Jetzt modulqualifizierter Aufruf `DnsServer\Get-DnsServerStatistics` und Auflistung der Unterobjekte `TimeStatistics`, `QueryStatistics`, `RecursionStatistics`, `ErrorStatistics` und `CacheStatistics` (Spalten Bereich/Statistik/Wert).
- `Get-DNSSecSettings`: nutzt jetzt `Get-DnsServerZone` (`IsSigned`) für primäre, nicht automatisch erstellte Zonen, `Get-DnsServerDnsSecZoneSetting` (DenialOfExistence, KeyMasterServer, EnableRfc5011KeyRollover) und `Get-DnsServerSigningKey` (Anzahl KSK/ZSK) statt falscher Eigenschaften.
- `Get-DNSServerScavengingSettings` zeigt zusätzlich `LastScavengeTime`; `Get-DNSResourceRecords` liest `TimeToLive` und die Datensatzdaten generisch aus `RecordData` (max. 20 Zonen × 50 Einträge, ohne automatisch erstellte Zonen/TrustAnchors).
- `Get-DHCPServerAuthorization` lieferte Failover-Daten. Jetzt die in AD autorisierten DHCP-Server über `Get-DhcpServerInDC` (Server, IP, „DieserServer“). Die Failover-Abfrage ist in die neue Funktion `Get-DHCPFailover` gewandert.
- `Get-DHCPConfiguration` zeigt jetzt die Servereinstellungen aus `Get-DhcpServerSetting`, `Get-DhcpServerDatabase` und `Get-DhcpServerVersion` (Spalten Einstellung/Wert).
- `Get-DHCPv4ScopeStatistics` verwendet die korrekten Eigenschaften `InUse`, `Free`, `Reserved`, `PercentageInUse`; `Get-DHCPServerOptions` gibt Mehrfachwerte (z.B. DNS-Server) lesbar aus; `Get-DHCPServerLeases` fragt alle Scopes ab (100 je Scope, max. 1000) inkl. ClientId und Status.
- `Get-DomainControllerHealth` wertet jetzt `dcdiag` zeilenweise aus (OK/Fehler/Info, auch deutsche Ausgabe „bestanden“/„nicht bestanden“).
- Firewall-Profile: `Enabled` ist ein GpoBoolean – „NotConfigured“ wird nicht mehr als aktiviert angezeigt; zusätzlich Standardaktionen ein-/ausgehend und Protokollierung blockierter Verbindungen.
- `Get-SystemBackupConfig` las nicht existierende Eigenschaften von `Get-WBBackupSet`; jetzt BackupTime, VersionId, Sicherungsziel, Volumes und wiederherstellbare Elemente bzw. Hinweis, wenn das Feature fehlt.
- `Get-SQLServerInfo` erkennt auch benannte Instanzen (`MSSQL$*`) und zugehörige Dienste (Agent, Browser, SSIS/SSRS/SSAS).
- `Get-WindowsDefender` (Echtzeitschutz, Signaturversion/-aktualisierung, letzte Scans) und `Get-UserAccountControl` (ConsentPromptBehaviorAdmin, sicherer Desktop, Admin-Genehmigungsmodus) liefern zusätzliche Angaben.

### GUI
- Kopfzeile responsiv: Der Ergebniszähler hatte einen festen `Margin="1475,0,-20,0"` und eine feste Höhe und lag bei kleineren Fenstern über dem Titel bzw. außerhalb des sichtbaren Bereichs. Jetzt Grid-Spalten (`*` / `Auto`), Titel mit `TextTrimming`.
- Während eines Audits werden alle Audit-Buttons deaktiviert, die Statusleiste zeigt die Laufzeit in Sekunden, ein Fortschrittsbalken (indeterminate) und ein Warte-Cursor erscheinen. Abschluss mit „Fertig – n Ergebnis(se) in x s“; Fehler aus dem Runspace (`Streams.Error`) werden angezeigt und in der Konsole ausgegeben.
- Neue Buttons: „User Accounts“ und „FSMO Roles“ (Active Directory) sowie „Groups“, „Service Accounts (MSA/gMSA)“, „Computer Account Summary“, „Password Policy“, „Replication Sites“, „Replication Subnets“, „Site Links“, „Optional Features“ und „DC Service Health“ (AD Advanced Info).
- Bisher ungenutzte Audit-Funktionen über neue Buttons erreichbar: „Firewall Profiles“ (Network), „Windows Server Backup“ (Roles & Features), „Microsoft Defender“ und „UAC Settings“ (Security & Users), „DC Diagnostics (dcdiag)“ (AD Advanced Info), „Resource Records“, „Server Statistics“, „Scavenging“ und „DNSSEC Zones“ (DNS Server), „Authorized Servers (AD)“, „Leases“, „Server Options“, „Scope Statistics“ und „Failover“ (DHCP Server) sowie neue Kategorie „🏢 Server Applications“ mit „SQL Server“, „Exchange Server“ und „SharePoint“.
- Beim Schließen des Fensters wird ein laufender Hintergrund-Audit gestoppt.

### Befehle
- WSUS: `GetUpdates()` → `GetUpdates($scope)` / `GetUpdateCount($scope)` mit `ApprovedStates` und `IncludedInstallationStates`.
- RDS: `Get-RDLicenseConfiguration` + `Get-CimInstance Win32_TSLicenseKeyPack`.
- NPS: `Get-Service IAS`, `Get-NpsRadiusClient`, `netsh nps show np|crp`.
- AD: `Get-ADUser`, `Get-ADGroup`, `Get-ADServiceAccount`, `Get-ADDefaultDomainPasswordPolicy`, `Get-ADFineGrainedPasswordPolicy`, `Get-ADReplicationSubnet`, `Get-ADReplicationSiteLink`.
- DNS: `DnsServer\Get-DnsServerStatistics`, `Get-DnsServerDnsSecZoneSetting`, `Get-DnsServerSigningKey`.
- DHCP: `Get-DhcpServerInDC`, `Get-DhcpServerSetting`, `Get-DhcpServerDatabase`, `Get-DhcpServerVersion`.
- AD: `dcdiag.exe`; Sicherung: `Get-WBBackupSet`.

### Geändert
- Versionsangaben (Header, Fenstertitel, Kopfzeile, HTML-Bericht, README) auf 0.4.4.
- README: Hinweis auf nicht vorhandenes „Vollständiges Audit“ durch Hinweis auf die Hintergrundausführung ersetzt.

### Entfernt
- Doppelte, nie aufgerufene Funktionen: `Get-InstalledRoles` (Duplikat von `Get-InstalledFeatures`, Spalte „Type“ dorthin übernommen), `Get-ServerUpdates` (Duplikat von `Get-WindowsUpdates`, Beschreibung dorthin übernommen), `Get-HyperVInfo` (abgedeckt durch die Hyper-V-Buttons) und `Get-DHCPServerInformation` (abgedeckt durch `Get-DHCPConfiguration`/`Get-DHCPv4Scopes`).
- `Get-NetworkSecurity` in `Get-FirewallProfiles` umbenannt (lieferte nur Firewall-Profile).

## [0.4.3] – 14.10.2026

Pull Request: [#1](https://github.com/PS-PhinIT/PhinIT.PowerShell_Auditing-Reporting/pull/1)

Audit (Sicherheit, Performance, Funktionen, Verweise, GUI, Befehle) – Details siehe [AUDIT.md](../AUDIT.md).

### Sicherheit
- CSV-Export: Schutz vor CSV-/Formel-Injection (`ConvertTo-CsvSafeObject`) – Werte, die mit `=`, `@`, Tab, CR oder mit `+`/`-` gefolgt von Text beginnen, erhalten ein vorangestelltes `'` (Telefonnummern und negative Zahlen bleiben unverändert).
- HTML-Injection im HTML-Berichtskopf behoben: Titel, Kategorie, Servername und Domain werden mit `[System.Net.WebUtility]::HtmlEncode` kodiert (Tabellenzellen kodiert `ConvertTo-Html` bereits).
- Ungültig gewordene Authenticode-Signatur entfernt – das Skript muss vom Herausgeber neu signiert werden.

### Performance
- Installierte Software über die Uninstall-Registry (64/32 Bit) statt `Win32_Product` (langsam, löst MSI-Konsistenzprüfungen/-Reparaturen aus).
- `Update-Output`: `$processedData +=` durch `List[Object]` ersetzt.
- Doppelte, ungenutzte `Get-GPO -All`-Abfrage entfernt.

### Behoben
- `$window.ShowDialog()` stand vor den Zertifikats-/Rollen-Funktionen – diese wurden nie definiert. Aufruf ans Skriptende verschoben.
- 249 Zeilen identisch doppelt vorhandener Funktionen (Zertifikate, Rollen, SQL, Exchange …) entfernt.
- Ergebnistabelle wurde im HTML-Bericht doppelt ausgegeben.
- HTML-Berichtstitel war immer „Fertig“ – der letzte Audit-Titel wird nun in `$script:LastAuditTitle` gemerkt.
- `.Message.Substring()` warf bei Events ohne Meldungstext eine Null-Exception.
- „Domain Admins“ sprachunabhängig über die Domain-SID (RID 512) aufgelöst (deutsche DCs: „Domänen-Admins“).
- `Get-ADReplicationSite` jetzt mit `-Filter *` (lieferte nur den lokalen Standort).
- WDS-Images werden mit `-Recurse` gefunden.
- WDS-Stammordner wird aus der Registry (`WDSTFTP\RootFolder`) gelesen statt fest `C:\RemoteInstall` (Fallback bleibt `C:\RemoteInstall`).

### GUI
- Fehlende Click-Handler für `ButtonInstalledCertificates`, `ButtonCertificateAuthorities` und `ButtonExpiringCertificates` ergänzt.

### Befehle
- Nicht existierendes Cmdlet `Get-WsusComputerTargetGroup` → `$server.GetComputerTargetGroups()`.
- WSUS: `Classification`/`ApprovedCount` → `UpdateClassificationTitle`/`IsApproved`.
- `Get-RDSessionHost` mit Pflichtparameter `-CollectionName` je Session-Collection (blockierte zuvor mit Eingabeaufforderung).
- `Get-VMSnapshot` → `Get-VM | Get-VMSnapshot`.
- KMS: `IsS_Running` → `IsKeyManagementServiceMachine` (Spalte „KMSHost“).
- DNS: nicht existierende Eigenschaften `AllowZoneEditing`, `LogQueries`, `WriteToLog` → Round Robin aus den Servereinstellungen, Logging aus `Get-DnsServerDiagnostics`; `CacheSize` → `MaxKBSize`.
- DHCP: `ToString()` auf CIM-Objekten → Spalten `DnsName` und `IPAddress`.

### Geändert
- Versionsangaben (Header, Fenstertitel, Kopfzeile, HTML-Bericht) auf 0.4.3; zuvor stand dort trotz Dateiname V0.4.2 noch 0.4.0.
- Dateiname ohne Versionsnummer: `WindowsServer_Audit_V0.4.2.ps1` → `WindowsServer_Audit.ps1`.
- README: korrigierter Skriptname, geschlossener Codeblock, Hinweis auf nicht existierende `$DEBUG`-Variable entfernt.

### Entfernt
- Kompilierte EXE-Dateien, ZIP-Paket, alte Skriptversionen (`# Versions`) und Screenshots aus dem Repository.

## [0.4.2] – 19.01.2026

Stand zum Zeitpunkt des Repository-Imports (kein Datum im Skript hinterlegt).

### Hinzugefügt
- Weitere Audits: AD-Benutzer/-Gruppen/-Computer/-Dienstkonten, Kennwortrichtlinie, Replikations-Standorte, -Subnetze und -Standortverknüpfungen, DHCP (Autorisierung, Leases, Optionen, Scope-Statistiken), Zertifizierungsstellen.
- HTML-Export der Audit-Ergebnisse (`Export-AuditResultsToHtml`).

## [0.4.1] – nach 13.07.2025
### Hinzugefügt
- AD-Cluster, erweiterte DC-Informationen, Funktionsebenen, GPO-Zusammenfassung, Standortkonfiguration, DFS-Namespaces und -Replikation, Dateifreigaben inkl. Berechtigungen und Kontingente, Hyper-V-Snapshots und -Switches.

## [0.4.0] – nach 13.07.2025
### Geändert
- Komplettes Redesign: Sidebar-Menü mit Audit-Kategorien links, Output-Bereich rechts; schlankere Codebasis mit eigenständigen Audit-Funktionen (System, Dienste, Events, AD, Netzwerk).

## [0.3.0] – 13.07.2025
### Hinzugefügt
- Debug-Edition mit sicheren Dispatcher-Aufrufen (`Invoke-SafeDispatcher`, `Invoke-SafeDoEvents`) und Panel-Navigation.

## [0.2.3] – 23.05.2025
### Hinzugefügt
- Verbindungsaudit mit 50+ Netzwerk-Audit-Befehlen, TCP/UDP-Analyse mit Prozess-Zuordnung, Netzwerk-Topologie-Mapping, DRAW.IO-Export, Blacklist-/Sicherheitsanalyse, ARP-/MAC-Analyse.

## [0.1.9] – 23.05.2025
### Hinzugefügt
- AD Health Check (DHCP-Discovery, Service-Abhängigkeiten, dcdiag, Zeit-Synchronisation, Sysvol-Replikation).
- Backup & Storage, NPS/Remote Access, Verbindungs-Audit (Grundfunktionen), HTML-Export mit responsivem Design.

## [0.0.12] – 23.05.2025
### Hinzugefügt
- Erste Version: Server-Audit mit Rollen-Erkennung, CMD- und PowerShell-Audit-Befehlen, System-, AD- (ADFS, AD LDS, AD RMS), Sicherheits- und Dienste-Audits, HTML-Export.
