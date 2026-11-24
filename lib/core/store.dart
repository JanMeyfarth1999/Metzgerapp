import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'seed.dart';
import 'types.dart';

const kinds = ['slaughter','meat','grade','ingredient','supplier','recipe','recipeVersion','recipeImage','priceHistory','calculation','production','sale','regulation','rule','qualityCheck','hygieneTemplate','hygieneCheck','settings','category','animal'];
class LocalStore extends ChangeNotifier {
  Database? _db;
  List<Json> _records=[];
  bool loading=true;
  String? error;
  List<Json> all(String kind,{bool includeArchived=false}) => _records.where((r)=>r['kind']==kind).map((r)=>map(r['data'])).where((r)=>includeArchived||r['archived']!=true).toList()..sort((a,b)=>nameOf(a).toLowerCase().compareTo(nameOf(b).toLowerCase()));
  Json? get(String kind,String id) => all(kind,includeArchived:true).where((r)=>r['id']==id).firstOrNull;
  List<Json> get materials => [...all('meat').map((r)=>{...r,'kind':'meat'}),...all('ingredient').map((r)=>{...r,'kind':'ingredient'})];
  List<String> get recipeCategories => {...categories,...all('category').map(nameOf)}.toList();
  List<String> get animalTypes => {...animals,...all('animal').map(nameOf)}.toList();
  Json get settings => get('settings','main')??{'id':'main','name':'Einstellungen','theme':'System','tax':0,'hourlyRate':null,'electricityRate':null,'waterRate':null,'textScale':1.0};
  Future<void> open() async {
    loading=true;error=null;notifyListeners();
    try {
      _db ??= await openDatabase(p.join(await getDatabasesPath(),'metzgerapp.db'),version:1,onCreate:(db,version) async {
        await db.execute('CREATE TABLE records (kind TEXT NOT NULL, id TEXT NOT NULL, data TEXT NOT NULL, PRIMARY KEY(kind,id))');
        final batch=db.batch();
        for(final r in seedRecords()) {batch.insert('records',_encode(r));}
        await batch.commit(noResult:true);
      });
      await _refresh();
    } catch(e){error=str(e);} finally{loading=false;notifyListeners();}
  }
  Map<String,Object?> _encode(Json row)=>{'kind':row['kind'],'id':row['id'],'data':jsonEncode(row['data'])};
  Future<void> _refresh() async {
    final rows=await _db!.query('records');
    _records=rows.map((r)=><String,dynamic>{'kind':r['kind'],'id':r['id'],'data':jsonDecode(r['data'] as String)}).toList();
  }
  Future<Json> save(String kind,Json data,{bool history=true}) async {
    if(!kinds.contains(kind)) throw ArgumentError('Unbekannter Datentyp');
    final id=str(data['id']).isEmpty?newId():str(data['id']);
    final previous=get(kind,id);
    final next=<String,dynamic>{...data,'id':id,'created':previous?['created']??data['created']??now(),'updated':now()};
    await _db!.transaction((tx) async {
      if(history && kind=='recipe' && previous!=null) {
        final histId=newId();
        await tx.insert('records',_encode({'kind':'recipeVersion','id':histId,'data':{...previous,'id':histId,'recipeId':id,'name':previous['name'],'snapshot':previous}}));
        next['version']=n(previous['version']).toInt()+1;
      }
      if(kind=='recipe' && previous==null) next['version']=1;
      if(history && ['meat','ingredient'].contains(kind) && (previous==null || ['buyPrice','buyQuantity','buyUnit'].any((k)=>previous[k]!=next[k]))) {
        final histId=newId();
        await tx.insert('records',_encode({'kind':'priceHistory','id':histId,'data':{'id':histId,'name':next['name'],'materialId':id,'materialKind':kind,'buyPrice':next['buyPrice'],'buyQuantity':next['buyQuantity'],'buyUnit':next['buyUnit'],'created':now()}}));
      }
      await tx.insert('records',_encode({'kind':kind,'id':id,'data':next}),conflictAlgorithm:ConflictAlgorithm.replace);
    });
    await _refresh();notifyListeners();return next;
  }
  Future<void> archive(String kind,Json data,bool archived) async {await save(kind,{...data,'archived':archived},history:false);}
  String backup({bool rulesOnly=false})=>jsonEncode({'format':rulesOnly?'metzgerapp-rules':'metzgerapp-backup','schema':1,'created':now(),'records':rulesOnly?_records.where((r)=>['regulation','rule'].contains(r['kind'])).toList():_records});
  List<Json> parseBackup(String content,{bool rulesOnly=false}) {
    final decoded=map(jsonDecode(content));
    if(decoded['format']!=(rulesOnly?'metzgerapp-rules':'metzgerapp-backup')||decoded['schema']!=1||decoded['records'] is! List) throw const FormatException('Unbekanntes Dateiformat oder Schemaversion.');
    final original=decoded['records'] as List;
    if(original.length>100000) throw const FormatException('Zu viele Datensätze.');
    final rows=maps(original);final keys=<String>{};
    if(rows.length!=original.length) throw const FormatException('Ungültige Datensätze.');
    for(final row in rows) {
      final kind=str(row['kind']), id=str(row['id']);final data=map(row['data']);
      if(!kinds.contains(kind)||id.isEmpty||data['id']!=id||data['name'] is! String||!keys.add('$kind/$id')||(rulesOnly&&!['regulation','rule'].contains(kind))) throw const FormatException('Ungültiger oder doppelter Datensatz.');
      if(kind=='recipeImage' && (data['encoded'] is! String || str(data['encoded']).length>1400000)) throw const FormatException('Ungültige Bilddatei.');
      if(kind=='recipe' && (data['lines'] is! List || numOrNull(data['baseKg'])==null || n(data['baseKg'])<=0)) throw const FormatException('Ungültige Rezeptdaten.');
      if(['production','calculation'].contains(kind) && (data['lines'] is! List || data['summary'] is! Map)) throw const FormatException('Ungültige Kalkulationsdaten.');
      if(kind=='slaughter' && (data['products'] is! List || data['summary'] is! Map || numOrNull(data['usableKg'])==null || n(data['usableKg'])<=0)) throw const FormatException('Ungültige Schlachtungsdaten.');
      if(kind=='rule' && !qualityMetrics.containsKey(str(data['metric']))) throw const FormatException('Unbekannter Prüfparameter.');
    }
    return rows;
  }
  Future<void> restore(List<Json> rows,{bool rulesOnly=false}) async {
    await _db!.transaction((tx) async {
      if(!rulesOnly) await tx.delete('records');
      final batch=tx.batch();
      for(final r in rows) {
        final row=Map<String,dynamic>.from(r);
        if(rulesOnly && row['kind']=='rule') row['data']={...map(row['data']),'verified':false,'checkedOn':'','reviewer':''};
        batch.insert('records',_encode(row),conflictAlgorithm:ConflictAlgorithm.replace);
      }
      await batch.commit(noResult:true);
    });
    await _refresh();notifyListeners();
  }
}
final storeProvider=ChangeNotifierProvider<LocalStore>((ref){final store=LocalStore();store.open();return store;});
