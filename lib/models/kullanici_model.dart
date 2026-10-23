import 'package:hive/hive.dart';
part 'kullanici_model.g.dart';

@HiveType(typeId: 4) // Eğer diğer modellerin 0,1,2,3 ise buna 4 veriyoruz
class Kullanici extends HiveObject {
  @HiveField(0)
  String adSoyad;

  @HiveField(1)
  String cinsiyet; // "Erkek" veya "Kadın"

  @HiveField(2)
  String pinKodu;

  @HiveField(3)
  bool beniHatirla;

  Kullanici({
    required this.adSoyad,
    required this.cinsiyet,
    required this.pinKodu,
    this.beniHatirla = true,
  });
}