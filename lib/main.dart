import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 
import 'models/hastalik_model.dart';
import 'models/ilac_model.dart';
import 'models/randevu_model.dart';
import 'models/kullanici_model.dart'; 
import 'services/bildirim_servisi.dart';
import 'services/dil_servisi.dart'; 
import 'screens/ozet_ekrani.dart'; 
import 'screens/hastaliklar_sayfasi.dart';
import 'screens/ilaclar_sayfasi.dart';
import 'screens/randevular_sayfasi.dart';
import 'screens/raporlar_sayfasi.dart';
import 'screens/profil_kayit_ekrani.dart'; 
import 'screens/kilit_ekrani.dart'; 
import 'screens/acilis_ekrani.dart';


final ValueNotifier<ThemeMode> temaYoneticisi = ValueNotifier(ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  Hive.registerAdapter(HastalikAdapter());
  Hive.registerAdapter(IlacAdapter());
  Hive.registerAdapter(RandevuAdapter());
  Hive.registerAdapter(KullaniciAdapter()); 
  
  await Hive.openBox<Hastalik>('hastaliklar');
  await Hive.openBox<Ilac>('ilaclar');
  await Hive.openBox<Randevu>('randevular');
  await Hive.openBox<Kullanici>('kullanici_kutusu'); 
  await Hive.openBox('gizlenenBildirimler');

  
  await BildirimServisi.baslat();
  runApp(const HastalikTakipApp());
}

class HastalikTakipApp extends StatelessWidget {
  const HastalikTakipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaYoneticisi,
      builder: (context, guncelTema, _) {
        return ValueListenableBuilder<String>(
          valueListenable: dilYoneticisi,
          builder: (context, guncelDil, _) {
            return MaterialApp(
              title: 'Kişisel Sağlık Asistanım',
              debugShowCheckedModeBanner: false,
              themeMode: guncelTema,
              locale: guncelDil == 'TR' ? const Locale('tr', 'TR') : const Locale('en', 'US'),
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [ Locale('tr', 'TR'), Locale('en', 'US') ],
              
              theme: ThemeData(
                brightness: Brightness.light,
                scaffoldBackgroundColor: const Color(0xFFF5F7FA),
                primaryColor: const Color(0xFF009688),
                colorScheme: const ColorScheme.light(primary: Color(0xFF009688), secondary: Color(0xFF00796B), surface: Colors.white),
                appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF009688), foregroundColor: Colors.white, elevation: 0),
                cardTheme: CardThemeData(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              ),
              
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: const Color(0xFF0B131E),
                primaryColor: const Color(0xFF00C48C),
                colorScheme: const ColorScheme.dark(primary: Color(0xFF00C48C), secondary: Color(0xFF00A3FF), surface: Color(0xFF161F2C)),
                appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0B131E), foregroundColor: Colors.white, elevation: 0),
                cardTheme: CardThemeData(color: const Color(0xFF161F2C), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                  backgroundColor: Color(0xFF0B131E), 
                  selectedItemColor: Color(0xFF00C48C), 
                  unselectedItemColor: Color(0xFF8B98A5),
                  elevation: 8,
                ),
              ),
              // Yönlendirme mantığı AcilisEkrani'ne taşındı
              home: const AcilisEkrani(), 
            );
          }
        );
      },
    );
  }
}

class AnaEkran extends StatefulWidget {
  const AnaEkran({super.key});
  @override
  State<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> {
  int _seciliSayfa = 0;
  
  final List<Widget> _sayfalar = [
    const OzetEkrani(), 
    const HastaliklarSayfasi(), 
    const IlaclarSayfasi(), 
    const RandevularSayfasi(),
    const RaporlarSayfasi(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _sayfalar[_seciliSayfa],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _seciliSayfa,
        onTap: (index) => setState(() => _seciliSayfa = index),
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.dashboard_customize), label: metin('ozet')),
          BottomNavigationBarItem(icon: const Icon(Icons.medical_services_outlined), label: metin('hastaliklar')),
          BottomNavigationBarItem(icon: const Icon(Icons.medication_liquid_outlined), label: metin('ilaclar')),
          BottomNavigationBarItem(icon: const Icon(Icons.calendar_month), label: metin('randevular')),
          const BottomNavigationBarItem(icon: Icon(Icons.insert_chart_outlined), label: 'Raporlar'), 
        ],
      ),
    );
  }
}