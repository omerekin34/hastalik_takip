import 'package:hive/hive.dart';
part 'hastalik_model.g.dart';

@HiveType(typeId: 0)
class Hastalik extends HiveObject {
  @HiveField(0)
  String ad;

  @HiveField(1)
  String poliklinik;

  @HiveField(2)
  String durum; // 'Aktif Tedavi', 'Kronik', 'Geçmiş / İyileşti'

  @HiveField(3)
  String doktor;

  @HiveField(4)
  String hastane;

  @HiveField(5)
  DateTime tarih;

  @HiveField(6)
  String notlar;

  @HiveField(7)
  List<String> ilaclar;

  Hastalik({
    required this.ad,
    required this.poliklinik,
    required this.durum,
    required this.doktor,
    required this.hastane,
    required this.tarih,
    required this.notlar,
    required this.ilaclar,
  });
}