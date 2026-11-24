# Test- und Abnahmeplan

## Vor dem ersten Einsatz

1. `flutter doctor -v`, einmalig `setup.ps1`, danach `flutter analyze` und `flutter test`.
2. Android-Emulator starten und `flutter run` ausführen. Eine Release-APK erstellen und auf dem Zielhandy testen. Alle nachfolgenden Fälle mit fiktiven Daten durchführen.
3. Prüfen, dass die Release-App im Flugmodus startet, Daten speichert, nach Neustart wieder lädt und keine Online-Funktionen benötigt.

## Funktionstests

| Test | Erwartung |
|---|---|
| Erster Start | 15 leere Wurstvorlagen, keine freigegebenen Prüfregeln, 3 Hygienevorlagen. Nach Neustart keine Duplikate. |
| Fleisch / Güteklasse | Eigene Sortierung anlegen, Fleisch dazu anlegen; Einkaufspreis wird gespeichert. Preisänderung erscheint im Preisverlauf. |
| Zutat | 500 g Gewürz für 18 € anlegen, 30 g verbrauchen: 1,08 €; Preis/kg 36 €. |
| Einheit | 1 kg → 1000 g; 30 min → 0,5 h. Liter zu kg wird ohne Dichte nicht automatisch umgerechnet. |
| Rezept | 1 kg Basis, 700 g Fleisch + 300 g Speck erfassen. Fleischanteile 70/30 %. Auf 10 kg skalieren: 7 kg/3 kg. Gewürz 18 g wird zu 180 g. |
| Rezeptbild | Lokales Foto auswählen, speichern, Neustart, Versionshistorie und Bildanzeige testen. |
| Rezeptänderung | Änderung erzeugt neue Version; alte Version bleibt einsehbar und kann als neue Version übernommen werden. |
| Kostenrechnung | 100 € Gesamtkosten, 15 kg Rohgewicht, 20 % Verlust: 12 kg Endgewicht; 8,33 €/kg. 14 €/kg netto: 168 € Umsatz, 68 € Plangewinn, 40,48 % Marge, 68 % Aufschlag. |
| Zielmarge | 40 % Zielmarge: 13,89 €/kg netto (gerundete Anzeige). |
| Fehlerwerte | Negativkosten, inkompatible Einheiten, Endgewicht null, Verlust 100 % und fehlende Pflichtwerte abweisen. |
| Produktion | Tatsächliches Endgewicht und Kosten speichern. Spätere Änderung von Stammdatenpreisen verändert den Snapshot nicht. |
| Verkäufe | 5 kg zu 14 €/kg: 70 € Erlös, Differenz zu 100 € Chargenkosten −30 €. Weitere Verkäufe nachtragen; Verkauf über Restmenge ablehnen. |
| Qualität | Ohne Analysewerte kein geschätzter Fettwert oder BEFFE; keine Regel → keine Beurteilung. Fiktive betriebliche Testregel anlegen und nur mit passenden Testwerten prüfen. Ungeprüfte/historische Quelle nicht als erfüllt ausweisen. |
| Regeländerung | Quelle ändern: bisherige Freigabe einer Regel nicht weiter verwenden. Regeldatei importieren: erneute fachliche Prüfung erforderlich. |
| HACCP | Offene Punkte als unvollständig dokumentieren. Abweichung ohne Maßnahme nicht speichern. Produktionszuordnung prüfen. |
| PDF / CSV | Über Android-Dateiauswahl in lokalen Ordner speichern; Umlaute, Zahlen, mehrere Seiten und Excel-Import kontrollieren. |
| Backup | Komplettbackup auf lokalem Speicher anlegen. In separatem Testprofil/-gerät wiederherstellen; Preise, Bilder, Regeln, Produktionen und Verkäufe vergleichen. Fehlerhafte JSON-Datei muss vor Austausch der Datenbank abgewiesen werden. |
| Update | Test-APK mit gleicher Anwendungs-ID und gleichem Signaturschlüssel aktualisieren. Daten müssen erhalten bleiben. Vorher sichern. |

## Prüfstatus zum Lieferzeitpunkt

- Vorhandene Dateien, Pfade und ZIP-Inhalt überprüft.
- Dart-Quelldateien strukturell auf ausgeglichene Klammern und abgeschlossene Zeichenketten geprüft.
- Android-XML-Dateien auf Wohlgeformtheit geprüft; Shell-Skript auf Syntax geprüft.
- Berechnungsfälle in `test/calculations_test.dart` hinterlegt (noch nicht mit Flutter ausgeführt).
- Flutter-Analyse, Unit-Testlauf, Gradle-Build, Android-Installation, echter Dateidialog und Praxistest stehen noch aus, da SDK und Android-Gerät nicht in der Erstellungsumgebung verfügbar waren.
- Fachliche und lebensmittelrechtliche Abnahme steht aus. Keine verbindlichen Grenzwerte vorinstalliert.
