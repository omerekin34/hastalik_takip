import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/kullanici_model.dart';
import '../main.dart'; // AnaEkran'a yönlendirmek için

class ProfilKayitEkrani extends StatefulWidget {
  const ProfilKayitEkrani({super.key});

  @override
  State<ProfilKayitEkrani> createState() => _ProfilKayitEkraniState();
}

class _ProfilKayitEkraniState extends State<ProfilKayitEkrani> {
  final _adController = TextEditingController();
  final _pinController = TextEditingController();
  String _secilenCinsiyet = 'Erkek';
  bool _beniHatirla = true;

  void _kayitOl() async {
    if (_adController.text.trim().isEmpty || _pinController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen adınızı ve en az 4 haneli PIN girin.', style: TextStyle(color: Colors.white)), 
          backgroundColor: Colors.redAccent
        ),
      );
      return;
    }

    try {
      // Veritabanına Kullanıcıyı Kaydediyoruz
      final box = Hive.box<Kullanici>('kullanici_kutusu');
      final yeniKullanici = Kullanici(
        adSoyad: _adController.text.trim(),
        cinsiyet: _secilenCinsiyet,
        pinKodu: _pinController.text,
        beniHatirla: _beniHatirla,
      );
      await box.put('profil', yeniKullanici); 

      // Kayıt bitince Ana Ekrana yönlendir (Geçmişi temizleyerek)
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AnaEkran()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      debugPrint("Kayıt Hatası: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kayıt olurken bir hata oluştu. Lütfen uygulamayı yeniden başlatın.', style: TextStyle(color: Colors.white)), 
            backgroundColor: Colors.redAccent
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B131E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.health_and_safety, color: Color(0xFF00C48C), size: 64),
              const SizedBox(height: 16),
              const Text('Hoş Geldiniz', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              const Text('Kişisel sağlık asistanınızı kurun.', style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 40),
              
              TextField(
                controller: _adController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Adınız Soyadınız',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.person, color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF161F2C),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _secilenCinsiyet,
                dropdownColor: const Color(0xFF161F2C),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Hitap (Cinsiyet)',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.wc, color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF161F2C),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: ['Erkek', 'Kadın'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _secilenCinsiyet = val!),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Güvenlik PIN Kodu',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF161F2C),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              
              SwitchListTile(
                title: const Text('Beni Hatırla (Oto Giriş)', style: TextStyle(color: Colors.white, fontSize: 14)),
                activeColor: const Color(0xFF00C48C),
                value: _beniHatirla,
                onChanged: (val) => setState(() => _beniHatirla = val),
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _kayitOl,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C48C),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Profili Oluştur', style: TextStyle(color: Color(0xFF0B131E), fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}