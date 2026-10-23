import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/kullanici_model.dart';
import '../models/hastalik_model.dart';
import '../models/ilac_model.dart';
import '../models/randevu_model.dart';
import 'yapay_zeka_sayfasi.dart';
import 'kilit_ekrani.dart';
import 'profil_kayit_ekrani.dart';

class OzetEkrani extends StatefulWidget {
  const OzetEkrani({Key? key}) : super(key: key);

  @override
  State<OzetEkrani> createState() => _OzetEkraniState();
}

class _OzetEkraniState extends State<OzetEkrani> {
  final Color bgColor = const Color(0xFF0B131E);
  final Color cardColor = const Color(0xFF161F2C);
  final Color primaryGreen = const Color(0xFF00C48C);
  final Color primaryBlue = const Color(0xFF00A3FF);
  final Color primaryOrange = const Color(0xFFFF9900);
  final Color textLight = const Color(0xFFFFFFFF);
  final Color textMuted = const Color(0xFF8B98A5);

  @override
  Widget build(BuildContext context) {
    // Tüm veritabanlarını aynı anda dinleyerek özet ekranını anlık güncelliyoruz
    return AnimatedBuilder(
      animation: Listenable.merge([
        Hive.box<Kullanici>('kullanici_kutusu').listenable(),
        Hive.box<Hastalik>('hastaliklar').listenable(),
        Hive.box<Ilac>('ilaclar').listenable(),
        Hive.box<Randevu>('randevular').listenable(),
      ]),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildGreeting(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Sağlık Özetiniz', '3 Gösterge'),
                  const SizedBox(height: 12),
                  _buildHealthSummaryCards(),
                  const SizedBox(height: 24),
                  _buildUpcomingAppointment(),
                  const SizedBox(height: 24),
                  _buildDailyMedicinePlan(),
                  const SizedBox(height: 24),
                  _buildPolyclinicDistribution(),
                  const SizedBox(height: 24),
                  _buildAIAssistantCard(context),
                  const SizedBox(height: 20), // Alt menü boşluğu
                ],
              ),
            ),
          ),
        );
      },
    );
  }

Widget _buildHeader(BuildContext context) {
    // 1. Bildirim sayısını hesaplıyoruz
    int bildirimSayisi = _aktifBildirimSayisiHesapla();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.add, color: primaryGreen, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kişisel Sağlık Asistanım', style: TextStyle(color: textLight, fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: primaryGreen, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text('Cihazda Güvende • SQLite', style: TextStyle(color: primaryGreen, fontSize: 10)),
                  ],
                )
              ],
            )
          ],
        ),
        Row(
          children: [
            // AKILLI BİLDİRİM ZİLİ
            InkWell(
              onTap: () => _bildirimMenusuAc(context),
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.notifications_none, color: textMuted, size: 26),
                  if (bildirimSayisi > 0)
                    Positioned(
                      right: -2, top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                        child: Text('$bildirimSayisi', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    )
                ],
              ),
            ),
            const SizedBox(width: 16),
            InkWell(
              onTap: () => _profilAyarMenusu(context), 
              child: CircleAvatar(
                backgroundColor: primaryGreen.withOpacity(0.2),
                radius: 16,
                child: Icon(Icons.person, color: primaryGreen, size: 18),
              ),
            )
          ],
        )
      ],
    );
  }
 void _profilAyarMenusu(BuildContext context) {
    final box = Hive.box<Kullanici>('kullanici_kutusu');
    final kullanici = box.get('profil');

    if (kullanici == null) return;

    final adController = TextEditingController(text: kullanici.adSoyad);
    final pinController = TextEditingController(text: kullanici.pinKodu);
    String secilenCinsiyet = kullanici.cinsiyet;
    bool beniHatirla = kullanici.beniHatirla;

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
                      Text('Profil Ayarları', style: TextStyle(color: textLight, fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(icon: Icon(Icons.close, color: textMuted), onPressed: () => Navigator.pop(context))
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: adController,
                    style: TextStyle(color: textLight),
                    decoration: InputDecoration(labelText: 'Adınız Soyadınız', labelStyle: TextStyle(color: textMuted), prefixIcon: Icon(Icons.person, color: textMuted), filled: true, fillColor: bgColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: secilenCinsiyet,
                    dropdownColor: bgColor,
                    style: TextStyle(color: textLight),
                    decoration: InputDecoration(labelText: 'Hitap (Cinsiyet)', filled: true, fillColor: bgColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                    items: ['Erkek', 'Kadın'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setModalState(() => secilenCinsiyet = val!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: TextStyle(color: textLight),
                    decoration: InputDecoration(labelText: 'Güvenlik PIN Kodu', labelStyle: TextStyle(color: textMuted), prefixIcon: Icon(Icons.lock, color: textMuted), filled: true, fillColor: bgColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                  ),
                  SwitchListTile(
                    title: Text('Beni Hatırla (Oto Giriş)', style: TextStyle(color: textLight, fontSize: 14)),
                    activeColor: primaryGreen,
                    contentPadding: EdgeInsets.zero,
                    value: beniHatirla,
                    onChanged: (val) => setModalState(() => beniHatirla = val),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (adController.text.isNotEmpty && pinController.text.length >= 4) {
                          kullanici.adSoyad = adController.text.trim();
                          kullanici.cinsiyet = secilenCinsiyet;
                          kullanici.pinKodu = pinController.text;
                          kullanici.beniHatirla = beniHatirla;
                          kullanici.save(); // Veritabanını güncelledik
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil başarıyla güncellendi!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Güncelle', style: TextStyle(color: Color(0xFF0B131E), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        // 1. Önce menüyü aşağı indirip kapatıyoruz
                        Navigator.pop(context); 
                        
                        // 2. Veritabanındaki profili tamamen temizliyoruz (sıfırlıyoruz)
                        await box.clear(); 
                        
                        // 3. Bizi kesin olarak en baştaki Kayıt Ekranına fırlatıyor
                        if (context.mounted) {
                          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const ProfilKayitEkrani()), 
                            (route) => false,
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.redAccent.withOpacity(0.5)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      icon: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
                      label: const Text('Hesabı Sıfırla ve Çıkış Yap', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
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

  Widget _buildGreeting() {
    final kullaniciBox = Hive.box<Kullanici>('kullanici_kutusu');
    final kullanici = kullaniciBox.get('profil');
    String isim = kullanici?.adSoyad.split(' ').first ?? 'Misafir';
    String unvan = (kullanici?.cinsiyet == 'Kadın') ? 'Hanım' : 'Bey';
    
    String anlikSaat = DateFormat('HH:mm').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Giriş Yapıldı • Sağlık Profilim', style: TextStyle(color: textMuted, fontSize: 12)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Merhaba, $isim$unvan 👋', style: TextStyle(color: textLight, fontSize: 24, fontWeight: FontWeight.bold)),
            
            // ARTI BUTONU ARTIK TIKLANABİLİR VE HIZLI EKLE MENÜSÜNÜ AÇIYOR
            InkWell(
              onTap: () => _hizliEkleMenusuAc(context),
              borderRadius: BorderRadius.circular(20),
              child: CircleAvatar(backgroundColor: cardColor, radius: 20, child: Icon(Icons.add, color: primaryGreen)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: primaryGreen.withOpacity(0.3))),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, color: primaryGreen, size: 14),
              const SizedBox(width: 8),
              Text('Son yerel eşleme: Bugün, $anlikSaat • Cihaz İçi S...', style: TextStyle(color: primaryGreen, fontSize: 11)),
              const SizedBox(width: 8),
              Text('Aktif', style: TextStyle(color: primaryGreen, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSectionTitle(String title, String subtitle, {Color? badgeColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: textLight, fontSize: 16, fontWeight: FontWeight.bold)),
        if (badgeColor != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: badgeColor.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: Text(subtitle, style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.bold)),
          )
        else
          Text(subtitle, style: TextStyle(color: textMuted, fontSize: 12)),
      ],
    );
  }

  Widget _buildHealthSummaryCards() {
    final hastalikKutusu = Hive.box<Hastalik>('hastaliklar');
    final ilacKutusu = Hive.box<Ilac>('ilaclar');
    final randevuKutusu = Hive.box<Randevu>('randevular');
    
    int toplamHastalik = hastalikKutusu.length;
    int toplamIlac = ilacKutusu.length;
    
    final simdi = DateTime.now();
    var gelecekRandevular = randevuKutusu.values.where((r) => r.randevuTarihi.isAfter(simdi)).toList();
    gelecekRandevular.sort((a, b) => a.randevuTarihi.compareTo(b.randevuTarihi));
    int planliRandevuSayisi = gelecekRandevular.length;
    
    String hastalikIsimleri = hastalikKutusu.values.map((e) => e.ad).take(2).join(', ');
    if (hastalikIsimleri.isEmpty) hastalikIsimleri = 'Kayıt bulunmuyor';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                icon: Icons.medical_services_outlined,
                iconColor: primaryGreen,
                badgeText: 'Stabil',
                count: toplamHastalik.toString(),
                countSuffix: ' kayıt',
                title: 'Kayıtlı Hastalık',
                subtitle: hastalikIsimleri,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                icon: Icons.medication_outlined,
                iconColor: primaryBlue,
                badgeText: 'Günlük',
                count: toplamIlac.toString(),
                countSuffix: ' adet',
                title: 'Aktif İlaçlar',
                subtitle: 'Takipte',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (planliRandevuSayisi > 0)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: primaryOrange.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.calendar_today, color: primaryOrange, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$planliRandevuSayisi Planlı Randevu', style: TextStyle(color: textLight, fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('${gelecekRandevular.first.doktorAd} • ${gelecekRandevular.first.hastaneAd}', style: TextStyle(color: textMuted, fontSize: 12), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: textMuted),
              ],
            ),
          )
      ],
    );
  }

  Widget _buildInfoCard({required IconData icon, required Color iconColor, required String badgeText, required String count, required String countSuffix, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 24),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: iconColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)), child: Text(badgeText, style: TextStyle(color: iconColor, fontSize: 10, fontWeight: FontWeight.bold)))
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(count, style: TextStyle(color: textLight, fontSize: 24, fontWeight: FontWeight.bold)),
              Text(countSuffix, style: TextStyle(color: textMuted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: textLight, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(color: textMuted, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointment() {
    final randevuKutusu = Hive.box<Randevu>('randevular');
    final simdi = DateTime.now();
    var gelecekRandevular = randevuKutusu.values.where((r) => r.randevuTarihi.isAfter(simdi)).toList();
    
    if (gelecekRandevular.isEmpty) return const SizedBox.shrink();

    gelecekRandevular.sort((a, b) => a.randevuTarihi.compareTo(b.randevuTarihi));
    Randevu siradaki = gelecekRandevular.first;
    int kalanGun = siradaki.randevuTarihi.difference(simdi).inDays;

    return Column(
      children: [
        _buildSectionTitle('Yaklaşan Randevunuz', kalanGun == 0 ? 'Bugün' : '$kalanGun Gün Kaldı', badgeColor: primaryOrange),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(backgroundColor: primaryGreen.withOpacity(0.2), radius: 24, child: Icon(Icons.person, color: primaryGreen, size: 28)),
                      Positioned(bottom: 0, right: 0, child: Container(decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle), child: Icon(Icons.check_circle, color: primaryGreen, size: 16))),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(siradaki.doktorAd, style: TextStyle(color: textLight, fontSize: 15, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                            const SizedBox(width: 8),
                            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: primaryGreen.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: Text('Kayıtlı', style: TextStyle(color: primaryGreen, fontSize: 10))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(siradaki.hastaneAd, style: TextStyle(color: primaryGreen, fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, color: primaryBlue, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(siradaki.randevuTarihi), style: TextStyle(color: textLight, fontSize: 13, fontWeight: FontWeight.bold)),
                          Text('Saat: ${DateFormat('HH:mm').format(siradaki.randevuTarihi)}', style: TextStyle(color: textMuted, fontSize: 11)),
                        ],
                      ),
                    ),
                    Icon(Icons.alarm, color: textMuted, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(Icons.edit_note, 'Soru Notu'),
                  _buildActionButton(Icons.calendar_today, 'Takvim'),
                  _buildActionButton(Icons.navigation_outlined, 'Yol Tarifi'),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(border: Border.all(color: textMuted.withOpacity(0.3)), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, color: textMuted, size: 14),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: textLight, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDailyMedicinePlan() {
    final ilacKutusu = Hive.box<Ilac>('ilaclar');
    var gunlukIlaclar = ilacKutusu.values.toList();
    
    if (gunlukIlaclar.isEmpty) return const SizedBox.shrink();

    int alinan = gunlukIlaclar.where((i) => i.alindiMi).length;
    int toplam = gunlukIlaclar.length;

    return Column(
      children: [
        _buildSectionTitle('Günün İlaç Planı', '$alinan / $toplam Alındı'),
        const SizedBox(height: 12),
        ...gunlukIlaclar.map((ilac) => _buildMedicineTile(ilac)).toList(),
      ],
    );
  }

  Widget _buildMedicineTile(Ilac ilac) {
    bool alindi = ilac.alindiMi;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: alindi ? cardColor.withOpacity(0.5) : cardColor,
        border: alindi ? null : Border.all(color: primaryBlue.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16)
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () { ilac.alindiMi = !ilac.alindiMi; ilac.save(); },
            child: CircleAvatar(
              backgroundColor: alindi ? primaryGreen : bgColor,
              radius: 16,
              child: Icon(alindi ? Icons.check : Icons.access_time, color: alindi ? bgColor : primaryBlue, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(ilac.ad, style: TextStyle(color: alindi ? textMuted : textLight, fontSize: 14, fontWeight: FontWeight.bold, decoration: alindi ? TextDecoration.lineThrough : null)),
                    const SizedBox(width: 8),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: primaryGreen.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: Text(ilac.zamanDilimi, style: TextStyle(color: primaryGreen, fontSize: 9))),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${ilac.saat} • ${ilac.talimat}', style: TextStyle(color: textMuted, fontSize: 11)),
              ],
            ),
          ),
          if (!alindi)
            ElevatedButton(
              onPressed: () { ilac.alindiMi = true; ilac.save(); },
              style: ElevatedButton.styleFrom(backgroundColor: primaryBlue.withOpacity(0.2), foregroundColor: primaryBlue, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('İçtim', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            )
          else
            Text(ilac.saat, style: TextStyle(color: textMuted, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPolyclinicDistribution() {
    final hastalikKutusu = Hive.box<Hastalik>('hastaliklar');
    var hastaliklar = hastalikKutusu.values.toList();
    
    if (hastaliklar.isEmpty) return const SizedBox.shrink();

    Map<String, int> poliSayilari = {};
    for (var h in hastaliklar) {
      poliSayilari[h.poliklinik] = (poliSayilari[h.poliklinik] ?? 0) + 1;
    }
    var siraliPoli = poliSayilari.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    int toplamZiyaret = hastaliklar.length;
    List<Color> renkler = [primaryGreen, primaryBlue, primaryOrange, textMuted];

    // En son randevu/hastalık tarihi
    hastaliklar.sort((a, b) => b.tarih.compareTo(a.tarih));
    String sonTarih = DateFormat('dd MMMM yyyy', 'tr_TR').format(hastaliklar.first.tarih);

    return Column(
      children: [
        _buildSectionTitle('Poliklinik Dağılımı', 'Tüm Zamanlar'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 60, height: 60,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ...siraliPoli.take(3).toList().reversed.toList().asMap().entries.map((entry) {
                          int i = entry.key;
                          // Ters çevirdiğimiz için asıl indeksi bulmamız lazım
                          int realIndex = siraliPoli.length > 3 ? (2 - i) : (siraliPoli.length - 1 - i); 
                          
                          double kumeDeger = 0;
                          for (int j = 0; j <= realIndex; j++) {
                            kumeDeger += siraliPoli[j].value / toplamZiyaret;
                          }
                          return CircularProgressIndicator(value: kumeDeger, strokeWidth: 8, color: renkler[realIndex % renkler.length], backgroundColor: Colors.transparent);
                        }).toList(),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$toplamZiyaret', style: TextStyle(color: textLight, fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('ZİYARET', style: TextStyle(color: textMuted, fontSize: 6, letterSpacing: 1)),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: siraliPoli.take(3).toList().asMap().entries.map((entry) {
                        var poli = entry.value;
                        int yuzde = ((poli.value / toplamZiyaret) * 100).toInt();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(width: 8, height: 8, decoration: BoxDecoration(color: renkler[entry.key % renkler.length], shape: BoxShape.circle)),
                                  const SizedBox(width: 8),
                                  Text(poli.key, style: TextStyle(color: textLight, fontSize: 12)),
                                ],
                              ),
                              Row(
                                children: [
                                  Text('%$yuzde', style: TextStyle(color: textLight, fontSize: 12, fontWeight: FontWeight.bold)),
                                  Text(' (${poli.value})', style: TextStyle(color: textMuted, fontSize: 11)),
                                ],
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  )
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white10, height: 1)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Son Muayene: ', style: TextStyle(color: textMuted, fontSize: 11)),
                  Text(sonTarih, style: TextStyle(color: primaryGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildAIAssistantCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryOrange, width: 1.5),
        boxShadow: [BoxShadow(color: primaryOrange.withOpacity(0.1), blurRadius: 20, spreadRadius: 0)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: primaryOrange, size: 20),
                  const SizedBox(width: 8),
                  Text('AI KLİNİK ASİSTAN', style: TextStyle(color: textLight, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ],
              ),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: primaryOrange.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Text('Akıllı Analiz', style: TextStyle(color: primaryOrange, fontSize: 10, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 16),
          Text('"Sisteme girdiğiniz randevunuz ve son tahlil sonuçlarınıza göre doktorunuza sormak isteyebileceğiniz soruları hazırlayabilirim."', style: TextStyle(color: textMuted, fontSize: 13, height: 1.4, fontStyle: FontStyle.italic)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // AI Sayfasına Yönlendirme
                Navigator.push(context, MaterialPageRoute(builder: (context) => const YapayZekaSayfasi()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryOrange.withOpacity(0.15), foregroundColor: primaryOrange, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              icon: const Icon(Icons.arrow_back_ios, size: 14),
              label: const Text('Yapay Zeka İle Randevuya\nHazırlan', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          )
        ],
      ),
    );
  }
  // --- HIZLI EKLE MENÜSÜ VE MİNİ FORMLAR ---

  void _hizliEkleMenusuAc(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: textMuted.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Text('Hızlı Ekle', style: TextStyle(color: textLight, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildHizliEkleButonu('Yeni İlaç', 'Günlük planınıza hızlıca ilaç ekleyin', Icons.medication, primaryBlue, () {
                Navigator.pop(context);
                _hizliIlacFormuAc(context);
              }),
              const SizedBox(height: 12),
              _buildHizliEkleButonu('Yeni Randevu', 'Gelecek hastane ziyaretini planlayın', Icons.calendar_month, primaryOrange, () {
                Navigator.pop(context);
                _hizliRandevuFormuAc(context);
              }),
              const SizedBox(height: 12),
              _buildHizliEkleButonu('Yeni Hastalık / Ziyaret', 'Klinik geçmişinize kayıt düşün', Icons.medical_services, primaryGreen, () {
                Navigator.pop(context);
                _hizliHastalikFormuAc(context);
              }),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
    );
  }

  Widget _buildHizliEkleButonu(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.3))),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: textLight, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: textMuted, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: textMuted)
          ],
        ),
      ),
    );
  }

  // MİNİ İLAÇ FORMU
  void _hizliIlacFormuAc(BuildContext context) {
    final adController = TextEditingController();
    final miktarController = TextEditingController();

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Hızlı İlaç Ekle', style: TextStyle(color: textLight, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: adController, style: TextStyle(color: textLight), decoration: InputDecoration(labelText: 'İlaç Adı (Örn: Parol)', filled: true, fillColor: bgColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            const SizedBox(height: 12),
            TextField(controller: miktarController, keyboardType: TextInputType.number, style: TextStyle(color: textLight), decoration: InputDecoration(labelText: 'Kalan Miktar (Adet)', filled: true, fillColor: bgColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (adController.text.isNotEmpty && miktarController.text.isNotEmpty) {
                    Hive.box<Ilac>('ilaclar').add(Ilac(
                      ad: adController.text, tur: 'Tablet', talimat: 'Gerektiğinde', kalanMiktar: int.parse(miktarController.text), bagliTeshis: 'Genel', zamanDilimi: 'Sabah', saat: '08:00'
                    ));
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Hızlı Kaydet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // MİNİ RANDEVU FORMU
  void _hizliRandevuFormuAc(BuildContext context) {
    final doktorController = TextEditingController();
    final hastaneController = TextEditingController();

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Hızlı Randevu Ekle', style: TextStyle(color: textLight, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: doktorController, style: TextStyle(color: textLight), decoration: InputDecoration(labelText: 'Doktor Adı', filled: true, fillColor: bgColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            const SizedBox(height: 12),
            TextField(controller: hastaneController, style: TextStyle(color: textLight), decoration: InputDecoration(labelText: 'Hastane / Bölüm', filled: true, fillColor: bgColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (doktorController.text.isNotEmpty && hastaneController.text.isNotEmpty) {
                    Hive.box<Randevu>('randevular').add(Randevu(doktorAd: doktorController.text, hastaneAd: hastaneController.text, randevuTarihi: DateTime.now().add(const Duration(days: 1))));
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: primaryOrange, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Yarına Hızlı Kaydet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // MİNİ HASTALIK FORMU
  void _hizliHastalikFormuAc(BuildContext context) {
    final adController = TextEditingController();
    final poliklinikController = TextEditingController();

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Hızlı Hastalık/Ziyaret Ekle', style: TextStyle(color: textLight, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: adController, style: TextStyle(color: textLight), decoration: InputDecoration(labelText: 'Teşhis / Hastalık Adı', filled: true, fillColor: bgColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            const SizedBox(height: 12),
            TextField(controller: poliklinikController, style: TextStyle(color: textLight), decoration: InputDecoration(labelText: 'Poliklinik', filled: true, fillColor: bgColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (adController.text.isNotEmpty && poliklinikController.text.isNotEmpty) {
                    Hive.box<Hastalik>('hastaliklar').add(Hastalik(
                      ad: adController.text, poliklinik: poliklinikController.text, durum: 'Aktif Tedavi', doktor: 'Belirtilmedi', hastane: 'Belirtilmedi', tarih: DateTime.now(), notlar: '', ilaclar: []
                    ));
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Hızlı Kaydet', style: TextStyle(color: Color(0xFF0B131E), fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  // --- BİLDİRİM MERKEZİ FONKSİYONLARI ---

  int _aktifBildirimSayisiHesapla() {
    int sayac = 0;
    final ilaclar = Hive.box<Ilac>('ilaclar').values;
    final randevular = Hive.box<Randevu>('randevular').values;
    final simdi = DateTime.now();

    // 1. Alınmamış İlaçlar & Kritik Stok
    for (var ilac in ilaclar) {
      if (!ilac.alindiMi) sayac++;
      if (ilac.kalanMiktar <= 5) sayac++;
    }

    // 2. Yaklaşan Randevular (Önümüzdeki 3 gün)
    for (var randevu in randevular) {
      if (randevu.randevuTarihi.isAfter(simdi) && randevu.randevuTarihi.difference(simdi).inDays <= 3) {
        sayac++;
      }
    }
    return sayac;
  }

  void _bildirimMenusuAc(BuildContext context) {
    final ilaclar = Hive.box<Ilac>('ilaclar').values;
    final randevular = Hive.box<Randevu>('randevular').values;
    final simdi = DateTime.now();
    
    List<Widget> bildirimKartlari = [];

    // Kritik Stok Bildirimleri
    for (var ilac in ilaclar.where((i) => i.kalanMiktar <= 5)) {
      bildirimKartlari.add(_buildBildirimKarti(Icons.warning_amber_rounded, Colors.redAccent, 'Kritik İlaç Stoku', '${ilac.ad} adlı ilacınızdan sadece ${ilac.kalanMiktar} adet kaldı. Lütfen reçetenizi yenileyin.'));
    }

    // Alınmamış İlaç Bildirimleri
    for (var ilac in ilaclar.where((i) => !i.alindiMi)) {
      bildirimKartlari.add(_buildBildirimKarti(Icons.access_time, primaryOrange, 'İlaç Saati Geldi', '${ilac.zamanDilimi} dozu olan ${ilac.ad} henüz alınmadı. Lütfen ilacınızı içiniz.'));
    }

    // Yaklaşan Randevu Bildirimleri
    for (var randevu in randevular) {
      if (randevu.randevuTarihi.isAfter(simdi) && randevu.randevuTarihi.difference(simdi).inDays <= 3) {
        int gunKald = randevu.randevuTarihi.difference(simdi).inDays;
        String zamanMetni = gunKald == 0 ? 'Bugün' : '$gunKald gün sonra';
        bildirimKartlari.add(_buildBildirimKarti(Icons.calendar_month, primaryBlue, 'Yaklaşan Randevu', '$zamanMetni ${randevu.doktorAd} ile ${randevu.hastaneAd} randevunuz var.'));
      }
    }

    if (bildirimKartlari.isEmpty) {
      bildirimKartlari.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(child: Text('Şu an için yeni bir bildiriminiz yok.', style: TextStyle(color: textMuted))),
        )
      );
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: textMuted.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Bildirim Merkezi', style: TextStyle(color: textLight, fontSize: 18, fontWeight: FontWeight.bold)),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: primaryGreen.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Text('${bildirimKartlari.length > 1 ? bildirimKartlari.length : _aktifBildirimSayisiHesapla()} Yeni', style: TextStyle(color: primaryGreen, fontSize: 12, fontWeight: FontWeight.bold)))
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: bildirimKartlari,
                ),
              )
            ],
          ),
        );
      }
    );
  }

  Widget _buildBildirimKarti(IconData icon, Color color, String title, String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.3))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: textLight, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(message, style: TextStyle(color: textMuted, fontSize: 12, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }
}