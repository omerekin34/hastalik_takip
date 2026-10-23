import 'package:hive/hive.dart';
part 'ilac_model.g.dart';

@HiveType(typeId: 1)
class Ilac extends HiveObject {
  @HiveField(0)
  String ad;

  @HiveField(1)
  String tur; // Tablet, Şurup, Damla vs.

  @HiveField(2)
  String talimat; // Tok karnına, Aç vs.

  @HiveField(3)
  int kalanMiktar; // Örn: 30

  @HiveField(4)
  String bagliTeshis; // Hipertansiyon vs.

  @HiveField(5)
  String zamanDilimi; // Sabah, Öğle, Akşam, Gece

  @HiveField(6)
  String saat; // 08:30

  @HiveField(7)
  bool alindiMi; // Günlük takip için

  Ilac({
    required this.ad,
    required this.tur,
    required this.talimat,
    required this.kalanMiktar,
    required this.bagliTeshis,
    required this.zamanDilimi,
    required this.saat,
    this.alindiMi = false,
  });
}