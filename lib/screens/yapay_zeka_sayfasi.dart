import 'package:flutter/material.dart';
import '../services/gemini_servisi.dart';
import '../services/dil_servisi.dart';
import '../main.dart'; // temaYoneticisi için

class YapayZekaSayfasi extends StatefulWidget {
  const YapayZekaSayfasi({super.key});

  @override
  State<YapayZekaSayfasi> createState() => _YapayZekaSayfasiState();
}

class _YapayZekaSayfasiState extends State<YapayZekaSayfasi> {
  // Projenin genel tema renkleri
  final Color bgColor = const Color(0xFF0B131E);
  final Color cardColor = const Color(0xFF161F2C);
  final Color primaryGreen = const Color(0xFF00C48C);
  final Color primaryBlue = const Color(0xFF00A3FF);
  final Color textLight = const Color(0xFFFFFFFF);
  final Color textMuted = const Color(0xFF8B98A5);

  final TextEditingController _mesajController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _mesajlar = [];
  bool _bekleniyor = false;

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında yapay zekanın ilk karşılama mesajı
    _mesajlar.add({'gonderen': 'ai', 'mesaj': metin('ai_hosgeldin')});
  }

  void _mesajGonder(String metinDegeri) async {
    if (metinDegeri.trim().isEmpty) return;

    setState(() {
      _mesajlar.add({'gonderen': 'user', 'mesaj': metinDegeri});
      _bekleniyor = true;
    });
    
    _mesajController.clear();
    _asaKaydir();

    // Gemini API'ye soruyu gönderiyoruz
    String cevap = await GeminiServisi.soruSor(metinDegeri);

    setState(() {
      _mesajlar.add({'gonderen': 'ai', 'mesaj': cevap});
      _bekleniyor = false;
    });
    _asaKaydir();
  }

  void _asaKaydir() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaYoneticisi,
      builder: (context, tema, _) {
        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: Row(
              children: [
                Icon(Icons.auto_awesome, color: primaryGreen, size: 20),
                const SizedBox(width: 8),
                Text(metin('asistana_sor'), style: TextStyle(color: textLight, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            backgroundColor: cardColor,
            elevation: 0,
            iconTheme: IconThemeData(color: textLight),
          ),
          body: Column(
            children: [
              // Üstteki Uyarı Bandı (Turuncu/Amber şık uyarı tasarımı)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFFFF9900).withOpacity(0.15),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFFFF9900), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        metin('ai_uyari'),
                        style: const TextStyle(color: Color(0xFFFF9900), fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Mesajlaşma Alanı
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _mesajlar.length,
                  itemBuilder: (context, index) {
                    final msg = _mesajlar[index];
                    final isMe = msg['gonderen'] == 'user';
                    
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isMe ? primaryGreen.withOpacity(0.2) : cardColor,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
                            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                          ),
                          border: Border.all(color: isMe ? primaryGreen.withOpacity(0.4) : Colors.white10),
                        ),
                        child: Text(
                          msg['mesaj']!,
                          style: TextStyle(
                            color: isMe ? textLight : textLight,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Yükleniyor Animasyonu
              if (_bekleniyor)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: primaryGreen)),
                      const SizedBox(width: 10),
                      Text("Yapay zeka düşünüyor...", style: TextStyle(color: textMuted, fontSize: 12)),
                    ],
                  ),
                ),

              // ÖRNEK SORULAR (ACTION CHIPS) ALANI
              _ornekSorularAlani(),

              // Mesaj Gönderme Kutusu
              Container(
                padding: const EdgeInsets.all(16),
                color: cardColor,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _mesajController,
                        style: TextStyle(color: textLight),
                        decoration: InputDecoration(
                          hintText: metin('mesaj_yaz'),
                          hintStyle: TextStyle(color: textMuted, fontSize: 13),
                          filled: true,
                          fillColor: bgColor,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (value) => _mesajGonder(value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: primaryGreen,
                      radius: 22,
                      child: IconButton(
                        icon: Icon(Icons.send, color: bgColor, size: 18),
                        onPressed: () => _mesajGonder(_mesajController.text),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // HAZIR SORULAR WIDGET'I
  Widget _ornekSorularAlani() {
    List<String> ornekSorular = dilYoneticisi.value == 'TR' 
      ? [
          "💊 Bugün hangi ilaçları almalıyım?",
          "🩺 İlaçlarımın yan etkileri neler?",
          "📅 Yaklaşan randevum var mı?",
          "🤕 Baş ağrısına ne iyi gelir?",
          "📊 Sağlık verilerimi özetle"
        ] 
      : [
          "💊 Which meds should I take today?",
          "🩺 What are the side effects?",
          "📅 Upcoming appointments?",
          "🤕 What's good for a headache?",
          "📊 Summarize my health data"
        ];

    return Container(
      height: 45,
      margin: const EdgeInsets.only(bottom: 8, top: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: ornekSorular.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              elevation: 0,
              backgroundColor: cardColor,
              side: BorderSide(color: primaryBlue.withOpacity(0.3)),
              label: Text(
                ornekSorular[index], 
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: primaryBlue,
                )
              ),
              onPressed: () {
                _mesajGonder(ornekSorular[index]);
              },
            ),
          );
        }
      ),
    );
  }
}