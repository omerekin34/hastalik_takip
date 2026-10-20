import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiServisi {
  // API Anahtarın buraya eklendi:
  static const String _apiKey = 'AQ.Ab8RN6LzHgpPLHPfgezLCtO6Xc8e19_ajlnyGN7FE_xYdm0jrg'; 
  
  static late final GenerativeModel _model;
  static late final ChatSession chat;

  static void baslat() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(
        'Sen empatik, profesyonel ve son derece bilgili bir tıbbi yapay zeka asistanısın. '
        'Kullanıcıların ilaç etkileşimleri, hastalık belirtileri, sağlıklı yaşam ve ilk yardım gibi '
        'konulardaki sorularını tıbbi literatüre dayanarak anlaşılır bir dille cevapla. '
        'Kullanıcı sana hangi dilde (Türkçe veya İngilizce) soru sorarsa, o dilde yanıt ver. '
        'Ancak her cevabının sonuna kesinlikle şu uyarıyı ekle: "Bu bilgiler bilgilendirme amaçlıdır, '
        'kesin teşhis ve tedavi için lütfen doktorunuza başvurun."'
      ),
    );
    chat = _model.startChat();
  }

  static Future<String> soruSor(String soru) async {
    try {
      final response = await chat.sendMessage(Content.text(soru));
      return response.text ?? "Cevap oluşturulamadı.";
    } catch (e) {
      print("Yapay Zeka Hatası: $e"); 
      return "Bağlantı hatası oluştu. Lütfen internetinizi veya API anahtarınızı kontrol edin.";
    }
  }
}