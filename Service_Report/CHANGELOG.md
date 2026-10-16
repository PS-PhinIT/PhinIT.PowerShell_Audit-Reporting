# Changelog – Service_Report

Alle nennenswerten Änderungen an Service_Report werden in dieser Datei dokumentiert.

Das Format basiert auf [Keep a Changelog](https://keepachangelog.com/de/1.1.0/),
und dieses Projekt folgt [Semantic Versioning](https://semver.org/lang/de/).

> Hinweis: Für dieses Repository existieren keine Pull Requests. Die Version 0.0.1 wurde aus dem
> Script-Header und der Git-Historie rekonstruiert (Datum = Aufnahme ins Repository).

---

## [0.0.2] - 2026-10-14

### 🐛 Behoben
- **GUI startete nicht:** Ungültiges XAML (`Padding`/`BorderThickness` an `StackPanel`, SVG-Data-URI als Fenster-Icon, `Margin="Auto"`) korrigiert.
- Risikostufe wird einmal pro Dienst berechnet (zuvor mehrfach je Anzeige/Export).
- Dienste werden nach dem Anzeigen des Fensters geladen (`ContentRendered`) – kein „eingefrorenes“ Fenster beim Start.
- Ausgaben von MessageBox/Dialog-Rückgaben werden unterdrückt (keine Konsolenausgabe).

### 🔒 Sicherheit
- Neues Risikomodell: `LocalSystem`/`SYSTEM`/Admin-Konten = Kritisch; benutzerdefinierte Konten = Warnung; `LocalService`, `NetworkService`, virtuelle Dienstkonten und gMSA = Normal.
- HTML-Export kodiert alle Werte (keine HTML/Script-Injection über Dienstnamen oder -beschreibungen).

### 🔧 Geändert
- `Get-CimInstance` statt des veralteten `Get-WmiObject`.
- HTML-Bericht mit `StringBuilder` (Performance), Speichern über WPF-`SaveFileDialog`, Kopieren über WPF-Zwischenablage.
- Dateiname ohne Versionsnummer: `Service_Report.ps1` (Version steht in README und CHANGELOG).

### 📚 Dokumentation
- README und CHANGELOG hinzugefügt.

### 🗑️ Entfernt
- Versionsdatei `Service_Report_V0.0.1.ps1` (ersetzt durch `Service_Report.ps1`).

---

## [0.0.1] - 2026-01-19

### 🚀 Erste Version
- WPF-GUI mit Dienstliste und Hervorhebung sicherheitskritischer Konten.
- HTML-Export und Kopieren in die Zwischenablage.

---

**Aktuelle Version:** 0.0.2  
**Autor:** PhinIT
