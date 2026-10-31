import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';

import '../services/dil_servisi.dart'; 
import '../main.dart'; 
import 'profil_kayit_ekrani.dart'; 

import '../models/kullanici_model.dart';
import '../models/ilac_model.dart';
import '../models/randevu_model.dart';
import '../models/hastalik_model.dart';

class KilitEkrani extends StatefulWidget {
  const KilitEkrani({super.key});

  @override
  State<KilitEkrani> createState() => _KilitEkraniState();
}

class _KilitEkraniState extends State<KilitEkrani> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _dogrulaniyor = false;

  final Color bgColor = const Color(0xFF0B131E);
  final Color primaryGreen = const Color(0xFF00C48C);
  final Color cardColor = const Color(0xFF161F2C);
  final Color textLight = Colors.white;
  final Color textMuted = Colors.grey;

  @override
  void initState() {
    super.initState();
    _kimlikDogrula();
  }

  Future<void> _kimlikDogrula() async {
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _anaEkranaGec());
      return;
    }

    setState(() => _dogrulaniyor = true);
    
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        _anaEkranaGec();
        return;
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: metin('guvenlik_uyarisi') ?? 'Giriş yapmak için parmak izinizi okutun',
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: false),
      );

      if (didAuthenticate) {
        _anaEkranaGec();
      } else {
        // Biyometrik iptal edilirse veya başarısız olursa PIN sor
        _pinSormaDialoguAc();
      }
    } on PlatformException catch (e) {
      debugPrint("Güvenlik hatası: $e");
      _pinSormaDialoguAc(); // Hata verirse yine PIN'e düşür
    } finally {
      if (mounted) setState(() => _dogrulaniyor = false);
    }
  }

  // EFSANE ÖZELLİK: PIN İLE GİRİŞ YEDEĞİ (Emülatörler ve Sensör Bozulmaları İçin)
  void _pinSormaDialoguAc() {
    final box = Hive.box<Kullanici>('kullanici_kutusu');
    final kullanici = box.get('profil');
    if (kullanici == null) return;

    TextEditingController pinController = TextEditingController();
    bool pinGizli = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: cardColor,
          title: Text('PIN ile Giriş', style: TextStyle(color: textLight, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: pinController,
            obscureText: pinGizli,
            keyboardType: TextInputType.number,
            maxLength: 6,
            style: const TextStyle(color: Colors.white, letterSpacing: 4, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: 'Güvenlik PIN Kodunuz',
              labelStyle: TextStyle(color: textMuted),
              suffixIcon: IconButton(
                icon: Icon(pinGizli ? Icons.visibility_off : Icons.visibility, color: textMuted),
                onPressed: () => setStateDialog(() => pinGizli = !pinGizli),
              ),
              enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00C48C))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('İptal', style: TextStyle(color: Colors.grey))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
              onPressed: () {
                if (pinController.text == kullanici.pinKodu) {
                  Navigator.pop(context);
                  _anaEkranaGec();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Hatalı PIN Girdiniz!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent)
                  );
                }
              },
              child: const Text('Giriş Yap', style: TextStyle(color: Color(0xFF0B131E), fontWeight: FontWeight.bold)),
            ),
          ],
        )
      )
    );
  }

  void _anaEkranaGec() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AnaEkran()),
      (Route<dynamic> route) => false, 
    );
  }

  Future<void> _hesabiSifirla() async {
    bool onayla = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: Text('Hesabı Sıfırla', style: TextStyle(color: textLight)),
        content: Text('Tüm verileriniz silinecek ve uygulamayı ilk açtığınız güne döneceksiniz. Onaylıyor musunuz?', style: TextStyle(color: textMuted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Sıfırla', style: TextStyle(color: Colors.white))
          ),
        ],
      )
    ) ?? false;

    if (onayla) {
      // HİVE ÇÖKMESİNİ ÖNLEYEN YENİ TEMİZLİK MANTIĞI
      final kBox = Hive.box<Kullanici>('kullanici_kutusu');
      await kBox.delete('profil'); // Sadece profili siler, kutuyu kapatıp sistemi bozmaz.
      
      await Hive.box<Ilac>('ilaclar').clear();
      await Hive.box<Randevu>('randevular').clear();
      await Hive.box<Hastalik>('hastaliklar').clear();
      await Hive.box('gizlenenBildirimler').clear();
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ProfilKayitEkrani()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Icon(Icons.lock_person, size: 100, color: primaryGreen),
                const SizedBox(height: 30),
                Text(
                  metin('uygulama_baslik') ?? 'Kişisel Sağlık Asistanım', 
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textLight), 
                  textAlign: TextAlign.center
                ),
                const SizedBox(height: 15),
                Text(
                  metin('kilit_uyari') ?? 'Sağlık verilerinize erişmek için lütfen kimliğinizi doğrulayın.', 
                  style: TextStyle(fontSize: 14, color: textMuted), 
                  textAlign: TextAlign.center
                ),
                const SizedBox(height: 50),
                
                if (_dogrulaniyor && !kIsWeb)
                  CircularProgressIndicator(color: primaryGreen)
                else
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _kimlikDogrula,
                          icon: const Icon(Icons.fingerprint, size: 28),
                          label: Text(metin('kilit_ac') ?? 'Parmak İzi ile Kilidi Aç', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: primaryGreen,
                            foregroundColor: bgColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // YENİ BUTON: PIN KODU İLE GİRİŞ
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _pinSormaDialoguAc,
                          icon: const Icon(Icons.dialpad, size: 24),
                          label: const Text('PIN Kodu ile Giriş Yap', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            foregroundColor: primaryGreen,
                            side: BorderSide(color: primaryGreen.withOpacity(0.5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                
                const Spacer(),
                
                TextButton.icon(
                  onPressed: _hesabiSifirla, 
                  icon: const Icon(Icons.cleaning_services, size: 18, color: Colors.redAccent), 
                  label: const Text('Başka Hesaba Geç / Sıfırla', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}