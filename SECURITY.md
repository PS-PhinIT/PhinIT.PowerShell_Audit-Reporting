# Sicherheitsrichtlinie / Security Policy

## Unterstützte Versionen

Unterstützt wird jeweils nur die **aktuelle Version** eines Moduls (siehe Root-[README.md](README.md) bzw. die `CHANGELOG.md` des Moduls).

| Modul | Unterstützte Version |
|-------|----------------------|
| ActiveDirectory_Audit | 0.6.8 |
| WindowsServer_Audit (WindowsServer_Audit) | 0.4.5 |
| Application_Audit | 0.0.4 |
| Connections_Audit | 0.0.7 |

## Sicherheitslücke melden

Bitte melde Sicherheitslücken **nicht** über öffentliche Issues, sondern vertraulich über
[GitHub Security Advisories](https://github.com/PS-PhinIT/PhinIT.PowerShell_Auditing-Reporting/security/advisories/new)
oder über das Kontaktformular auf [www.phinit.de](https://www.phinit.de).

Bitte angeben: betroffenes Modul und Version, Beschreibung, Schritte zur Reproduktion und mögliche Auswirkungen.

## Hinweise zum sicheren Einsatz

- Die Tools lesen Konfigurations- und Verzeichnisdaten (AD, Server, Clients) – Reports können **sensible Informationen** enthalten. Exporte (CSV/HTML) entsprechend schützen und nicht öffentlich ablegen.
- Skripte nur aus vertrauenswürdiger Quelle ausführen und vor dem Einsatz die Authenticode-Signatur prüfen (`Get-AuthenticodeSignature`). Nach dem Audit vom 14.10.2026 sind die Skripte bis zur erneuten Signierung durch den Herausgeber **unsigniert**.
- `Set-ExecutionPolicy -Scope Process` bevorzugen, statt die Ausführungsrichtlinie dauerhaft zu lockern.
- CSV-Exporte nicht ungeprüft in Tabellenkalkulationen mit aktivierten Makros/externen Inhalten öffnen.
- Ergebnisse des letzten Sicherheits-Audits: [AUDIT.md](AUDIT.md).
