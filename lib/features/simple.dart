import 'package:flutter/material.dart';
import '../core/calculations.dart';
import '../core/files.dart';
import '../core/slaughter.dart';
import '../core/store.dart';
import '../core/types.dart';
import '../shared/ui.dart';
import 'calculation_page.dart';
import 'hygiene.dart';
import 'lines.dart';
import 'materials.dart';
import 'quality.dart';
import 'recipes.dart';
import 'settings.dart';

String kg(dynamic v)=>shownNum(v,suffix:' kg',digits:2);
const nameField=FieldSpec('name','Name',required:true);

class SimpleHome extends StatelessWidget {
  final LocalStore store; const SimpleHome({super.key,required this.store});
  @override Widget build(BuildContext context)=>AnimatedBuilder(animation:store,builder:(context,_) {
    final rows=store.all('slaughter')..sort((a,b)=>str(b['updated']).compareTo(str(a['updated'])));
    return Scaffold(appBar:AppBar(title:const Text('MetzgerApp'),actions:[IconButton(tooltip:'Mehr',onPressed:()=>openPage(context,MorePage(store:store)),icon:const Icon(Icons.more_horiz))]),
      body:SafeArea(child:ListView(padding:const EdgeInsets.all(18),children:[
        Text('Was möchtest du machen?',style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.bold)),
        const SizedBox(height:6),const Text('Alles bleibt auf deinem Handy.'),const SizedBox(height:20),
        FilledButton.icon(onPressed:()=>openPage(context,SlaughterEditor(store:store)),icon:const Icon(Icons.add_circle_outline,size:28),label:const Padding(padding:EdgeInsets.symmetric(vertical:13),child:Text('Neue Schlachtung',style:TextStyle(fontSize:19)))),
        const SizedBox(height:10),
        HomeTile(icon:Icons.list_alt,title:'Meine Schlachtungen',subtitle:'Aufteilen, weiterbearbeiten, Ergebnis ansehen',onTap:()=>openPage(context,SlaughterList(store:store))),
        HomeTile(icon:Icons.menu_book,title:'Meine Rezepte',subtitle:'Wurstsorten und Zutaten',onTap:()=>openPage(context,SimpleRecipes(store:store))),
        HomeTile(icon:Icons.calculate_outlined,title:'Kosten berechnen',subtitle:'Ein Produkt kalkulieren',onTap:()=>openPage(context,QuickCalculation(store:store))),
        HomeTile(icon:Icons.sell_outlined,title:'Fleisch & Preise',subtitle:'Fleisch, Gewürze und Einkaufspreise',onTap:()=>openPage(context,PriceHub(store:store))),
        if(rows.isNotEmpty)...[const SizedBox(height:18),Text('Zuletzt bearbeitet',style:Theme.of(context).textTheme.titleMedium),HomeTile(icon:Icons.history,title:nameOf(rows.first),subtitle:'${str(rows.first['date'])} · ${kg(rows.first['usableKg'])}',onTap:()=>openPage(context,SlaughterEditor(store:store,initial:rows.first)))],
        const SizedBox(height:16),TextButton.icon(onPressed:()=>openPage(context,MorePage(store:store)),icon:const Icon(Icons.settings_outlined),label:const Text('Mehr · Qualität, Hygiene, Einstellungen')),
      ])));
  });
}
class HomeTile extends StatelessWidget {
  final IconData icon;final String title,subtitle;final VoidCallback onTap;
  const HomeTile({super.key,required this.icon,required this.title,this.subtitle='',required this.onTap});
  @override Widget build(BuildContext context)=>Card(clipBehavior:Clip.antiAlias,child:ListTile(leading:Icon(icon,size:30,color:Theme.of(context).colorScheme.primary),title:Text(title,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w600)),subtitle:subtitle.isEmpty?null:Text(subtitle),trailing:const Icon(Icons.chevron_right),onTap:onTap));
}
class MorePage extends StatelessWidget {
  final LocalStore store;const MorePage({super.key,required this.store});
  @override Widget build(BuildContext context)=>PageFrame(title:'Mehr',child:ListView(padding:const EdgeInsets.all(12),children:[
    HomeTile(icon:Icons.fact_check_outlined,title:'Qualität & BEFFE',onTap:()=>openPage(context,QualityHub(store:store))),
    HomeTile(icon:Icons.gavel,title:'Gesetze & Richtlinien',onTap:()=>openPage(context,regulationsPage(context,store))),
    HomeTile(icon:Icons.health_and_safety_outlined,title:'Hygiene & HACCP',onTap:()=>openPage(context,HygieneHub(store:store))),
    HomeTile(icon:Icons.inventory_outlined,title:'Erweiterte Fleischverwaltung',onTap:()=>openPage(context,materialsPage(context,store,true))),
    HomeTile(icon:Icons.inventory_2_outlined,title:'Erweiterte Zutatenverwaltung',onTap:()=>openPage(context,materialsPage(context,store,false))),
    HomeTile(icon:Icons.category_outlined,title:'Fleischgüteklassen',onTap:()=>openPage(context,gradesPage(context,store))),
    HomeTile(icon:Icons.local_shipping_outlined,title:'Lieferanten',onTap:()=>openPage(context,suppliersPage(context,store))),
    HomeTile(icon:Icons.factory_outlined,title:'Einzelproduktionen & Verkäufe',onTap:()=>openPage(context,HistoryPage(store:store,production:true))),
    HomeTile(icon:Icons.history,title:'Gespeicherte Einzelkalkulationen',onTap:()=>openPage(context,HistoryPage(store:store))),
    HomeTile(icon:Icons.bar_chart,title:'Statistik Einzelproduktionen',onTap:()=>openPage(context,StatisticsPage(store:store))),
    HomeTile(icon:Icons.calculate,title:'Erweiterte Einzelkalkulation',onTap:()=>openPage(context,CalculationPage(store:store))),
    HomeTile(icon:Icons.settings_outlined,title:'Einstellungen & Datensicherung',onTap:()=>openPage(context,SettingsPage(store:store))),
  ]));
}
class PriceHub extends StatelessWidget {
  final LocalStore store;const PriceHub({super.key,required this.store});
  @override Widget build(BuildContext context)=>PageFrame(title:'Fleisch & Preise',child:ListView(padding:const EdgeInsets.all(12),children:[
    HomeTile(icon:Icons.restaurant,title:'Fleisch',subtitle:'Tierart, Güteklasse, €/kg',onTap:()=>openPage(context,SimplePrices(store:store,meat:true))),
    HomeTile(icon:Icons.inventory_2_outlined,title:'Gewürze & andere Zutaten',subtitle:'Einkaufspreis und Packungsgröße',onTap:()=>openPage(context,SimplePrices(store:store,meat:false))),
  ]));
}
class SimplePrices extends StatelessWidget {
  final LocalStore store;final bool meat;const SimplePrices({super.key,required this.store,required this.meat});
  Future<void> edit(BuildContext context,Json? row) async {await openPage(context,SimplePriceEditor(store:store,meat:meat,initial:row));}
  @override Widget build(BuildContext context)=>AnimatedBuilder(animation:store,builder:(context,_)=>PageFrame(title:meat?'Fleischpreise':'Zutatenpreise',child:ListView(padding:const EdgeInsets.all(14),children:[
    FilledButton.icon(onPressed:()=>edit(context,null),icon:const Icon(Icons.add),label:Text(meat?'Fleisch hinzufügen':'Zutat hinzufügen')),
    for(final row in store.all(meat?'meat':'ingredient')) HomeTile(icon:meat?Icons.restaurant:Icons.inventory_2_outlined,title:nameOf(row),subtitle:'${shownMoney(row['buyPrice'])} / ${shownNum(row['buyQuantity'])} ${str(row['buyUnit'])}${meat?' · ${str(row['grade'])}':''}',onTap:()=>edit(context,row)),
    if(store.all(meat?'meat':'ingredient').isEmpty)const EmptyState('Noch nichts angelegt. Du kannst jederzeit neue Preise hinzufügen.'),
  ])));
}
class SimplePriceEditor extends StatefulWidget {
  final LocalStore store;final bool meat;final Json? initial;const SimplePriceEditor({super.key,required this.store,required this.meat,this.initial});
  @override State<SimplePriceEditor> createState()=>_SimplePriceEditorState();
}
class _SimplePriceEditorState extends State<SimplePriceEditor> {
  final form=GlobalKey<FormState>();late Json data={'buyQuantity':1.0,'buyUnit':widget.meat?'kg':'g','animal':'Schwein','category':'Gewürz','food':true,...?widget.initial};bool busy=false;
  Future<void> save()async{if(busy||!(form.currentState?.validate()??false))return;setState(()=>busy=true);await guarded(context,()async{await widget.store.save(widget.meat?'meat':'ingredient',data);if(mounted)Navigator.pop(context);});if(mounted)setState(()=>busy=false);}
  @override Widget build(BuildContext context)=>PageFrame(title:widget.meat?'Fleischpreis':'Zutatenpreis',child:Form(key:form,child:ListView(padding:const EdgeInsets.all(16),children:[
    Fields(specs:[nameField,if(widget.meat)...[FieldSpec('animal','Tierart',choices:widget.store.animalTypes,required:true),const FieldSpec('grade','Güteklasse (z. B. S II)')]else const FieldSpec('category','Kategorie',choices:ingredientCategories,required:true),const FieldSpec('buyQuantity','Einkaufsmenge',number:true,min:0.000001,required:true),FieldSpec('buyUnit','Einheit',choices:widget.meat?const ['kg','g']:units,required:true),const FieldSpec('buyPrice','Preis für diese Menge (€ netto)',number:true,min:0,required:true)],data:data,changed:()=>setState((){})),
    if(!widget.meat)SwitchListTile(title:const Text('Essbare Zutat'),subtitle:const Text('Bei Verpackung oder Verbrauchsmaterial ausschalten.'),value:data['food']!=false,onChanged:(v)=>setState(()=>data['food']=v)),
    FilledButton.icon(onPressed:busy?null:save,icon:const Icon(Icons.check),label:const Text('Speichern')),
    if(widget.initial!=null)TextButton(onPressed:()async{await openPage(context,MaterialEditor(store:widget.store,meat:widget.meat,initial:widget.store.get(widget.meat?'meat':'ingredient',str(data['id']))));if(context.mounted)Navigator.pop(context);},child:const Text('Weitere Angaben (Analyse, Lieferant, Archiv)')),
  ])));
}

class SimpleRecipes extends StatefulWidget {
  final LocalStore store;const SimpleRecipes({super.key,required this.store});
  @override State<SimpleRecipes> createState()=>_SimpleRecipesState();
}
class _SimpleRecipesState extends State<SimpleRecipes>{String query='';
  @override Widget build(BuildContext context)=>AnimatedBuilder(animation:widget.store,builder:(context,_)=>PageFrame(title:'Meine Rezepte',child:ListView(padding:const EdgeInsets.all(14),children:[
    FilledButton.icon(onPressed:()=>openPage(context,SimpleRecipeEditor(store:widget.store)),icon:const Icon(Icons.add),label:const Text('Eigenes Rezept anlegen')),
    const SizedBox(height:12),TextField(decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'Wurst suchen'),onChanged:(v)=>setState(()=>query=v.toLowerCase())),
    const SizedBox(height:8),for(final r in widget.store.all('recipe').where((r)=>nameOf(r).toLowerCase().contains(query)))HomeTile(icon:Icons.menu_book_outlined,title:nameOf(r),subtitle:maps(r['lines']).isEmpty?'Leere Vorlage – antippen zum Ausfüllen':'${maps(r['lines']).length} Zutaten · ${str(r['category'])}',onTap:()=>openPage(context,SimpleRecipeEditor(store:widget.store,initial:r))),
  ])));
}
class SimpleRecipeEditor extends StatefulWidget {
  final LocalStore store;final Json? initial;const SimpleRecipeEditor({super.key,required this.store,this.initial});
  @override State<SimpleRecipeEditor> createState()=>_SimpleRecipeEditorState();
}
class _SimpleRecipeEditorState extends State<SimpleRecipeEditor>{
  final form=GlobalKey<FormState>();late Json data={'name':'','category':'Sonstiges','baseKg':1.0,'loss':0.0,...?widget.initial};late List<Json> lines=maps(data['lines']);late Json process=map(data['process']);bool busy=false;
  Future<void> save({bool duplicate=false})async{if(busy||!(form.currentState?.validate()??false))return;setState(()=>busy=true);await guarded(context,()async{final row={...data,'lines':lines,'process':process,'template':lines.isEmpty};if(duplicate){row.remove('id');row.remove('created');row['name']='${nameOf(row)} – Kopie';}await widget.store.save('recipe',row);if(mounted)Navigator.pop(context);});if(mounted)setState(()=>busy=false);}
  Future<void> add([int? index])async{final line=await openPage<Json>(context,SimpleLineEditor(store:widget.store,initial:index==null?null:lines[index]));if(line!=null&&mounted)setState((){if(index==null){lines.add(line);}else{lines[index]=line;}});}
  @override Widget build(BuildContext context)=>PageFrame(title:widget.initial==null?'Neues Rezept':nameOf(widget.initial!),child:Form(key:form,child:ListView(padding:const EdgeInsets.all(14),children:[
    Fields(specs:[nameField,FieldSpec('category','Wurstart',choices:widget.store.recipeCategories,required:true),const FieldSpec('baseKg','Rezept gilt für wie viel kg Fleisch?',number:true,min:0.001,required:true),const FieldSpec('loss','Erwarteter Gewichtsverlust (%)',number:true,min:0,max:99.99,required:true)],data:data,changed:()=>setState((){})),
    Section('Fleisch & Zutaten',[
      if(lines.isEmpty)const Text('Füge Fleisch, Speck, Gewürze und weitere Zutaten hinzu.'),
      for(var i=0;i<lines.length;i++)ListTile(contentPadding:EdgeInsets.zero,title:Text(nameOf(lines[i])),subtitle:Text('${shownNum(lines[i]['quantity'],digits:3)} ${str(lines[i]['unit'])} · ${str(lines[i]['grade'])}'),onTap:()=>add(i),trailing:IconButton(tooltip:'Entfernen',icon:const Icon(Icons.close),onPressed:()=>setState(()=>lines.removeAt(i)))),
      OutlinedButton.icon(onPressed:()=>add(),icon:const Icon(Icons.add),label:const Text('Fleisch oder Zutat hinzufügen')),
    ]),
    Fields(specs:const [FieldSpec('instructions','Herstellung / Anleitung',multiline:true)],data:process,changed:()=>setState((){})),
    FilledButton.icon(onPressed:busy?null:()=>save(),icon:const Icon(Icons.check),label:const Text('Rezept speichern')),
    if(widget.initial!=null)...[TextButton(onPressed:busy?null:()=>save(duplicate:true),child:const Text('Als Kopie speichern')),TextButton(onPressed:()async{if(!await confirm(context,'Erweiterte Ansicht öffnen?','Nicht gespeicherte Änderungen werden verworfen. Speichere zuerst, wenn du sie behalten willst.'))return;if(!context.mounted)return;await openPage(context,RecipeDetail(store:widget.store,recipeId:str(widget.initial!['id'])));if(context.mounted)Navigator.pop(context);},child:const Text('Weitere Angaben / Qualität / PDF'))],
  ])));
}
class SimpleLineEditor extends StatefulWidget {
  final LocalStore store;final Json? initial;const SimpleLineEditor({super.key,required this.store,this.initial});
  @override State<SimpleLineEditor> createState()=>_SimpleLineEditorState();
}
class _SimpleLineEditorState extends State<SimpleLineEditor>{
  final form=GlobalKey<FormState>();int fieldVersion=0;late Json data={'materialKind':'ingredient','unit':'g','buyQuantity':1.0,'buyUnit':'g','food':true,'costType':'Material',...?widget.initial};
  @override Widget build(BuildContext context){final isMeat=data['materialKind']=='meat';final materials=widget.store.materials;final selected=materials.any((m)=>m['id']==data['materialId'])?str(data['materialId']):null;return PageFrame(title:'Fleisch oder Zutat',child:Form(key:form,child:ListView(padding:const EdgeInsets.all(16),children:[
    if(materials.isNotEmpty)DropdownButtonFormField<String>(isExpanded:true,key:ValueKey(selected),value:selected,decoration:const InputDecoration(labelText:'Aus gespeicherten Preisen auswählen'),items:[for(final m in materials)DropdownMenuItem(value:str(m['id']),child:Text(nameOf(m),overflow:TextOverflow.ellipsis))],onChanged:(v){final m=materials.firstWhere((m)=>m['id']==v);setState((){data={...materialSnapshot(m,quantity:n(data['quantity']),unit:str(m['buyUnit']))};fieldVersion++;});}),
    const SizedBox(height:12),if(selected!=null)TextButton(onPressed:()=>setState((){data={...data}..remove('materialId');fieldVersion++;}),child:const Text('Freie Eingabe statt Preisverknüpfung')),
    if(selected==null)DropdownButtonFormField<String>(value:isMeat?'meat':'ingredient',decoration:const InputDecoration(labelText:'Art'),items:const [DropdownMenuItem(value:'meat',child:Text('Fleisch / Speck / Innereien')),DropdownMenuItem(value:'ingredient',child:Text('Gewürz / andere Zutat'))],onChanged:(v)=>setState((){data['materialKind']=v;if(v=='meat'&&!['kg','g'].contains(data['unit'])){data['unit']='kg';data['buyUnit']='kg';}fieldVersion++;})),
    if(selected==null)Fields(specs:[nameField,if(isMeat)const FieldSpec('grade','Güteklasse')],data:data,changed:()=>setState((){}))else Text(nameOf(data),style:Theme.of(context).textTheme.titleLarge),
    const SizedBox(height:12),Fields(key:ValueKey('quantity-$fieldVersion'),specs:[const FieldSpec('quantity','Menge im Rezept',number:true,min:0.000001,required:true),FieldSpec('unit','Einheit',choices:selected!=null?compatibleUnits(str(data['buyUnit'])):isMeat?const ['kg','g']:units,required:true)],data:data,changed:()=>setState((){if(selected==null&&convert(1,str(data['unit']),str(data['buyUnit']))==null)data['buyUnit']=data['unit'];})),
    if(selected==null)...[const Text('Preis optional – leer lassen, wenn noch unbekannt.'),const SizedBox(height:8),Fields(key:ValueKey('price-$fieldVersion-${data['unit']}'),specs:[const FieldSpec('buyQuantity','Einkaufsmenge',number:true,min:0.000001,required:true),FieldSpec('buyUnit','Einkaufseinheit',choices:compatibleUnits(str(data['unit'])),required:true),const FieldSpec('buyPrice','Einkaufspreis gesamt (€ netto)',number:true,min:0)],data:data,changed:()=>setState((){})),if(!isMeat)SwitchListTile(title:const Text('Essbare Zutat'),value:data['food']!=false,onChanged:(v)=>setState(()=>data['food']=v))],
    FilledButton.icon(onPressed:(){if(!(form.currentState?.validate()??false))return;if(convert(1,str(data['unit']),str(data['buyUnit']))==null){toast(context,'Bitte passende Einkaufseinheit wählen.');return;}Navigator.pop(context,{...data,'costType':'Material','food':isMeat||data['food']!=false});},icon:const Icon(Icons.check),label:const Text('Übernehmen')),
  ])));}
}

class SlaughterList extends StatelessWidget {
  final LocalStore store;const SlaughterList({super.key,required this.store});
  @override Widget build(BuildContext context)=>AnimatedBuilder(animation:store,builder:(context,_){final rows=store.all('slaughter')..sort((a,b)=>str(b['date']).compareTo(str(a['date'])));return PageFrame(title:'Meine Schlachtungen',child:ListView(padding:const EdgeInsets.all(14),children:[FilledButton.icon(onPressed:()=>openPage(context,SlaughterEditor(store:store)),icon:const Icon(Icons.add),label:const Text('Neue Schlachtung')),if(rows.isEmpty)const EmptyState('Noch keine Schlachtung gespeichert.'),for(final r in rows)HomeTile(icon:Icons.list_alt,title:nameOf(r),subtitle:'${str(r['date'])} · ${kg(r['usableKg'])} · ${maps(r['products']).length} Produkte',onTap:()=>openPage(context,SlaughterEditor(store:store,initial:r)))]));});
}
class SlaughterEditor extends StatefulWidget {
  final LocalStore store;final Json? initial;const SlaughterEditor({super.key,required this.store,this.initial});
  @override State<SlaughterEditor> createState()=>_SlaughterEditorState();
}
class _SlaughterEditorState extends State<SlaughterEditor>{
  final form=GlobalKey<FormState>();late Json data={'animal':'Schwein','date':today(),'count':1,'animalCost':0.0,'slaughterCost':0.0,'otherCost':0.0,...?widget.initial};late List<Json> products=maps(data['products']);late int step=widget.initial==null?0:1;bool busy=false;
  Json get summary=>slaughterSummary(data,products);
  void change()=>setState((){});
  bool validateBasics(){if(!(form.currentState?.validate()??false))return false;if(numOrNull(data['count'])==null||n(data['count'])<1||n(data['count'])%1!=0){toast(context,'Bitte eine ganze Anzahl Tiere eingeben.');return false;}if(n(summary['usedKg'])>n(data['usableKg'])+0.000001){toast(context,'Bereits verplantes Gewicht ist größer als die verfügbare Menge. Bitte Produkte reduzieren.');return false;}return true;}
  Future<void> add([int? index])async{final available=n(data['usableKg'])-n(summary['usedKg'])+(index==null?0:n(products[index]['rawKg']));final row=await openPage<Json>(context,ProductEditor(store:widget.store,available:available,initial:index==null?null:products[index]));if(row!=null&&mounted)setState((){if(index==null){products.add(row);}else{products[index]=row;}});}
  Future<void> save()async{if(busy||summary['valid']!=true)return;if(step==0&&!validateBasics())return;setState(()=>busy=true);await guarded(context,()async{final saved=await widget.store.save('slaughter',{...data,'name':str(data['name']).trim().isEmpty?'${str(data['animal'])} – ${str(data['date'])}':str(data['name']).trim(),'products':products,'summary':summary},history:false);data={...saved};if(mounted){toast(context,'Schlachtung gespeichert.');Navigator.pop(context);}});if(mounted)setState(()=>busy=false);}
  Future<void> export()async=>guarded(context,()async{final s=summary;await LocalFiles.report('Schlachtung ${str(data['name']).isEmpty?str(data['animal']):str(data['name'])}',[('Datum / Tierart','${str(data['date'])} / ${str(data['animal'])}'),('Nutzbares Gewicht',kg(data['usableKg'])),('Noch nicht verplant',kg(s['remainingKg'])),for(final p in products)(nameOf(p),'Rohware: ${kg(p['rawKg'])}; Fertig: ${kg(p['outputKg'])}; Kosten: ${shownMoney(slaughterProductSummary(p,numOrNull(s['rate']))['cost'])}\n${maps(p['recipeLines']).map((l)=>'${nameOf(l)}: ${shownNum(l['quantity'],digits:3)} ${str(l['unit'])} (${l['fromSlaughter']==true?'eigene Schlachtung':'Zukauf'})').join('\n')}'),('Gesamtkosten',shownMoney(s['cost'])),('Möglicher Netto-Umsatz',shownMoney(s['revenue'])),('Kalkuliertes Ergebnis',shownMoney(s['profit'])),('Hinweis','Planwerte. Gesamtkosten enthalten auch noch nicht verplante Rohware. Keine fachliche Freigabe.')]);});
  @override Widget build(BuildContext context){final s=summary;final rate=numOrNull(s['rate']);final usable=n(data['usableKg']);final used=n(s['usedKg']);return PageFrame(title:widget.initial==null?'Neue Schlachtung':'Schlachtung bearbeiten',child:Column(children:[
    Padding(padding:const EdgeInsets.fromLTRB(16,8,16,12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Schritt ${step+1} von 3 · ${['Tier & Kosten','Produkte aufteilen','Ergebnis'][step]}',style:Theme.of(context).textTheme.titleMedium),const SizedBox(height:8),LinearProgressIndicator(value:(step+1)/3)])),
    Expanded(child:ListView(key:ValueKey(step),padding:const EdgeInsets.fromLTRB(14,0,14,16),children:[
      if(step==0)Form(key:form,child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        const Text('Was wurde geschlachtet und was hat es gekostet?'),const SizedBox(height:12),
        Fields(specs:[FieldSpec('animal','Tierart',choices:widget.store.animalTypes,required:true),const FieldSpec('usableKg','Verwertbare Rohware (kg)',number:true,min:0.001,required:true,hint:'Fleisch, Fett, Blut und Innereien zusammen.')],data:data,changed:change),
        Section('Was hat die Schlachtung gekostet?',[
          Fields(specs:const [FieldSpec('animalCost','Tier / Einkauf (€ netto)',number:true,min:0,required:true),FieldSpec('slaughterCost','Schlachtung / Zerlegung (€ netto)',number:true,min:0,required:true)],data:data,changed:change),ValueRow('Zusammen',shownMoney(s['baseCost']),strong:true),
        ]),
        ExpansionTile(title:const Text('Weitere Angaben (optional)'),maintainState:true,children:[Fields(specs:const [FieldSpec('name','Bezeichnung / Charge'),FieldSpec('date','Datum (JJJJ-MM-TT)',date:true,required:true),FieldSpec('count','Anzahl Tiere',number:true,min:1,required:true),FieldSpec('carcassKg','Schlachtkörpergewicht (kg)',number:true,min:0.001),FieldSpec('otherCost','Weitere gemeinsame Kosten (€ netto)',number:true,min:0,required:true)],data:data,changed:change)]),
      ])),
      if(step==1)...[
        Section('Verfügbares Fleisch & Rohware',[
          Text(kg(s['remainingKg']),style:Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight:FontWeight.bold,color:Theme.of(context).colorScheme.primary)),const Text('noch nicht verplant'),const SizedBox(height:12),LinearProgressIndicator(value:usable>0?(used/usable).clamp(0.0,1.0).toDouble():0),ValueRow('Verplant', '${kg(used)} von ${kg(usable)}'),ValueRow('Anteilige Rohwarenkosten / kg',shownMoney(rate)),
        ]),
        FilledButton.icon(onPressed:()=>add(),icon:const Icon(Icons.add),label:const Text('Produkt hinzufügen')),
        if(products.isEmpty)const EmptyState('Was möchtest du daraus machen? Füge z. B. Bratwurst, Ahle Wurst oder Frischfleisch hinzu.'),
        for(var i=0;i<products.length;i++)Card(child:ListTile(title:Text(nameOf(products[i]),style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text('${kg(products[i]['rawKg'])} Rohware → ${kg(products[i]['outputKg'])} fertig\nKosten: ${shownMoney(slaughterProductSummary(products[i],rate)['cost'])}'),isThreeLine:true,onTap:()=>add(i),trailing:IconButton(tooltip:'Produkt entfernen',icon:const Icon(Icons.close),onPressed:()async{if(await confirm(context,'Produkt entfernen?','${nameOf(products[i])} aus dieser Schlachtung entfernen?')&&mounted)setState(()=>products.removeAt(i));}))),
      ],
      if(step==2)...[
        Section('Ergebnis der Schlachtung',[
          ValueRow('Verwertbares Gewicht',kg(data['usableKg'])),ValueRow('Verplante Rohware',kg(s['usedKg'])),ValueRow('Noch nicht verplant',kg(s['remainingKg'])),const Divider(),ValueRow('Tier, Schlachtung, gemeinsame Kosten',shownMoney(s['baseCost'])),ValueRow('Zutaten und weitere Produktkosten',shownMoney(s['extraCost'])),ValueRow('Gesamtkosten',shownMoney(s['cost']),strong:true),ValueRow('Möglicher Umsatz netto',shownMoney(s['revenue'])),const Divider(),const Text('Kalkuliertes Ergebnis bei Verkauf',style:TextStyle(fontWeight:FontWeight.bold)),Text(shownMoney(s['profit']),style:Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight:FontWeight.bold)),
          if(n(s['remainingKg'])>0.000001)const Notice('Auch die Kosten der unverplanten Rohware sind im Gesamtergebnis enthalten. Ein möglicher späterer Verkauf dieser Rohware ist noch nicht berücksichtigt.'),
          if(s['cost']==null||s['revenue']==null)const Notice('Fehlende Zutatenpreise, Endgewichte oder Verkaufspreise ergänzen, um das Ergebnis zu berechnen.'),
        ]),
        for(final p in products)Section(nameOf(p),[ValueRow('Rohware',kg(p['rawKg'])),ValueRow('Fertige Menge',kg(p['outputKg'])),ValueRow('Kosten',shownMoney(slaughterProductSummary(p,rate)['cost'])),ValueRow('Kosten je fertigem kg',shownMoney(slaughterProductSummary(p,rate)['costKg'])),ValueRow('Kalkulierter Gewinn',shownMoney(slaughterProductSummary(p,rate)['profit'])),if(maps(p['recipeLines']).isNotEmpty)ExpansionTile(title:const Text('Benötigte Zutaten'),children:[for(final l in maps(p['recipeLines']))ValueRow('${nameOf(l)}${l['fromSlaughter']==true?' (eigene)':''}','${shownNum(l['quantity'],digits:3)} ${str(l['unit'])}')])]),
        OutlinedButton.icon(onPressed:export,icon:const Icon(Icons.picture_as_pdf_outlined),label:const Text('Als PDF speichern')),
      ],
    ])),
    SafeArea(top:false,child:Padding(padding:const EdgeInsets.fromLTRB(14,8,14,10),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      if(step<2)FilledButton(onPressed:busy?null:(){if(step==0&&!validateBasics())return;setState(()=>step++);},child:Text(step==0?'Weiter – Produkte auswählen':'Weiter – Ergebnis ansehen'))else FilledButton.icon(onPressed:busy||s['valid']!=true?null:save,icon:const Icon(Icons.check),label:const Text('Schlachtung speichern')),
      if(step>0)Row(children:[Expanded(child:TextButton(onPressed:busy?null:()=>setState(()=>step--),child:const Text('Zurück'))),if(step==1)Expanded(child:TextButton(onPressed:busy||s['valid']!=true?null:save,child:const Text('Zwischenstand speichern')))]),
    ]))),
  ]));}
}

class ProductEditor extends StatefulWidget {
  final LocalStore store;final double available;final Json? initial;const ProductEditor({super.key,required this.store,required this.available,this.initial});
  @override State<ProductEditor> createState()=>_ProductEditorState();
}
class _ProductEditorState extends State<ProductEditor>{
  final form=GlobalKey<FormState>();late Json data={'name':'','manualCost':0.0,'recipeMode':false,...?widget.initial};late List<Json> recipeLines=maps(data['sourceLines']);int outputVersion=0;late Set<int> own=(data['ownIndices'] is List?(data['ownIndices'] as List).whereType<int>().toSet():<int>{});
  void select(Json? r){setState((){if(r==null){data['recipeId']=null;data['recipeMode']=false;recipeLines=[];own={};}else{data['recipeId']=r['id'];data['recipeVersion']=r['version'];data['recipeLoss']=r['loss'];data['name']=nameOf(r);recipeLines=scaledRecipeLines(r,widget.store,1);own={for(var i=0;i<recipeLines.length;i++)if(ownMeat(recipeLines[i]))i};data['recipeMode']=recipeLines.isNotEmpty&&own.isNotEmpty;}});}
  Json? get scaled=>data['recipeMode']==true?slaughterRecipe(recipeLines,own,n(data['rawKg'])):null;
  double? get extra{final manual=numOrNull(data['manualCost']);if(manual==null||manual<0)return null;if(data['recipeMode']!=true)return manual;final calculated=numOrNull(scaled?['extraCost']);return calculated==null?null:calculated+manual;}
  @override Widget build(BuildContext context){final recipes=widget.store.all('recipe');final selected=recipes.any((r)=>r['id']==data['recipeId'])?str(data['recipeId']):null;final result=scaled;return PageFrame(title:'Produkt hinzufügen / ändern',child:Form(key:form,child:ListView(padding:const EdgeInsets.all(16),children:[
    Notice('Noch verfügbar: ${kg(widget.available)} aus dieser Schlachtung.'),
    DropdownButtonFormField<String>(isExpanded:true,value:selected,decoration:const InputDecoration(labelText:'Wurstsorte / Rezept auswählen'),items:[const DropdownMenuItem(value:'custom',child:Text('Anderes Produkt / Frischfleisch')),for(final r in recipes)DropdownMenuItem(value:str(r['id']),child:Text(nameOf(r),overflow:TextOverflow.ellipsis))],onChanged:(v)=>select(recipes.where((r)=>r['id']==v).firstOrNull)),
    const SizedBox(height:12),KeyedSubtree(key:ValueKey('name-${data['recipeId']}'),child:Fields(specs:const [FieldSpec('name','Produktname',required:true)],data:data,changed:()=>setState((){}))),
    Fields(specs:[FieldSpec('rawKg','Rohware aus dieser Schlachtung (kg)',number:true,min:0.001,max:widget.available,required:true)],data:data,changed:()=>setState((){})),
    if(selected!=null&&widget.initial!=null)TextButton(onPressed:()=>select(recipes.firstWhere((r)=>r['id']==selected)),child:const Text('Aktuelles Rezept und Preise übernehmen')),
    if(recipeLines.isNotEmpty&&recipeLines.any(ownMeat))SwitchListTile(title:const Text('Zutaten aus Rezept berechnen'),subtitle:const Text('Nur eigenes Fleisch wird nicht erneut berechnet.'),value:data['recipeMode']==true,onChanged:(v)=>setState(()=>data['recipeMode']=v)),
    if(data['recipeMode']==true)...[
      ExpansionTile(title:const Text('Welches Fleisch stammt aus der Schlachtung?'),subtitle:const Text('Standard: alles. Zukauf abwählen.'),children:[for(var i=0;i<recipeLines.length;i++)if(ownMeat(recipeLines[i]))CheckboxListTile(title:Text(nameOf(recipeLines[i])),value:own.contains(i),onChanged:(v)=>setState(()=>v==true?own.add(i):own.remove(i)))]),
      if(result==null)const Notice('Bitte mindestens eine gültige Fleischposition der Schlachtung auswählen und Rohwarenmenge eingeben.'),
      if(result!=null)ExpansionTile(title:const Text('Berechnete Zutaten ansehen'),children:[for(final l in maps(result['lines']))ValueRow('${nameOf(l)}${l['fromSlaughter']==true?' (eigene)':''}','${shownNum(l['quantity'],digits:3)} ${str(l['unit'])}'),ValueRow('Zukauf laut Rezept',shownMoney(result['extraCost']))]),
      if(result!=null&&result['extraCost']==null)const Notice('Mindestens ein Zukaufpreis fehlt. Ergänze den Preis im Rezept oder schalte Rezeptberechnung aus und gib alle Zusatzkosten manuell ein.'),
    ]else if(selected!=null)const Notice('Ohne vollständige Rezeptberechnung: Zusatzkosten selbst eintragen.'),
    Fields(specs:[FieldSpec('manualCost',data['recipeMode']==true?'Weitere Kosten (€ netto)':'Alle Zutaten / zusätzliche Kosten (€ netto)',number:true,min:0,required:true),const FieldSpec('salePrice','Verkaufspreis pro kg (€ netto)',number:true,min:0)],data:data,changed:()=>setState((){})),
    Fields(key:ValueKey(outputVersion),specs:const [FieldSpec('outputKg','Fertige Menge nach Herstellung (kg)',number:true,min:0,hint:'Leer lassen, solange noch nicht bekannt.')],data:data,changed:()=>setState((){})),
    if(n(data['rawKg'])>0&&data['recipeMode']!=true)TextButton(onPressed:()=>setState((){data['outputKg']=n(data['rawKg']);outputVersion++;}),child:const Text('Rohgewicht als Endgewicht übernehmen')),
    if(result!=null&&estimatedFinished(maps(result['lines']),numOrNull(data['recipeLoss']))!=null)TextButton(onPressed:()=>setState((){data['outputKg']=estimatedFinished(maps(result['lines']),numOrNull(data['recipeLoss']));outputVersion++;}),child:const Text('Endgewicht laut Rezept schätzen')), 
    ValueRow('Zusatzkosten (ohne eigene Rohware)',shownMoney(extra),strong:true),
    FilledButton.icon(onPressed:(){if(!(form.currentState?.validate()??false))return;if(data['recipeMode']==true&&result==null){toast(context,'Rezept oder Fleischzuordnung prüfen.');return;}Navigator.pop(context,{...data,'sourceLines':recipeLines,'ownIndices':own.toList(),'recipeLines':maps(result?['lines']),'extraCost':extra});},icon:const Icon(Icons.check),label:const Text('Produkt übernehmen')),
  ])));}
}

class QuickCalculation extends StatefulWidget {
  final LocalStore store;const QuickCalculation({super.key,required this.store});
  @override State<QuickCalculation> createState()=>_QuickCalculationState();
}
class _QuickCalculationState extends State<QuickCalculation>{
  final form=GlobalKey<FormState>();Json data={'name':'','kg':1.0,'additional':0.0,'manual':0.0};Json? recipe;bool busy=false;
  List<Json> get lines=>recipe==null||n(recipe!['baseKg'])<=0?[]:scaledRecipeLines(recipe!,widget.store,n(data['kg'])/n(recipe!['baseKg']));
  double? get cost{final x=numOrNull(data['additional']);if(x==null||x<0)return null;final ls=lines;if(recipe==null||ls.isEmpty){final m=numOrNull(data['manual']);return m==null||m<0?null:m+x;}if(ls.any((l)=>lineCost(l)==null))return null;return ls.fold(0.0,(s,l)=>s+lineCost(l)!)+x;}
  double? get output=>numOrNull(data['outputKg']);
  double? get revenue=>output!=null&&output!>=0&&numOrNull(data['salePrice'])!=null&&n(data['salePrice'])>=0?output!*n(data['salePrice']):null;
  Future<void> save()async{if(busy||!(form.currentState?.validate()??false))return;if(cost==null){toast(context,'Bitte fehlende Preise ergänzen.');return;}setState(()=>busy=true);await guarded(context,()async{final ls=lines;final all=<Json>[...ls,if(ls.isEmpty){'name':'Materialkosten','quantity':1.0,'unit':'Pauschale','buyUnit':'Pauschale','buyQuantity':1.0,'buyPrice':data['manual'],'costType':'Material','food':false},{'name':'Weitere Kosten','quantity':1.0,'unit':'Pauschale','buyUnit':'Pauschale','buyQuantity':1.0,'buyPrice':data['additional'],'costType':'Sonstiges','food':false}];final c=Calculation(lines:all,inputKg:numOrNull(data['kg']),actualOutputKg:output,salePriceNet:numOrNull(data['salePrice']));await widget.store.save('calculation',{'name':str(data['name']).trim().isEmpty?'Einzelkalkulation ${today()}':str(data['name']).trim(),'lines':all,'summary':c.summary(),'inputKg':data['kg'],'actualOutputKg':output,'salePriceNet':data['salePrice'],'recipeId':recipe?['id'],'recipeVersion':recipe?['version']});if(mounted){toast(context,'Kalkulation gespeichert.');Navigator.pop(context);}});if(mounted)setState(()=>busy=false);}
  @override Widget build(BuildContext context){final r=recipe;final ls=lines;final c=cost;final rev=revenue;return PageFrame(title:'Kosten berechnen',child:Form(key:form,child:ListView(padding:const EdgeInsets.all(16),children:[
    DropdownButtonFormField<String>(isExpanded:true,value:r==null?'manual':str(r['id']),decoration:const InputDecoration(labelText:'Rezept auswählen (optional)'),items:[const DropdownMenuItem(value:'manual',child:Text('Ohne Rezept / freie Kalkulation')),for(final r in widget.store.all('recipe'))DropdownMenuItem(value:str(r['id']),child:Text(nameOf(r),overflow:TextOverflow.ellipsis))],onChanged:(v)=>setState((){recipe=widget.store.all('recipe').where((x)=>x['id']==v).firstOrNull;data['name']=recipe==null?'':nameOf(recipe!);})),
    const SizedBox(height:12),KeyedSubtree(key:ValueKey(r?['id']),child:Fields(specs:const [FieldSpec('name','Produktname')],data:data,changed:()=>setState((){}))),
    Fields(specs:[const FieldSpec('kg','Fleisch-/Bezugsmenge (kg)',number:true,min:0.001,required:true),if(ls.isEmpty)const FieldSpec('manual','Materialkosten gesamt (€ netto)',number:true,min:0,required:true),const FieldSpec('additional','Weitere Kosten (€ netto)',number:true,min:0,required:true),const FieldSpec('outputKg','Fertige Menge (kg)',number:true,min:0.001),const FieldSpec('salePrice','Verkaufspreis pro kg (€ netto)',number:true,min:0)],data:data,changed:()=>setState((){})),
    if(ls.isNotEmpty)ExpansionTile(title:const Text('Rezeptmengen und Kosten'),children:[for(final l in ls)ValueRow('${nameOf(l)} · ${shownNum(l['quantity'],digits:3)} ${str(l['unit'])}',shownMoney(lineCost(l)))]),
    Section('Ergebnis',[ValueRow('Gesamtkosten',shownMoney(c),strong:true),ValueRow('Kosten pro kg',shownMoney(c!=null&&output!=null&&output!>0?c/output!:null)),ValueRow('Möglicher Umsatz',shownMoney(rev)),ValueRow('Kalkulierter Gewinn',shownMoney(c!=null&&rev!=null?rev-c:null),strong:true),if(c==null)const Notice('Mindestens ein Preis fehlt.')]),
    FilledButton.icon(onPressed:busy?null:save,icon:const Icon(Icons.check),label:const Text('Kalkulation speichern')),TextButton(onPressed:()=>openPage(context,CalculationPage(store:widget.store,recipe:r,recipeKg:numOrNull(data['kg']))),child:const Text('Erweiterte Kalkulation (Marge, Steuern, Stückpreise)')),
  ])));}
}
