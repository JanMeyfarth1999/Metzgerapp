import 'dart:collection';
import 'types.dart';

const _unitFactors = <String,(String,double)>{'kg':('mass',1000),'g':('mass',1),'mg':('mass',0.001),'l':('volume',1000),'ml':('volume',1),'Stück':('count',1),'m':('length',100),'cm':('length',1),'h':('time',60),'min':('time',1),'kWh':('energy',1),'Pauschale':('flat',1)};

double? convert(double amount,String from,String to) {
  final a=_unitFactors[from], b=_unitFactors[to];
  if(a==null || b==null || a.$1!=b.$1 || !amount.isFinite) return null;
  return amount*a.$2/b.$2;
}
List<String> compatibleUnits(String unit) => units.where((u)=>convert(1,u,unit)!=null).toList();
double? lineCost(Json line) {
  final quantity=numOrNull(line['quantity']), price=numOrNull(line['buyPrice']), pack=numOrNull(line['buyQuantity']);
  if(quantity==null || price==null || pack==null || quantity<0 || price<0 || pack<=0) return null;
  final converted=convert(quantity,str(line['unit']),str(line['buyUnit']));
  return converted==null ? null : converted/pack*price;
}
Json materialSnapshot(Json material,{required double quantity,required String unit}) => {
  'materialId':material['id'],'materialKind':material['kind'],'name':material['name'],'animal':material['animal'],'grade':material['grade'],'quantity':quantity,'unit':unit,'buyQuantity':material['buyQuantity'],'buyUnit':material['buyUnit'],'buyPrice':material['buyPrice'],'analysis':map(material['analysis']),'allergens':material['allergens'],'additives':material['additives'],'supplier':material['supplier'],'costType':'Material','food':material['food']!=false, 'batch':''};

class Calculation {
  final List<Json> lines;
  final double? inputKg, lossPercent, actualOutputKg, salePriceNet, taxPercent, pieces, targetMargin, soldKg;
  const Calculation({required this.lines,this.inputKg,this.lossPercent,this.actualOutputKg,this.salePriceNet,this.taxPercent,this.pieces,this.targetMargin,this.soldKg});
  bool get costsComplete => lines.isNotEmpty && lines.every((l)=>lineCost(l)!=null);
  double get knownCosts => lines.fold(0.0,(sum,l)=>sum+(lineCost(l)??0));
  double? get cost => costsComplete ? knownCosts : null;
  double? get outputKg {
    if(actualOutputKg!=null) return actualOutputKg!>0 ? actualOutputKg : null;
    if(inputKg==null || inputKg!<=0 || lossPercent==null || lossPercent!<0 || lossPercent!>=100) return null;
    return inputKg!*(1-lossPercent!/100);
  }
  double? get costKg => cost!=null && outputKg!=null ? cost!/outputKg! : null;
  double? get costPiece => cost!=null && pieces!=null && pieces!>0 ? cost!/pieces! : null;
  double? get grossPrice => salePriceNet!=null && salePriceNet!>=0 && taxPercent!=null && taxPercent!>=0 ? salePriceNet!*(1+taxPercent!/100) : null;
  double? get revenue => salePriceNet!=null && salePriceNet!>=0 && outputKg!=null ? salePriceNet!*outputKg! : null;
  double? get profit => revenue!=null && cost!=null ? revenue!-cost! : null;
  double? get margin => profit!=null && revenue!>0 ? profit!/revenue!*100 : null;
  double? get markup => profit!=null && cost!>0 ? profit!/cost!*100 : null;
  double? get targetPrice => costKg!=null && targetMargin!=null && targetMargin!>=0 && targetMargin!<100 ? costKg!/(1-targetMargin!/100) : null;
  double? get actualRevenue => soldKg!=null && soldKg!>=0 && outputKg!=null && soldKg!<=outputKg! && salePriceNet!=null && salePriceNet!>=0 ? soldKg!*salePriceNet! : null;
  double? get actualBalance => actualRevenue!=null && cost!=null ? actualRevenue!-cost! : null;
  double? get actualLoss => inputKg!=null && inputKg!>0 && outputKg!=null ? (1-outputKg!/inputKg!)*100 : null;
  Json summary()=>{'cost':cost,'knownCosts':knownCosts,'outputKg':outputKg,'costKg':costKg,'cost100g':costKg==null?null:costKg!/10,'costPiece':costPiece,'grossPrice':grossPrice,'revenue':revenue,'profit':profit,'margin':margin,'markup':markup,'targetPrice':targetPrice,'actualRevenue':actualRevenue,'actualBalance':actualBalance,'actualLoss':actualLoss};
}

/// Estimates for the raw weighed mixture, not the finished product.
/// Missing analysis values or non-mass food items suppress the estimate.
Json rawAnalysis(List<Json> lines,{bool meatOnly=false}) {
  final food=lines.where((l)=>l['food']!=false && l['costType']=='Material' && (!meatOnly || l['materialKind']=='meat')).toList();
  final result=<String,dynamic>{};
  if(food.isEmpty) return result;
  final weights=food.map((l)=>convert(n(l['quantity']),str(l['unit']),'kg')).toList();
  if(weights.any((x)=>x==null || x<0)) return result;
  final total=weights.fold(0.0,(a,b)=>a+(b??0));
  if(total<=0) return result;
  for(final key in [...rawMetrics,'beffe']) {
    var sum=0.0; var complete=true;
    for(var i=0;i<food.length;i++) {
      if(weights[i]==0) continue;
      final value=numOrNull(map(food[i]['analysis'])[key]);
      if(value==null || value<0 || (metricUnit(key)=='%' && value>100)) {complete=false;break;}
      sum+=value*weights[i]!;
    }
    if(complete) result[key]=sum/total;
  }
  final mp=numOrNull(result['meatProtein']), cp=numOrNull(result['connectiveProtein']), col=numOrNull(result['collagen']);
  if(mp!=null && cp!=null && mp>=cp) {
    result['beffe']=mp-cp;
    }
  final beffe=numOrNull(result['beffe']);
  if(mp!=null&&mp>0&&beffe!=null&&beffe<=mp) result['beffeRatio']=beffe/mp*100;
  if(mp!=null && mp>0 && col!=null) result['collagenRatio']=col/mp*100;
  return result;
}

List<Json> evaluateRules({required List<Json> rules,required List<Json> regulations,required String category,required String product,required Json estimates,required List<Json> observations,required String date,Set<String> confirmedRules=const {}}) {
  final out=<Json>[];
  for(final r in rules) {
    if(r['archived']==true || (str(r['category']).isNotEmpty && r['category']!='Alle' && r['category']!=category) || (str(r['product']).isNotEmpty && str(r['product']).toLowerCase()!=product.toLowerCase())) continue;
    final reg=regulations.where((x)=>x['id']==r['regulationId']).firstOrNull;
    final key=str(r['metric']), basis=str(r['basis']);
    final low=numOrNull(r['min']), high=numOrNull(r['max']);
    final observation=observations.where((o)=>o['metric']==key && o['basis']==basis).lastOrNull;
    final measured=observation!=null && ['Messung','Labor'].contains(observation['source']) && str(observation['reference']).trim().isNotEmpty;
    final value=basis=='Rohmischung (Schätzung)' ? numOrNull(estimates[key]) : numOrNull(observation?['value']);
    final start=str(r['validFrom']), end=str(r['validUntil']);
    final regStart=str(reg?['effectiveFrom']), regEnd=str(reg?['effectiveUntil']);
    final applicable=(start.isEmpty || date.compareTo(start)>=0)&&(end.isEmpty||date.compareTo(end)<=0)&&(regStart.isEmpty||date.compareTo(regStart)>=0)&&(regEnd.isEmpty||date.compareTo(regEnd)<=0);
    String status;
    if(!applicable) {status='Außerhalb Gültigkeit';}
    else if(reg==null || reg['archived']==true || ['Historisch','Historisch / zu klären','Ungeklärt'].contains(reg['status']) || r['verified']!=true || str(r['checkedOn']).isEmpty || str(r['reviewer']).trim().isEmpty || str(r['reference']).trim().isEmpty || str(reg['source']).trim().isEmpty || (r['sourceRevision']!=null && r['sourceRevision']!=reg['updated']) || (low==null&&high==null) || (low!=null&&high!=null&&low>high)) {status='Regel nicht freigegeben';}
    else if(str(r['conditions']).trim().isNotEmpty && !confirmedRules.contains(str(r['id']))) {status='Anwendbarkeit nicht bestätigt';}
    else if(value==null) {status='Wert fehlt';}
    else if(basis!='Rohmischung (Schätzung)' && !measured) {status='Mess-/Labornachweis fehlt';}
    else if((low!=null && value<low)||(high!=null && value>high)) {status=basis=='Rohmischung (Schätzung)'?'Schätzwert außerhalb Bereich':'Grenzwertabweichung';}
    else {status=basis=='Rohmischung (Schätzung)'?'Schätzwert im Bereich':'Einzelanforderung erfüllt';}
    out.add({'rule':Map<String,dynamic>.from(r),'regulation':reg,'name':r['name'],'value':value,'unit':metricUnit(key),'status':status,'basis':basis,'observation':observation});
  }
  return out;
}

/// Live sales totals are separate from the immutable production cost snapshot.
Json salesTotals(Json production,List<Json> sales){
  final summary=map(production['summary']);
  final initialRevenue=numOrNull(summary['actualRevenue']);
  final own=sales.where((s)=>s['productionId']==production['id']).toList();
  final quantity=(initialRevenue==null?0.0:n(production['soldKg']))+own.fold(0.0,(sum,s)=>sum+n(s['quantityKg']));
  final revenue=(initialRevenue??0.0)+own.fold(0.0,(sum,s)=>sum+n(s['quantityKg'])*n(s['priceNet']));
  final hasSales=initialRevenue!=null||own.isNotEmpty;
  return {'quantityKg':quantity,'remainingKg':n(summary['outputKg'])-quantity,'revenue':hasSales?revenue:null,'balance':hasSales&&numOrNull(summary['cost'])!=null?revenue-n(summary['cost']):null};
}
