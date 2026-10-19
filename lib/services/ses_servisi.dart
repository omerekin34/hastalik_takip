import 'package:flutter_tts/flutter_tts.dart';

class SesServisi {
  static final FlutterTts _tts = FlutterTts();
  static bool okuyorMu = false;

  static Future<void> konus(String metin, String dil) async {
    // İngilizce ise Amerikan aksanı, Türkçe ise Türk aksanı
    await _tts.setLanguage(dil == 'EN' ? "en-US" : "tr-TR");
    
    // Yaşlıların rahat anlaması için hızı biraz düşürüyoruz (Tane tane okur)
    await _tts.setSpeechRate(0.45); 
    await _tts.setPitch(1.0);
    
    okuyorMu = true;
    await _tts.speak(metin);
  }

  static Future<void> durdur() async {
    await _tts.stop();
    okuyorMu = false;
  }
}