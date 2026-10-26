import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/kullanici_model.dart';
import '../main.dart'; // AnaEkran yönlendirmesi için
import 'profil_kayit_ekrani.dart';
import 'kilit_ekrani.dart';

class AcilisEkrani extends StatefulWidget {
  const AcilisEkrani({Key? key}) : super(key: key);

  @override
  State<AcilisEkrani> createState() => _AcilisEkraniState();
}

class _AcilisEkraniState extends State<AcilisEkrani> with SingleTickerProviderStateMixin {
  late AnimationController _animasyonKontrolcu;
  late Animation<double> _fadeAnimasyonu;
  late Animation<double> _scaleAnimasyonu;

  final Color bgColor = const Color(0xFF0B131E);
  final Color primaryGreen = const Color(0xFF00C48C);

  @override
  void initState() {
    super.initState();
    
    // Açılış animasyonları
    _animasyonKontrolcu = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _fadeAnimasyonu = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animasyonKontrolcu, curve: Curves.easeIn));
    _scaleAnimasyonu = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _animasyonKontrolcu, curve: Curves.elasticOut));
    
    _animasyonKontrolcu.forward();

    _yonlendirmeYap();
  }

  Future<void> _yonlendirmeYap() async {
    // Uygulama açılırken 3 saniye bu şık ekranı gösterir
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    final box = Hive.box<Kullanici>('kullanici_kutusu');
    final kullanici = box.get('profil');

    // Kullanıcı durumuna göre akıllı yönlendirme
    if (kullanici == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfilKayitEkrani()));
    } else if (kullanici.beniHatirla) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AnaEkran()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const KilitEkrani()));
    }
  }

  @override
  void dispose() {
    _animasyonKontrolcu.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimasyonu,
          child: ScaleTransition(
            scale: _scaleAnimasyonu,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Parlayan Premium Logo Alanı
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: primaryGreen.withOpacity(0.2), blurRadius: 40, spreadRadius: 10),
                    ],
                  ),
                  child: Icon(Icons.monitor_heart_outlined, color: primaryGreen, size: 80),
                ),
                const SizedBox(height: 32),
                
                // Başlık
                const Text(
                  'Kişisel Sağlık\nAsistanım',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.2, letterSpacing: 1.5),
                ),
                const SizedBox(height: 12),
                
                // Alt Başlık
                Text(
                  'Sizin Sağlığınız, Sizin Kontrolünüzde',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, letterSpacing: 0.5),
                ),
                
                const SizedBox(height: 60),
                
                // Şık Yükleniyor Göstergesi
                SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(color: primaryGreen, strokeWidth: 3),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}