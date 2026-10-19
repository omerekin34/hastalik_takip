import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiServisi {
  // BURAYA GOOGLE AI STUDIO'DAN ALDIĞIN API ANAHTARINI YAPIŞTIR:
  static const String _apiKey = 'AQ.Ab8RN6K-zO2qMMs5GIa7KRuakU0zgsf6qM5cRDstvs-fNVVSEg'; 
  
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
      return "Bağlantı hatası oluştu. Lütfen internetinizi kontrol edin.";
    }
  }
}