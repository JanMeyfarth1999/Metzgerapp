import 'package:flutter/material.dart';
import '../core/types.dart';
import '../core/store.dart';
import '../core/calculations.dart';
import '../shared/ui.dart';

class SalesSection extends StatelessWidget {
  final LocalStore store;final Json production;
  const SalesSection({super.key,required this.store,required this.production});
  Future<void> add(BuildContext context)async{
    final result=await showDialog<Json>(context:context,builder:(_)=>_SaleDialog(production:production));
    if(result==null||!context.mounted)return;
    final totals=salesTotals(production,store.all('sale'));
    if(n(result['quantityKg'])>n(totals['remainingKg'])+0.0000001){toast(context,'Verkaufsmenge übersteigt die noch verfügbare Menge.');return;}
    await guarded(context,()async{await store.save('sale',{...result,'productionId':production['id'],'name':nameOf(production)});if(context.mounted)toast(context,'Verkauf gespeichert.');});
  }
  @override Widget build(BuildContext context){final sales=store.all('sale').where((r)=>r['productionId']==production['id']).toList()..sort((a,b)=>str(b['date']).compareTo(str(a['date'])));final totals=salesTotals(production,sales);
    return Section('Verkäufe nachtragen',[const Notice('Neue Verkäufe werden separat gespeichert. Die ursprüngliche Kalkulation bleibt unverändert. Die laufende Differenz enthält die gesamten Chargenkosten.'),ValueRow('Verkauft','${fmt(n(totals['quantityKg']))} kg'),ValueRow('Verbleibend','${fmt(n(totals['remainingKg']))} kg'),ValueRow('Nettoerlös gesamt',shownMoney(totals['revenue']),strong:true),ValueRow('Nettoerlös minus Chargenkosten',shownMoney(totals['balance']),strong:true),for(final sale in sales)ListTile(contentPadding:EdgeInsets.zero,title:Text('${fmt(n(sale['quantityKg']))} kg · ${money(n(sale['priceNet']))}/kg'),subtitle:Text('${str(sale['date'])} · ${str(sale['notes'])}'),trailing:Text(money(n(sale['quantityKg'])*n(sale['priceNet'])))),OutlinedButton.icon(onPressed:n(totals['remainingKg'])>0.0000001?()=>add(context):null,icon:const Icon(Icons.add),label:const Text('Verkauf erfassen'))]);
  }
}
class _SaleDialog extends StatefulWidget{final Json production;const _SaleDialog({required this.production});@override State<_SaleDialog> createState()=>_SaleDialogState();}
class _SaleDialogState extends State<_SaleDialog>{final form=GlobalKey<FormState>();late Json data={'date':today(),'priceNet':widget.production['salePrice']};
  @override Widget build(BuildContext context)=>AlertDialog(title:const Text('Verkauf erfassen'),content:Form(key:form,child:SingleChildScrollView(child:Fields(specs:const [FieldSpec('date','Verkaufsdatum',date:true,required:true),FieldSpec('quantityKg','Verkaufte Menge (kg)',number:true,min:0.000001,required:true),FieldSpec('priceNet','Verkaufspreis netto (€/kg)',number:true,min:0,required:true),FieldSpec('notes','Notiz / Beleg',multiline:true)],data:data,changed:()=>setState((){})))),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Abbrechen')),FilledButton(onPressed:(){if(form.currentState?.validate()??false)Navigator.pop(context,data);},child:const Text('Speichern'))]);
}
