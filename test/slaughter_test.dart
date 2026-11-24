import 'package:flutter_test/flutter_test.dart';
import 'package:metzgerapp/core/slaughter.dart';
import 'package:metzgerapp/core/types.dart';

void main(){
  final data=<String,dynamic>{'usableKg':80,'animalCost':240,'slaughterCost':120,'otherCost':40};
  test('Costs of entire slaughter included even when some raw material remains',(){
    final products=<Json>[{'rawKg':30,'extraCost':30,'outputKg':25,'salePrice':12},{'rawKg':40,'extraCost':20,'outputKg':36,'salePrice':10}];
    final s=slaughterSummary(data,products);
    expect(s['remainingKg'],10);expect(s['rate'],5);expect(s['cost'],450);expect(s['revenue'],660);expect(s['profit'],210);
    expect(slaughterProductSummary(products.first,5)['cost'],180);
  });
  test('Over-allocation invalid',(){expect(slaughterSummary(data,[{'rawKg':81}])['valid'],false);});
  test('Missing prices or weights do not become zero',(){final s=slaughterSummary(data,[{'rawKg':20,'extraCost':null,'outputKg':null,'salePrice':12}]);expect(s['cost'],isNull);expect(s['revenue'],isNull);expect(s['profit'],isNull);});
  test('Own meat not purchased again; purchased meat and seasonings counted',(){
    final lines=<Json>[
      {'name':'Own meat','materialKind':'meat','costType':'Material','quantity':0.8,'unit':'kg','buyQuantity':1,'buyUnit':'kg','buyPrice':10},
      {'name':'Purchased fat','materialKind':'meat','costType':'Material','quantity':0.2,'unit':'kg','buyQuantity':1,'buyUnit':'kg','buyPrice':5},
      {'name':'Salt','materialKind':'ingredient','costType':'Material','quantity':20,'unit':'g','buyQuantity':1000,'buyUnit':'g','buyPrice':10},
    ];
    final r=slaughterRecipe(lines,{0},8)!;expect(r['extraCost'],closeTo(12,1e-8));expect(maps(r['lines'])[0]['quantity'],8);expect(maps(r['lines'])[1]['quantity'],2);expect(maps(r['lines'])[2]['quantity'],200);
    expect(estimatedFinished(maps(r['lines']),20),closeTo(8.16,1e-8));
    expect(slaughterRecipe(lines,{},8),isNull);
  });
}
