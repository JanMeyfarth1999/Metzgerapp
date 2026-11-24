import 'dart:math';
import 'package:intl/intl.dart';

typedef Json = Map<String, dynamic>;
final _random = Random.secure();
String newId() => '${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(1 << 31).toRadixString(16)}';
String now() => DateTime.now().toIso8601String();
String today() => DateFormat('yyyy-MM-dd').format(DateTime.now());
String str(dynamic v) => v?.toString() ?? '';
double? numOrNull(dynamic v) {
  if (v == null) return null;
  final n = v is num ? v.toDouble() : double.tryParse(str(v).trim().replaceAll(',', '.'));
  return n != null && n.isFinite ? n : null;
}
double n(dynamic v) => numOrNull(v) ?? 0;
Json map(dynamic v) => v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
List<Json> maps(dynamic v) => v is List ? v.whereType<Map>().map(map).toList() : <Json>[];
List<String> strings(dynamic v) => v is List ? v.map(str).toList() : <String>[];
String fmt(num v, [int digits = 3]) => NumberFormat.decimalPatternDigits(locale: 'de_DE', decimalDigits: digits).format(v);
String money(num v) => NumberFormat.currency(locale: 'de_DE', symbol: '€').format(v);
String dateLabel(dynamic v) {
  final dt = DateTime.tryParse(str(v));
  return dt == null ? str(v) : DateFormat('dd.MM.yyyy HH:mm').format(dt.toLocal());
}
String nameOf(Json x) => str(x['name']);
const categories = ['Rohwurst', 'Brühwurst', 'Kochwurst', 'Bratwurst', 'Hackfleisch', 'Fleischzubereitung', 'Rohpökelware', 'Kochpökelware', 'Frischfleisch', 'Konserve', 'Sonstiges'];
const animals = ['Schwein','Rind','Kalb','Schaf','Ziege','Lamm','Geflügel','Wild','Sonstiges'];
const units = ['kg','g','mg','l','ml','Stück','m','cm','h','min','kWh','Pauschale'];
const ingredientCategories = ['Gewürz','Gewürzmischung','Salz','Zusatzstoff','Flüssigkeit','Wursthülle','Verpackung','Sonstige Zutat','Verbrauchsmaterial'];
const qualityMetrics = <String,String>{'fat':'Fett','protein':'Gesamteiweiß','meatProtein':'Fleischeiweiß','connectiveProtein':'Bindegewebseiweiß','foreignProtein':'Fremdeiweiß','water':'Wasser','collagen':'Kollagen','salt':'Salz','beffe':'BEFFE','beffeRatio':'BEFFE im Fleischeiweiß','collagenRatio':'Kollagen/Fleischeiweiß','nitrite':'Nitrit','nitrate':'Nitrat','ph':'pH-Wert','aw':'aw-Wert','microbiology':'Mikrobiologie (KBE/g)','coreTemp':'Kerntemperatur','storageTemp':'Lagertemperatur','processTemp':'Verarbeitungstemperatur','humidity':'Luftfeuchtigkeit','loss':'Gewichtsverlust'};
const rawMetrics = ['fat','protein','meatProtein','connectiveProtein','foreignProtein','water','collagen','salt','nitrite','nitrate'];
String metricUnit(String key) => switch(key) {'nitrite' || 'nitrate' => 'mg/kg','ph' || 'aw' => 'dimensionslos','microbiology' => 'KBE/g','coreTemp' || 'storageTemp' || 'processTemp' => '°C',_ => '%'};
const processFields = <String,String>{'wolf':'Wolfgröße / Lochscheibe','cutter':'Kuttereinstellungen','braet':'Brättemperatur','smoke':'Räucherzeit / Temperatur','cook':'Koch-/Brühzeit','core':'Kerntemperatur (Soll)','maturation':'Reifezeit','drying':'Trocknungszeit','humidity':'Luftfeuchtigkeit (Soll)','storage':'Lagerbedingungen','shelfLife':'Haltbarkeit / Verbrauchsdatum (Vorgabe)','packaging':'Verpackung','instructions':'Herstellungsanleitung','notes':'Notizen'};
const costTypes = ['Material','Arbeitskosten','Strom','Wasser','Maschinenkosten','Reinigung','Transport','Gemeinkosten','Sonstiges'];
