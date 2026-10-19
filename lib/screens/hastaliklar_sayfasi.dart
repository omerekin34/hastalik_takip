import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../models/hastalik_model.dart';
import '../services/dil_servisi.dart'; 
import '../services/ses_servisi.dart'; // SES MOTORU
import '../main.dart'; 

class HastaliklarSayfasi extends StatefulWidget {
  const HastaliklarSayfasi({super.key});
  @override
  State<HastaliklarSayfasi> createState() => _HastaliklarSayfasiState();
}

class _HastaliklarSayfasiState extends State<HastaliklarSayfasi> {
  final Box<Hastalik> _hastalikKutusu = Hive.box<Hastalik>('hastaliklar');
  bool sesliOkunuyor = false;

  void _sesliOku(List<Hastalik> hastaliklar) async {
    if (sesliOkunuyor) { await SesServisi.durdur(); setState(() => sesliOkunuyor = false); return; }
    setState(() => sesliOkunuyor = true);
    
    String okunacakMetin = metin('hastalik_giris');
    for (var hastalik in hastaliklar) {
      okunacakMetin += "${evrenselCeviri(hastalik.ad)}. ";
    }

    await SesServisi.konus(okunacakMetin, dilYoneticisi.value);
    Future.delayed(Duration(seconds: hastaliklar.length * 2 + 2), () {
      if (mounted) setState(() => sesliOkunuyor = false);
    });
  }

  void _kayitPenceresiAc({Hastalik? varOlanHastalik}) {
    final hastalikListesi = hastalikListesiDinamik; final digerSecenek = metin('diger');
    String secilenHastalik = hastalikListesi.first; bool hastalikDiger = false;
    final adController = TextEditingController(); final notController = TextEditingController(text: varOlanHastalik?.doktorNotu ?? '');
    Uint8List? secilenResimBytes = varOlanHastalik?.resimBytes; final ImagePicker picker = ImagePicker();

    if (varOlanHastalik != null) {
      String cevrilmisAd = evrenselCeviri(varOlanHastalik.ad);
      if (hastalikListesi.contains(cevrilmisAd)) secilenHastalik = cevrilmisAd; else { secilenHastalik = digerSecenek; hastalikDiger = true; adController.text = varOlanHastalik.ad; }
    }

    showModalBottomSheet(
      context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(varOlanHastalik == null ? metin('yeni_hastalik') : metin('hastalik_duzenle'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                      IconButton(icon: const Icon(Icons.close), color: temaYoneticisi.value == ThemeMode.dark ? Colors.grey.shade400 : Colors.grey.shade700, onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: secilenHastalik, decoration: InputDecoration(labelText: metin('hastalik_sec'), border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.sick)),
                    items: [...hastalikListesi, digerSecenek].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setModalState(() { secilenHastalik = val!; hastalikDiger = val == digerSecenek; }),
                  ),
                  if (hastalikDiger) ...[const SizedBox(height: 10), TextField(controller: adController, decoration: InputDecoration(labelText: metin('sikayet_yaz'), border: const OutlineInputBorder()))],
                  const SizedBox(height: 15),
                  TextField(controller: notController, decoration: InputDecoration(labelText: metin('doktor_notu'), border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.notes)), maxLines: 3),
                  const SizedBox(height: 15),
                  secilenResimBytes != null ? Stack(alignment: Alignment.topRight, children: [ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.memory(secilenResimBytes!, height: 120, width: double.infinity, fit: BoxFit.cover)), IconButton(icon: const Icon(Icons.cancel, color: Colors.red, size: 30), onPressed: () => setModalState(() => secilenResimBytes = null))]) : OutlinedButton.icon(onPressed: () async { final XFile? resim = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50); if (resim != null) { final bytes = await resim.readAsBytes(); setModalState(() => secilenResimBytes = bytes); } }, icon: const Icon(Icons.add_a_photo, color: Colors.teal), label: Text(metin('fotograf_ekle'), style: const TextStyle(color: Colors.teal)), style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.teal), padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20))),
                  const SizedBox(height: 15),
                  SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () { final finalAd = hastalikDiger ? adController.text : secilenHastalik; if (finalAd.isNotEmpty) { if (varOlanHastalik == null) _hastalikKutusu.add(Hastalik(ad: finalAd, teshisTarihi: DateTime.now(), doktorNotu: notController.text, resimBytes: secilenResimBytes)); else { varOlanHastalik.ad = finalAd; varOlanHastalik.doktorNotu = notController.text; varOlanHastalik.resimBytes = secilenResimBytes; varOlanHastalik.save(); } Navigator.pop(context); } }, icon: const Icon(Icons.save), label: Text(varOlanHastalik == null ? metin('kaydet') : metin('guncelle')), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), backgroundColor: Colors.teal, foregroundColor: Colors.white))),
                  const SizedBox(height: 20),
                ],
              ),
            );
          });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaYoneticisi,
      builder: (context, tema, _) {
        return ValueListenableBuilder<String>(
          valueListenable: dilYoneticisi,
          builder: (context, dil, _) {
            return Scaffold(
              body: ValueListenableBuilder(
                valueListenable: _hastalikKutusu.listenable(),
                builder: (context, Box<Hastalik> box, _) {
                  if (box.values.isEmpty) return Center(child: Text(metin('hastalik_yok'), textAlign: TextAlign.center));
                  var hastaliklar = box.values.toList()..sort((a, b) => b.teshisTarihi.compareTo(a.teshisTarihi));
                  
                  return Column(
                    children: [
                      // SESLİ OKU BUTONU
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _sesliOku(hastaliklar),
                            icon: Icon(sesliOkunuyor ? Icons.stop_circle : Icons.record_voice_over, size: 28),
                            label: Text(sesliOkunuyor ? metin('okunuyor') : metin('sesli_oku_hastalik'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: sesliOkunuyor ? Colors.red.shade400 : (tema == ThemeMode.dark ? const Color(0xFF80CBC4) : const Color(0xFF00796B)),
                              foregroundColor: sesliOkunuyor ? Colors.white : (tema == ThemeMode.dark ? Colors.black : Colors.white),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: hastaliklar.length,
                          itemBuilder: (context, index) {
                            Hastalik hastalik = hastaliklar[index];
                            return Card(
                              elevation: 2, margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: ListTile(
                                leading: hastalik.resimBytes != null ? ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.memory(hastalik.resimBytes!, width: 50, height: 50, fit: BoxFit.cover)) : const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.medical_information, color: Colors.white)),
                                title: Text(evrenselCeviri(hastalik.ad), style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${metin('tarih')}: ${hastalik.teshisTarihi.day}/${hastalik.teshisTarihi.month}/${hastalik.teshisTarihi.year}\n${metin('not')}: ${hastalik.doktorNotu}'),
                                isThreeLine: true,
                                trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _kayitPenceresiAc(varOlanHastalik: hastalik)), IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => hastalik.delete())]),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              floatingActionButton: FloatingActionButton(onPressed: () => _kayitPenceresiAc(), backgroundColor: Colors.teal, foregroundColor: Colors.white, child: const Icon(Icons.add)),
            );
          }
        );
      }
    );
  }
}