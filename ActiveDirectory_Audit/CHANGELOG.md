# Changelog – ActiveDirectory_Audit

Alle nennenswerten Änderungen an `ActiveDirectory_Audit.ps1` werden in dieser Datei dokumentiert.
Format angelehnt an [Keep a Changelog](https://keepachangelog.com/de/1.1.0/), Versionierung nach [SemVer](https://semver.org/lang/de/).

> **Hinweis zur Herkunft:** Ab 0.6.5 entspricht jeder Eintrag einem Pull Request (siehe Verweis unter der Version).
> Bis zum Import-Commit (19.01.2026) gab es keine Pull Requests – die Einträge bis 0.6.4 wurden daher aus den früher im Ordner
> `# Versions` / `# Beta` abgelegten Skriptständen (Vergleich der enthaltenen Funktionen, Header- und GUI-Versionsangaben) sowie der
> bisherigen Versionshistorie in der README rekonstruiert. Das Datum stammt aus dem jeweiligen Skriptstand („Last Update“);
> war dort keines hinterlegt, ist der Zeitraum über die nächste datierte Version eingegrenzt (z. B. „vor 01.07.2025“).

## [0.6.9] – 15.10.2026

### Behoben
- Security-HeatMap: Gefilterte AD-Benutzer werden für Passwortsicherheit und Kontoaktivität immer als Array gezählt. Einzelne Treffer liefern dadurch keine `ADPropertyValueCollection` mehr an die Division (`op_Division`); leere und mehrfache Treffer werden ebenfalls korrekt gezählt.

## [0.6.8] – 14.10.2026

Pull Request: [#3](https://github.com/PS-PhinIT/PhinIT.PowerShell_Auditing-Reporting/pull/3) – Korrekturen nach Auswertung eines vollständigen Konsolen-Laufs.

### Behoben
- Risikoeinstufungen: In 16 `switch`-Blöcken mit überlappenden Bedingungen (z. B. `{$_ -ge 10}`, `{$_ -ge 7}`, …) fehlte `break` – ein Konto erhielt dadurch mehrere Stufen gleichzeitig (z. B. „Critical High Medium Low“) und wurde in jeder Statistik mitgezählt (z. B. „Critical: 59, High: 1067, Medium: 1204“ bei 1204 Benutzern), die Abteilungsrisiken zeigten dagegen immer 0/0/0. Betroffen: `Get-WeakPasswordPolicyUsers`, `Get-RiskyGroupMemberships`, `Get-PrivilegedAccounts`, `Get-DepartmentStatistics`, `Get-DepartmentSecurityRisks`, `Get-CompromiseIndicators`, `Get-KerberoastableAccounts`, `Get-ASREPRoastableAccounts`, `Get-HoneyTokens`, `Get-HighPrivServiceAccounts`, `Get-FineGrainedPasswordPolicies`, `Get-ACLAnalysis`. Jetzt gilt jeweils nur die höchste zutreffende Stufe.
- Einzelne AD-Objekte: Liefert ein AD-Cmdlet genau ein Objekt, hat dieses in Windows PowerShell 5.1 kein verwendbares `.Count` – Ergebnisse werden jetzt mit `@()` in ein Array gefasst. Dadurch u. a.:
  - Sites & Subnets: „No AD Replication Sites found.“ bei Domänen mit genau einem Standort (z. B. `Default-First-Site-Name`); Site-Links je Standort über den gültigen Filter `SitesIncluded` statt `Sites`.
  - Schema Admin Paths: Gruppe mit genau einem Mitglied wurde als „Empty (Compliant)“ gemeldet.
  - Ebenso in Security Dashboard, Replikationsstatus, Vertrauensstellungen, Quotas & Limits, Authentifizierungsprotokollen, Kennwortrichtlinien-Übersicht und Netzwerktopologie (Division durch 0 bei genau einem DC).
- `Get-DelegationAnalysis` fand nie delegierte Objekte („0 delegated objects found“): `TrustedForDelegation`/`TrustedToAuthForDelegation` sind keine LDAP-Attribute und funktionieren nicht mit `Get-ADObject -Filter`. Jetzt LDAP-Filter auf die `userAccountControl`-Bits bzw. `msDS-AllowedToDelegateTo`; Domänencontroller (unconstrained delegation) und schreibgeschützte Domänencontroller (RODC, constrained delegation) – jeweils Standardkonfiguration – werden als „Info“ ausgewiesen.
- `Get-FailedAuthPatterns`: ohne Treffer fehlte die Abschlussmeldung in der Konsole; Zählung bei genau einem Konto je Bereich korrigiert.
- `Get-UsersByManager`: Die Abschlussmeldung zählte Überschriftzeilen als Benutzer (1205 statt 1204) – jetzt Anzahl Benutzer, Manager und Benutzer ohne Manager; Manageranzahl bei genau einem Manager korrigiert.
- `Get-HoneyTokens`: `PasswordNeverExpires` wurde nicht geladen (Indikator griff nie); Sortierung nach Verdachtsstufe High → Medium → Low statt alphabetisch.

### Geändert
- Konsolenmeldungen von `Get-PrivilegedAccounts` auf Englisch (wie alle übrigen Konsolenmeldungen).
- `Get-HoneyTokens`: Die Abschlussmeldung nennt zusätzlich die Anzahl wahrscheinlicher Honey Tokens (die Gesamtzahl umfasst alle Namens-/Beschreibungstreffer wie `*test*`).
- Debug-Ausgabe „ReportData Typ“ der benutzerdefinierten Abfrage erscheint nur noch mit `$DebugPreference` (`Write-DebugLog`) statt bei jeder Abfrage in der Konsole.

## [0.6.7] – 14.10.2026

Pull Request: [#2](https://github.com/PS-PhinIT/PhinIT.PowerShell_Auditing-Reporting/pull/2) – zweite Audit-Runde; ActiveDirectory_Audit ist die Design-Vorlage für die einheitliche Oberfläche aller Module.

### GUI
- Fußzeile responsiv: drei Spalten (Version/Stand · Statusanzeige · Copyright) statt fester Ränder (620/780 px) – Status und Copyright überlappen bei kleineren Fenstern nicht mehr, lange Statusmeldungen werden gekürzt (`TextTrimming`).
- Einheitliches Branding „© PhinIT | www.phinit.de“ (vorher „© 2025 easyIT - PSScripts.de“); der Link in der Fußzeile öffnet https://www.phinit.de.
- Name, Version und Stand zentral in `$script:AppName`, `$script:AppVersion`, `$script:AppDate` – Fenstertitel, Kopf-/Fußzeile und About-Dialog lesen nur noch diese Werte.

### Behoben
- Quick-Button „Circular References“ rief `Get-CircularNestedGroups` (Verschachtelungsanalyse) statt der Zykluserkennung auf – jetzt `Get-CircularGroups`; ohne Zyklen erscheint „No circular group references found.“ statt einer Platzhalterzeile.
- `Get-CircularGroups`: `NumberOfGroups`/`GroupsInvolved` zählten die Startgruppe doppelt. Jetzt ein Ergebnis je zirkulärer Verschachtelung (stark zusammenhängende Gruppenmenge, auch Gruppe als Mitglied von sich selbst): `GroupsInvolved` listet **alle** beteiligten Gruppen – auch bei mehreren sich überschneidenden Zyklen –, `CircularPath` zeigt den kürzesten Beispielzyklus, `CycleId` ist eindeutig.

### Performance
- `Get-CircularGroups`: Tarjan-Algorithmus (iterativ, lineare Laufzeit, keine Rekursionstiefe) statt Aufzählung aller Pfade (vorher exponentielle Laufzeit bei stark verschachtelten Gruppen); lädt nur `MemberOf` statt `Members`.

### Entfernt
- Nie aufgerufener Code: `Get-ADGroupReportData`, `Get-ADComputerReportData`, `Get-CircularNestedGroups`, `Get-DynamicDistGroups` (Duplikat von `Get-DynamicDistributionGroups`), `Save-ReportTemplate` samt Klasse `ReportTemplate`, `Add-SafeEventHandler`, `Update-ResultVisualization`, `Initialize-ResultVisualization`.

## [0.6.6] – 14.10.2026

Pull Request: [#1](https://github.com/PS-PhinIT/PhinIT.PowerShell_Auditing-Reporting/pull/1)

### Sicherheit
- `Get-BitLockerStatus`: BitLocker-Recovery-Passwörter werden standardmäßig maskiert (z. B. `******-…-123456 (KeyID 1A2B3C4D, 2025-05-01)`) – nur der letzte 6-stellige Block, die Kurz-KeyID aus dem Objektnamen und das Sicherungsdatum sind sichtbar. Damit landen keine vollständigen Schlüssel mehr in der Ergebnistabelle und in CSV/HTML-Exporten. Die Vollanzeige ist nur noch bei explizitem Aufruf mit `Get-BitLockerStatus -ShowFullRecoveryKey` möglich.

### Hinzugefügt
- Alle 47 bisherigen Platzhalter-Quick-Reports durch echte Report-Funktionen ersetzt (`Show-PlaceholderNotice` entfernt). Jede Funktion liefert ein einheitliches Spaltenschema, mindestens eine Hinweiszeile (z. B. „keine Auffälligkeiten“, „kein Zugriff“) und protokolliert über `Write-ADReportLog`:
  - Benutzersicherheit: `Get-KerberosDelegationReport` (unconstrained/constrained/RBCD), `Get-CertificateServicesReport` (CAs + Vorlagen aus dem Configuration-NC, ESC1–ESC4-Indikatoren), `Get-LAPSCoverageReport` (Legacy-LAPS + Windows LAPS, Schemaprüfung, Abdeckung je Computer – Kennwörter werden nicht gelesen), `Get-ProtectedUsersReport`, `Get-AuthenticationPolicyReport`, `Get-NTLMAuditReport` (NTLM-Einstellungen der DCs per WinRM/Remote-Registry + Event 8004), `Get-PreWin2000AccessReport`, `Get-PAWReport` (Heuristik wird im Report ausgewiesen), `Get-PasswordSprayReport` (4625/4771 am PDC-Emulator, Zeitfenster-Gruppierung), `Get-PasswordComplexityReport` (Domänenrichtlinie + PSOs), `Get-SmartCardRequiredReport`, `Get-KerberosEncryptionTypesReport` (DES/RC4-only/nicht gesetzt).
  - Angriffsindikatoren: `Get-GoldenTicketIndicators` (krbtgt- und RODC-krbtgt-Kennwortalter), `Get-SilverTicketIndicators`, `Get-PassTheHashIndicators` (NTLM-/Logon-Typ-9-Anmeldungen privilegierter Konten auf DCs), `Get-SkeletonKeyIndicators` (RunAsPPL auf DCs, Event 7045).
  - Gruppen/Benutzer: `Get-NestedGroupDepthReport` (zyklensicher, mit Cache), `Get-GroupMembershipTimelineReport` (`Get-ADReplicationAttributeMetadata -ShowAllLinkedValues`), `Get-UPNConflictReport`, `Get-ManagerChainReport`, `Get-MultipleEmailAddressReport`, `Get-AdminCountAnomalyReport`, `Get-NamingConventionReport` (Regex anpassbar über `$Global:EasyADNamingConvention`).
  - Computer: `Get-ComputerTrustErrorReport` (inkl. Netlogon-Events 5722/5723/5805), `Get-IPv6ReadinessReport`, `Get-ComputerLifecycleReport`.
  - GPO: `Get-GPOBackupStatusReport` (optionaler Backup-Ordner per Ordnerauswahl), `Get-GPOVersionDiscrepancyReport` (AD- vs. SYSVOL-Version), `Get-WMIFilterReport`, `Get-GPOLoopbackReport`.
  - Compliance/Audit: `Get-AuditPolicyComplianceReport` (GPO-XML + `auditpol` am PDC, sprachunabhängig über Subkategorie-GUIDs), `Get-ObjectAccessAuditingReport` (SACLs kritischer Container), `Get-PrivilegedOperationReport` (4672/4728/4732/4756), `Get-AccountLockoutTrackingReport` (gesperrte Konten + 4740 mit Aufrufer), `Get-LoginTrendReport`, `Get-AccountCreationTrendReport`, `Get-GroupMembershipChangeReport` (30 Tage), `Get-PasswordChangeFrequencyReport`, `Get-PCIDSSComplianceReport` (PASS/FAIL nach PCI-DSS v4.0, Abschnitt 8).
  - DNS/Netzwerk: `Get-StaleDNSRecordReport` (DnsServer-Modul oder LDAP-Fallback über `dnsRecord`), `Get-DynamicDNSRegistrationReport`, `Get-SubnetAssignmentReport`, `Get-ReplicationLatencyReport`, `Get-SiteLinkCostReport`.
  - Integration: `Get-ExchangeAttributeReport` (Schemaversion, Empfängertypen, Anomalien), `Get-AzureADConnectReport` (MSOL_/Sync_/AAD_-Konten, ADSync-gMSA, AZUREADSSOACC, `mS-DS-ConsistencyGuid`), `Get-CustomAttributeUsageReport` (extensionAttribute1–15).
- Gemeinsame Hilfsfunktionen für die neuen Reports (Kontext-Cache, privilegierte Gruppen per SID, Eventlog-Abfrage mit `MaxEvents` und Fehlerzeile, Remote-Registry per WinRM/RemoteRegistry, Subnetzprüfung IPv4/IPv6, Windows-Supportdaten).
- GUI: Buttons „Help“ und „About“, Ergebniszähler für Users/Computers/Groups im Kopfbereich, Quick-Button „Stale Computer Passwords“ (Computer Management).
- GUI: Tabs „Network Topology“, „Security HeatMap“ und „Report Builder“ neben der Ergebnistabelle.

### Geändert
- `Get-OSSummary`: Support-/EOL-Status pro Computer anhand von Edition und Build (Windows 10 Supportende 14.10.2025, LTSC/LTSB-Versionen, Windows 11 je Featureupdate, Server 2003–2025, Server 2012/2012 R2 EOL 10.10.2023, Server 2016 → 12.01.2027); neue Spalten `EOLCount` und `Note`, Risiko „High“ bei Supportende < 12 Monate.
- Report Builder: Felder auch per Doppelklick hinzufügbar, keine doppelten Felder, Computer- und Gruppenfelder werden ausgewertet.
- Fenstertitel und Kopfzeile zeigen die tatsächliche Version („ActiveDirectory_Audit v0.6.6“ statt „v0.6.X Series“).

### Performance
- Array-Aufbau per `+=` (jedes Mal vollständige Kopie des Arrays) AST-basiert auf `System.Collections.Generic.List[object]` mit `.Add()`/`.AddRange()` umgestellt: 413 von 525 `$variable += …`-Zuweisungen. Verbleibend sind nur numerische Zähler/Scores (73), String-Verkettungen (21), kleine feste Listen mit Literal-Initialisierung (14 bzw. 3 bei einer Einzeltreffer-Rückgabe) und ein rekursiver Pfad-Parameter, der bewusst Kopiersemantik benötigt (1).
- `Get-BitLockerStatus`: BitLocker-Recovery-Objekte werden einmalig domänenweit abgefragt und über den Parent-DN den Computern zugeordnet (statt einer LDAP-Abfrage pro Computer); neue Spalten `RecoveryKeyCount` und `LatestBackup`.

### Behoben
- `Get-CircularGroups`: Zirkuläre Gruppenmitgliedschaften wurden nie gemeldet, weil das `+=` in der verschachtelten Funktion `Find-CircularReference` nur eine lokale Kopie der Ergebnisliste erzeugte – jetzt gemeinsame Liste mit `.Add()`.
- Initialisierung von Topologie, HeatMap und Report Builder lief auf Skriptebene vor dem Laden des Fensters und war damit wirkungslos – jetzt im `Loaded`-Event des Fensters.
- Report Builder: Entfernen-Button nutzte eine nicht vorhandene Variable; beim Hinzufügen wurde immer das erste Element entfernt; Vorschau übernahm bei leerer Auswahl das MessageBox-Ergebnis als Zeile.
- `Write-ADReportLog -Terminal` gab nichts aus – Konsolenausgabe mit Zeitstempel und Farbe je Typ (in PS2EXE-Builds unterdrückt).
- `Get-SYSVOLHealthCheck`: DFSR-/FRS-Erkennung nutzt `Get-CimInstance` mit Fallback auf `Get-WmiObject`, wenn CIM/WinRM fehlschlägt.
- Verweise auf nicht existierende GUI-Elemente bereinigt: `ButtonHelp`, `ButtonAbout`, `ButtonQuickStaleComputerPasswords`, `UserCountText`, `ComputerCountText`, `GroupCountText` sowie die Visualisierungs-Controls wurden in der XAML ergänzt.

### Entfernt
- Tote GUI-Verweise ohne Funktion: `ButtonQuickMobileDeviceUsers`, `ListBoxSelectAttributes`, `TextBlockSelectedRows`, `TextBlockLastUpdate`, `ResultCountGrid`.
- `Show-PlaceholderNotice` (keine Platzhalter mehr vorhanden).

## [0.6.5] – 14.10.2026

Pull Request: [#1](https://github.com/PS-PhinIT/PhinIT.PowerShell_Auditing-Reporting/pull/1)

Audit (Sicherheit, Performance, Funktionen, Verweise, GUI, Befehle) – Details siehe [AUDIT.md](../AUDIT.md).

### Sicherheit
- CSV-Export: Schutz vor CSV-/Formel-Injection – Werte, die mit `=`, `@`, Tab, CR oder mit `+`/`-` gefolgt von Text beginnen, erhalten ein vorangestelltes `'` (Telefonnummern und negative Zahlen bleiben unverändert).
- AD-Filter (`Build-FilterString`): Hochkommas im Suchwert werden maskiert (`'` → `''`); Werte wie „O'Brien“ brachen zuvor die Abfrage.
- Ungültig gewordene Authenticode-Signatur entfernt – das Skript muss vom Herausgeber neu signiert werden.

### Performance
- `Get-SecurityHeatMapData`: `-Properties *` durch die 6 benötigten Attribute ersetzt.
- `Get-SYSVOLHealthCheck`: `Get-GPO -All` einmal pro Domäne statt pro Domänencontroller.
- `Get-OrganizationChart`: Managerkette aus einem Cache statt per `Get-ADUser` je Ebene.
- `$array +=` in Benutzerschleifen durch `List[object]` ersetzt (5 Stellen).

### Behoben
- Doppelt kodierte Umlaute (Mojibake, 126 Vorkommen in 101 Zeilen) repariert. Funktional relevant: deutsche Gruppennamen „Domänen-Admins“, „Domänencontroller“, „Organisations-Domänencontroller“ sowie „Invité“ wurden in lokalisierten Domänen nicht gefunden.
- Fehlende Funktion `Show-QuickReport` ergänzt – alle 47 Schnellreport-Buttons lösten zuvor „Befehl nicht gefunden“ aus.
- Doppelt definierte Funktion `Get-LoginTimeAnalysis`: Die zweite Definition (eigentlich „Stale Computer Passwords“) überschrieb die erste. Umbenannt in `Get-StaleComputerPasswords`; leeres `PasswordLastSet` bricht den Report nicht mehr ab.
- Doppelt definierte Funktion `Get-OSSummary`: verdeckte erste Fassung entfernt.
- `Update-ResultCounters`: Reports mit genau einem Treffer warfen wegen `[IList]` einen Fehler.
- `Get-OrganizationChart`: Manager-Cache war nach Manager-DN statt Benutzer-DN aufgebaut – Untergebene wurden als Manager angezeigt.
- Configuration-DN wurde mit dem DNS-Namen gebaut („CN=Configuration,contoso.com“) bzw. stimmte nur in der Stammdomäne – jetzt `(Get-ADRootDSE).configurationNamingContext`.
- AD-Filter `{ Site -eq $Site.Name }` löste die Variable nicht auf – jetzt `"Site -eq '$($Site.Name)'"`.
- `Get-ACLAnalysis`: Configuration- und Schema-Container wurden mit doppeltem Präfix („CN=Configuration,CN=Configuration,…“, „CN=Schema,CN=Schema,…“) abgefragt und daher nie ausgewertet.

### GUI
- Platzhalter-Reports zeigen statt einer reinen Konsolenausgabe (`Write-Host`) einen Hinweis per MessageBox und Statuszeile (`Show-PlaceholderNotice`).
- Reset-Button: Tippfehler `RadioButtonGroupMembership` → `RadioButtonGroupMemberships`.

### Geändert
- Versionsangaben vereinheitlicht (Header, XAML „v0.6.X Series“, Statusleiste, About-Dialog inkl. Herausgeber PhinIT).
- Dateiname ohne Versionsnummer: `ActiveDirectory_Audit_v0.6.4.ps1` → `ActiveDirectory_Audit.ps1`.

### Entfernt
- Kompilierte EXE-Dateien, alte Skriptversionen (`# Versions`, `# Beta`) und Screenshots aus dem Repository.

## [0.6.4] – 19.01.2026

Beta-Stand (GUI-Angabe noch „v0.6.2 | Last Update: 30.12.2025“); im Repository seit dem Import, als 0.6.5 veröffentlicht.

### Hinzugefügt
- Neue Reports: `Get-AccountCreationTimeline`, `Get-DeletedObjectsRecovery`, `Get-DSGVOComplianceReport`, `Get-GPOConflictAnalysis`, `Get-GPOSecurityBaseline`, `Get-LoginTimeAnalysis`, `Get-OrganizationChart`, `Get-ProxyAddressChanges`.
- Zahlreiche Schnellreport-Buttons (teilweise als Platzhalter).

## [0.6.2] – 30.12.2025
### Geändert
- Beginn der Versionsreihe 0.6.X; Überarbeitung bestehender Reports und der GUI.

## [0.5.5] – 07.07.2025
### Geändert
- Stabilisierung der 0.5.X-Reihe (letzte als EXE veröffentlichte Version).

## [0.5.4] – 07.07.2025
### Behoben
- Fehlerkorrekturen und Stabilität (Abschluss der Reihe 0.5.X, „FINAL“).

## [0.5.3] – 02.07.2025
### Geändert
- Performance-Optimierungen und Stabilitätsverbesserungen.

## [0.5.1] / [0.5.2] – 01.07.2025 / 02.07.2025
### Hinzugefügt
- Security Dashboard mit Risikometriken (`Get-SecurityDashboard`).
- Kompromittierungs-Indikatoren (`Get-CompromiseIndicators`), Authentifizierungsprotokoll-Analyse (`Get-AuthProtocolAnalysis`), Muster fehlgeschlagener Anmeldungen (`Get-FailedAuthPatterns`).
- `Get-ConditionalAccessPolicies`, `Get-ExpiredPasswordUsers`, `Get-KerberoastableAccounts`.
### Geändert
- Verbesserte Risikobewertung.

## [0.4.2] – 01.07.2025

Abschlussversion der Reihe 0.4.X („FINAL“).

### Hinzugefügt
- Report-Builder (`Initialize-ReportBuilder`, `Build-CustomReport`, Report-Vorlagen).
- Netzwerk-Topologie (`Get-ADNetworkTopology`, `Draw-TopologyOnCanvas`) und Security-Heatmap (`Get-SecurityHeatMapData`, `Draw-SecurityHeatMap`).
- Report „Computer nach Betriebssystem“, erweiterte Filter und Exportfunktionen.

## [0.3.4] – vor 01.07.2025

Abschlussversion der Reihe 0.3.X („FINAL“); kein Datum im Skript hinterlegt.

### Hinzugefügt
- ACL-Analyse, AdminSDHolder-Objekte, erweiterte Delegierungen, Fine-Grained Password Policies, Foreign Security Principals, GPO-Berechtigungen, leere GPOs, Vererbungsunterbrechungen, Kontosperrungsrichtlinien, hochprivilegierte Dienstkonten.

## [0.3.3] – vor 01.07.2025
### Hinzugefügt
- Zirkuläre Gruppen, große/leere Gruppen, Gruppen ohne Besitzer, mail-aktivierte und dynamische Verteilergruppen, Computer nach Standort/OS-Version, nie angemeldete Computer, doppelte Computernamen, Gastkonto-Status.

## [0.3.2] – vor 01.07.2025
### Hinzugefügt
- GPO-Übersicht, BitLocker-Status, Honey-Tokens, Managed Service Accounts, verschachtelte Gruppen, ablaufende Konten, DES-/Reversible-Encryption-Benutzer, OS-Zusammenfassung.

## [0.3.1] – vor 01.07.2025
### Hinzugefügt
- Sicherheitsanalysen: AS-REP-Roasting, DCSync-Rechte, Delegierungen, Zertifikatssicherheit, Schema-Admin-Pfade, DNS-Health, SYSVOL-Health, Backup-Readiness, Quotas.
- Erweiterter Filter (`Build-FilterString`).

## [0.2.1] / [0.2.2] – vor 01.07.2025

Abschlussversion der Reihe 0.2.X („FINAL“); kein Datum im Skript hinterlegt.

### Hinzugefügt
- Infrastruktur-Reports (OU-Hierarchie, Standorte und Subnetze, DNS, GPOs).
- Export nach CSV/HTML.

## [0.1.1] – [0.1.4] – vor 01.07.2025

Abschlussversion der Reihe 0.1.X („FINAL“); kein Datum im Skript hinterlegt.

### Hinzugefügt
- Sicherheitsanalyse (privilegierte Konten, riskante Gruppenmitgliedschaften, schwache Kennwortrichtlinien), DC-Status, FSMO-Rollen, Replikationsstatus.
- Computer-Reports, Gruppenmitgliedschaften von Benutzern.

## [0.0.13] – [0.0.19] – vor 01.07.2025

Abschlussversion der Reihe 0.0.X („FINAL“); kein Datum im Skript hinterlegt.

### Hinzugefügt
- Erste Version mit WPF-GUI, Benutzer- und Gruppen-Reports, Protokollierung (`Write-ADReportLog`), Ergebnis-Visualisierung und erweiterte Filterung.
