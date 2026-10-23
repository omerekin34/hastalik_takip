// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hastalik_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HastalikAdapter extends TypeAdapter<Hastalik> {
  @override
  final int typeId = 0;

  @override
  Hastalik read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Hastalik(
      ad: fields[0] as String,
      poliklinik: fields[1] as String,
      durum: fields[2] as String,
      doktor: fields[3] as String,
      hastane: fields[4] as String,
      tarih: fields[5] as DateTime,
      notlar: fields[6] as String,
      ilaclar: (fields[7] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Hastalik obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.ad)
      ..writeByte(1)
      ..write(obj.poliklinik)
      ..writeByte(2)
      ..write(obj.durum)
      ..writeByte(3)
      ..write(obj.doktor)
      ..writeByte(4)
      ..write(obj.hastane)
      ..writeByte(5)
      ..write(obj.tarih)
      ..writeByte(6)
      ..write(obj.notlar)
      ..writeByte(7)
      ..write(obj.ilaclar);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HastalikAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
