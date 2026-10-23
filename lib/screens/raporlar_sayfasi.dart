import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/hastalik_model.dart';
import '../models/ilac_model.dart';
import '../models/randevu_model.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class RaporlarSayfasi extends StatefulWidget {
  const RaporlarSayfasi({Key? key}) : super(key: key);

  @override
  State<RaporlarSayfasi> createState() => _RaporlarSayfasiState();
}

class _RaporlarSayfasiState extends State<RaporlarSayfasi> {
  // Tema Renkleri
  final Color bgColor = const Color(0xFF0B131E);
  final Color cardColor = const Color(0xFF161F2C);
  final Color primaryGreen = const Color(0xFF00C48C);
  final Color primaryBlue = const Color(0xFF00A3FF);
  final Color primaryOrange = const Color(0xFFFF9900);
  final Color textLight = const Color(0xFFFFFFFF);
  final Color textMuted = const Color(0xFF8B98A5);

  String _seciliZamanFiltresi = 'Tüm Zamanlar';

 @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        Hive.box<Hastalik>('hastaliklar').listenable(),
        Hive.box<Ilac>('ilaclar').listenable(),
        Hive.box<Randevu>('randevular').listenable(),
      ]),
      builder: (context, child) {
        var hastaliklar = Hive.box<Hastalik>('hastaliklar').values.toList();
        var ilaclar = Hive.box<Ilac>('ilaclar').values.toList();
        var randevular = Hive.box<Randevu>('randevular').values.toList();

        // 1. SEÇİLEN ZAMANA GÖRE TARİH HESAPLAMASI
        DateTime simdi = DateTime.now();
        DateTime? filtreTarihi;

        if (_seciliZamanFiltresi == 'Haftalık') {
          filtreTarihi = simdi.subtract(const Duration(days: 7));
        } else if (_seciliZamanFiltresi == 'Aylık') {
          filtreTarihi = simdi.subtract(const Duration(days: 30));
        } else if (_seciliZamanFiltresi == 'Yıllık') {
          filtreTarihi = simdi.subtract(const Duration(days: 365));
        }

        // 2. LİSTELERİ FİLTRELEME (İlaçlar aktif takip olduğu için filtrelenmez)
        if (filtreTarihi != null) {
          hastaliklar = hastaliklar.where((h) => h.tarih.isAfter(filtreTarihi!)).toList();
          randevular = randevular.where((r) => r.randevuTarihi.isAfter(filtreTarihi!)).toList();
        }

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  _buildTimeFilters(),
                  const SizedBox(height: 24),
                  _buildStatsGrid(hastaliklar, ilaclar, randevular),
                  const SizedBox(height: 24),
                  _buildPolyclinicSection(hastaliklar),
                  const SizedBox(height: 24),
                  _buildTensionTrend(), 
                  const SizedBox(height: 24),
                  _buildMonthlyVisits(hastaliklar),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

 Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.monitor_heart, color: primaryGreen, size: 14),
                  const SizedBox(width: 6),
                  Text('KLİNİK TELEMETRİ', style: TextStyle(color: primaryGreen, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ],
              ),
              const SizedBox(height: 4),
              Text('Sağlık Raporu &\nAnalizler', style: TextStyle(color: textLight, fontSize: 22, fontWeight: FontWeight.bold, height: 1.2)),
              const SizedBox(height: 4),
              Text('Cihaz üzerinde yerel derlenen veriler', style: TextStyle(color: textMuted, fontSize: 11)),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => _disaAktarMenuAc(context), // BURASI YENİ FONKSİYONA BAĞLANDI
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: textMuted.withOpacity(0.5)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          icon: Icon(Icons.download, color: textLight, size: 16),
          label: Text('Dışa Aktar', style: TextStyle(color: textLight, fontSize: 12)),
        )
      ],
    );
  }

  Widget _buildTimeFilters() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTimeTab('Haftalık'),
        _buildTimeTab('Aylık'),
        _buildTimeTab('Yıllık'),
        _buildTimeTab('Tüm Zamanlar'),
      ],
    );
  }

  Widget _buildTimeTab(String label) {
    bool isSelected = _seciliZamanFiltresi == label;
    
    return InkWell(
      onTap: () {
        setState(() {
          _seciliZamanFiltresi = label; // Tıklanan sekmeyi aktif yap
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryGreen : Colors.transparent, 
          borderRadius: BorderRadius.circular(20)
        ),
        child: Text(
          label, 
          style: TextStyle(
            color: isSelected ? bgColor : textMuted, 
            fontSize: 12, 
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
          )
        ),
      ),
    );
  }

  Widget _buildStatsGrid(List<Hastalik> hastaliklar, List<Ilac> ilaclar, List<Randevu> randevular) {
    // 1. Ziyaret Sayısı ve Farklı Branşlar
    int ziyaretSayisi = hastaliklar.length;
    int farkliBrans = hastaliklar.map((e) => e.poliklinik).toSet().length;

    // 2. İlaç Uyum Skoru
    int alinanIlac = ilaclar.where((i) => i.alindiMi).length;
    int uyumYuzdesi = ilaclar.isEmpty ? 0 : ((alinanIlac / ilaclar.length) * 100).toInt();
    String uyumMetni = uyumYuzdesi > 80 ? 'Harika Seviye' : (uyumYuzdesi > 50 ? 'Orta Seviye' : 'Düşük Seviye');

    // 3. Randevu ve Hastalık Toplamı
    int toplamKayit = randevular.length + hastaliklar.length;
    String sonTarih = hastaliklar.isNotEmpty 
        ? DateFormat('dd MMM yyyy', 'tr_TR').format(hastaliklar.last.tarih) 
        : 'Kayıt Yok';

    // 4. Tahmini DB Boyutu (Göstermelik eğlenceli dinamik hesap)
    double dbBoyutu = (toplamKayit * 0.15) + (ilaclar.length * 0.05);
    if (dbBoyutu < 0.1) dbBoyutu = 0.1;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('Doktor Ziyareti', '$ziyaretSayisi', 'Kayıt', '$farkliBrans farklı branş', Icons.medical_services_outlined, primaryGreen)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('İlaç Uyum Skoru', '%$uyumYuzdesi', '', uyumMetni, Icons.fact_check_outlined, primaryBlue)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('Sistem Kaydı', '$toplamKayit', 'Veri', 'Son: $sonTarih', Icons.folder_open, primaryOrange)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Veritabanı Boyutu', dbBoyutu.toStringAsFixed(1), 'MB', 'Tamamı cihazınızda', Icons.data_usage, primaryGreen)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String unit, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: textMuted, fontSize: 11)),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: TextStyle(color: textLight, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Text(unit, style: TextStyle(color: textMuted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (title == 'Veritabanı Boyutu') Icon(Icons.lock, color: color, size: 10),
              if (title == 'Veritabanı Boyutu') const SizedBox(width: 4),
              Expanded(child: Text(subtitle, style: TextStyle(color: title == 'Veritabanı Boyutu' ? color : textMuted, fontSize: 10), overflow: TextOverflow.ellipsis)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPolyclinicSection(List<Hastalik> hastaliklar) {
    // Poliklinik sayılarını hesapla
    Map<String, int> poliSayilari = {};
    for (var h in hastaliklar) {
      poliSayilari[h.poliklinik] = (poliSayilari[h.poliklinik] ?? 0) + 1;
    }

    // En çok gidilenleri sırala
    var siraliPoli = poliSayilari.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    
    // Toplam ziyaret
    int toplamZiyaret = hastaliklar.length;

    // Renk havuzu
    List<Color> renkler = [primaryGreen, primaryBlue, primaryOrange, textMuted];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: primaryGreen, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text('Poliklinik Dağılımı', style: TextStyle(color: textLight, fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              Text('$toplamZiyaret Ziyaret Kayıtlı', style: TextStyle(color: textMuted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 24),
          
          if (toplamZiyaret == 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text('Henüz klinik kaydınız bulunmuyor.', style: TextStyle(color: textMuted)),
            )
          else ...[
            // Dinamik Merkez Grafik
            SizedBox(
              width: 120, height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ...siraliPoli.asMap().entries.map((entry) {
                    int index = entry.key;
                    if (index > 3) return const SizedBox.shrink(); // Sadece ilk 4'ü çiz
                    
                    double percentage = entry.value.value / toplamZiyaret;
                    
                    // İç içe geçmesi için value'yi kümülatif yapıyoruz
                    double kumeDeger = 0;
                    for (int i = 0; i <= index; i++) {
                      kumeDeger += siraliPoli[i].value / toplamZiyaret;
                    }

                    return CircularProgressIndicator(
                      value: kumeDeger, 
                      strokeWidth: 14, 
                      color: renkler[index % renkler.length],
                      backgroundColor: Colors.transparent,
                    );
                  }).toList().reversed, // Büyükten küçüğe üst üste binmesi için ters çevir
                  
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Toplam', style: TextStyle(color: textMuted, fontSize: 10)),
                      Text('$toplamZiyaret', style: TextStyle(color: textLight, fontSize: 28, fontWeight: FontWeight.bold)),
                      Text('Kayıt', style: TextStyle(color: textMuted, fontSize: 10)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Dinamik Liste Elemanları (Sadece en çok gidilen 4 poliklinik)
            ...siraliPoli.take(4).toList().asMap().entries.map((entry) {
              int index = entry.key;
              var poli = entry.value;
              double yuzde = (poli.value / toplamZiyaret) * 100;
              
              // Son gidilen tarihi bul
              var buPolidekiler = hastaliklar.where((h) => h.poliklinik == poli.key).toList();
              buPolidekiler.sort((a, b) => b.tarih.compareTo(a.tarih));
              String sonTarih = DateFormat('dd MMM').format(buPolidekiler.first.tarih);
              String sonDoktor = buPolidekiler.first.doktor;

              return _buildPolyclinicListItem(
                renkler[index], 
                poli.key, 
                '$sonDoktor • Son: $sonTarih', 
                '${poli.value} Ziyaret', 
                '%${yuzde.toStringAsFixed(1)}',
                isLast: index == (siraliPoli.length > 4 ? 3 : siraliPoli.length - 1)
              );
            }).toList(),
          ]
        ],
      ),
    );
  }

  Widget _buildPolyclinicListItem(Color color, String title, String subtitle, String count, String percentage, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: textLight, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: textMuted, fontSize: 11), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(count, style: TextStyle(color: textLight, fontSize: 12, fontWeight: FontWeight.bold)),
              Text(percentage, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTensionTrend() {
    // Tansiyon veritabanı eklendiğinde burası da dinamikleştirilebilir.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.diamond_outlined, color: primaryBlue, size: 18),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tansiyon & Nabız Trendi', style: TextStyle(color: textLight, fontSize: 15, fontWeight: FontWeight.bold)),
                      Text('Örnek görselleştirme paneli', style: TextStyle(color: textMuted, fontSize: 11)),
                    ],
                  ),
                ],
              ),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: primaryGreen.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Text('Hedefte\n(120/80)', textAlign: TextAlign.center, style: TextStyle(color: primaryGreen, fontSize: 9, fontWeight: FontWeight.bold)))
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTensionValue('Sistolik (Büyük)', '122', 'mmHg', primaryGreen),
              _buildTensionValue('Diyastolik (Küçük)', '78', 'mmHg', primaryBlue),
              _buildTensionValue('Ortalama Nabız', '72', 'bpm', primaryOrange),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(8, (index) {
                final heightSistolik = 60.0 + (index % 3 == 0 ? 10 : (index % 2 == 0 ? -5 : 5));
                final heightDiyastolik = 40.0 + (index % 2 == 0 ? 8 : -8);
                return SizedBox(
                  width: 30,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(width: 4, height: heightSistolik, decoration: BoxDecoration(color: primaryGreen.withOpacity(0.5), borderRadius: BorderRadius.circular(2))),
                      Container(width: 4, height: heightDiyastolik, decoration: BoxDecoration(color: primaryBlue.withOpacity(0.8), borderRadius: BorderRadius.circular(2))),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1 Eyl', style: TextStyle(color: textMuted, fontSize: 10)),
              Text('8 Eyl', style: TextStyle(color: textMuted, fontSize: 10)),
              Text('Bugün', style: TextStyle(color: textMuted, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(primaryGreen, 'Sistolik'),
              const SizedBox(width: 16),
              _buildLegend(primaryBlue, 'Diyastolik'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTensionValue(String label, String value, String unit, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: textMuted, fontSize: 10)),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(width: 2),
            Text(unit, style: TextStyle(color: textMuted, fontSize: 10)),
          ],
        )
      ],
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(children: [Container(width: 8, height: 3, color: color), const SizedBox(width: 6), Text(label, style: TextStyle(color: textMuted, fontSize: 10))]);
  }

 Widget _buildMonthlyVisits(List<Hastalik> hastaliklar) {
    // Son 6 ayın ziyaretlerini hesapla
    DateTime simdi = DateTime.now();
    List<int> aylikZiyaretler = List.filled(6, 0);
    List<String> ayIsimleri = [];

    for (int i = 5; i >= 0; i--) {
      DateTime hedefAy = DateTime(simdi.year, simdi.month - i, 1);
      ayIsimleri.add(DateFormat('MMM', 'tr_TR').format(hedefAy));
      
      int oAydakiKayit = hastaliklar.where((h) => h.tarih.year == hedefAy.year && h.tarih.month == hedefAy.month).length;
      aylikZiyaretler[5 - i] = oAydakiKayit;
    }

    // Grafik çubuklarının taşmaması için en yüksek değeri bulup orantılıyoruz
    int maxZiyaret = aylikZiyaretler.reduce((curr, next) => curr > next ? curr : next);
    if (maxZiyaret == 0) maxZiyaret = 1; // Sıfıra bölünme hatasını önle

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_month, color: primaryGreen, size: 16),
                  const SizedBox(width: 8),
                  Text('Aylık Ziyaret Sıklığı', style: TextStyle(color: textLight, fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              Text('${simdi.year} Yılı', style: TextStyle(color: textMuted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 24),
          
          // Dinamik Bar Chart (Taşma ve Parametre hatası fixed)
          SizedBox(
            height: 120, // Yüksekliği biraz artırdık taşmasın diye
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                // Hata vermemesi için sayıları kesin olarak double'a çeviriyoruz
                double gecerliMax = maxZiyaret > 0 ? maxZiyaret.toDouble() : 1.0;
                double ziyaretSayisi = aylikZiyaretler[index].toDouble();
                
                // Maksimum yükseklik 90 piksel olacak şekilde oranlıyoruz
                double barHeight = (ziyaretSayisi / gecerliMax) * 90.0; 
                if (barHeight < 10 && ziyaretSayisi > 0) barHeight = 10.0; // En az 10px görünsün
                
                // DÜZELTME: color: parametresi eklendi
                return _buildBar(barHeight, ayIsimleri[index], color: ziyaretSayisi > 0 ? primaryGreen : null);
              }),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: textMuted, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(hastaliklar.isEmpty ? 'Kayıtlı veri bekleniyor...' : 'Grafik son 6 aydaki klinik kayıtlarınızı yansıtmaktadır.', style: TextStyle(color: textMuted, fontSize: 11))),
              ],
            ),
          )
        ],
      ),
    );
  }
  Widget _buildBar(double height, String label, {Color? color}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: height > 0 ? height : 2, // Sıfırsa bile minik çizgi kalsın
          decoration: BoxDecoration(
            color: color ?? cardColor,
            border: Border.all(color: color != null ? Colors.transparent : textMuted.withOpacity(0.3)),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 8),  
        Text(label, style: TextStyle(color: textMuted, fontSize: 10)),
      ],
    );
  }
 void _disaAktarMenuAc(BuildContext context) {
    final hastaliklar = Hive.box<Hastalik>('hastaliklar').values.toList();
    final ilaclar = Hive.box<Ilac>('ilaclar').values.toList();
    final randevular = Hive.box<Randevu>('randevular').values.toList();

    String rapor = "Tarih: ${DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR').format(DateTime.now())}\n";
    rapor += "--------------------------------------\n\n";

    rapor += "🏥 HASTALIKLAR & ZİYARETLER (${hastaliklar.length} Kayıt)\n";
    if (hastaliklar.isEmpty) {
      rapor += "- Kayıt bulunmuyor.\n";
    } else {
      for (var h in hastaliklar) {
        rapor += "- ${DateFormat('dd.MM.yyyy').format(h.tarih)}: ${h.ad} (${h.poliklinik}) | Dr: ${h.doktor}\n";
      }
    }
    rapor += "\n";

    rapor += "💊 GÜNCEL İLAÇ LİSTESİ (${ilaclar.length} Kayıt)\n";
    if (ilaclar.isEmpty) {
      rapor += "- Kayıt bulunmuyor.\n";
    } else {
      for (var i in ilaclar) {
        rapor += "- ${i.ad} (${i.tur}) - Kalan: ${i.kalanMiktar} adet | Kullanım: ${i.zamanDilimi}, ${i.saat}\n";
      }
    }
    rapor += "\n";

    rapor += "📅 PLANLI RANDEVULAR\n";
    var gelecekRandevular = randevular.where((r) => r.randevuTarihi.isAfter(DateTime.now())).toList();
    gelecekRandevular.sort((a,b) => a.randevuTarihi.compareTo(b.randevuTarihi));
    
    if (gelecekRandevular.isEmpty) {
      rapor += "- Kayıt bulunmuyor.\n";
    } else {
      for (var r in gelecekRandevular) {
        rapor += "- ${DateFormat('dd.MM.yyyy HH:mm').format(r.randevuTarihi)}: Dr. ${r.doktorAd} (${r.hastaneAd})\n";
      }
    }
    rapor += "\n--------------------------------------\n";
    rapor += "*Bu rapor Kişisel Sağlık Asistanım uygulaması üzerinden oluşturulmuştur.";

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Verileri Dışa Aktar', style: TextStyle(color: textLight, fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: Icon(Icons.close, color: textMuted), onPressed: () => Navigator.pop(context))
                ],
              ),
              const SizedBox(height: 8),
              Text('Raporunuzu PDF olarak cihazınıza indirebilir veya metin olarak kopyalayabilirsiniz.', style: TextStyle(color: textMuted, fontSize: 12)),
              const SizedBox(height: 16),
              
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: textMuted.withOpacity(0.3))),
                  child: SingleChildScrollView(
                    child: Text("📋 KİŞİSEL SAĞLIK RAPORU\n$rapor", style: TextStyle(color: textLight, fontSize: 12, height: 1.5, fontFamily: 'monospace')),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // YENİ: PDF İNDİRME BUTONU
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _pdfOlusturVePaylas(context, rapor);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: primaryOrange, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 18),
                  label: const Text('PDF Olarak İndir / Paylaş', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              
              // ESKİ: METİN KOPYALAMA BUTONU
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: "📋 KİŞİSEL SAĞLIK RAPORU\n$rapor"));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rapor metni kopyalandı!'), backgroundColor: Colors.green));
                  },
                  style: OutlinedButton.styleFrom(side: BorderSide(color: primaryGreen), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  icon: Icon(Icons.copy, color: primaryGreen, size: 18),
                  label: Text('Sadece Metni Kopyala', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        );
      }
    );
  }

  // YEPYENİ PDF OLUŞTURUCU FONKSİYON
  Future<void> _pdfOlusturVePaylas(BuildContext context, String raporMetni) async {
    // Yükleniyor animasyonu göster (Çünkü font indirmesi 1-2 saniye sürebilir)
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF Hazırlanıyor...'), duration: Duration(seconds: 1)));

    final pdf = pw.Document();
    // Türkçe karakterlerin PDF'te bozulmaması için Google Fonts kullanıyoruz
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('KİŞİSEL SAĞLIK RAPORU', style: pw.TextStyle(font: fontBold, fontSize: 24, color: PdfColors.teal800)),
              ),
              pw.SizedBox(height: 10),
              pw.Text(raporMetni, style: pw.TextStyle(font: fontRegular, fontSize: 12, lineSpacing: 1.5)),
            ],
          );
        },
      ),
    );

    // Printing paketi doğrudan sistemin paylaşma/kaydetme menüsünü tetikler
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'Kisisel_Saglik_Raporu.pdf');
  }
}