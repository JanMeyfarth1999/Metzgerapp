import 'calculations.dart';
import 'types.dart';

/// Allocate common slaughter costs over all usable raw mass, never over only
/// the products already planned. Recipe ingredients bought separately are extra.
Json slaughterSummary(Json data, List<Json> products) {
  final usable = numOrNull(data['usableKg']);
  final animal = numOrNull(data['animalCost']);
  final butcher = numOrNull(data['slaughterCost']);
  final other = numOrNull(data['otherCost']);
  final base = [animal, butcher, other].every((v) => v != null && v >= 0)
      ? animal! + butcher! + other! : null;
  final used = products.fold(0.0, (s, p) => s + n(p['rawKg']));
  final valid = usable != null && usable > 0 && products.every((p)=>numOrNull(p['rawKg'])!=null&&n(p['rawKg'])>0) && used <= usable + 0.000001;
  final rate = valid && base != null ? base / usable! : null;
  final extraKnown = products.every((p) => numOrNull(p['extraCost']) != null && n(p['extraCost']) >= 0);
  final extra = extraKnown ? products.fold(0.0, (s, p) => s + n(p['extraCost'])) : null;
  final total = base != null && extra != null ? base + extra : null;
  final revenueKnown = products.isNotEmpty && products.every((p) => numOrNull(p['outputKg']) != null && n(p['outputKg']) >= 0 && numOrNull(p['salePrice']) != null && n(p['salePrice']) >= 0);
  final revenue = revenueKnown ? products.fold(0.0, (s, p) => s + n(p['outputKg']) * n(p['salePrice'])) : null;
  return {'usedKg':used,'remainingKg':usable == null ? null : usable-used,'valid':valid,'baseCost':base,'rate':rate,'extraCost':extra,'cost':total,'revenue':revenue,'profit':valid && total != null && revenue != null ? revenue-total : null};
}

Json slaughterProductSummary(Json product, double? rate) {
  final raw = numOrNull(product['rawKg']);
  final extra = numOrNull(product['extraCost']);
  final output = numOrNull(product['outputKg']);
  final price = numOrNull(product['salePrice']);
  final cost = raw != null && rate != null && extra != null ? raw*rate+extra : null;
  final revenue = output != null && price != null ? output*price : null;
  return {'cost':cost,'costKg':cost != null && output != null && output>0 ? cost/output:null,'revenue':revenue,'profit':cost != null && revenue != null ? revenue-cost:null};
}

bool ownMeat(Json line) => line['materialKind']=='meat' && line['costType']=='Material';

/// Convert a recipe to the given amount of meat from this slaughter. Other
/// meat and ingredients are purchased; own meat has no additional purchase cost.
/// An empty/invalid recipe or a recipe with no selected own meat is not usable.
Json? slaughterRecipe(List<Json> lines, Set<int> own, double rawKg) {
  if (rawKg<=0 || !rawKg.isFinite || own.isEmpty || own.any((i)=>i<0 || i>=lines.length || !ownMeat(lines[i]))) return null;
  var ownKg=0.0;
  for(final i in own) {
    final q=numOrNull(lines[i]['quantity']);
    final kg=q==null?null:convert(q,str(lines[i]['unit']),'kg');
    if(kg==null || kg<0) return null;
    ownKg+=kg;
  }
  if(ownKg<=0) return null;
  final factor=rawKg/ownKg;
  final scaled=<Json>[];
  var extra=0.0;
  var complete=true;
  for(var i=0;i<lines.length;i++) {
    final q=numOrNull(lines[i]['quantity']);
    if(q==null || q<0 || !(q*factor).isFinite) return null;
    final l=<String,dynamic>{...lines[i],'quantity':q*factor,'fromSlaughter':own.contains(i)};
    final cost=own.contains(i)?0.0:lineCost(l);
    if(cost==null) {complete=false;} else {extra+=cost;}
    scaled.add({...l,'extraCost':cost});
  }
  return {'lines':scaled,'extraCost':complete?extra:null};
}

/// Estimate only when all edible ingredient quantities are known by mass.
/// No volume-to-weight assumption is made.
double? estimatedFinished(List<Json> lines, double? loss) {
  if(loss==null || loss<0 || loss>=100) return null;
  final food=lines.where((l)=>l['food']!=false && l['costType']=='Material').toList();
  if(food.isEmpty) return null;
  var weight=0.0;
  for(final l in food) {
    final q=numOrNull(l['quantity']);
    final kg=q==null?null:convert(q,str(l['unit']),'kg');
    if(kg==null||kg<0) return null;
    weight+=kg;
  }
  return weight>0?weight*(1-loss/100):null;
}
