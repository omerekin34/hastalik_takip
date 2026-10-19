import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // WEB KONTROLÜ İÇİN EKLENDİ
import '../services/dil_servisi.dart';
import '../main.dart'; 

class KilitEkrani extends StatefulWidget {
  const KilitEkrani({super.key});

  @override
  State<KilitEkrani> createState() => _KilitEkraniState();
}

class _KilitEkraniState extends State<KilitEkrani> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _dogrulaniyor = false;

  @override
  void initState() {
    super.initState();
    _kimlikDogrula();
  }

  Future<void> _kimlikDogrula() async {
    // 1. EĞER BİLGİSAYARDA (WEB) ÇALIŞIYORSA DİREKT ANA EKRANA GEÇ
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _anaEkranaGec();
      });
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
        localizedReason: metin('guvenlik_uyarisi'),
        options: const AuthenticationOptions(
          stickyAuth: true, 
          biometricOnly: false, 
        ),
      );

      if (didAuthenticate) {
        _anaEkranaGec();
      }
    } on PlatformException catch (e) {
      debugPrint("Güvenlik hatası: $e");
    } finally {
      if (mounted) setState(() => _dogrulaniyor = false);
    }
  }

  void _anaEkranaGec() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AnaEkran()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaYoneticisi,
      builder: (context, tema, _) {
        final isDark = tema == ThemeMode.dark;
        
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_person, size: 100, color: isDark ? const Color(0xFF80CBC4) : const Color(0xFF00796B)),
                  const SizedBox(height: 30),
                  Text(metin('uygulama_baslik'), style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87), textAlign: TextAlign.center),
                  const SizedBox(height: 15),
                  Text(metin('kilit_uyari'), style: TextStyle(fontSize: 16, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600), textAlign: TextAlign.center),
                  const SizedBox(height: 50),
                  if (_dogrulaniyor && !kIsWeb)
                    const CircularProgressIndicator(color: Colors.teal)
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _kimlikDogrula,
                        icon: const Icon(Icons.fingerprint, size: 28),
                        label: Text(metin('kilit_ac'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: isDark ? const Color(0xFF80CBC4) : const Color(0xFF00796B),
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}