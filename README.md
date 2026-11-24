# MetzgerApp 2.0 – Einfache Bedienung (Android, offline)

Die lokale SQLite-Datenbank und die bisherigen 15 Rezeptvorlagen bleiben erhalten. Die Startseite ist neu: Neue Schlachtung, Meine Schlachtungen, Meine Rezepte, Kosten berechnen, Fleisch & Preise. Die Fachfunktionen sind unter Mehr erreichbar.

## APK über das vorhandene GitHub-Repository bauen

Wenn V1 bereits auf GitHub liegt: Das separate Update-ZIP entpacken. Auf der **Code-Übersicht im Hauptordner** des Repositorys `Add file` → `Upload files` wählen. Die Ordner `lib` und `test` sowie `pubspec.yaml` gemeinsam in das Upload-Feld ziehen (nicht die ZIP und nicht den äußeren Update-Ordner). Bestehende gleichnamige Dateien werden aktualisiert; keine Dateien im Repository löschen. Mit `Commit changes` direkt auf `main` speichern. Der vorhandene Workflow baut die neue APK. Unter Actions den neuesten Durchlauf öffnen und bei Erfolg `MetzgerApp-Test-APK` unter Artifacts herunterladen, ZIP entpacken und APK installieren. Das Update-ZIP enthält nur die geänderten Dateien, nicht das vollständige Projekt.

Bei einem neuen Repository: den kompletten Inhalt des Vollprojekts hochladen; `.github/workflows/build-apk.yml` muss vorhanden sein. Ggf. wie bei V1 manuell anlegen. Windows lokal: `powershell -ExecutionPolicy Bypass -File .\setup.ps1`; anschließend `flutter analyze`, `flutter test`, `flutter run`.

**Vor der Installation V1 sichern!** In V1 Einstellungen → Vollständiges Backup exportieren und Datei außerhalb des App-Speichers sichern. Debug-APKs von GitHub können unterschiedliche Signaturen haben. Falls Android ein Update ablehnt, erst nach erfolgreicher Datensicherung V1 deinstallieren, V2 installieren und Backup unter Mehr → Einstellungen & Datensicherung wiederherstellen. Ein Deinstallieren ohne Backup löscht lokale Daten. Backups nicht ins GitHub-Repository hochladen. Die App bleibt vollständig offline; GitHub dient nur zur Kompilierung. Die Test-APK ist keine dauerhaft signierte Release-APK.

## Arbeitsablauf
1. Neue Schlachtung: Tierart, verwertbares Gewicht, Kosten für Tier und Schlachtung. Weitere Angaben optional.
2. Produkte hinzufügen: Wurstsorte auswählen oder Frischfleisch/eigenes Produkt eingeben; Rohwarenmenge, zusätzliche Kosten, Fertiggewicht und Verkaufspreis erfassen. Bei ausgefülltem Rezept können Zutaten und Zukaufpreise automatisch umgerechnet werden. Standardmäßig gelten alle Fleischpositionen als eigene Rohware; bei zugekauftem Fleisch die Position abwählen. Blut und Innereien aus der Schlachtung als Fleisch/Rohware im Rezept anlegen, damit sie aus dem verfügbaren Gewicht abgezogen werden. Endgewicht manuell oder mit expliziter Rezeptschätzung (nur bekannte Massen).
3. Ergebnis: Restmenge, Kosten pro Produkt, Gesamtkosten, möglicher Netto-Umsatz und kalkuliertes Ergebnis. Speichern oder PDF erstellen. Zwischenstände lassen sich im zweiten Schritt speichern und später bearbeiten.

Gemeinsame Schlachtungskosten werden gleichmäßig je kg verwertbarer Rohware verteilt. Das ist eine vereinfachte Kalkulationsmethode, keine Bewertung nach Marktwert einzelner Teilstücke. Alle gemeinsamen Kosten bleiben im Gesamtergebnis enthalten, auch wenn Rohware unverplant bleibt. Fehlende Preisangaben werden nicht automatisch als null bewertet. Manuell erfasste Kosten von 0 sind als bewusste Null zu verstehen. Die App erfasst für die Schlachtungen einen Planumsatz, nicht automatisch tatsächliche Verkäufe. Es gibt zunächst keine getrennte Bestandsführung pro Teilstück und Güteklasse, sondern einen gemeinsamen Rohwarenpool pro Schlachtung. Historische Produkt-Preisstände bleiben in den gespeicherten Produktdaten erhalten, bis der Nutzer ausdrücklich aktuelle Rezeptpreise übernimmt.

## Prüfung
Die vorhandenen Fachfunktionen und Quellen bleiben erhalten. Keine verbindlichen ungeprüften Grenzwerte, keine lebensmittelrechtliche Freigabe. Die neue Version wurde auf Dateistruktur, Klammerbalance und Berechnungsbeispiele geprüft; Flutter-SDK/Android-SDK waren in der Erstellungsumgebung nicht verfügbar. Die neuen Dart-Tests müssen in GitHub Actions laufen, bevor die APK getestet werden kann. Siehe `docs/TESTPLAN_V2.md`.
