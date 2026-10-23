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

  // Formu dinamik hale getirdik: Yeni kayıt için boş, düzenleme için dolu açılır
  void _kayitFormuAc({Hastalik? varOlanHastalik}) {
    final adController = TextEditingController(text: varOlanHastalik?.ad ?? '');
    final poliklinikController = TextEditingController(text: varOlanHastalik?.poliklinik ?? '');
    final doktorController = TextEditingController(text: varOlanHastalik?.doktor ?? '');
    final hastaneController = TextEditingController(text: varOlanHastalik?.hastane ?? '');
    final notlarController = TextEditingController(text: varOlanHastalik?.notlar ?? '');
    final ilaclarController = TextEditingController(text: varOlanHastalik?.ilaclar.join(', ') ?? '');
    String seciliDurum = varOlanHastalik?.durum ?? 'Aktif Tedavi';

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
                      Text(varOlanHastalik == null ? 'Yeni Hastalık / Ziyaret' : 'Hastalığı Düzenle', style: TextStyle(color: textLight, fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(icon: Icon(Icons.close, color: textMuted), onPressed: () => Navigator.pop(context))
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(adController, 'Hastalık / Teşhis Adı', Icons.medical_services),
                  _buildTextField(poliklinikController, 'Poliklinik (Örn: Üroloji)', Icons.domain),
                  DropdownButtonFormField<String>(
                    value: seciliDurum,
                    dropdownColor: bgColor,
                    style: TextStyle(color: textLight),
                    decoration: InputDecoration(filled: true, fillColor: bgColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
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
                        if (adController.text.isNotEmpty) {
                          if (varOlanHastalik == null) {
                            // YENİ KAYIT
                            final yeniKayit = Hastalik(
                              ad: adController.text,
                              poliklinik: poliklinikController.text.isEmpty ? 'Genel' : poliklinikController.text,
                              durum: seciliDurum,
                              doktor: doktorController.text,
                              hastane: hastaneController.text,
                              tarih: DateTime.now(),
                              notlar: notlarController.text,
                              ilaclar: ilaclarController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                            );
                            _hastalikKutusu.add(yeniKayit);
                          } else {
                            // GÜNCELLEME
                            varOlanHastalik.ad = adController.text;
                            varOlanHastalik.poliklinik = poliklinikController.text.isEmpty ? 'Genel' : poliklinikController.text;
                            varOlanHastalik.durum = seciliDurum;
                            varOlanHastalik.doktor = doktorController.text;
                            varOlanHastalik.hastane = hastaneController.text;
                            varOlanHastalik.notlar = notlarController.text;
                            varOlanHastalik.ilaclar = ilaclarController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                            varOlanHastalik.save(); // Değişiklikleri veritabanına yaz
                          }
                          Navigator.pop(context);
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hastalık & Ziyaret\nGeçmişi', style: TextStyle(color: textLight, fontSize: 24, fontWeight: FontWeight.bold, height: 1.2)),
                          const SizedBox(height: 6),
                          Text('Klinik kayıtlarınız, hekim notları', style: TextStyle(color: textMuted, fontSize: 12)),
                        ],
                      ),
                      InkWell(
                        onTap: () => _kayitFormuAc(),
                        child: CircleAvatar(backgroundColor: primaryGreen, radius: 20, child: Icon(Icons.add, color: bgColor)),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _kayitFormuAc(),
                      style: OutlinedButton.styleFrom(side: BorderSide(color: primaryGreen.withOpacity(0.5)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14), backgroundColor: primaryGreen.withOpacity(0.05)),
                      icon: Icon(Icons.add_circle_outline, color: primaryGreen, size: 18),
                      label: Text('Yeni Ziyaret / Hastalık Ekle', style: TextStyle(color: primaryGreen, fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
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
              // DÜZENLE VE SİL BUTONLARI BURADA YAN YANA
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