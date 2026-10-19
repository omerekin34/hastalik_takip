import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/ilac_model.dart';
import '../services/dil_servisi.dart'; 
import '../services/ses_servisi.dart'; // SES MOTORU
import '../services/bildirim_servisi.dart'; // BİLDİRİM (ALARM) MOTORU EKLENDİ
import '../main.dart'; 

class IlaclarSayfasi extends StatefulWidget {
  const IlaclarSayfasi({super.key});
  @override
  State<IlaclarSayfasi> createState() => _IlaclarSayfasiState();
}

class _IlaclarSayfasiState extends State<IlaclarSayfasi> {
  final Box<Ilac> _ilacKutusu = Hive.box<Ilac>('ilaclar');
  bool sesliOkunuyor = false;

  // SESLİ OKUMA TETİKLEYİCİSİ
  void _sesliOku(List<Ilac> ilaclar) async {
    if (sesliOkunuyor) {
      await SesServisi.durdur();
      setState(() => sesliOkunuyor = false);
      return;
    }

    setState(() => sesliOkunuyor = true);
    
    String okunacakMetin = metin('ilac_giris'); 
    
    for (var ilac in ilaclar) {
      String cevrilmisDoz = evrenselCeviri(ilac.doz);
      String cevrilmisSiklik = evrenselCeviri(ilac.kullanimSikligi);
      
      okunacakMetin += "${ilac.ad}, $cevrilmisDoz, $cevrilmisSiklik. ";
    }

    await SesServisi.konus(okunacakMetin, dilYoneticisi.value);
    
    Future.delayed(Duration(seconds: ilaclar.length * 4), () {
      if (mounted) setState(() => sesliOkunuyor = false);
    });
  }

  void _ilacFormuAc({Ilac? varOlanIlac}) {
    final ilacListesi = ilacListesiDinamik; final dozajListesi = dozajListesiDinamik; final siklikListesi = siklikListesiDinamik; final digerSecenek = metin('diger');
    String secilenIlac = ilacListesi.first; bool ilacDiger = false; final adController = TextEditingController();
    String secilenDozaj = dozajListesi.first; bool dozajDiger = false; final dozController = TextEditingController();
    String secilenSiklik = siklikListesi.first; bool siklikDiger = false; final siklikController = TextEditingController();
    
    if (varOlanIlac != null) {
      if (ilacListesi.contains(varOlanIlac.ad)) secilenIlac = varOlanIlac.ad; else { secilenIlac = digerSecenek; ilacDiger = true; adController.text = varOlanIlac.ad; }
      String cevrilmisDoz = evrenselCeviri(varOlanIlac.doz);
      if (dozajListesi.contains(cevrilmisDoz)) secilenDozaj = cevrilmisDoz; else { secilenDozaj = digerSecenek; dozajDiger = true; dozController.text = varOlanIlac.doz; }
      String cevrilmisSiklik = evrenselCeviri(varOlanIlac.kullanimSikligi);
      if (siklikListesi.contains(cevrilmisSiklik)) secilenSiklik = cevrilmisSiklik; else { secilenSiklik = digerSecenek; siklikDiger = true; siklikController.text = varOlanIlac.kullanimSikligi; }
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
                      Expanded(child: Text(varOlanIlac == null ? metin('yeni_ilac') : metin('ilac_duzenle'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                      IconButton(icon: const Icon(Icons.close), color: temaYoneticisi.value == ThemeMode.dark ? Colors.grey.shade400 : Colors.grey.shade700, onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: secilenIlac, decoration: InputDecoration(labelText: metin('ilac_sec'), border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.medication)),
                    items: [...ilacListesi, digerSecenek].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setModalState(() { secilenIlac = val!; ilacDiger = val == digerSecenek; }),
                  ),
                  if (ilacDiger) ...[const SizedBox(height: 10), TextField(controller: adController, decoration: InputDecoration(labelText: metin('ilac_adi_yaz'), border: const OutlineInputBorder()))],
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: secilenDozaj, decoration: InputDecoration(labelText: metin('dozaj_sec'), border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.local_pharmacy)),
                    items: [...dozajListesi, digerSecenek].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setModalState(() { secilenDozaj = val!; dozajDiger = val == digerSecenek; }),
                  ),
                  if (dozajDiger) ...[const SizedBox(height: 10), TextField(controller: dozController, decoration: InputDecoration(labelText: metin('dozaj_yaz'), border: const OutlineInputBorder()))],
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: secilenSiklik, decoration: InputDecoration(labelText: metin('siklik_sec'), border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.access_time)),
                    items: [...siklikListesi, digerSecenek].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setModalState(() { secilenSiklik = val!; siklikDiger = val == digerSecenek; }),
                  ),
                  if (siklikDiger) ...[const SizedBox(height: 10), TextField(controller: siklikController, decoration: InputDecoration(labelText: metin('siklik_yaz'), border: const OutlineInputBorder()))],
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async { // BİLDİRİM KURMAK İÇİN ASYNC YAPILDI
                        final finalAd = ilacDiger ? adController.text : secilenIlac;
                        final finalDoz = dozajDiger ? dozController.text : secilenDozaj;
                        final finalSiklik = siklikDiger ? siklikController.text : secilenSiklik;
                        
                        if (finalAd.isNotEmpty) {
                          if (varOlanIlac == null) {
                            int yeniId = await _ilacKutusu.add(Ilac(ad: finalAd, doz: finalDoz, kullanimSikligi: finalSiklik));
                            await BildirimServisi.ilacHatirlaticiKur(yeniId, finalAd, finalDoz, finalSiklik); // ALARM KURULDU
                          } else { 
                            varOlanIlac.ad = finalAd; varOlanIlac.doz = finalDoz; varOlanIlac.kullanimSikligi = finalSiklik; varOlanIlac.save(); 
                            await BildirimServisi.ilacHatirlaticiKur(varOlanIlac.key, finalAd, finalDoz, finalSiklik); // ALARM GÜNCELLENDİ
                          }
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.save), label: Text(varOlanIlac == null ? metin('kaydet') : metin('guncelle')),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), backgroundColor: Colors.teal, foregroundColor: Colors.white),
                    ),
                  ),
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
                valueListenable: _ilacKutusu.listenable(),
                builder: (context, Box<Ilac> box, _) {
                  if (box.values.isEmpty) return Center(child: Text(metin('ilac_yok'), textAlign: TextAlign.center));
                  
                  var ilaclarListesi = box.values.toList();
                  
                  return Column(
                    children: [
                      // --- ERİŞİLEBİLİRLİK: SESLİ OKUMA BUTONU ---
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _sesliOku(ilaclarListesi),
                            icon: Icon(sesliOkunuyor ? Icons.stop_circle : Icons.record_voice_over, size: 28),
                            label: Text(sesliOkunuyor ? metin('okunuyor') : metin('sesli_oku'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: sesliOkunuyor ? Colors.red.shade400 : (tema == ThemeMode.dark ? const Color(0xFF80CBC4) : const Color(0xFF00796B)),
                              foregroundColor: sesliOkunuyor ? Colors.white : (tema == ThemeMode.dark ? Colors.black : Colors.white),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ),
                      
                      // İLAÇ LİSTESİ
                      Expanded(
                        child: ListView.builder(
                          itemCount: ilaclarListesi.length,
                          itemBuilder: (context, index) {
                            Ilac ilac = ilaclarListesi[index];
                            return Card(
                              elevation: 2, margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: ListTile(
                                leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.medication_liquid, color: Colors.white)),
                                title: Text(ilac.ad, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${metin('dozaj')}: ${evrenselCeviri(ilac.doz)}\n${metin('siklik')}: ${evrenselCeviri(ilac.kullanimSikligi)}'),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _ilacFormuAc(varOlanIlac: ilac)),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red), 
                                      onPressed: () {
                                        BildirimServisi.bildirimiIptalEt(ilac.key); // İLAÇ SİLİNİNCE ALARM DA İPTAL OLUR
                                        ilac.delete();
                                      }
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              floatingActionButton: FloatingActionButton(onPressed: () => _ilacFormuAc(), backgroundColor: Colors.teal, foregroundColor: Colors.white, child: const Icon(Icons.add)),
            );
          }
        );
      }
    );
  }
}