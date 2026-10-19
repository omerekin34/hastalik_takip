import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'hastalik_model.g.dart';

@HiveType(typeId: 0)
class Hastalik extends HiveObject {
  @HiveField(0)
  String ad;

  @HiveField(1)
  DateTime teshisTarihi;

  @HiveField(2)
  String doktorNotu;

  @HiveField(3)
  bool devamEdiyorMu;

  // YENİ EKLENEN: Fotoğraf verisini (reçete/tahlil) cihazda tutacak alan
  @HiveField(4)
  Uint8List? resimBytes;

  Hastalik({
    required this.ad,
    required this.teshisTarihi,
    required this.doktorNotu,
    this.devamEdiyorMu = true,
    this.resimBytes,
  });
}