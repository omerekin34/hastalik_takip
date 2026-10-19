import 'package:flutter/material.dart';
import '../services/dil_servisi.dart';
import '../services/gemini_servisi.dart';
import '../main.dart';

class YapayZekaSayfasi extends StatefulWidget {
  const YapayZekaSayfasi({super.key});

  @override
  State<YapayZekaSayfasi> createState() => _YapayZekaSayfasiState();
}

class Message {
  final String text;
  final bool isUser;
  Message({required this.text, required this.isUser});
}

class _YapayZekaSayfasiState extends State<YapayZekaSayfasi> {
  final TextEditingController _mesajController = TextEditingController();
  final List<Message> _mesajlar = [];
  bool _bekleniyor = false;

  @override
  void initState() {
    super.initState();
    GeminiServisi.baslat();
    // İlk karşılama mesajını listeye ekliyoruz
    _mesajlar.add(Message(text: metin('ai_hosgeldin'), isUser: false));
  }

  Future<void> _mesajGonder() async {
    if (_mesajController.text.trim().isEmpty) return;

    final soru = _mesajController.text;
    setState(() {
      _mesajlar.add(Message(text: soru, isUser: true));
      _mesajController.clear();
      _bekleniyor = true;
    });

    final cevap = await GeminiServisi.soruSor(soru);

    setState(() {
      _bekleniyor = false;
      _mesajlar.add(Message(text: cevap, isUser: false));
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = temaYoneticisi.value == ThemeMode.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(metin('asistana_sor')),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.amber.shade100,
            width: double.infinity,
            child: Text(metin('ai_uyari'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _mesajlar.length,
              itemBuilder: (context, index) {
                final mesaj = _mesajlar[index];
                return Align(
                  alignment: mesaj.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: mesaj.isUser ? Colors.teal : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(mesaj.isUser ? 16 : 0),
                        bottomRight: Radius.circular(mesaj.isUser ? 0 : 16),
                      ),
                    ),
                    child: Text(
                      mesaj.text,
                      style: TextStyle(color: mesaj.isUser ? Colors.white : (isDark ? Colors.white : Colors.black87)),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_bekleniyor) const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(color: Colors.teal)),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mesajController,
                    decoration: InputDecoration(
                      hintText: metin('mesaj_yaz'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onSubmitted: (_) => _mesajGonder(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.teal,
                  radius: 24,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _mesajGonder,
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