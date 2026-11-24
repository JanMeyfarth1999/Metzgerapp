import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/store.dart';
import 'core/types.dart';
import 'features/simple.dart';

void main() { WidgetsFlutterBinding.ensureInitialized(); runApp(const ProviderScope(child: MetzgerApp())); }
class MetzgerApp extends ConsumerWidget {
  const MetzgerApp({super.key});
  ThemeData theme(Brightness brightness) {
    final scheme=ColorScheme.fromSeed(seedColor:const Color(0xff8e2937),brightness:brightness);
    return ThemeData(useMaterial3:true,colorScheme:scheme,scaffoldBackgroundColor:scheme.surface,
      inputDecorationTheme:const InputDecorationTheme(border:OutlineInputBorder(),filled:true),
      filledButtonTheme:FilledButtonThemeData(style:FilledButton.styleFrom(minimumSize:const Size(0,54),textStyle:const TextStyle(fontSize:16,fontWeight:FontWeight.w600))),
      outlinedButtonTheme:OutlinedButtonThemeData(style:OutlinedButton.styleFrom(minimumSize:const Size(0,52),textStyle:const TextStyle(fontSize:16))),
      listTileTheme:const ListTileThemeData(minVerticalPadding:12),
      appBarTheme:AppBarTheme(backgroundColor:scheme.surface,foregroundColor:scheme.onSurface,centerTitle:false));
  }
  @override Widget build(BuildContext context,WidgetRef ref) {
    final store=ref.watch(storeProvider);
    final settings=store.settings;
    return MaterialApp(title:'MetzgerApp',debugShowCheckedModeBanner:false,locale:const Locale('de','DE'),supportedLocales:const [Locale('de','DE')],localizationsDelegates:GlobalMaterialLocalizations.delegates,theme:theme(Brightness.light),darkTheme:theme(Brightness.dark),themeMode:settings['theme']=='Hell'?ThemeMode.light:settings['theme']=='Dunkel'?ThemeMode.dark:ThemeMode.system,
      builder:(context,child){final media=MediaQuery.of(context);final scale=(numOrNull(settings['textScale'])??1).clamp(.9,1.4).toDouble();return MediaQuery(data:media.copyWith(textScaler:TextScaler.linear(media.textScaler.scale(scale))),child:child??const SizedBox.shrink());},
      home:store.loading?const Scaffold(body:Center(child:CircularProgressIndicator())):store.error!=null?Scaffold(body:Center(child:PaddingFallback(store:store))):SimpleHome(store:store));
  }
}
class PaddingFallback extends StatelessWidget {
  final LocalStore store; const PaddingFallback({super.key,required this.store});
  @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,children:[Text('Datenbank konnte nicht geöffnet werden.\n${store.error}'),FilledButton(onPressed:store.open,child:const Text('Erneut versuchen'))]));
}
