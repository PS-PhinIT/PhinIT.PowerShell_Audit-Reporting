# Mitwirken / Contributing

Vielen Dank für dein Interesse an der **PhinIT Auditing & Reporting Suite**!

## Grundregeln

1. **Ein Skript pro Modul, ohne Versionsnummer im Dateinamen** (z. B. `ActiveDirectory_Audit/ActiveDirectory_Audit.ps1`).
   Ältere Stände werden **nicht** als Kopie abgelegt – sie sind über die Git-Historie verfügbar.
2. **Jede Änderung wird dokumentiert:**
   - Versionsnummer im Skript-Header und in `$script:AppVersion`/`$script:AppDate` erhöhen ([SemVer](https://semver.org/lang/de/)) – Fenstertitel, Kopf-/Fußzeile und About-Dialog lesen nur diese Variablen.
   - Eintrag mit Versionsnummer **und Datum** in der `CHANGELOG.md` des Moduls (Kategorien: Hinzugefügt, Geändert, Behoben, Entfernt, Sicherheit, Performance, GUI, Befehle) mit Verweis auf den Pull Request. Einen Abschnitt „Unreleased“ gibt es nicht.
   - `README.md` des Moduls anpassen (Version-Badge, Funktionen, Aufruf).
   - Repository-weite Änderungen zusätzlich in der Root-[CHANGELOG.md](CHANGELOG.md).
3. **Keine Binärdateien** (EXE, ZIP) und keine Screenshots einchecken. Kompilierte Versionen gehören in GitHub Releases.
4. **Jedes Modul muss** eine `README.md` und eine `CHANGELOG.md` enthalten.

## Code-Richtlinien

- Kompatibel zu **Windows PowerShell 5.1** bleiben (sofern im Modul nicht anders angegeben); Dateien als **UTF-8 mit BOM** speichern.
- Werte in HTML-Reports immer kodieren (`[System.Net.WebUtility]::HtmlEncode` bzw. `ConvertTo-Html`).
- Kein `Invoke-Expression` mit Benutzereingaben; AD-Filterwerte maskieren.
- Große Ergebnismengen mit `List[object]`/`ArrayList` statt `$array +=` aufbauen; bei AD-Abfragen nur benötigte `-Properties` laden.
- Alle per `FindName` verwendeten Steuerelemente müssen im XAML existieren.
- Vor dem Commit Syntax prüfen:
  ```powershell
  $errors = $null
  [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path .\ActiveDirectory_Audit\ActiveDirectory_Audit.ps1), [ref]$null, [ref]$errors) | Out-Null
  $errors
  ```
  und – falls verfügbar – `Invoke-ScriptAnalyzer` ausführen.
- Signierte Skripte nach Änderungen neu signieren (`Set-AuthenticodeSignature`).

## Einheitliche Oberfläche (GUI)

Alle Module verwenden das Design von **ActiveDirectory_Audit** (modern, schlicht). Neue oder geänderte Oberflächen halten sich an:

| Bereich | Vorgabe |
|---------|---------|
| Fenster | `Background="#F8FAFC"`, `FontFamily="Segoe UI"`, `ResizeMode="CanResizeWithGrip"`, `WindowStartupLocation="CenterScreen"`, Titel `"$($script:AppName) v$($script:AppVersion)"` |
| Raster | Zeilen `50` (Kopfzeile) · `*` (Inhalt, Rand `24,20,24,0`) · `25` (Fußzeile); Inhalt: Sidebar `320` · Abstand `24` · Ergebnisbereich `*` |
| Kopfzeile | `#374151`, Titel 20 SemiBold `#F9FAFB`; Zähler-Kacheln `#FF4C5B73` (Höhe 49); Buttons „Help“/„About“ `#4B5563` (70 × 30) |
| Sidebar | `ScrollViewer` → `Border` (`#F8FAFC`, Rahmen `#E5E7EB`, Radius 6, Padding 16) mit `Expander`-Bereichen (`ExpanderStyle`) |
| Ergebnisbereich | `ModernCard` (weiß, Rahmen `#E5E7EB`, Radius 6, Padding `20,16`), Überschrift `CategoryHeader`, Aktionen als `ModernButton` rechts daneben |
| Buttons | `ModernButton` (weiß, Rahmen `#D1D5DB`, Hover `#F3F4F6`/`#6366F1`), Hauptaktion `PrimaryButton` (`#6366F1`); deaktiviert = Deckkraft 0,5 |
| Tabellen | Kopf `#F3F4F6`/`#374151` SemiBold, Padding `12,8`; Zellen `12,6`; Auswahl `#EEF2FF`/`#6366F1`; Wechselzeilen `#F8FAFC` |
| Fußzeile | `#374151`, drei Spalten: links „Name \| Version \| Last Update“, Mitte Statusanzeige (`Ellipse` grün `#10B981` / gelb `#F59E0B` / rot `#EF4444`) + einzeilige Statusmeldung, rechts „© PhinIT \| www.phinit.de“ (Link) |

Weitere Regeln: keine festen Pixel-Ränder zur Positionierung (responsive Spalten), Statusmeldungen einzeilig (vollständiger Text im Tooltip), lang laufende Abfragen nach Möglichkeit im Hintergrund-Runspace (wie WindowsServer_Audit/Application_Audit) – die Datenfunktionen greifen dann nicht auf Steuerelemente zu.

## Pull Requests

- Kurze Beschreibung des Problems/der Änderung, betroffenes Modul und neue Versionsnummer angeben.
- Sicherheitslücken bitte **nicht** öffentlich melden – siehe [SECURITY.md](SECURITY.md).
