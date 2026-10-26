import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/hastalik_model.dart';

class HastaliklarSayfasi extends StatefulWidget {
  const HastaliklarSayfasi({Key? key}) : super(key: key);

  @override
  State<HastaliklarSayfasi> createState() => _HastaliklarSayfasiState();
}

class _HastaliklarSayfasiState extends State<HastaliklarSayfasi> {
  final Box<Hastalik> _hastalikKutusu = Hive.box<Hastalik>('hastaliklar');
  String _seciliFiltre = 'Tümü';

  final Color bgColor = const Color(0xFF0B131E);
  final Color cardColor = const Color(0xFF161F2C);
  final Color primaryGreen = const Color(0xFF00C48C);
  final Color primaryBlue = const Color(0xFF00A3FF);
  final Color primaryOrange = const Color(0xFFFF9900);
  final Color textLight = const Color(0xFFFFFFFF);
  final Color textMuted = const Color(0xFF8B98A5);

  // En bilindik 10 poliklinik / branş listesi
  final List<String> _populerBolumler = [
    'Dahiliye (İç Hastalıkları)',
    'Kardiyoloji',
    'Nöroloji',
    'Ortopedi ve Travmatoloji',
    'Göz Hastalıkları',
    'Kulak Burun Boğaz (KBB)',
    'Cildiye (Dermatoloji)',
    'Üroloji',
    'Kadın Hastalıkları ve Doğum',
    'Çocuk Sağlığı ve Hastalıkları',
    'Diğer / Manuel Yaz'
  ];

  // Sık Karşılaşılan Teşhisler / Hastalık Önerileri
  final List<String> _populerTeshisler = [
    'Hipertansiyon (Yüksek Tansiyon)',
    'Tip 2 Diyabet (Şeker Hastalığı)',
    'Astım / KOAH',
    'Migren / Kronik Baş Ağrısı',
    'Bel / Boyun Fıtığı',
    'Mide Gastriti / Reflü',
    'Tiroid (Guatr)',
    'Romatizma / Eklem Ağrısı',
    'Kolesterol Yüksekliği',
    'Diğer / Manuel Yaz'
  ];

  void _kayitFormuAc({Hastalik? varOlanHastalik}) {
    final doktorController = TextEditingController(text: varOlanHastalik?.doktor ?? '');
    final hastaneController = TextEditingController(text: varOlanHastalik?.hastane ?? '');
    final notlarController = TextEditingController(text: varOlanHastalik?.notlar ?? '');
    final ilaclarController = TextEditingController(text: varOlanHastalik?.ilaclar.join(', ') ?? '');
    
    final manuelAdController = TextEditingController();
    final manuelPoliklinikController = TextEditingController();

    String? seciliAd = varOlanHastalik?.ad;
    bool manuelAdModu = false;

    String? seciliPoliklinik = varOlanHastalik?.poliklinik;
    bool manuelPoliklinikModu = false;

    String seciliDurum = varOlanHastalik?.durum ?? 'Aktif Tedavi';

    // Hastalık adı eşleşme kontrolü
    if (seciliAd != null && seciliAd.isNotEmpty) {
      if (!_populerTeshisler.contains(seciliAd)) {
        seciliAd = 'Diğer / Manuel Yaz';
        manuelAdModu = true;
        manuelAdController.text = varOlanHastalik?.ad ?? '';
      }
    }

    // Poliklinik eşleşme kontrolü
    if (seciliPoliklinik != null && seciliPoliklinik.isNotEmpty) {
      if (!_populerBolumler.contains(seciliPoliklinik)) {
        seciliPoliklinik = 'Diğer / Manuel Yaz';
        manuelPoliklinikModu = true;
        manuelPoliklinikController.text = varOlanHastalik?.poliklinik ?? '';
      }
    }

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(varOlanHastalik == null ? 'Yeni Hastalık / Ziyaret' : 'Hastalığı Düzenle', style: TextStyle(color: textLight, fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(icon: Icon(Icons.close, color: textMuted), onPressed: () => Navigator.pop(context))
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // HASTALIK / TEŞHİS SEÇİMİ (Açılır Menü + Manuel)
                  DropdownButtonFormField<String>(
                    value: seciliAd,
                    dropdownColor: cardColor,
                    style: TextStyle(color: textLight),
                    decoration: InputDecoration(
                      labelText: 'Hastalık / Teşhis Seçin',
                      labelStyle: TextStyle(color: textMuted),
                      prefixIcon: Icon(Icons.medical_services, color: primaryGreen),
                      filled: true,
                      fillColor: bgColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
                    ),
                    items: _populerTeshisler.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) {
                      setModalState(() {
                        seciliAd = val;
                        if (val == 'Diğer / Manuel Yaz') {
                          manuelAdModu = true;
                        } else {
                          manuelAdModu = false;
                        }
                      });
                    },
                  ),

                  if (manuelAdModu) ...[
                    const SizedBox(height: 10),
                    _buildTextField(manuelAdController, 'Teşhis Adını Kendiniz Yazın', Icons.edit),
                  ],
                  const SizedBox(height: 12),

                  // POLİKLİNİK SEÇİMİ (Açılır Menü + Manuel)
                  DropdownButtonFormField<String>(
                    value: seciliPoliklinik,
                    dropdownColor: cardColor,
                    style: TextStyle(color: textLight),
                    decoration: InputDecoration(
                      labelText: 'Poliklinik / Bölüm Seçin',
                      labelStyle: TextStyle(color: textMuted),
                      prefixIcon: Icon(Icons.domain, color: primaryBlue),
                      filled: true,
                      fillColor: bgColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
                    ),
                    items: _populerBolumler.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                    onChanged: (val) {
                      setModalState(() {
                        seciliPoliklinik = val;
                        if (val == 'Diğer / Manuel Yaz') {
                          manuelPoliklinikModu = true;
                        } else {
                          manuelPoliklinikModu = false;
                        }
                      });
                    },
                  ),

                  if (manuelPoliklinikModu) ...[
                    const SizedBox(height: 10),
                    _buildTextField(manuelPoliklinikController, 'Poliklinik Adını Kendiniz Yazın', Icons.edit),
                  ],
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: seciliDurum,
                    dropdownColor: cardColor,
                    style: TextStyle(color: textLight),
                    decoration: InputDecoration(
                      labelText: 'Tedavi Durumu',
                      labelStyle: TextStyle(color: textMuted),
                      prefixIcon: Icon(Icons.info, color: primaryOrange),
                      filled: true, 
                      fillColor: bgColor, 
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
                    ),
                    items: ['Aktif Tedavi', 'Kronik', 'Geçmiş / İyileşti'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setModalState(() => seciliDurum = val!),
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(doktorController, 'Doktor Adı', Icons.person),
                  _buildTextField(hastaneController, 'Hastane', Icons.local_hospital),
                  _buildTextField(notlarController, 'Doktor Notu / Açıklama', Icons.edit_note, maxLines: 3),
                  _buildTextField(ilaclarController, 'İlaçlar (Virgülle ayırın)', Icons.medication),
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        String finalAd = manuelAdModu ? manuelAdController.text : (seciliAd ?? 'Genel Teşhis');
                        String finalPoliklinik = manuelPoliklinikModu ? manuelPoliklinikController.text : (seciliPoliklinik ?? 'Genel');

                        if (finalAd.isNotEmpty) {
                          if (varOlanHastalik == null) {
                            final yeniKayit = Hastalik(
                              ad: finalAd,
                              poliklinik: finalPoliklinik.isEmpty ? 'Genel' : finalPoliklinik,
                              durum: seciliDurum,
                              doktor: doktorController.text,
                              hastane: hastaneController.text,
                              tarih: DateTime.now(),
                              notlar: notlarController.text,
                              ilaclar: ilaclarController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                            );
                            _hastalikKutusu.add(yeniKayit);
                          } else {
                            varOlanHastalik.ad = finalAd;
                            varOlanHastalik.poliklinik = finalPoliklinik.isEmpty ? 'Genel' : finalPoliklinik;
                            varOlanHastalik.durum = seciliDurum;
                            varOlanHastalik.doktor = doktorController.text;
                            varOlanHastalik.hastane = hastaneController.text;
                            varOlanHastalik.notlar = notlarController.text;
                            varOlanHastalik.ilaclar = ilaclarController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                            varOlanHastalik.save();
                          }
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Lütfen hastalık veya teşhis adını boş bırakmayın!')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: Text(varOlanHastalik == null ? 'Kaydet' : 'Güncelle', style: const TextStyle(color: Color(0xFF0B131E), fontWeight: FontWeight.bold)),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: TextStyle(color: textLight),
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: textMuted),
          prefixIcon: Icon(icon, color: textMuted),
          filled: true,
          fillColor: bgColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  @override
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. YENİ DÜZENLENEN ÜST KISIM (Geri Butonu, Başlık ve Hastalık Ekle Butonu) ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new, color: textLight, size: 20),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hastalık & Ziyaret\nGeçmişi', style: TextStyle(color: textLight, fontSize: 20, fontWeight: FontWeight.bold, height: 1.2)),
                            const SizedBox(height: 4),
                            Text('Klinik kayıtlarınız, hekim notları', style: TextStyle(color: textMuted, fontSize: 11)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _kayitFormuAc(), // Senin orjinal fonksiyonun
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen.withOpacity(0.2), 
                          foregroundColor: primaryGreen, 
                          elevation: 0, 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), 
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                        ),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Hastalık Ekle', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  // --------------------------------------------------------------------------------
                  
                  const SizedBox(height: 16),
                  
                  // --- 2. FİLTRE BUTONLARI (Aynen korundu) ---
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Tümü'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Aktif Tedavi'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Kronik'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Geçmiş / İyileşti'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // --- 3. DİNAMİK LİSTE KISMI ---
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _hastalikKutusu.listenable(),
                builder: (context, Box<Hastalik> box, _) {
                  var liste = box.values.toList();
                  if (_seciliFiltre != 'Tümü') {
                    liste = liste.where((h) => h.durum == _seciliFiltre).toList();
                  }
                  
                  if (liste.isEmpty) {
                    return Center(child: Text('Henüz kayıt bulunmuyor.', style: TextStyle(color: textMuted)));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: liste.length,
                    itemBuilder: (context, index) {
                      final hastalik = liste[index];
                      return _buildDynamicCard(hastalik);
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _seciliFiltre == label;
    return InkWell(
      onTap: () => setState(() => _seciliFiltre = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryGreen.withOpacity(0.2) : cardColor,
          border: Border.all(color: isSelected ? primaryGreen : textMuted.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? primaryGreen : textMuted, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  Widget _buildDynamicCard(Hastalik hastalik) {
    Color durumRengi = primaryGreen;
    if (hastalik.durum == 'Aktif Tedavi') durumRengi = primaryOrange;
    if (hastalik.durum == 'Kronik') durumRengi = primaryBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                  Text(hastalik.poliklinik, style: TextStyle(color: textMuted, fontSize: 12)),
                  const SizedBox(width: 8),
                  Container(width: 4, height: 4, decoration: BoxDecoration(color: durumRengi, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(hastalik.durum, style: TextStyle(color: durumRengi, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: textMuted, size: 20),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    onPressed: () => _kayitFormuAc(varOlanHastalik: hastalik),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    onPressed: () => hastalik.delete(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(hastalik.ad, style: TextStyle(color: textLight, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.medical_information_outlined, color: textMuted, size: 14),
              const SizedBox(width: 6),
              Expanded(child: Text('${hastalik.doktor} • ${hastalik.hastane}', style: TextStyle(color: textMuted, fontSize: 12), overflow: TextOverflow.ellipsis)),
            ],
          ),
          if (hastalik.notlar.isNotEmpty) ...[
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white10, height: 1)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.edit_document, color: durumRengi, size: 16),
                    const SizedBox(width: 6),
                    Text('Doktor Ziyaret Notu', style: TextStyle(color: durumRengi, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                Text(DateFormat('dd MMM yyyy').format(hastalik.tarih), style: TextStyle(color: textMuted, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 8),
            Text(hastalik.notlar, style: TextStyle(color: textLight, fontSize: 13, height: 1.4)),
          ],
          if (hastalik.ilaclar.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: hastalik.ilaclar.map((ilac) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: textMuted.withOpacity(0.2))),
                child: Text(ilac, style: TextStyle(color: textLight, fontSize: 11)),
              )).toList(),
            ),
          ]
        ],
      ),
    );
  }
}