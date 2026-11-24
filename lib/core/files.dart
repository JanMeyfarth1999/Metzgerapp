import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'types.dart';

class LocalFiles {
  static const _channel=MethodChannel('de.metzgerapp/files');
  static Future<bool> save(String name,Uint8List bytes,String mime) async => await _channel.invokeMethod<bool>('save',{'name':name,'bytes':bytes,'mime':mime})??false;
  static Future<Uint8List?> pick(String mime) => _channel.invokeMethod<Uint8List>('pick',{'mime':mime});
  static Future<bool> saveText(String name,String data,String mime)=>save(name,Uint8List.fromList(utf8.encode(data)),mime);
  static String safeName(String s) => s.replaceAll(RegExp(r'[^a-zA-Z0-9äöüÄÖÜß_-]'),'_');
  static String csvCell(dynamic v) {
    var s=str(v);if(RegExp(r'^[=+@\-\t\r]').hasMatch(s)) s="'$s";
    return '"${s.replaceAll('"','""')}"';
  }
  static Future<bool> csv(String name,List<List<dynamic>> rows)=>saveText('$name.csv','\ufeff${rows.map((r)=>r.map(csvCell).join(';')).join('\r\n')}','text/csv');
  static String _pdfText(String s)=>s.replaceAll('✓','OK').replaceAll('–','-').replaceAll('→','->').replaceAll('€',' EUR').replaceAll('²','2').replaceAll('³','3').replaceAll(RegExp(r'[^\x20-\x7e\xa0-\xff\n\r]'),'?');
  static Future<bool> report(String title,List<(String,String)> entries) async {
    final doc=pw.Document();
    final widgets=<pw.Widget>[pw.Header(level:0,text:_pdfText(title)),pw.Text('MetzgerApp | ${dateLabel(now())}'),pw.SizedBox(height:14)];
    for(final entry in entries) {
      widgets.add(pw.Text(_pdfText(entry.$1),style:pw.TextStyle(fontWeight:pw.FontWeight.bold)));
      final text=_pdfText(entry.$2);final chunks=<String>[];
      for(var i=0;i<text.length;i+=550){chunks.add(text.substring(i,(i+550).clamp(0,text.length).toInt()));}
      for(final chunk in chunks){widgets.add(pw.Text(chunk));}
      widgets.add(pw.SizedBox(height:7));
    }
    doc.addPage(pw.MultiPage(pageFormat:PdfPageFormat.a4,maxPages:500,build:(_)=>widgets,footer:(ctx)=>pw.Text('Seite ${ctx.pageNumber} / ${ctx.pagesCount}',style:const pw.TextStyle(fontSize:9))));
    return save('${safeName(title)}.pdf',await doc.save(),'application/pdf');
  }
}
