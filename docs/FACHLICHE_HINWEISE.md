# Fachliche Hinweise und Quellen

Die App ist eine lokale Dokumentations- und Kalkulationshilfe. Sie enthält ein Quellenverzeichnis, keine amtliche Gesetzessammlung. Kein automatisch aktualisierter Rechtsstand, keine geprüften Standard-Grenzwerte. Die Anwendbarkeit hängt insbesondere von Produkt, Herstellungsweise, Betriebsart und Vermarktung ab. Rechtsstand und konkrete Anforderungen sind fachlich zu ermitteln; ein gespeicherter Prüfstatus ist keine Rechts- oder Verkehrsfähigkeitsbescheinigung.

## Originalquellen zur Prüfung

- LMHV: https://www.gesetze-im-internet.de/lmhv_2007/
- Tier-LMHV: https://www.gesetze-im-internet.de/tier-lmhv/ (u. a. Anlage 5 zur fachlichen Prüfung des Hackfleischbereichs)
- LFGB: https://www.gesetze-im-internet.de/lfgb/
- LMZDV: https://www.gesetze-im-internet.de/lmzdv/
- EG 178/2002: https://eur-lex.europa.eu/eli/reg/2002/178/oj?locale=de
- EG 852/2004: https://eur-lex.europa.eu/eli/reg/2004/852/oj?locale=de
- EG 853/2004: https://eur-lex.europa.eu/eli/reg/2004/853/oj?locale=de
- EG 1333/2008: https://eur-lex.europa.eu/eli/reg/2008/1333/oj?locale=de
- EG 2073/2005: https://eur-lex.europa.eu/eli/reg/2005/2073/oj?locale=de
- EU 1169/2011 (LMIV): https://eur-lex.europa.eu/eli/reg/2011/1169/oj?locale=de
- EU 2023/2108: https://eur-lex.europa.eu/eli/reg/2023/2108/oj?locale=de
- Deutsches Lebensmittelbuch / aktuelle Leitsätze: https://www.deutsche-lebensmittelbuch-kommission.de/

EUR-Lex-Links führen zu den jeweiligen Rechtsakten; für den Einsatz ist jeweils die einschlägige aktuelle konsolidierte Fassung und ggf. die Übergangsregelung zu prüfen. Historische Einträge FlV, LMBG und HVO/HFlV bleiben als Suchbegriffe erhalten. Drittverordnung: genaue Bezeichnung und Fundstelle noch mit dem Metzgermeister klären.

## Prüflogik

- Rohmischung: gewichteter Mittelwert auf Massebasis, bei vollständigen Eingangswerten je Merkmal. Bei nicht kompatiblen Einheiten, fehlenden Werten oder nichtpositiver Gesamtmasse wird keine Schätzung ausgegeben. Für Fleisch allein gibt es eine getrennte Schätzung.
- BEFFE = Fleischeiweiß minus Bindegewebseiweiß (Massenanteile auf derselben Basis), sofern beide Werte bekannt und plausibel sind. Direkt eingegebene BEFFE-Werte dienen als Alternative, wenn vollständige Ausgangswerte fehlen. BEFFE im Fleischeiweiß = BEFFE / Fleischeiweiß × 100, nur bei positivem Fleischeiweiß und plausibler Relation. Kollagen/Fleischeiweiß wird separat ermittelt. Kein Ersatz für vorgeschriebene Analytik.
- Die automatische Vergleichsfunktion ist eine einfache Min-/Max-Regel mit Metrik, Einheit, Produktkategorie, optional exaktem Produktnamen, Basis, Gültigkeitszeitraum, Fundstelle und Fachfreigabe. Bedingungen müssen bei der Prüfung explizit bestätigt werden. Änderungen der zugeordneten Quelle erfordern eine erneute Freigabe. Importierte Regeldateien sind zunächst ungeprüft.
- Rohmischungs-Schätzungen erhalten ausdrücklich Schätzwert-Status. Mess-/Laborwerte mit nachvollziehbarem Herkunftsnachweis sind für andere Prüfbasisarten erforderlich. Die App beurteilt nicht, ob ein Laborverfahren oder Probenplan fachlich geeignet ist.
- Zusatzstoffe: Konzentrationen bzw. Nitrit-/Nitratwerte können in Stammdaten und Messungen dokumentiert werden; einfache massenbezogene Schätzwerte sind nur bei vollständiger Zusammensetzung möglich. Keine Berechnung komplexer rechtlicher Höchstmengen unter Berücksichtigung aller Lebensmittelkategorien, Herstellungsverfahren, Ausnahmen und Restmengen.
- Hygienelisten sind Beispielvorlagen, kein fertiges HACCP-Konzept. Soll- und Istwerte sind vom Betrieb vorzugeben bzw. tatsächlich zu messen.
