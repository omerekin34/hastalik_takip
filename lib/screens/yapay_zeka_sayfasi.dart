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

  void _mesajGonder(String metin) async {
    if (metin.trim().isEmpty) return;

    setState(() {
      _mesajlar.add({'gonderen': 'user', 'mesaj': metin});
      _bekleniyor = true;
    });
    
    _mesajController.clear();
    _asaKaydir();

    // Gemini API'ye soruyu gönderiyoruz
    String cevap = await GeminiServisi.soruSor(metin);

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
        final isDark = tema == ThemeMode.dark;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(metin('asistana_sor')),
            backgroundColor: isDark ? const Color(0xFF004D40) : Colors.teal,
            foregroundColor: Colors.white,
          ),
          body: Column(
            children: [
              // Üstteki Uyarı Bandı
              Container(
                width: double.infinity,
                color: Colors.amber.shade200,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  metin('ai_uyari'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13),
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
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe 
                              ? (isDark ? Colors.teal.shade700 : Colors.teal) 
                              : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
                            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                          ),
                        ),
                        child: Text(
                          msg['mesaj']!,
                          style: TextStyle(
                            color: isMe 
                                ? Colors.white 
                                : (isDark ? Colors.white : Colors.black87),
                            fontSize: 15,
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
                      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? Colors.tealAccent : Colors.teal)),
                      const SizedBox(width: 10),
                      Text("Yapay zeka düşünüyor...", style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey)),
                    ],
                  ),
                ),

              // ==========================================
              // ÖRNEK SORULAR (ACTION CHIPS) ALANI BURASI
              // ==========================================
              _ornekSorularAlani(isDark),

              // Mesaj Gönderme Kutusu
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, -2))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _mesajController,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          hintText: metin('mesaj_yaz'),
                          hintStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        onSubmitted: (value) => _mesajGonder(value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: isDark ? Colors.teal.shade700 : Colors.teal,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () => _mesajGonder(_mesajController.text),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  // HAZIR SORULAR WIDGET'I
  Widget _ornekSorularAlani(bool isDark) {
    // Dile göre otomatik değişen hazır sorular
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
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: ornekSorular.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              elevation: 2,
              backgroundColor: isDark ? const Color(0xFF004D40) : Colors.teal.shade50,
              side: BorderSide(color: Colors.teal.withOpacity(0.5)),
              label: Text(
                ornekSorular[index], 
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.teal.shade800,
                )
              ),
              onPressed: () {
                // Kullanıcı butona bastığında soruyu doğrudan yapay zekaya gönderir
                _mesajGonder(ornekSorular[index]);
              },
            ),
          );
        }
      )
    );
  }
}