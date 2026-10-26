// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'randevu_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RandevuAdapter extends TypeAdapter<Randevu> {
  @override
  final int typeId = 2;

  @override
  Randevu read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Randevu(
      doktorAd: fields[0] as String,
      hastaneAd: fields[1] as String,
      randevuTarihi: fields[2] as DateTime,
      bildirimAcikMi: fields[3] as bool,
      notlar: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Randevu obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.doktorAd)
      ..writeByte(1)
      ..write(obj.hastaneAd)
      ..writeByte(2)
      ..write(obj.randevuTarihi)
      ..writeByte(3)
      ..write(obj.bildirimAcikMi)
      ..writeByte(4)
      ..write(obj.notlar);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RandevuAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
