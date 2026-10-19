import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 
import 'models/hastalik_model.dart';
import 'models/ilac_model.dart';
import 'models/randevu_model.dart';
import 'services/bildirim_servisi.dart';
import 'services/dil_servisi.dart'; 
import 'screens/ozet_sayfasi.dart';
import 'screens/hastaliklar_sayfasi.dart';
import 'screens/ilaclar_sayfasi.dart';
import 'screens/randevular_sayfasi.dart';
import 'screens/acilis_ekrani.dart';
import 'screens/kilit_ekrani.dart'; // Biyometrik ekranı dahil ettik

// Tüm uygulamadan erişilebilecek Tema Yöneticisi
final ValueNotifier<ThemeMode> temaYoneticisi = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(HastalikAdapter());
  Hive.registerAdapter(IlacAdapter());
  Hive.registerAdapter(RandevuAdapter());
  await Hive.openBox<Hastalik>('hastaliklar');
  await Hive.openBox<Ilac>('ilaclar');
  await Hive.openBox<Randevu>('randevular');
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
                scaffoldBackgroundColor: const Color(0xFF121212),
                primaryColor: const Color(0xFF80CBC4),
                colorScheme: const ColorScheme.dark(primary: Color(0xFF80CBC4), secondary: Color(0xFF4DB6AC), surface: Color(0xFF1E1E1E)),
                appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1E1E1E), foregroundColor: Color(0xFF80CBC4), elevation: 0),
                cardTheme: CardThemeData(color: const Color(0xFF1E1E1E), elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: Color(0xFF1E1E1E), selectedItemColor: Color(0xFF80CBC4), unselectedItemColor: Colors.grey),
              ),
              home: const KilitEkrani(), // veya const AcilisEkrani()
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
    const OzetSayfasi(), const HastaliklarSayfasi(), const IlaclarSayfasi(), const RandevularSayfasi(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaYoneticisi,
      builder: (context, tema, _) {
        return ValueListenableBuilder<String>(
          valueListenable: dilYoneticisi,
          builder: (context, dil, _) {
            return Scaffold(
              appBar: AppBar(
                title: Text(metin('uygulama_baslik'), style: const TextStyle(fontWeight: FontWeight.bold)),
                actions: [
                  TextButton(
                    onPressed: dilDegistir,
                    child: Text(dilYoneticisi.value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: tema == ThemeMode.light ? Colors.white : const Color(0xFF80CBC4))),
                  ),
                  IconButton(
                    icon: Icon(tema == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
                    onPressed: () => temaYoneticisi.value = tema == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
                  ),
                ],
              ),
              body: _sayfalar[_seciliSayfa],
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _seciliSayfa,
                onTap: (index) => setState(() => _seciliSayfa = index),
                type: BottomNavigationBarType.fixed,
                items: [
                  BottomNavigationBarItem(icon: const Icon(Icons.dashboard), label: metin('ozet')),
                  BottomNavigationBarItem(icon: const Icon(Icons.medical_services), label: metin('hastaliklar')),
                  BottomNavigationBarItem(icon: const Icon(Icons.medication), label: metin('ilaclar')),
                  BottomNavigationBarItem(icon: const Icon(Icons.calendar_month), label: metin('randevular')),
                ],
              ),
            );
          }
        );
      }
    );
  }
}