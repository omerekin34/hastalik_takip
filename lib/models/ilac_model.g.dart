// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ilac_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IlacAdapter extends TypeAdapter<Ilac> {
  @override
  final int typeId = 1;

  @override
  Ilac read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Ilac(
      ad: fields[0] as String,
      tur: fields[1] as String,
      talimat: fields[2] as String,
      kalanMiktar: fields[3] as int,
      bagliTeshis: fields[4] as String,
      zamanDilimi: fields[5] as String,
      saat: fields[6] as String,
      alindiMi: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Ilac obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.ad)
      ..writeByte(1)
      ..write(obj.tur)
      ..writeByte(2)
      ..write(obj.talimat)
      ..writeByte(3)
      ..write(obj.kalanMiktar)
      ..writeByte(4)
      ..write(obj.bagliTeshis)
      ..writeByte(5)
      ..write(obj.zamanDilimi)
      ..writeByte(6)
      ..write(obj.saat)
      ..writeByte(7)
      ..write(obj.alindiMi);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IlacAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
