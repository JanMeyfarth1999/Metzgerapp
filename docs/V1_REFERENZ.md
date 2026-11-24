# MetzgerApp 1.0 – lokale Android-App

Flutter-Quellprojekt für Rezeptverwaltung, Metzger-Kalkulation, Produktionsdokumentation und Qualitätsprüfung. Die App benötigt auf dem Handy weder Konto noch Server, Cloud, Werbung oder Telemetrie. Daten liegen in der privaten SQLite-Datenbank der App; Exportdateien werden über den Android-Dateidialog an einem selbst gewählten Ort gespeichert.

**Status:** Umgesetzter, statisch durchgesehener V1-Quellcode. Flutter/Dart/Android-SDK standen in der Erstellungsumgebung nicht zur Verfügung. Es wurde daher noch kein Flutter-Build, kein Unit-Testlauf und kein Emulator-/Gerätetest durchgeführt. Die Tests sind im Projekt enthalten. Vor produktiver Nutzung unbedingt ausführen und fachlich abnehmen.

## 1. In VS Code starten (Windows)

1. ZIP entpacken, z. B. nach `E:\flutter\MetzgerApp`. Den entpackten Ordner mit `pubspec.yaml` in VS Code über **Datei → Ordner öffnen** öffnen.
2. Flutter und Android SDK müssen installiert und Flutter/Dart im PATH verfügbar sein. Terminal in VS Code öffnen (PowerShell). Prüfen:

   ```powershell
   flutter doctor -v
   ```

3. Einmalig die Einrichtung ausführen:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\setup.ps1
   ```

   Das Skript erzeugt die Android-Gradle- und Wrapper-Dateien mit **deinem lokal installierten Flutter-SDK**, kopiert das App-spezifische Android-Overlay (Dateizugriff und Backup-Schutz), lädt Pub-Abhängigkeiten und formatiert den Dart-Code. Es überschreibt die Dart-Quelldateien nicht, abgesehen von der Formatierung. Für diesen Entwicklungsschritt und den ersten Gradle-Build kann Internet nötig sein; die installierte App selbst ist offline.

4. Statische Analyse und Unit-Tests ausführen:

   ```powershell
   flutter analyze
   flutter test
   ```

   Bei Fehlern die vollständige Ausgabe prüfen. Es wird empfohlen, die Erstinstallation zunächst nur mit Testdaten zu erproben.

5. Android-Emulator starten oder Android-Handy mit aktiviertem USB-Debugging anschließen, Verbindung am Gerät erlauben:

   ```powershell
   flutter devices
   flutter run
   ```

   Alternativ in VS Code Gerät auswählen und F5 drücken. Flutter-/Dart-Erweiterungen werden empfohlen.

6. Nach bestandenem Praxistest eine APK erstellen:

   ```powershell
   flutter build apk --release
   ```

   Die APK liegt danach unter `build\app\outputs\flutter-apk\app-release.apk`. Auf das Android-Handy übertragen und installieren (Android kann die Erlaubnis zur Installation aus der ausgewählten Quelle verlangen). Für den dauerhaften Einsatz eine eigene Release-Signatur einrichten und sicher aufbewahren; Updates benötigen dieselbe Anwendungs-ID und denselben Signaturschlüssel. Ein Debug-Signaturschlüssel ist keine gute Dauerlösung. Vor Updates und Gerätewechseln immer exportieren und Wiederherstellung testen.

Unter Linux/macOS stattdessen `bash setup.sh` verwenden; Zielplattform bleibt Android.

## 2. Enthaltene Funktionen

| Bereich | Implementierung |
|---|---|
| Startseite | Material-3-Dashboard, Suche in Listen, Navigation, Hell/Dunkel/System, Schriftfaktor |
| Stammdaten | Fleisch, individuelle Güteklassen und Tierarten, Lieferanten, Zutaten, Gewürze, Zusatzstoffe, Verpackung, Preise, Preisverlauf, Analysewerte und Allergen-/Zusatzstoffangaben |
| Rezepte | 15 leere Wurstvorlagen, weitere eigene Rezepte und Kategorien, Duplizieren, Versionen, Mengen bezogen auf frei wählbare Fleisch-/Speckbasis, Berechnung der Fleischanteile, Zutaten in verschiedenen Einheiten, Prozessdaten, lokale Fotos |
| Kalkulation | Rezept übernehmen oder freie Kalkulation, kompatible Einheiten, beliebige Kostenpositionen, Arbeitszeit, Strom, Wasser, sonstige Kosten, Gewichtsverlust und direktes Endgewicht, Kosten pro kg/100 g/Stück |
| Gewinn | Netto-/Bruttopreis, einstellbare Steuer, Zielmarge, Aufschlag, kalkulierter Umsatz und Gewinn, tatsächliche Verkäufe je Charge separat |
| Produktionen | Historische unveränderliche Kostensnapshots, Rezeptversionen, Datum/Uhrzeit, Rohstoffchargen, tatsächliches Endgewicht, Verantwortliche, Haltbarkeitsangabe, Verkaufsbuch, verknüpfte Protokolle |
| Qualitätskontrolle | Gewichtete Rohmischungsschätzung, BEFFE und BEFFE im Fleischeiweiß, Kollagenquotient, manuelle Labor-/Messwerte, konfigurierbare min/max-Prüfregeln mit Gültigkeit, Bedingungen, Fachprüfung und Quellenrevision |
| Vorschriften | Lokales Quellenverzeichnis für LMHV, Tier-LMHV, FlV, LMBG/LFGB, HVO/HFlV, Drittverordnung, LMIV, LMZDV, EU-Verordnungen, Leitsätze und betriebliche Qualitätsregeln. Import/Export geprüfter Regeldateien mit erneuter Freigabe. |
| Hygiene / HACCP | Anpassbare Checklisten, Hackfleisch-Checkliste, Soll-/Ist-Werte und Korrekturmaßnahmen, Verantwortliche, Zuordnung zu Produktionen, Protokollhistorie |
| Statistiken | Produktionsmengen, Kosten, Planerträge, erfasste Nettoerlöse, Produktvergleich und Preisverlauf |
| Export | Vollständige JSON-Datensicherung und transaktionaler Restore, CSV-Auswertung, PDF-Rezepte, Kalkulationen, Produktionsberichte, Qualitäts- und Hygieneprotokolle |

### Mitgelieferte Wurstvorlagen

Blutwurst, Leberwurst, Bratwurst, Knoblauch-Krakauer, Schinkenwurst, Mortadella, Jagdwurst, Presskopf, Feine Leberwurst, Rote Wurst (Ahle Wurst), Weckewerk, Pfefferbeißer, Thüringer Bauern-Knackwurst, Rote Wurst von Schaf/Ziege, Pfefferbeißer Schaf/Ziege.

Die Kategorien sind unverbindliche Vorschläge; Zusammensetzung, Preise, Herstellungsparameter und fachliche Grenzwerte sind absichtlich leer. Die Datenbank wird nur beim ersten Start mit diesen Vorlagen befüllt. Es werden keine familiären Rezepte erfunden.

### Empfohlener Ablauf

1. Güteklassen, Fleisch, Zutaten und Einkaufspreise anlegen.
2. Eine Rezeptvorlage öffnen, bearbeiten, Bezugsmenge festlegen und die Positionen hinzufügen. Bei Basis 1 kg können Gewürzmengen in g/kg direkt als g erfasst werden. Die Fleischanteile werden aus den eingetragenen Fleischmengen errechnet.
3. Rezept öffnen, gewünschte Bezugsmenge eingeben und **Kosten & Gewinn berechnen**. Für Einzelkorrekturen Position antippen. Bei Rezeptübernahme werden aktuelle Stammdatenpreise verwendet; archivierte Stammdaten nutzen den letzten gespeicherten Stand mit Hinweis.
4. Gewichtsverlust, direkt gewogenes Endgewicht oder Rohmasse prüfen. Wenn Flüssigkeiten in Litern erfasst sind, wird keine Dichte geraten; tatsächliches Roh- oder Endgewicht manuell eingeben.
5. Verkaufspreis oder Zielmarge und den individuell zutreffenden Steuersatz eingeben. Ergebnis speichern.
6. Produktion mit tatsächlichem Endgewicht speichern, nachträglich Verkäufe erfassen; ggf. Qualitäts- und Hygieneprotokoll verknüpfen.
7. In Einstellungen regelmäßig ein vollständiges Backup außerhalb des App-Speichers anlegen.

## 3. Technischer Aufbau

```text
MetzgerApp/
├── lib/
│   ├── main.dart                 # App, Theme, Dashboard
│   ├── core/
│   │   ├── types.dart             # Formate, Datentypen, Konstanten
│   │   ├── calculations.dart      # Reine Berechnungs- und Prüfregeln
│   │   ├── store.dart             # SQLite, Riverpod, Datensicherung
│   │   ├── seed.dart              # 15 Vorlagen, Quellen, Hygienevorlagen
│   │   └── files.dart             # Native Datei-Brücke, CSV/PDF
│   ├── features/
│   │   ├── materials.dart         # Fleisch/Zutaten/Güteklassen/Lieferanten
│   │   ├── lines.dart             # Rohstoff-/Kostenpositionen
│   │   ├── recipes.dart           # Rezeptverwaltung
│   │   ├── calculation_page.dart  # Kalkulation und Produktionen
│   │   ├── sales.dart             # Nachträgliche Verkäufe
│   │   ├── quality.dart           # Prüfregeln und Messwerte
│   │   ├── hygiene.dart           # HACCP-Protokolle
│   │   └── settings.dart          # Backup, Regelimport, Statistiken
│   └── shared/ui.dart             # Wiederverwendbare Eingabefelder
├── android/                       # Native App-Quellen; Gradle wird generiert
├── tool/android_overlay/          # Android-Quellen für die Einrichtung
├── test/calculations_test.dart    # Unit-Testfälle
├── docs/                          # Fachliche Hinweise und Testplan
├── .vscode/                       # VS-Code-Startkonfiguration
├── setup.ps1                     # Windows-Einrichtung
├── setup.sh                      # Linux/macOS-Einrichtung
├── pubspec.yaml
└── README.md
```

**Entscheidung für diese Version:** Flutter + Dart + Riverpod + SQLite über `sqflite`. Die versionierte SQLite-Tabelle `records` nutzt einen zusammengesetzten Primärschlüssel (`kind`, `id`) und JSON-Nutzdaten. Dadurch sind kein Freezed-/Drift-Codegenerator und keine manuell generierten Dateien nötig. Navigation erfolgt über Flutter Navigator; Dateidialoge über Android SAF. Es handelt sich nicht um das ursprünglich angedachte normalisierte 27-Tabellen-Schema. Die Datensätze können später migriert werden; Schema-Version 1 und Backup-Version 1 sind definiert. Die App speichert Rezeptfotos als separate Datensätze und referenziert diese aus Rezepten, um die SQLite-Zeilengröße zu begrenzen.

**Berechnung:** Dezimalwerte werden in Dart als `double` verarbeitet und für die Anzeige kaufmännisch auf die jeweilige Stellenzahl gerundet. Keine zertifizierte Buchhaltungs- oder Steuerberechnung. Dezimaltrennzeichen Komma oder Punkt eingeben, keine Tausendertrennzeichen. Die Rohmischungsschätzung nimmt massenbezogene Eingaben und vollständige Analysewerte an. Unbekannte Werte werden nicht als null Prozent interpretiert.

## 4. Wichtige Grenzen

- Keine vorgefertigten verbindlichen Grenzwerte, keine vollständigen Gesetzesvolltexte, kein automatisches Rechtsupdate. Das Quellenverzeichnis ist ein Ausgangspunkt. Alle fachlichen Regeln und deren Anwendungsbereich müssen vor Nutzung überprüft werden. Die genaue Drittverordnung ist weiterhin offen. Historische Quellen sind als solche gekennzeichnet. Siehe `docs/FACHLICHE_HINWEISE.md`.
- Die Prüfengine unterstützt numerische Bereichsregeln und manuelle Geltungsbereichsbestätigung. Komplexe Ausnahmen, Zusatzstoffregeln mit mehreren Komponenten, Reifungsmodelle, Labor-Probenpläne und rechtliche Freigaben werden nicht vollständig automatisch beurteilt. Keine Lebensmittelsicherheit allein anhand der App garantieren.
- Kein Warenwirtschaftssystem, keine Buchhaltung, keine automatische Etikettenerstellung, keine Inventur, kein Barcode-Scanner. Diese Funktionen waren für spätere Erweiterungen vorgesehen.
- Es gibt keine Cloud, kein Login und keine Mehrbenutzerverwaltung. Android-Systembackups sind in der Hauptmanifest-Konfiguration deaktiviert. In Debug-Builds kann die von Flutter erzeugte Debug-Manifestdatei für die lokale Debug-Verbindung eine Internet-Berechtigung enthalten; Release-Hauptmanifest hat keine. Beim Dateidialog lokale Speicherorte wählen (nicht bewusst einen Cloud-Anbieter auswählen).
- Backups sind unverschlüsselte JSON-Dateien mit allen App-Daten; sicher aufbewahren. Bei Deinstallation, Verlust oder Defekt des Geräts ohne Backup können Daten verloren gehen. Android-Dateidialog beschränkt einen Import/Export auf 64 MB; bei großen Bildbeständen ist eine spätere Streaming-/Archiv-Backup-Implementierung nötig. Fotos werden durch Android auf JPEG und höchstens 1200 px Kantenlänge verkleinert; maximal acht Fotos pro Rezept, einzelne Bilddatei maximal 1 MB. Foto-Datensätze bleiben auch bei Entfernung erhalten, damit ältere Versionen funktionieren; unbenutzte Bilddatensätze können künftig bereinigt werden.
- Dies ist eine noch nicht auf einem Android-Gerät abgenommene Entwicklungsfassung, keine fertige zertifizierte Fachsoftware. Vor gewerblicher Nutzung Fachregeln, Datensicherheit, Bedienung und Berechnungen testen.
