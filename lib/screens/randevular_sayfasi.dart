import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/randevu_model.dart';
import '../services/bildirim_servisi.dart';
import '../services/ses_servisi.dart'; // Eğer sesli okuma kullanıyorsan
import '../services/dil_servisi.dart';

class RandevularSayfasi extends StatefulWidget {
  const RandevularSayfasi({Key? key}) : super(key: key);

  @override
  State<RandevularSayfasi> createState() => _RandevularSayfasiState();
}

class _RandevularSayfasiState extends State<RandevularSayfasi> {
  final Box<Randevu> _randevuKutusu = Hive.box<Randevu>('randevular');
  bool sesliOkunuyor = false;

  final Color bgColor = const Color(0xFF0B131E);
  final Color cardColor = const Color(0xFF161F2C);
  final Color primaryGreen = const Color(0xFF00C48C);
  final Color primaryOrange = const Color(0xFFFF9900);
  final Color textLight = const Color(0xFFFFFFFF);
  final Color textMuted = const Color(0xFF8B98A5);
  final Color primaryBlue = const Color(0xFF00A3FF);

  void _sesliOku(List<Randevu> randevular) async {
    if (sesliOkunuyor) { 
      await SesServisi.durdur(); 
      setState(() => sesliOkunuyor = false); 
      return; 
    }
    setState(() => sesliOkunuyor = true);
    
    String okunacakMetin = "Yaklaşan randevularınız: ";
    for (var r in randevular) {
      okunacakMetin += "${r.doktorAd}, ${r.hastaneAd}. ";
    }

    await SesServisi.konus(okunacakMetin, dilYoneticisi.value);
    Future.delayed(Duration(seconds: randevular.length * 3 + 2), () {
      if (mounted) setState(() => sesliOkunuyor = false);
    });
  }

  void _randevuFormuAc({Randevu? varOlanRandevu}) {
    final doktorController = TextEditingController(text: varOlanRandevu?.doktorAd ?? '');
    final hastaneController = TextEditingController(text: varOlanRandevu?.hastaneAd ?? '');
    DateTime secilenTarih = varOlanRandevu?.randevuTarihi ?? DateTime.now().add(const Duration(days: 1));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(varOlanRandevu == null ? 'Yeni Randevu Ekle' : 'Randevuyu Düzenle', style: TextStyle(color: textLight, fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(icon: Icon(Icons.close, color: textMuted), onPressed: () => Navigator.pop(context))
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: doktorController,
                    style: TextStyle(color: textLight),
                    decoration: InputDecoration(labelText: 'Doktor Adı (Örn: Dr. Ali Yılmaz)', labelStyle: TextStyle(color: textMuted), prefixIcon: Icon(Icons.person, color: textMuted), filled: true, fillColor: bgColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                  ),
                  const SizedBox(height: 12),
                  
                  TextField(
                    controller: hastaneController,
                    style: TextStyle(color: textLight),
                    decoration: InputDecoration(labelText: 'Hastane & Bölüm (Örn: Şehir Hast. - Üroloji)', labelStyle: TextStyle(color: textMuted), prefixIcon: Icon(Icons.local_hospital, color: textMuted), filled: true, fillColor: bgColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                  ),
                  const SizedBox(height: 16),
                  
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
                    tileColor: bgColor,
                    leading: Icon(Icons.calendar_month, color: primaryOrange), 
                    title: Text('Randevu Tarihi ve Saati', style: TextStyle(color: textMuted, fontSize: 12)), 
                    subtitle: Text(DateFormat('dd/MM/yyyy - HH:mm').format(secilenTarih), style: TextStyle(color: textLight, fontWeight: FontWeight.bold)), 
                    onTap: () async { 
                      DateTime? tarih = await showDatePicker(
                        context: context, initialDate: secilenTarih, firstDate: DateTime.now(), lastDate: DateTime(2030),
                        builder: (context, child) => Theme(data: ThemeData.dark().copyWith(colorScheme: ColorScheme.dark(primary: primaryGreen)), child: child!),
                      ); 
                      if (tarih != null) { 
                        TimeOfDay? saat = await showTimePicker(
                          context: context, initialTime: TimeOfDay.fromDateTime(secilenTarih),
                          builder: (context, child) => Theme(data: ThemeData.dark().copyWith(colorScheme: ColorScheme.dark(primary: primaryGreen)), child: child!),
                        ); 
                        if (saat != null) {
                          setModalState(() => secilenTarih = DateTime(tarih.year, tarih.month, tarih.day, saat.hour, saat.minute));
                        }
                      } 
                    }
                  ),
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (doktorController.text.isNotEmpty && hastaneController.text.isNotEmpty) {
                          if (varOlanRandevu == null) {
                            // YENİ KAYIT
                            int yeniId = await _randevuKutusu.add(Randevu(doktorAd: doktorController.text, hastaneAd: hastaneController.text, randevuTarihi: secilenTarih));
                            await BildirimServisi.randevuHatirlaticiKur(yeniId, doktorController.text, hastaneController.text, secilenTarih); 
                          } else {
                            // GÜNCELLEME
                            varOlanRandevu.doktorAd = doktorController.text;
                            varOlanRandevu.hastaneAd = hastaneController.text;
                            varOlanRandevu.randevuTarihi = secilenTarih;
                            varOlanRandevu.save();
                            await BildirimServisi.randevuHatirlaticiKur(varOlanRandevu.key, doktorController.text, hastaneController.text, secilenTarih); 
                          }
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: Text(varOlanRandevu == null ? 'Kaydet' : 'Güncelle', style: const TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: primaryGreen, foregroundColor: bgColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))
                    )
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        });
      },
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
                      Text('PLANLI TAKİP', style: TextStyle(color: primaryOrange, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      const SizedBox(height: 4),
                      Text('Randevular', style: TextStyle(color: textLight, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _randevuFormuAc(),
                    style: ElevatedButton.styleFrom(backgroundColor: primaryGreen.withOpacity(0.2), foregroundColor: primaryGreen, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Yeni Randevu', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _randevuKutusu.listenable(),
                builder: (context, Box<Randevu> box, _) {
                  var randevular = box.values.toList()..sort((a, b) => a.randevuTarihi.compareTo(b.randevuTarihi));
                  
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: randevular.isEmpty ? null : () => _sesliOku(randevular),
                            icon: Icon(sesliOkunuyor ? Icons.stop_circle : Icons.volume_up, size: 20),
                            label: Text(sesliOkunuyor ? 'Okunuyor...' : 'Randevuları Sesli Oku', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: sesliOkunuyor ? Colors.redAccent : primaryBlue.withOpacity(0.5)),
                              backgroundColor: sesliOkunuyor ? Colors.redAccent.withOpacity(0.1) : primaryBlue.withOpacity(0.05),
                              foregroundColor: sesliOkunuyor ? Colors.redAccent : primaryBlue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Expanded(
                        child: randevular.isEmpty 
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.event_busy, color: textMuted.withOpacity(0.5), size: 64),
                                const SizedBox(height: 16),
                                Text('Gelecek bir randevunuz bulunmuyor.', style: TextStyle(color: textMuted, fontSize: 14)),
                              ],
                            )
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: randevular.length,
                            itemBuilder: (context, index) {
                              Randevu randevu = randevular[index];
                              bool gecmisMi = randevu.randevuTarihi.isBefore(DateTime.now());
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardColor, 
                                  borderRadius: BorderRadius.circular(16),
                                  border: gecmisMi ? null : Border.all(color: primaryOrange.withOpacity(0.3))
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(backgroundColor: primaryGreen.withOpacity(0.2), radius: 24, child: Icon(Icons.person, color: primaryGreen, size: 28)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(randevu.doktorAd, style: TextStyle(color: textLight, fontSize: 16, fontWeight: FontWeight.bold)),
                                              const SizedBox(height: 4),
                                              Text(randevu.hastaneAd, style: TextStyle(color: textMuted, fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(icon: Icon(Icons.edit_outlined, color: textMuted, size: 20), onPressed: () => _randevuFormuAc(varOlanRandevu: randevu), constraints: const BoxConstraints(), padding: const EdgeInsets.symmetric(horizontal: 4)),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                              constraints: const BoxConstraints(), padding: EdgeInsets.zero,
                                              onPressed: () {
                                                BildirimServisi.bildirimiIptalEt(randevu.key); 
                                                randevu.delete();
                                              }
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
                                      child: Row(
                                        children: [
                                          Icon(Icons.calendar_month, color: gecmisMi ? textMuted : primaryOrange, size: 20),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(randevu.randevuTarihi), style: TextStyle(color: gecmisMi ? textMuted : textLight, fontSize: 13, fontWeight: FontWeight.bold)),
                                                Text('Saat: ${DateFormat('HH:mm').format(randevu.randevuTarihi)}', style: TextStyle(color: textMuted, fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                          if (!gecmisMi)
                                            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: primaryOrange.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Text('Yaklaşıyor', style: TextStyle(color: primaryOrange, fontSize: 10, fontWeight: FontWeight.bold))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}