import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart'; 
import 'package:fl_chart/fl_chart.dart'; 
import '../models/hastalik_model.dart';
import '../models/ilac_model.dart';
import '../models/randevu_model.dart';
import '../services/dil_servisi.dart';
import '../services/pdf_servisi.dart'; 
import '../main.dart'; 
import 'yapay_zeka_sayfasi.dart'; 

class OzetSayfasi extends StatefulWidget {
  const OzetSayfasi({super.key});
  @override
  State<OzetSayfasi> createState() => _OzetSayfasiState();
}

class _OzetSayfasiState extends State<OzetSayfasi> {
  final Box<Hastalik> _hastalikKutusu = Hive.box<Hastalik>('hastaliklar');
  final Box<Ilac> _ilacKutusu = Hive.box<Ilac>('ilaclar');
  final Box<Randevu> _randevuKutusu = Hive.box<Randevu>('randevular');
  final List<Color> pastaRenkleri = [Colors.teal, Colors.orange, Colors.purple, Colors.blue, Colors.red, Colors.green];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaYoneticisi,
      builder: (context, tema, _) {
        return ValueListenableBuilder<String>(
          valueListenable: dilYoneticisi,
          builder: (context, dil, _) {
            final isDark = tema == ThemeMode.dark;
            int hastalikSayisi = _hastalikKutusu.length; int ilacSayisi = _ilacKutusu.length; int randevuSayisi = _randevuKutusu.length;
            Randevu? enYakinRandevu;
            var tumRandevular = _randevuKutusu.values.toList();
            
            if (tumRandevular.isNotEmpty) {
              var siraliRandevular = List<Randevu>.from(tumRandevular)..sort((a, b) => a.randevuTarihi.compareTo(b.randevuTarihi));
              try { enYakinRandevu = siraliRandevular.firstWhere((r) => r.randevuTarihi.isAfter(DateTime.now())); } catch (e) { enYakinRandevu = null; }
            }

            Map<String, int> bolumSayilari = {};
            for(var r in tumRandevular) {
              String bolum = r.hastaneAd.contains(' - ') ? r.hastaneAd.split(' - ').last : r.hastaneAd;
              // DÜZELTİLEN KISIM BURASI: Artık bölümleri randevuMekanCeviri fonksiyonu çevirecek
              String cevrilmisBolum = randevuMekanCeviri(bolum); 
              bolumSayilari[cevrilmisBolum] = (bolumSayilari[cevrilmisBolum] ?? 0) + 1;
            }

            Map<int, int> aylikRandevular = {1:0, 2:0, 3:0, 4:0, 5:0, 6:0, 7:0, 8:0, 9:0, 10:0, 11:0, 12:0};
            for(var r in tumRandevular) { aylikRandevular[r.randevuTarihi.month] = (aylikRandevular[r.randevuTarihi.month] ?? 0) + 1; }

            return Scaffold(
              body: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Text(metin('saglik_ozetiniz'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.5,
                    children: [
                      _istatistikKarti(metin('kayitli_hastalik'), hastalikSayisi.toString(), Icons.medical_information, Colors.orange, isDark),
                      _istatistikKarti(metin('aktif_ilac'), ilacSayisi.toString(), Icons.medication, Colors.blue, isDark),
                      _istatistikKarti(metin('randevular'), randevuSayisi.toString(), Icons.calendar_month, Colors.purple, isDark),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(metin('yaklasan_randevu'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  if (enYakinRandevu != null)
                    Card(
                      color: isDark ? const Color(0xFF004D40) : Colors.teal.shade50, elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isDark ? const Color(0xFF80CBC4) : Colors.transparent)),
                      child: ListTile(
                        leading: Icon(Icons.event_available, color: isDark ? const Color(0xFF80CBC4) : Colors.teal, size: 40),
                        title: Text('Dr. ${enYakinRandevu.doktorAd}', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                        subtitle: Text('${randevuMekanCeviri(enYakinRandevu.hastaneAd)}\n${DateFormat('dd/MM/yyyy - HH:mm').format(enYakinRandevu.randevuTarihi)}', style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.black54)),
                        isThreeLine: true,
                      ),
                    )
                  else
                    Card(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, child: Padding(padding: const EdgeInsets.all(16.0), child: Text(metin('randevu_yok'), textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)))),
                  
                  const SizedBox(height: 30),
                  Text(metin('istatistikler'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                  const SizedBox(height: 16),

                  _grafikKarti(
                    baslik: metin('bolum_dagilimi'), isDark: isDark,
                    icerik: bolumSayilari.isEmpty ? Center(child: Text(metin('yetersiz_veri'), style: TextStyle(color: isDark ? Colors.grey : Colors.black54))) : Row(
                      children: [
                        Expanded(
                          flex: 4, 
                          child: AspectRatio(
                            aspectRatio: 1, 
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2, centerSpaceRadius: 30, 
                                sections: bolumSayilari.entries.toList().asMap().entries.map((entry) { 
                                  return PieChartSectionData(color: pastaRenkleri[entry.key % pastaRenkleri.length], value: entry.value.value.toDouble(), title: '${entry.value.value}', radius: 40, titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)); 
                                }).toList()
                              )
                            )
                          )
                        ),
                        const SizedBox(width: 24), 
                        Expanded(
                          flex: 5, 
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center, 
                            crossAxisAlignment: CrossAxisAlignment.start, 
                            children: bolumSayilari.entries.toList().asMap().entries.map((entry) { 
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4), 
                                child: Row(
                                  children: [
                                    Container(width: 12, height: 12, color: pastaRenkleri[entry.key % pastaRenkleri.length]), 
                                    const SizedBox(width: 8), 
                                    Expanded(child: Text(entry.value.key, style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87), overflow: TextOverflow.ellipsis))
                                  ]
                                )
                              ); 
                            }).toList()
                          )
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _grafikKarti(
                    baslik: metin('aylik_randevu'), isDark: isDark,
                    icerik: tumRandevular.isEmpty ? Center(child: Text(metin('yetersiz_veri'), style: TextStyle(color: isDark ? Colors.grey : Colors.black54))) : AspectRatio(
                      aspectRatio: 1.7, child: BarChart(BarChartData(alignment: BarChartAlignment.spaceAround, maxY: (aylikRandevular.values.reduce((a, b) => a > b ? a : b) + 2).toDouble(), barTouchData: BarTouchData(enabled: false), titlesData: FlTitlesData(show: true, bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) { const aylar = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara']; const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']; String yazi = dil == 'TR' ? aylar[value.toInt() - 1] : months[value.toInt() - 1]; return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(yazi, style: TextStyle(fontSize: 10, color: isDark ? Colors.white70 : Colors.black87))); })), leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))), gridData: const FlGridData(show: false), borderData: FlBorderData(show: false), barGroups: aylikRandevular.entries.map((e) { return BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.toDouble(), color: Colors.teal, width: 12, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)), backDrawRodData: BackgroundBarChartRodData(show: true, toY: (aylikRandevular.values.reduce((a, b) => a > b ? a : b) + 2).toDouble(), color: isDark ? Colors.grey.shade800 : Colors.grey.shade200))]); }).toList())),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- PDF RAPORU BUTONU ---
                  SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () async { await PdfServisi.raporOlusturVePaylas(); }, icon: const Icon(Icons.picture_as_pdf, size: 24), label: Text(metin('pdf_rapor'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: isDark ? const Color(0xFF80CBC4) : const Color(0xFF00796B), foregroundColor: isDark ? Colors.black : Colors.white, elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
                  
                  // Sağ alt köşedeki sabit buton ekranı kaydırırken en alttaki elemanları (PDF Butonu) kapatmasın diye ekstra boşluk
                  const SizedBox(height: 80), 
                ],
              ),
              
              // İŞTE YENİ MİMARİ: SAĞ ALT KÖŞEDE SABİT KALAN YAPAY ZEKA BUTONU (Floating Action Button)
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const YapayZekaSayfasi()));
                },
                icon: const Icon(Icons.auto_awesome, size: 24),
                label: Text(metin('asistana_sor'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                backgroundColor: Colors.amber.shade700,
                foregroundColor: Colors.white,
                elevation: 6, // Havada durduğunu belli eden şık bir gölge
              ),
            );
          }
        );
      }
    );
  }

  Widget _istatistikKarti(String baslik, String deger, IconData ikon, Color renk, bool isDark) { return Card(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, elevation: 3, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Padding(padding: const EdgeInsets.all(12.0), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(ikon, color: isDark ? const Color(0xFF80CBC4) : renk, size: 30), const SizedBox(height: 5), Text(deger, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)), Text(baslik, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey), textAlign: TextAlign.center)]))); }
  Widget _grafikKarti({required String baslik, required Widget icerik, required bool isDark}) { return Card(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, elevation: 3, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: Padding(padding: const EdgeInsets.all(16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(baslik, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)), const SizedBox(height: 16), SizedBox(height: 180, child: icerik)]))); }
}