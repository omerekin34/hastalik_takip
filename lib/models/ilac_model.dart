import 'package:hive/hive.dart';

part 'ilac_model.g.dart';

@HiveType(typeId: 1)
class Ilac extends HiveObject {
  @HiveField(0)
  String ad;

  @HiveField(1)
  String doz;

  @HiveField(2)
  String kullanimSikligi;

  @HiveField(3)
  bool bittiMi;

  Ilac({
    required this.ad,
    required this.doz,
    required this.kullanimSikligi,
    this.bittiMi = false,
  });
}