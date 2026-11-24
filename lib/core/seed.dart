import 'types.dart';

List<Json> seedRecords() {
  final rows = <Json>[];
  void add(String kind, String id, Json data) => rows.add({'kind':kind,'id':id,'data':{'id':id,...data,'created':now(),'updated':now()}});
  final templates = <(String,String)>[
    ('Blutwurst','Kochwurst'),('Leberwurst','Kochwurst'),('Bratwurst','Bratwurst'),('Knoblauch-Krakauer','Brühwurst'),('Schinkenwurst','Brühwurst'),('Mortadella','Brühwurst'),('Jagdwurst','Brühwurst'),('Presskopf','Kochwurst'),('Feine Leberwurst','Kochwurst'),('Rote Wurst (Ahle Wurst)','Rohwurst'),('Weckewerk','Kochwurst'),('Pfefferbeißer','Rohwurst'),('Thüringer Bauern-Knackwurst','Rohwurst'),('Rote Wurst von Schaf/Ziege','Rohwurst'),('Pfefferbeißer Schaf/Ziege','Rohwurst')];
  for (var i=0;i<templates.length;i++) {
    add('recipe','template-$i',{'name':templates[i].$1,'category':templates[i].$2,'baseKg':1.0,'loss':0.0,'lines':<Json>[],'version':1,'template':true,'process':<String,dynamic>{},'observations':<Json>[],'images':<String>[], 'description':'Leere Vorlage – eigene Rezeptur eintragen. Kategorie fachlich prüfen.'});
  }
  final regs = <(String,String,String,String,String)>[
    ('LMHV','Lebensmittelhygiene-Verordnung','Rechtsquelle','https://www.gesetze-im-internet.de/lmhv_2007/','Allgemeine Hygiene'),
    ('Tier-LMHV','Tierische Lebensmittel-Hygieneverordnung','Rechtsquelle','https://www.gesetze-im-internet.de/tier-lmhv/','Tierische Lebensmittel; auch Hackfleisch'),
    ('FlV','Fleisch-Verordnung / Fleischrecht','Historisch / zu klären','','Genaue historische Fassung und Nachfolgeregeln prüfen.'),
    ('LMBG','Lebensmittel- und Bedarfsgegenständegesetz','Historisch','','Historische Bezeichnung; LFGB als heutige Referenz.'),
    ('LFGB','Lebensmittel- und Futtermittelgesetzbuch','Rechtsquelle','https://www.gesetze-im-internet.de/lfgb/','Lebensmittelsicherheit und Verbraucherschutz'),
    ('HVO / HFlV','Hackfleischverordnung','Historisch','','Historische Bezeichnung. Aktuelle Anforderungen unter Tier-LMHV und EU-Recht prüfen.'),
    ('Drittverordnung','Drittverordnung (Zuordnung offen)','Ungeklärt','','Exakte Bezeichnung und Fundstelle mit Fachperson klären.'),
    ('LMIV','EU 1169/2011 – Lebensmittelinformation','Rechtsquelle','https://eur-lex.europa.eu/eli/reg/2011/1169/oj?locale=de','Kennzeichnung und Allergene'),
    ('LMZDV','Lebensmittelzusatzstoff-Durchführungsverordnung','Rechtsquelle','https://www.gesetze-im-internet.de/lmzdv/','Nationale Durchführung von Zusatzstoffvorschriften'),
    ('EG 178/2002','Allgemeines Lebensmittelrecht','Rechtsquelle','https://eur-lex.europa.eu/eli/reg/2002/178/oj?locale=de','Sicherheit und Rückverfolgbarkeit'),
    ('EG 852/2004','Lebensmittelhygiene','Rechtsquelle','https://eur-lex.europa.eu/eli/reg/2004/852/oj?locale=de','Hygiene und HACCP'),
    ('EG 853/2004','Hygiene tierischer Lebensmittel','Rechtsquelle','https://eur-lex.europa.eu/eli/reg/2004/853/oj?locale=de','Besondere Hygieneanforderungen; Anwendungsbereich prüfen'),
    ('EG 1333/2008','Lebensmittelzusatzstoffe','Rechtsquelle','https://eur-lex.europa.eu/eli/reg/2008/1333/oj?locale=de','Zusatzstoffe und Verwendungsbedingungen'),
    ('EG 2073/2005','Mikrobiologische Kriterien','Rechtsquelle','https://eur-lex.europa.eu/eli/reg/2005/2073/oj?locale=de','Mikrobiologische Kriterien; Probenplan und Anwendungsbereich beachten'),
    ('EU 2023/2108','Änderungen zu Nitriten und Nitraten','Rechtsquelle','https://eur-lex.europa.eu/eli/reg/2023/2108/oj?locale=de','Änderung von Zusatzstoffvorschriften; konsolidierte Fassung prüfen'),
    ('DLMB','Deutsches Lebensmittelbuch','Fachlicher Leitsatz','https://www.deutsche-lebensmittelbuch-kommission.de/','Leitsätze sind keine Rechtsverordnungen.'),
    ('Leitsätze Fleisch','Leitsätze für Fleisch und Fleischerzeugnisse','Fachlicher Leitsatz','https://www.deutsche-lebensmittelbuch-kommission.de/','Produktspezifische Qualitätsmerkmale; Fassung prüfen'),
    ('HACCP','Gefahrenanalyse und kritische Kontrollpunkte','Fachkonzept','','Betriebsspezifische Gefahrenanalyse erforderlich.'),
    ('Qualität','Betriebliche Qualitätsrichtlinien','Betrieblich','','Eigene geprüfte Spezifikationen')];
  for(var i=0;i<regs.length;i++) {
    final r=regs[i]; add('regulation','reg-$i',{'name':r.$1,'title':r.$2,'status':r.$3,'source':r.$4,'notes':r.$5,'version':'','checkedOn':'','paragraph':'','effectiveFrom':'','effectiveUntil':''});
  }
  add('hygieneTemplate','hyg-start',{'name':'Vor Produktionsbeginn','items':['Arbeitsflächen gereinigt','Maschinen gereinigt und desinfiziert','Rohstoffe und Chargen kontrolliert','Kühltemperatur kontrolliert','Händehygiene / Arbeitskleidung kontrolliert'],'notes':'Beispiel – betrieblich anpassen.'});
  add('hygieneTemplate','hyg-hack',{'name':'Hackfleisch / Fleischzubereitung (HVO)','items':['Zulässige Rohstoffe geprüft','Kühlkette geprüft','Herstellungsdatum und Uhrzeit dokumentiert','Fett / Kollagen-Fleischeiweiß geprüft, soweit anwendbar','Verpackung / Kennzeichnung / Verbrauchsdatum geprüft','Maschinenreinigung dokumentiert','Mikrobiologische Anforderungen geprüft, soweit anwendbar'],'notes':'Erinnerungsliste, keine verbindliche HACCP-Vorgabe.'});
  add('hygieneTemplate','hyg-end',{'name':'Nach der Produktion','items':['Soll-/Ist-Temperaturen dokumentiert','Abkühlung / Lagerung geprüft','Reinigung dokumentiert','Abweichungen und Maßnahmen erfasst'],'notes':'Beispiel – betrieblich anpassen.'});
  return rows;
}
