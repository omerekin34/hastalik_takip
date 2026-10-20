import 'package:flutter/material.dart';
import '../main.dart'; // AnaEkran'a geçiş yapabilmek için
import '../services/dil_servisi.dart'; // Çoklu dil desteği için ekledik

class AcilisEkrani extends StatefulWidget {
  const AcilisEkrani({super.key});

  @override
  State<AcilisEkrani> createState() => _AcilisEkraniState();
}

class _AcilisEkraniState extends State<AcilisEkrani> {
  @override
  void initState() {
    super.initState();
    // Animasyonu 2.5 saniye gösterip otomatik olarak Ana Sayfaya geçiyoruz
    Future.delayed(const Duration(milliseconds: 2500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AnaEkran()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Temizlediğin arka plan resmini tam ekran yerleştiriyoruz
          Image.asset('assets/splash_logo.jpg', fit: BoxFit.cover),
          
          // GERÇEK HAREKETLİ ANİMASYON VE DİNAMİK YAZI
          Positioned( // 'const' kelimesini kaldırdık çünkü dil değişkeni dinamik
            bottom: 160, // TÜBİTAK logosunun tam üstüne hizaladık
            left: 0,
            right: 0,
            child: Column(
              children: [
                const CircularProgressIndicator(
                  color: Color(0xFF009688), // Turkuaz dönen çark
                  strokeWidth: 3,
                ),
                const SizedBox(height: 15),
                Text(
                  // Dil TR ise Yükleniyor, değilse Loading yazacak
                  dilYoneticisi.value == 'TR' ? 'Yükleniyor...' : 'Loading...', 
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF009688), // Turkuaz yazı
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}