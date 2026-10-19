import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/hastalik_model.dart';
import '../models/ilac_model.dart';
import '../models/randevu_model.dart';
import 'dil_servisi.dart'; 

class PdfServisi {
  static Future<void> raporOlusturVePaylas() async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();

    final hastalikKutusu = Hive.box<Hastalik>('hastaliklar');
    final ilacKutusu = Hive.box<Ilac>('ilaclar');
    final randevuKutusu = Hive.box<Randevu>('randevular');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (pw.Context context) {
          return [
            _baslikOlustur(),
            pw.SizedBox(height: 20),
            _hastaliklariListele(hastalikKutusu.values.toList()),
            pw.SizedBox(height: 20),
            _ilaclariListele(ilacKutusu.values.toList()),
            pw.SizedBox(height: 20),
            _randevulariListele(randevuKutusu.values.toList()),
          ];
        },
      ),
    );
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'Saglik_Raporum.pdf');
  }

  static pw.Widget _baslikOlustur() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(metin('uygulama_baslik'), style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.teal)),
        pw.SizedBox(height: 5),
        pw.Text('${metin('saglik_ozetiniz')} - ${DateFormat('dd/MM/yyyy').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
        pw.Divider(thickness: 2, color: PdfColors.teal),
      ],
    );
  }

  static pw.Widget _hastaliklariListele(List<Hastalik> hastaliklar) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(metin('hastaliklar'), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.orange)),
        pw.SizedBox(height: 10),
        if (hastaliklar.isEmpty) pw.Text(metin('hastalik_yok')),
        ...hastaliklar.map((h) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 8), padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(evrenselCeviri(h.ad), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text('${metin('tarih')}: ${DateFormat('dd/MM/yyyy').format(h.teshisTarihi)} | ${metin('not')}: ${h.doktorNotu}'),
            ]
          )
        )).toList()
      ]
    );
  }

  static pw.Widget _ilaclariListele(List<Ilac> ilaclar) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(metin('ilaclar'), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
        pw.SizedBox(height: 10),
        if (ilaclar.isEmpty) pw.Text(metin('ilac_yok')),
        ...ilaclar.map((i) => pw.Container(
          width: double.infinity, margin: const pw.EdgeInsets.only(bottom: 8), padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
          child: pw.Text('${i.ad} - ${metin('dozaj')}: ${evrenselCeviri(i.doz)} | ${metin('siklik')}: ${evrenselCeviri(i.kullanimSikligi)}')
        )).toList()
      ]
    );
  }

  static pw.Widget _randevulariListele(List<Randevu> randevular) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(metin('randevular'), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.purple)),
        pw.SizedBox(height: 10),
        if (randevular.isEmpty) pw.Text(metin('randevu_bos')),
        ...randevular.map((r) => pw.Container(
          width: double.infinity, margin: const pw.EdgeInsets.only(bottom: 8), padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
          child: pw.Text('Dr. ${r.doktorAd} - ${randevuMekanCeviri(r.hastaneAd)} | ${DateFormat('dd/MM/yyyy HH:mm').format(r.randevuTarihi)}')
        )).toList()
      ]
    );
  }
}