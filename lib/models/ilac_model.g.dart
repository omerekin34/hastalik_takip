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
      doz: fields[1] as String,
      kullanimSikligi: fields[2] as String,
      bittiMi: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Ilac obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.ad)
      ..writeByte(1)
      ..write(obj.doz)
      ..writeByte(2)
      ..write(obj.kullanimSikligi)
      ..writeByte(3)
      ..write(obj.bittiMi);
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
