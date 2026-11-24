import 'package:flutter/material.dart';
import '../core/types.dart';
import '../core/store.dart';

void toast(BuildContext context,String message)=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(message)));
Future<void> guarded(BuildContext context,Future<void> Function() task) async {try{await task();}catch(e){if(context.mounted)toast(context,'Fehler: $e');}}
Future<bool> confirm(BuildContext context,String title,String message) async => await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(title:Text(title),content:Text(message),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Abbrechen')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Bestätigen'))]))??false;
Future<T?> openPage<T>(BuildContext context,Widget page)=>Navigator.of(context).push<T>(MaterialPageRoute(builder:(_)=>page));
class PageFrame extends StatelessWidget {
  final String title;final Widget child;final List<Widget>? actions;final Widget? fab;
  const PageFrame({super.key,required this.title,required this.child,this.actions,this.fab});
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(title),actions:actions),body:SafeArea(child:child),floatingActionButton:fab);
}
class Section extends StatelessWidget {
  final String title;final List<Widget> children;final String? subtitle;
  const Section(this.title,this.children,{super.key,this.subtitle});
  @override Widget build(BuildContext context)=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[Text(title,style:Theme.of(context).textTheme.titleLarge),if(subtitle!=null)...[const SizedBox(height:4),Text(subtitle!,style:Theme.of(context).textTheme.bodySmall)],const SizedBox(height:12),...children])));
}
class Notice extends StatelessWidget {
  final String text;final IconData icon;
  const Notice(this.text,{super.key,this.icon=Icons.info_outline});
  @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(12),margin:const EdgeInsets.symmetric(vertical:8),decoration:BoxDecoration(color:Theme.of(context).colorScheme.surfaceContainerHighest,borderRadius:BorderRadius.circular(12)),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(icon,size:20),const SizedBox(width:10),Expanded(child:Text(text))]));
}
class ValueRow extends StatelessWidget {
  final String label,value;final bool strong;
  const ValueRow(this.label,this.value,{super.key,this.strong=false});
  @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.symmetric(vertical:5),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:Text(label)),const SizedBox(width:12),Flexible(child:Text(value,textAlign:TextAlign.end,style:strong?Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.bold):null))]));
}
String shownNum(dynamic value,{String suffix='',int digits=2})=>numOrNull(value)==null?'–':'${fmt(n(value),digits)}$suffix';
String shownMoney(dynamic value)=>numOrNull(value)==null?'–':money(n(value));
class EmptyState extends StatelessWidget {
  final String text; const EmptyState(this.text,{super.key});
  @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.all(28),child:Center(child:Text(text,textAlign:TextAlign.center)));
}
class FieldSpec {
  final String key,label;final bool required,number,multiline,check,date;final List<String>? choices;final double? min,max;final String? hint;
  const FieldSpec(this.key,this.label,{this.required=false,this.number=false,this.multiline=false,this.check=false,this.date=false,this.choices,this.min,this.max,this.hint});
}
/// Reusable local form. Numeric blanks are null, never implicit zero.
class Fields extends StatelessWidget {
  final List<FieldSpec> specs;final Json data;final VoidCallback changed;
  const Fields({super.key,required this.specs,required this.data,required this.changed});
  @override Widget build(BuildContext context)=>Column(children:[for(final f in specs) Padding(padding:const EdgeInsets.only(bottom:12),child:buildField(context,f))]);
  Widget buildField(BuildContext context,FieldSpec f){
    if(f.check) return SwitchListTile(contentPadding:EdgeInsets.zero,title:Text(f.label),subtitle:f.hint==null?null:Text(f.hint!),value:data[f.key]==true,onChanged:(v){data[f.key]=v;changed();});
    if(f.choices!=null){final options={...f.choices!,if(str(data[f.key]).isNotEmpty)str(data[f.key])}.toList();return DropdownButtonFormField<String>(isExpanded:true,value:options.contains(str(data[f.key]))?str(data[f.key]):null,decoration:InputDecoration(labelText:f.label,helperText:f.hint),items:options.map((x)=>DropdownMenuItem(value:x,child:Text(x,overflow:TextOverflow.ellipsis))).toList(),onChanged:(v){data[f.key]=v;changed();},validator:(v)=>f.required&&(v==null||v.isEmpty)?'Bitte auswählen':null);}
    return TextFormField(key:ValueKey(f.key),initialValue:str(data[f.key]),decoration:InputDecoration(labelText:f.label,hintText:f.hint,suffixIcon:f.date?const Icon(Icons.event):null),keyboardType:f.number?const TextInputType.numberWithOptions(decimal:true,signed:true):f.date?TextInputType.datetime:f.multiline?TextInputType.multiline:TextInputType.text,minLines:f.multiline?2:1,maxLines:f.multiline?6:1,onChanged:(v){data[f.key]=f.number?(v.trim().isEmpty?null:numOrNull(v)??v):v;changed();},validator:(v){final t=v?.trim()??'';if(t.isEmpty)return f.required?'Pflichtfeld':null;if(f.number){final value=numOrNull(t);if(value==null)return 'Ungültige Zahl';if(f.min!=null&&value<f.min!)return 'Mindestens ${f.min}';if(f.max!=null&&value>f.max!)return 'Höchstens ${f.max}';}if(f.date&&(!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(t)||DateTime.tryParse(t)==null||DateTime.parse(t).toIso8601String().substring(0,10)!=t))return 'Format: JJJJ-MM-TT';return null;});
  }
}
class RecordList extends StatefulWidget {
  final String title,kind;final LocalStore store;final Future<void> Function(Json?) edit;final String Function(Json)? subtitle;final Future<void> Function(Json)? detail;final bool allowArchive;
  const RecordList({super.key,required this.title,required this.kind,required this.store,required this.edit,this.subtitle,this.detail,this.allowArchive=true});
  @override State<RecordList> createState()=>_RecordListState();
}
class _RecordListState extends State<RecordList>{
  String query='';bool archived=false;
  @override Widget build(BuildContext context)=>AnimatedBuilder(animation:widget.store,builder:(context,_) {
    final items=widget.store.all(widget.kind,includeArchived:archived).where((r)=>('${nameOf(r)} ${widget.subtitle?.call(r)??''}').toLowerCase().contains(query.toLowerCase())).toList();
    return PageFrame(title:widget.title,fab:FloatingActionButton.extended(onPressed:()=>widget.edit(null),icon:const Icon(Icons.add),label:const Text('Neu')),child:Column(children:[Padding(padding:const EdgeInsets.all(12),child:TextField(decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'Suchen'),onChanged:(v)=>setState(()=>query=v))),if(widget.allowArchive)SwitchListTile(dense:true,title:const Text('Archivierte anzeigen'),value:archived,onChanged:(v)=>setState(()=>archived=v)),Expanded(child:items.isEmpty?const EmptyState('Noch keine Einträge. Über „Neu“ anlegen.'):ListView.builder(padding:const EdgeInsets.only(bottom:100),itemCount:items.length,itemBuilder:(ctx,i){final r=items[i];return Card(child:ListTile(title:Text(nameOf(r)),subtitle:Text('${r['archived']==true?'Archiviert · ':''}${widget.subtitle?.call(r)??''}'),onTap:()=>widget.detail==null?widget.edit(r):widget.detail!(r),trailing:widget.allowArchive?PopupMenuButton<String>(onSelected:(v) async {if(v=='edit'){await widget.edit(r);}else{await guarded(context,()async{await widget.store.archive(widget.kind,r,r['archived']!=true);});}},itemBuilder:(_)=>[const PopupMenuItem(value:'edit',child:Text('Bearbeiten')),PopupMenuItem(value:'archive',child:Text(r['archived']==true?'Wiederherstellen':'Archivieren'))]):const Icon(Icons.chevron_right)));}))]));});
}
class GenericEditor extends StatefulWidget {
  final String title,kind;final Json initial;final LocalStore store;final List<FieldSpec> fields;final String? notice;final String? Function(Json)? validate;
  const GenericEditor({super.key,required this.title,required this.kind,required this.initial,required this.store,required this.fields,this.notice,this.validate});
  @override State<GenericEditor> createState()=>_GenericEditorState();
}
class _GenericEditorState extends State<GenericEditor>{
  final form=GlobalKey<FormState>();late Json data={...widget.initial};bool busy=false;
  Future<void> save()async{if(busy||!(form.currentState?.validate()??false))return;final error=widget.validate?.call(data);if(error!=null){toast(context,error);return;}setState(()=>busy=true);await guarded(context,()async{await widget.store.save(widget.kind,data);if(mounted)Navigator.pop(context,true);});if(mounted)setState(()=>busy=false);}
  @override Widget build(BuildContext context)=>PageFrame(title:widget.title,child:Form(key:form,child:ListView(padding:const EdgeInsets.all(12),children:[if(widget.notice!=null)Notice(widget.notice!),Section('Angaben',[Fields(specs:widget.fields,data:data,changed:()=>setState((){}))]),const SizedBox(height:12),FilledButton.icon(onPressed:busy?null:save,icon:const Icon(Icons.save),label:const Text('Speichern'))])));
}
