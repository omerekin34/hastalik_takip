import 'package:flutter/material.dart';

final ValueNotifier<String> dilYoneticisi = ValueNotifier('TR');

const Map<String, Map<String, String>> sozluk = {
  'TR': {
    'uygulama_baslik': 'Kişisel Sağlık Asistanım', 'ozet': 'Özet', 'hastaliklar': 'Hastalıklar', 'ilaclar': 'İlaçlar', 'randevular': 'Randevular',
    'saglik_ozetiniz': 'Sağlık Özetiniz', 'kayitli_hastalik': 'Kayıtlı Hastalık', 'aktif_ilac': 'Aktif İlaç', 'yaklasan_randevu': 'Yaklaşan Randevunuz', 'randevu_yok': 'Planlanmış yaklaşan bir randevunuz bulunmamaktadır.',
    'kaydet': 'Kaydet', 'guncelle': 'Güncelle', 'diger': 'Diğer (Kendim Yazacağım)',
    'randevu_bos': 'Gelecek bir randevunuz bulunmuyor.', 'yeni_randevu': 'Yeni Randevu Ekle', 'randevu_duzenle': 'Randevuyu Düzenle', 'doktor_adi': 'Doktor Adı', 'il_sec': 'İl Seçin', 'ilce_sec': 'İlçe Seçin', 'hastane_sec': 'Hastane Seçin', 'hastane_yaz': 'Hastane Adını Tam Yazın', 'bolum_sec': 'Bölüm / Poliklinik', 'bolum_yaz': 'Bölüm Adını Yazın', 'tarih_saat': 'Randevu Tarihi ve Saati',
    'ilac_yok': 'Henüz eklenmiş bir ilaç yok.', 'yeni_ilac': 'Yeni İlaç Ekle', 'ilac_duzenle': 'İlacı Düzenle', 'ilac_sec': 'İlaç Seçin', 'ilac_adi_yaz': 'İlaç Adını Yazın', 'dozaj_sec': 'Dozaj Seçin', 'dozaj_yaz': 'Dozajı Yazın', 'siklik_sec': 'Kullanım Sıklığı', 'siklik_yaz': 'Sıklığı Yazın', 'dozaj': 'Dozaj', 'siklik': 'Sıklık',
    'hastalik_yok': 'Henüz bir kayıt yok.', 'yeni_hastalik': 'Yeni Hastalık / Doktor Notu Ekle', 'hastalik_duzenle': 'Kaydı Düzenle', 'hastalik_sec': 'Hastalık / Şikayet Seçin', 'sikayet_yaz': 'Şikayetinizi Yazın', 'doktor_notu': 'Doktorun Notları', 'fotograf_ekle': 'Reçete / Tahlil Fotoğrafı Ekle', 'tarih': 'Tarih', 'not': 'Not',
    'pdf_rapor': 'PDF Raporu İndir / Paylaş', 'istatistikler': 'Sağlık İstatistikleri', 'bolum_dagilimi': 'Poliklinik Dağılımı (Tüm Zamanlar)', 'aylik_randevu': 'Aylara Göre Randevu Yoğunluğu', 'yetersiz_veri': 'Grafik oluşturmak için yeterli veri yok.',
    'sesli_oku': 'İlaçlarımı Sesli Oku', 'okunuyor': 'Okunuyor...', 'ilac_giris': 'Kayıtlı ilaçlarınız şunlardır: ',
    'sesli_oku_hastalik': 'Hastalıkları Sesli Oku', 'hastalik_giris': 'Kayıtlı rahatsızlıklarınız şunlardır: ',
    'sesli_oku_randevu': 'Randevuları Sesli Oku', 'randevu_giris': 'Planlanmış randevularınız şunlardır: ',
    // BİYOMETRİK GÜVENLİK İÇİN EKLENENLER:
    'guvenlik_uyarisi': 'Sağlık verilerinize erişmek için kimliğinizi doğrulayın.',
    'kilit_ac': 'Kilidi Aç',
    'kilit_uyari': 'Verileriniz biyometrik şifreleme ile korunmaktadır.',
    // TR kısmının en altına:
    'asistana_sor': 'Yapay Zeka Asistanı',
    'mesaj_yaz': 'Sağlığınızla ilgili bir soru sorun...',
    'ai_uyari': 'Not: Yapay zeka tavsiyeleri doktor teşhisi yerine geçmez.',
    'ai_hosgeldin': 'Merhaba! Ben sizin kişisel sağlık asistanınızım. Tahlil sonuçlarınız, ilaç etkileşimleri veya belirtileriniz hakkında bana her şeyi sorabilirsiniz. Size nasıl yardımcı olabilirim?',
  },
  'EN': {
    'uygulama_baslik': 'My Health Assistant', 'ozet': 'Summary', 'hastaliklar': 'Illnesses', 'ilaclar': 'Medications', 'randevular': 'Appointments',
    'saglik_ozetiniz': 'Your Health Summary', 'kayitli_hastalik': 'Saved Illnesses', 'aktif_ilac': 'Active Meds', 'yaklasan_randevu': 'Upcoming Appointment', 'randevu_yok': 'You have no scheduled upcoming appointments.',
    'kaydet': 'Save', 'guncelle': 'Update', 'diger': 'Other (I will type)',
    'randevu_bos': 'You have no upcoming appointments.', 'yeni_randevu': 'Add New Appointment', 'randevu_duzenle': 'Edit Appointment', 'doktor_adi': 'Doctor Name', 'il_sec': 'Select City', 'ilce_sec': 'Select District', 'hastane_sec': 'Select Hospital', 'hastane_yaz': 'Type Hospital Name', 'bolum_sec': 'Department / Clinic', 'bolum_yaz': 'Type Department Name', 'tarih_saat': 'Appointment Date and Time',
    'ilac_yok': 'No medications added yet.', 'yeni_ilac': 'Add New Medication', 'ilac_duzenle': 'Edit Medication', 'ilac_sec': 'Select Medication', 'ilac_adi_yaz': 'Type Medication Name', 'dozaj_sec': 'Select Dosage', 'dozaj_yaz': 'Type Dosage', 'siklik_sec': 'Frequency of Use', 'siklik_yaz': 'Type Frequency', 'dozaj': 'Dosage', 'siklik': 'Frequency',
    'hastalik_yok': 'No records yet.', 'yeni_hastalik': 'Add Illness / Doctor Note', 'hastalik_duzenle': 'Edit Record', 'hastalik_sec': 'Select Illness / Complaint', 'sikayet_yaz': 'Type Your Complaint', 'doktor_notu': 'Doctor\'s Notes', 'fotograf_ekle': 'Add Prescription / Test Photo', 'tarih': 'Date', 'not': 'Note',
    'pdf_rapor': 'Download / Share PDF Report', 'istatistikler': 'Health Statistics', 'bolum_dagilimi': 'Department Distribution (All Time)', 'aylik_randevu': 'Appointment Density by Month', 'yetersiz_veri': 'Not enough data to generate chart.',
    'sesli_oku': 'Read My Medications Aloud', 'okunuyor': 'Reading...', 'ilac_giris': 'Your registered medications are: ',
    'sesli_oku_hastalik': 'Read Illnesses Aloud', 'hastalik_giris': 'Your registered illnesses are: ',
    'sesli_oku_randevu': 'Read Appointments Aloud', 'randevu_giris': 'Your scheduled appointments are: ',
    // BIOMETRIC SECURITY TRANSLATIONS:
    'guvenlik_uyarisi': 'Please authenticate to access your health data.',
    'kilit_ac': 'Unlock',
    'kilit_uyari': 'Your data is protected by biometric encryption.',
    'asistana_sor': 'AI Health Assistant',
    'mesaj_yaz': 'Ask a health-related question...',
    'ai_uyari': 'Note: AI advice does not replace a professional medical diagnosis.',
    'ai_hosgeldin': 'Hello! I am your personal health assistant. You can ask me anything about your symptoms, medications, or lab results. How can I help you today?',
  }
};

String metin(String anahtar) => sozluk[dilYoneticisi.value]?[anahtar] ?? anahtar;
void dilDegistir() => dilYoneticisi.value = dilYoneticisi.value == 'TR' ? 'EN' : 'TR';

List<String> get bolumListesiDinamik => dilYoneticisi.value == 'TR' ? ['Dahiliye (İç Hastalıkları)', 'Kardiyoloji', 'KBB', 'Göz Hastalıkları', 'Ortopedi', 'Nöroloji', 'Cildiye (Dermatoloji)', 'Psikiyatri', 'Üroloji', 'Kadın Doğum', 'Çocuk Sağlığı', 'Genel Cerrahi'] : ['Internal Medicine', 'Cardiology', 'ENT', 'Ophthalmology', 'Orthopedics', 'Neurology', 'Dermatology', 'Psychiatry', 'Urology', 'Gynecology', 'Pediatrics', 'General Surgery'];
List<String> get dozajListesiDinamik => dilYoneticisi.value == 'TR' ? ['500 mg', '1000 mg', '1 Ölçek', '1 Damla', 'Yarım Tablet', '1 Tablet', '2 Tablet'] : ['500 mg', '1000 mg', '1 Scoop', '1 Drop', 'Half Tablet', '1 Tablet', '2 Tablets'];
List<String> get siklikListesiDinamik => dilYoneticisi.value == 'TR' ? ['Sabah', 'Akşam', 'Sabah - Akşam', 'Günde 3 Kez', 'Aç Karnına', 'Tok Karnına', 'İhtiyaç Halinde'] : ['Morning', 'Evening', 'Morning - Evening', '3 Times a Day', 'On Empty Stomach', 'After Meals', 'As Needed'];
List<String> get hastalikListesiDinamik => dilYoneticisi.value == 'TR' ? ['Grip / Soğuk Algınlığı', 'Migren / Baş Ağrısı', 'Hipertansiyon', 'Diyabet (Şeker)', 'Astım / Bronşit', 'Mide Yanması / Gastrit', 'Eklem / Kas Ağrısı', 'Alerji'] : ['Flu / Cold', 'Migraine / Headache', 'Hypertension', 'Diabetes', 'Asthma / Bronchitis', 'Heartburn / Gastritis', 'Joint / Muscle Pain', 'Allergy'];
List<String> get ilacListesiDinamik => ['Parol', 'Arveles', 'Majezik', 'Aspirin', 'Augmentin', 'Calpol', 'Dolorex', 'Nurofen', 'Aferin', 'Katarin'];

String evrenselCeviri(String yazi) {
  if (dilYoneticisi.value == 'TR') return yazi;

  String sonuc = yazi;
  
  // Hastalıkları çevir
  List<String> trHastalik = ['Grip / Soğuk Algınlığı', 'Migren / Baş Ağrısı', 'Hipertansiyon', 'Diyabet (Şeker)', 'Astım / Bronşit', 'Mide Yanması / Gastrit', 'Eklem / Kas Ağrısı', 'Alerji'];
  List<String> enHastalik = ['Flu / Cold', 'Migraine / Headache', 'Hypertension', 'Diabetes', 'Asthma / Bronchitis', 'Heartburn / Gastritis', 'Joint / Muscle Pain', 'Allergy'];
  
  for (int i = 0; i < trHastalik.length; i++) {
    sonuc = sonuc.replaceAll(trHastalik[i], enHastalik[i]);
  }

  // Dozaj ve Sıklıkları çevir
  sonuc = sonuc.replaceAll('Ölçek', 'Scoop')
               .replaceAll('Damla', 'Drop')
               .replaceAll('Yarım Tablet', 'Half Tablet')
               .replaceAll('Tablet', 'Tablet')
               .replaceAll('Sabah - Akşam', 'Morning - Evening')
               .replaceAll('Sabah', 'Morning')
               .replaceAll('Akşam', 'Evening')
               .replaceAll('Günde 3 Kez', '3 Times a Day')
               .replaceAll('Aç Karnına', 'On Empty Stomach')
               .replaceAll('Tok Karnına', 'After Meals')
               .replaceAll('İhtiyaç Halinde', 'As Needed');

  return sonuc;
}

String randevuMekanCeviri(String dbMetin) {
  if (dilYoneticisi.value == 'TR') return dbMetin;

  String sonuc = dbMetin;

  // Hastane isimlerini ve tiplerini İngilizceye çevir
  sonuc = sonuc.replaceAll('Özel', 'Private')
               .replaceAll('Devlet Hastanesi', 'State Hospital')
               .replaceAll('Şehir Hastanesi', 'City Hospital')
               .replaceAll('Eğitim ve Araştırma Hastanesi', 'Training and Research Hospital')
               .replaceAll('Hastanesi', 'Hospital')
               .replaceAll('Hastane', 'Hospital');

  // Bölümleri otomatik eşleştirip çevir  
  List<String> trBolumler = ['Dahiliye (İç Hastalıkları)', 'Kardiyoloji', 'KBB', 'Göz Hastalıkları', 'Ortopedi', 'Nöroloji', 'Cildiye (Dermatoloji)', 'Psikiyatri', 'Üroloji', 'Kadın Doğum', 'Çocuk Sağlığı', 'Genel Cerrahi'];
  List<String> enBolumler = ['Internal Medicine', 'Cardiology', 'ENT', 'Ophthalmology', 'Orthopedics', 'Neurology', 'Dermatology', 'Psychiatry', 'Urology', 'Gynecology', 'Pediatrics', 'General Surgery'];

  for (int i = 0; i < trBolumler.length; i++) {
    sonuc = sonuc.replaceAll(trBolumler[i], enBolumler[i]);
  }

  return sonuc;
}