import 'package:hive/hive.dart';

part 'randevu_model.g.dart';

@HiveType(typeId: 2)
class Randevu extends HiveObject {
  @HiveField(0)
  String doktorAd;

  @HiveField(1)
  String hastaneAd;

  @HiveField(2)
  DateTime randevuTarihi;

  @HiveField(3)
  bool bildirimAcikMi;

  @HiveField(4)
  String? notlar;

  Randevu({
    required this.doktorAd,
    required this.hastaneAd,
    required this.randevuTarihi,
    this.bildirimAcikMi = true,
    this.notlar,
  });
}