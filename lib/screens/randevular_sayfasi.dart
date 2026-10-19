import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart'; 
import '../models/randevu_model.dart';
import '../services/bildirim_servisi.dart';
import '../services/dil_servisi.dart';
import '../services/ses_servisi.dart'; // SES MOTORU
import '../main.dart'; 

class RandevularSayfasi extends StatefulWidget {
  const RandevularSayfasi({super.key});
  @override
  State<RandevularSayfasi> createState() => _RandevularSayfasiState();
}

class _RandevularSayfasiState extends State<RandevularSayfasi> {
  final Box<Randevu> _randevuKutusu = Hive.box<Randevu>('randevular');
  Map<String, Map<String, List<String>>> hastaneRehberi = {};
  bool jsonYukleniyor = true;
  bool sesliOkunuyor = false;

  void _sesliOku(List<Randevu> randevular) async {
    if (sesliOkunuyor) { await SesServisi.durdur(); setState(() => sesliOkunuyor = false); return; }
    setState(() => sesliOkunuyor = true);
    
    String okunacakMetin = metin('randevu_giris');
    for (var randevu in randevular) {
      // Sadece Doktor adı ve Bölüm/Hastane okunsun
      okunacakMetin += "${randevu.doktorAd}, ${randevuMekanCeviri(randevu.hastaneAd)}. ";
    }

    await SesServisi.konus(okunacakMetin, dilYoneticisi.value);
    Future.delayed(Duration(seconds: randevular.length * 3 + 2), () {
      if (mounted) setState(() => sesliOkunuyor = false);
    });
  }

  @override
  void initState() { super.initState(); _jsonVerisiniYukle(); }

  Future<void> _jsonVerisiniYukle() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/veri/hastaneler.json');
      final decodedVeri = json.decode(jsonString);
      Map<String, Map<String, List<String>>> islenmisRehber = {};
      if (decodedVeri is List) {
        for (var item in decodedVeri) {
          String il = item['city']?.toString().trim() ?? 'Bilinmeyen İl'; String ilce = item['district']?.toString().trim() ?? 'Bilinmeyen İlçe'; String hastaneAd = item['name']?.toString().trim() ?? 'Bilinmeyen Hastane';
          if (!islenmisRehber.containsKey(il)) islenmisRehber[il] = {}; if (!islenmisRehber[il]!.containsKey(ilce)) islenmisRehber[il]![ilce] = []; if (!islenmisRehber[il]![ilce]!.contains(hastaneAd)) islenmisRehber[il]![ilce]!.add(hastaneAd);
        }
      } else if (decodedVeri is Map) {
        decodedVeri.forEach((ilAdi, ilceMap) { islenmisRehber[ilAdi] = {}; (ilceMap as Map).forEach((ilceAdi, hastaneListesi) { islenmisRehber[ilAdi]![ilceAdi] = List<String>.from(hastaneListesi); }); });
      }
      var siraliIlRehberi = Map.fromEntries(islenmisRehber.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
      for (var il in siraliIlRehberi.keys) {
        var siraliIlceler = Map.fromEntries(siraliIlRehberi[il]!.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
        for (var ilce in siraliIlceler.keys) siraliIlceler[ilce]!.sort((a, b) => a.compareTo(b));
        siraliIlRehberi[il] = siraliIlceler;
      }
      setState(() { hastaneRehberi = siraliIlRehberi; jsonYukleniyor = false; });
    } catch (e) { setState(() { jsonYukleniyor = false; }); }
  }

  void _randevuFormuAc({Randevu? varOlanRandevu}) {
    final doktorController = TextEditingController(text: varOlanRandevu?.doktorAd ?? '');
    String? secilenIl; String? secilenIlce; String? secilenHastane; bool mekanDiger = false;
    final manuelHastaneController = TextEditingController();
    final bolumListesi = bolumListesiDinamik; String secilenBolum = bolumListesi.first; bool bolumDiger = false;
    final bolumController = TextEditingController(); DateTime secilenTarih = varOlanRandevu?.randevuTarihi ?? DateTime.now(); final digerSecenek = metin('diger');

    if (varOlanRandevu != null) {
      String dbHastane = varOlanRandevu.hastaneAd;
      if (dbHastane.contains(' - ')) {
        int splitIndex = dbHastane.lastIndexOf(' - '); String kayitliMekan = dbHastane.substring(0, splitIndex); String kayitliBolum = dbHastane.substring(splitIndex + 3);
        String cevrilmisBolum = evrenselCeviri(kayitliBolum);
        mekanDiger = true; manuelHastaneController.text = kayitliMekan;
        if (bolumListesi.contains(cevrilmisBolum)) secilenBolum = cevrilmisBolum; else { secilenBolum = digerSecenek; bolumDiger = true; bolumController.text = kayitliBolum; }
      }
    }

    showModalBottomSheet(
      context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
            if (jsonYukleniyor) return const Padding(padding: EdgeInsets.all(40.0), child: Center(child: CircularProgressIndicator(color: Colors.teal)));
            List<String> guncelIlceler = secilenIl != null && hastaneRehberi.containsKey(secilenIl) ? hastaneRehberi[secilenIl]!.keys.toList() : []; List<String> guncelHastaneler = secilenIl != null && secilenIlce != null && hastaneRehberi[secilenIl]!.containsKey(secilenIlce) ? hastaneRehberi[secilenIl]![secilenIlce]! : [];
            
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(varOlanRandevu == null ? metin('yeni_randevu') : metin('randevu_duzenle'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))), IconButton(icon: const Icon(Icons.close), color: temaYoneticisi.value == ThemeMode.dark ? Colors.grey.shade400 : Colors.grey.shade700, onPressed: () => Navigator.pop(context))]),
                    const SizedBox(height: 15), TextField(controller: doktorController, decoration: InputDecoration(labelText: metin('doktor_adi'), border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.person))), const SizedBox(height: 10),
                    DropdownButtonFormField<String>(value: secilenIl, hint: Text(metin('il_sec')), decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: const Icon(Icons.map)), items: [...hastaneRehberi.keys, digerSecenek].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (val) { setModalState(() { secilenIl = val; secilenIlce = null; secilenHastane = null; mekanDiger = val == digerSecenek; }); }), const SizedBox(height: 10),
                    if (secilenIl != null && !mekanDiger) ...[DropdownButtonFormField<String>(value: secilenIlce, hint: Text(metin('ilce_sec')), decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: const Icon(Icons.location_city)), items: [...guncelIlceler, digerSecenek].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (val) { setModalState(() { secilenIlce = val; secilenHastane = null; mekanDiger = val == digerSecenek; }); }), const SizedBox(height: 10)],
                    if (secilenIlce != null && !mekanDiger) ...[DropdownButtonFormField<String>(value: secilenHastane, isExpanded: true, hint: Text(metin('hastane_sec')), decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: const Icon(Icons.local_hospital_outlined)), items: [...guncelHastaneler, digerSecenek].map((e) => DropdownMenuItem(value: e, child: Text(e == digerSecenek ? e : randevuMekanCeviri(e), overflow: TextOverflow.ellipsis))).toList(), onChanged: (val) { setModalState(() { secilenHastane = val; mekanDiger = val == digerSecenek; }); }), const SizedBox(height: 10)],
                    if (mekanDiger) ...[TextField(controller: manuelHastaneController, decoration: InputDecoration(labelText: metin('hastane_yaz'), border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.domain))), const SizedBox(height: 10)],
                    DropdownButtonFormField<String>(value: secilenBolum, decoration: InputDecoration(labelText: metin('bolum_sec'), border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.category)), items: [...bolumListesi, digerSecenek].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (val) => setModalState(() { secilenBolum = val!; bolumDiger = val == digerSecenek; })),
                    if (bolumDiger) ...[const SizedBox(height: 10), TextField(controller: bolumController, decoration: InputDecoration(labelText: metin('bolum_yaz'), border: const OutlineInputBorder()))],
                    const SizedBox(height: 15),
                    ListTile(shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey, width: 1), borderRadius: BorderRadius.circular(4)), leading: const Icon(Icons.calendar_month, color: Colors.teal), title: Text(metin('tarih_saat')), subtitle: Text(DateFormat('dd/MM/yyyy - HH:mm').format(secilenTarih)), onTap: () async { DateTime? tarih = await showDatePicker(context: context, initialDate: secilenTarih, firstDate: DateTime.now(), lastDate: DateTime(2030)); if (tarih != null) { TimeOfDay? saat = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(secilenTarih)); if (saat != null) setModalState(() => secilenTarih = DateTime(tarih.year, tarih.month, tarih.day, saat.hour, saat.minute)); } }),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          String finalMekan = mekanDiger ? manuelHastaneController.text : (secilenHastane != null && secilenHastane != digerSecenek ? secilenHastane! : '');
                          final finalBolum = bolumDiger ? bolumController.text : secilenBolum;
                          final tamMekan = finalMekan.isNotEmpty ? '$finalMekan - $finalBolum' : finalBolum;
                          
                          if (doktorController.text.isNotEmpty && finalBolum.isNotEmpty) {
                            if (varOlanRandevu == null) {
                              int yeniId = await _randevuKutusu.add(Randevu(doktorAd: doktorController.text, hastaneAd: tamMekan, randevuTarihi: secilenTarih));
                              await BildirimServisi.randevuHatirlaticiKur(yeniId, doktorController.text, tamMekan, secilenTarih); // YENİ ALARM KURULDU
                              BildirimServisi.anlikBildirimGoster(baslik: metin('yeni_randevu'), icerik: '${doktorController.text} - Kaydedildi');
                            } else {
                              varOlanRandevu.doktorAd = doktorController.text;
                              varOlanRandevu.hastaneAd = tamMekan;
                              varOlanRandevu.randevuTarihi = secilenTarih;
                              varOlanRandevu.save();
                              await BildirimServisi.randevuHatirlaticiKur(varOlanRandevu.key, doktorController.text, tamMekan, secilenTarih); // ALARM GÜNCELLENDİ
                            }
                            Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: Text(varOlanRandevu == null ? metin('kaydet') : metin('guncelle')),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), backgroundColor: Colors.teal, foregroundColor: Colors.white)
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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaYoneticisi,
      builder: (context, tema, _) {
        return ValueListenableBuilder<String>(
          valueListenable: dilYoneticisi,
          builder: (context, dil, _) {
            return Scaffold(
              body: ValueListenableBuilder(
                valueListenable: _randevuKutusu.listenable(),
                builder: (context, Box<Randevu> box, _) {
                  if (box.values.isEmpty) return Center(child: Text(metin('randevu_bos'), textAlign: TextAlign.center));
                  var randevular = box.values.toList()..sort((a, b) => a.randevuTarihi.compareTo(b.randevuTarihi));
                  
                  return Column(
                    children: [
                      // SESLİ OKU BUTONU
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _sesliOku(randevular),
                            icon: Icon(sesliOkunuyor ? Icons.stop_circle : Icons.record_voice_over, size: 28),
                            label: Text(sesliOkunuyor ? metin('okunuyor') : metin('sesli_oku_randevu'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                          itemCount: randevular.length,
                          itemBuilder: (context, index) {
                            Randevu randevu = randevular[index];
                            return Card(
                              elevation: 2, margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: ListTile(
                                leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.event, color: Colors.white)),
                                title: Text(randevu.doktorAd, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${randevuMekanCeviri(randevu.hastaneAd)}\n${metin('tarih_saat').split(' ').first}: ${DateFormat('dd/MM/yyyy - HH:mm').format(randevu.randevuTarihi)}'),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _randevuFormuAc(varOlanRandevu: randevu)),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () {
                                        BildirimServisi.bildirimiIptalEt(randevu.key); // SİLİNİNCE ALARMI DA İPTAL EDİYORUZ
                                        randevu.delete();
                                      }
                                    )
                                  ]
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
              floatingActionButton: FloatingActionButton(onPressed: () => _randevuFormuAc(), backgroundColor: Colors.teal, foregroundColor: Colors.white, child: const Icon(Icons.add)),
            );
          }
        );
      }
    );
  }
}