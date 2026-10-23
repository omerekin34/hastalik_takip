import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/ilac_model.dart';

class IlaclarSayfasi extends StatefulWidget {
  const IlaclarSayfasi({Key? key}) : super(key: key);

  @override
  State<IlaclarSayfasi> createState() => _IlaclarSayfasiState();
}

class _IlaclarSayfasiState extends State<IlaclarSayfasi> {
  final Box<Ilac> _ilacKutusu = Hive.box<Ilac>('ilaclar');
  bool _yerelBildirimAcik = true;

  final Color bgColor = const Color(0xFF0B131E);
  final Color cardColor = const Color(0xFF161F2C);
  final Color primaryGreen = const Color(0xFF00C48C);
  final Color primaryBlue = const Color(0xFF00A3FF);
  final Color primaryOrange = const Color(0xFFFF9900);
  final Color textLight = const Color(0xFFFFFFFF);
  final Color textMuted = const Color(0xFF8B98A5);

  void _ilacFormuAc({Ilac? varOlanIlac}) {
    final adController = TextEditingController(text: varOlanIlac?.ad ?? '');
    final turController = TextEditingController(text: varOlanIlac?.tur ?? '');
    final talimatController = TextEditingController(text: varOlanIlac?.talimat ?? '');
    final miktarController = TextEditingController(text: varOlanIlac?.kalanMiktar.toString() ?? '');
    final teshisController = TextEditingController(text: varOlanIlac?.bagliTeshis ?? '');
    
    String seciliZaman = varOlanIlac?.zamanDilimi ?? 'Sabah';
    TimeOfDay seciliSaat = TimeOfDay(
      hour: int.tryParse(varOlanIlac?.saat.split(':')[0] ?? '8') ?? 8,
      minute: int.tryParse(varOlanIlac?.saat.split(':')[1] ?? '0') ?? 0,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(varOlanIlac == null ? 'Yeni İlaç Ekle' : 'İlacı Düzenle', style: TextStyle(color: textLight, fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(icon: Icon(Icons.close, color: textMuted), onPressed: () => Navigator.pop(context))
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(adController, 'İlaç Adı (Doz ile birlikte)', Icons.medication),
                  _buildTextField(turController, 'Türü (Tablet, Şurup vs.)', Icons.science),
                  _buildTextField(talimatController, 'Kullanım Talimatı', Icons.info_outline),
                  _buildTextField(miktarController, 'Kalan Miktar (Sayı)', Icons.numbers, isNumber: true),
                  _buildTextField(teshisController, 'İlgili Teşhis', Icons.medical_services),
                  
                  DropdownButtonFormField<String>(
                    value: seciliZaman,
                    dropdownColor: bgColor,
                    style: TextStyle(color: textLight),
                    decoration: InputDecoration(filled: true, fillColor: bgColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                    items: ['Sabah', 'Öğle', 'Akşam', 'Gece'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setModalState(() => seciliZaman = val!),
                  ),
                  const SizedBox(height: 12),
                  
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    tileColor: bgColor,
                    leading: Icon(Icons.access_time, color: primaryGreen),
                    title: Text('Hatırlatıcı Saati', style: TextStyle(color: textMuted)),
                    subtitle: Text('${seciliSaat.hour.toString().padLeft(2,'0')}:${seciliSaat.minute.toString().padLeft(2,'0')}', style: TextStyle(color: textLight, fontWeight: FontWeight.bold)),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context, 
                        initialTime: seciliSaat,
                        builder: (context, child) => Theme(data: ThemeData.dark().copyWith(colorScheme: ColorScheme.dark(primary: primaryGreen)), child: child!),
                      );
                      if (time != null) setModalState(() => seciliSaat = time);
                    }
                  ),
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (adController.text.isNotEmpty && miktarController.text.isNotEmpty) {
                          String saatFormatli = '${seciliSaat.hour.toString().padLeft(2,'0')}:${seciliSaat.minute.toString().padLeft(2,'0')}';
                          
                          if (varOlanIlac == null) {
                            final yeniIlac = Ilac(
                              ad: adController.text,
                              tur: turController.text,
                              talimat: talimatController.text,
                              kalanMiktar: int.parse(miktarController.text),
                              bagliTeshis: teshisController.text,
                              zamanDilimi: seciliZaman,
                              saat: saatFormatli,
                            );
                            _ilacKutusu.add(yeniIlac);
                          } else {
                            varOlanIlac.ad = adController.text;
                            varOlanIlac.tur = turController.text;
                            varOlanIlac.talimat = talimatController.text;
                            varOlanIlac.kalanMiktar = int.parse(miktarController.text);
                            varOlanIlac.bagliTeshis = teshisController.text;
                            varOlanIlac.zamanDilimi = seciliZaman;
                            varOlanIlac.saat = saatFormatli;
                            varOlanIlac.save();
                          }
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: Text(varOlanIlac == null ? 'Kaydet' : 'Güncelle', style: const TextStyle(color: Color(0xFF0B131E), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        });
      }
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: TextStyle(color: textLight),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label, labelStyle: TextStyle(color: textMuted), prefixIcon: Icon(icon, color: textMuted), filled: true, fillColor: bgColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('GÜNLÜK TEDAVİ PLANI', style: TextStyle(color: primaryGreen, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      const SizedBox(height: 4),
                      Text('İlaç Takip & Hatırlatıcı', style: TextStyle(color: textLight, fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _ilacFormuAc(),
                    style: ElevatedButton.styleFrom(backgroundColor: primaryGreen.withOpacity(0.2), foregroundColor: primaryGreen, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Yeni İlaç', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _ilacKutusu.listenable(),
                builder: (context, Box<Ilac> box, _) {
                  var ilaclar = box.values.toList();
                  
                  // İstatistikleri hesapla
                  int aktifIlacSayisi = ilaclar.length;
                  int alinanDoz = ilaclar.where((i) => i.alindiMi).length;
                  double uyumYuzdesi = aktifIlacSayisi > 0 ? (alinanDoz / aktifIlacSayisi) : 0.0;
                  
                  // Kritik stokta olanları bul (5'ten az kalmışsa)
                  var kritikIlaclar = ilaclar.where((i) => i.kalanMiktar <= 5).toList();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsRow(aktifIlacSayisi, alinanDoz, uyumYuzdesi),
                        const SizedBox(height: 24),
                        
                        if (kritikIlaclar.isNotEmpty) ...[
                          _buildCriticalStockAlert(kritikIlaclar.first),
                          const SizedBox(height: 24),
                        ],
                        
                        _buildSectionTitle('Bugünün İlaç Dozları', '$aktifIlacSayisi Zamanlı Takip'),
                        const SizedBox(height: 16),
                        
                        if (ilaclar.isEmpty)
                          Center(child: Padding(padding: const EdgeInsets.all(20), child: Text('Henüz ilaç eklemediniz.', style: TextStyle(color: textMuted))))
                        else
                          ...ilaclar.map((ilac) => _buildDynamicMedicineCard(ilac)).toList(),
                          
                        const SizedBox(height: 24),
                        _buildBottomControls(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(int aktif, int alinan, double uyum) {
    return Row(
      children: [
        Expanded(child: _buildStatItem('$aktif Aktif', 'Düzenli Reçete')),
        Container(width: 1, height: 30, color: textMuted.withOpacity(0.3)),
        Expanded(child: _buildStatItem('$alinan / $aktif', 'Doz Alındı')),
        Container(width: 1, height: 30, color: textMuted.withOpacity(0.3)),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Uyum', style: TextStyle(color: textMuted, fontSize: 11)),
                  Text('%${(uyum * 100).toInt()}', style: TextStyle(color: textLight, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(width: 8),
              SizedBox(width: 24, height: 24, child: CircularProgressIndicator(value: uyum, strokeWidth: 3, color: primaryGreen, backgroundColor: cardColor))
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String title, String subtitle) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: textLight, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(subtitle, style: TextStyle(color: textMuted, fontSize: 11)),
      ],
    );
  }

  Widget _buildCriticalStockAlert(Ilac kritikIlac) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF2A1B14), border: Border.all(color: primaryOrange.withOpacity(0.5)), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notification_important, color: primaryOrange, size: 20),
              const SizedBox(width: 8),
              Text('KRİTİK STOK', style: TextStyle(color: primaryOrange, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const Spacer(),
              Text('${kritikIlac.kalanMiktar} Tablet Kaldı', style: TextStyle(color: primaryOrange, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text('${kritikIlac.ad} kutusunda son ${kritikIlac.kalanMiktar} tablet kaldı!', style: TextStyle(color: textLight, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Reçete yenileme zamanı yaklaşıyor. Tedavinizde aksama olmaması için randevu alın.', style: TextStyle(color: textMuted, fontSize: 12, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: textLight, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(subtitle, style: TextStyle(color: textMuted, fontSize: 12)),
      ],
    );
  }

  Widget _buildDynamicMedicineCard(Ilac ilac) {
    bool isCompleted = ilac.alindiMi;
    // Eğer ilaç alınmamışsa turuncu kart yapıyoruz
    bool isNext = !isCompleted; 

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNext ? cardColor : cardColor.withOpacity(0.6),
        border: isNext ? Border.all(color: primaryOrange.withOpacity(0.5)) : null,
        borderRadius: BorderRadius.circular(16)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(isCompleted ? Icons.wb_sunny_outlined : Icons.light_mode, color: isCompleted ? textMuted : primaryOrange, size: 16),
                  const SizedBox(width: 6),
                  Text('${ilac.zamanDilimi.toUpperCase()} • ${ilac.saat}', style: TextStyle(color: isCompleted ? textMuted : primaryOrange, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  IconButton(icon: Icon(Icons.edit, color: textMuted, size: 18), onPressed: () => _ilacFormuAc(varOlanIlac: ilac), constraints: const BoxConstraints(), padding: const EdgeInsets.symmetric(horizontal: 4)),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18), onPressed: () => ilac.delete(), constraints: const BoxConstraints(), padding: EdgeInsets.zero),
                  const SizedBox(width: 12),
                  if (isCompleted)
                    Row(children: [Icon(Icons.check, color: primaryGreen, size: 16), const SizedBox(width: 4), Text('Alındı', style: TextStyle(color: primaryGreen, fontSize: 12, fontWeight: FontWeight.bold))])
                  else
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: primaryOrange, borderRadius: BorderRadius.circular(8)), child: Text('Şimdi Alınmalı!', style: TextStyle(color: bgColor, fontSize: 10, fontWeight: FontWeight.bold)))
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(ilac.ad, style: TextStyle(color: isCompleted ? textMuted : textLight, fontSize: 18, fontWeight: FontWeight.bold, decoration: isCompleted ? TextDecoration.lineThrough : null)),
              const SizedBox(width: 8),
              Text(ilac.tur, style: TextStyle(color: textMuted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 110, child: Text('Kullanım Talimatı:', style: TextStyle(color: textMuted, fontSize: 11))), Expanded(child: Text(ilac.talimat, style: TextStyle(color: isCompleted ? textMuted : textLight, fontSize: 11)))]),
          const SizedBox(height: 4),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 110, child: Text('Kalan Miktar:', style: TextStyle(color: textMuted, fontSize: 11))), Expanded(child: Text('${ilac.kalanMiktar} adet kaldı', style: TextStyle(color: isNext ? primaryOrange : textMuted, fontSize: 11)))]),
          
          if (!isCompleted) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () { ilac.alindiMi = true; ilac.save(); },
                style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: bgColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Alındı Olarak İşaretle', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.wifi, color: primaryGreen, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Yerel Bildirimler: Açık', style: TextStyle(color: textLight, fontSize: 13, fontWeight: FontWeight.bold)),
                Text('İnternetsiz doğru ve cihaz çalar (SQLite)', style: TextStyle(color: textMuted, fontSize: 10)),
              ],
            ),
          ],
        ),
        Switch(value: _yerelBildirimAcik, onChanged: (val) => setState(() => _yerelBildirimAcik = val), activeColor: primaryGreen, activeTrackColor: primaryGreen.withOpacity(0.3))
      ],
    );
  }
}