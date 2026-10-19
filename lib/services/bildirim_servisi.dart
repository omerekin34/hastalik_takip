import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:math';

class BildirimServisi {
  static final FlutterLocalNotificationsPlugin _bildirimEklentisi = FlutterLocalNotificationsPlugin();

  static Future<void> baslat() async {
    // Saat dilimlerini başlatıyoruz (Türkiye saati için)
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

    const AndroidInitializationSettings androidAyarlari = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosAyarlari = DarwinInitializationSettings();
    
    const InitializationSettings ayarlar = InitializationSettings(android: androidAyarlari, iOS: iosAyarlari);
    
    // İŞTE ÇÖZÜM BURADA: Geliştiriciler parametrenin adını "settings" olarak değiştirmiş!
    await _bildirimEklentisi.initialize(settings: ayarlar);

    // Yeni Android sürümleri için bildirim ve alarm izinleri
    _bildirimEklentisi.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    _bildirimEklentisi.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestExactAlarmsPermission();
  }

  // ANLIK BİLDİRİM (Kaydedildi vs. mesajları için)
  static Future<void> anlikBildirimGoster({required String baslik, required String icerik}) async {
    const AndroidNotificationDetails androidDetay = AndroidNotificationDetails('anlik_kanal', 'Anlık Bildirimler', importance: Importance.max, priority: Priority.high);
    const NotificationDetails detay = NotificationDetails(android: androidDetay);
    
    await _bildirimEklentisi.show(
      id: Random().nextInt(1000), 
      title: baslik, 
      body: icerik, 
      notificationDetails: detay,
    );
  }

  // RANDEVUDAN TAM 24 SAAT ÖNCE HABER VEREN SİSTEM
  static Future<void> randevuHatirlaticiKur(int id, String doktorAd, String hastaneAd, DateTime randevuTarihi) async {
    DateTime hatirlatmaZamani = randevuTarihi.subtract(const Duration(days: 1)); // 1 GÜN ÖNCE
    
    if (hatirlatmaZamani.isBefore(DateTime.now())) return; 

    const AndroidNotificationDetails androidDetay = AndroidNotificationDetails('randevu_kanal', 'Randevu Hatırlatıcıları', importance: Importance.max, priority: Priority.high, icon: '@mipmap/ic_launcher');
    const NotificationDetails detay = NotificationDetails(android: androidDetay);

    await _bildirimEklentisi.zonedSchedule(
      id: id, 
      title: '📅 Randevunuz Yaklaşıyor!',
      body: 'Yarın $hastaneAd konumunda Dr. $doktorAd ile randevunuz var.',
      scheduledDate: tz.TZDateTime.from(hatirlatmaZamani, tz.local),
      notificationDetails: detay,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, 
    );
  }

  // İLAÇ KULLANIM SIKLIĞINA GÖRE (GÜNLÜK TEKRARLAYAN) ALARM
  static Future<void> ilacHatirlaticiKur(int id, String ilacAd, String dozaj, String siklik) async {
    List<int> saatler = [];
    if (siklik.contains('Sabah') || siklik.contains('Morning')) saatler.add(9); 
    if (siklik.contains('Akşam') || siklik.contains('Evening')) saatler.add(20); 
    if (siklik.contains('3 Kez') || siklik.contains('3 Times')) { saatler = [9, 14, 20]; } 
    if (saatler.isEmpty) saatler.add(12); 
    
    const AndroidNotificationDetails androidDetay = AndroidNotificationDetails('ilac_kanal', 'İlaç Hatırlatıcıları', importance: Importance.max, priority: Priority.high, icon: '@mipmap/ic_launcher');
    const NotificationDetails detay = NotificationDetails(android: androidDetay);

    for (int i = 0; i < saatler.length; i++) {
      final simdi = tz.TZDateTime.now(tz.local);
      var planlananZaman = tz.TZDateTime(tz.local, simdi.year, simdi.month, simdi.day, saatler[i]);
      if (planlananZaman.isBefore(simdi)) planlananZaman = planlananZaman.add(const Duration(days: 1)); 

      await _bildirimEklentisi.zonedSchedule(
        id: id + i * 1000, 
        title: '💊 İlaç Vakti!',
        body: '$ilacAd ($dozaj) alma vaktiniz geldi. Şifalar dileriz.',
        scheduledDate: planlananZaman,
        notificationDetails: detay,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, 
      );
    }
  }

  // İLAÇ VEYA RANDEVU SİLİNİRSE ALARMI DA İPTAL ET
  static Future<void> bildirimiIptalEt(int id) async {
    await _bildirimEklentisi.cancel(id: id);
    await _bildirimEklentisi.cancel(id: id + 1000);
    await _bildirimEklentisi.cancel(id: id + 2000);
  }
}