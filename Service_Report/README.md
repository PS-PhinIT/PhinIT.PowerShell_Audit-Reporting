# Service_Report – easyServiceReport

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Version](https://img.shields.io/badge/Version-0.0.2-orange)

**Service_Report** listet alle Windows-Dienste mit ihrem Dienstkonto auf und bewertet das Risiko des verwendeten Kontos. So lassen sich Dienste mit hohen Rechten oder gespeicherten Passwörtern schnell finden.

| | |
|---|---|
| **Version** | 0.0.2 |
| **Stand** | 2026-10-14 |
| **Script** | `Service_Report.ps1` |
| **Autor** | PhinIT |

---

## Features

- Übersicht aller Dienste (Name, Anzeigename, Status, Starttyp, Dienstkonto) per CIM (`Win32_Service`)
- Risikobewertung des Dienstkontos mit Zählern in der Kopfzeile
- Export als **HTML-Bericht** (alle Werte HTML-kodiert)
- Kopieren der Liste in die Zwischenablage
- Aktualisieren ohne Neustart

### Risikostufen

| Stufe | Konten | Bedeutung |
|---|---|---|
| **Kritisch** | `LocalSystem`, `NT AUTHORITY\SYSTEM`, Konten mit „admin“ im Namen | Höchste Rechte – Kompromittierung des Dienstes = Kompromittierung des Systems |
| **Warnung** | Benutzerdefinierte Domänen-/lokale Konten | Gespeichertes Passwort, oft zu weitreichende Rechte |
| **Normal** | `LocalService`, `NetworkService`, `NT SERVICE\*`, `NT VIRTUAL MACHINE\*`, gMSA (`...$`) | Eingeschränkte bzw. verwaltete Konten |
| **Unbekannt** | Kein Konto ermittelbar | Manuell prüfen |

---

## Voraussetzungen

- Windows 10/11 oder Windows Server 2016+
- Windows PowerShell 5.1
- Lesender Zugriff auf `Win32_Service` (Standardbenutzer genügt i. d. R.; als Administrator werden alle Dienste vollständig angezeigt)

---

## Start

```powershell
cd .\PhinIT.PowerShell_Server-Tools\Service_Report
powershell.exe -ExecutionPolicy Bypass -File .\Service_Report.ps1
```

Optional als EXE mit [PS2EXE](https://github.com/MScholtes/PS2EXE):

```powershell
Invoke-ps2exe .\Service_Report.ps1 .\Service_Report.exe -noConsole
```

---

## Ausgabe

- HTML-Bericht: `ServiceReport_<COMPUTERNAME>_YYYYMMDD_HHmmss.html` (Speicherort frei wählbar)

Der Bericht enthält Dienst- und Kontonamen des Systems – vertraulich behandeln.

---

## Changelog & Lizenz

- Versionshistorie: [CHANGELOG.md](CHANGELOG.md)
- Lizenz: MIT – siehe [LICENSE](../LICENSE)
