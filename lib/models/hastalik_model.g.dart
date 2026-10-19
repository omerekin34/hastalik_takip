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
      teshisTarihi: fields[1] as DateTime,
      doktorNotu: fields[2] as String,
      devamEdiyorMu: fields[3] as bool,
      resimBytes: fields[4] as Uint8List?,
    );
  }

  @override
  void write(BinaryWriter writer, Hastalik obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.ad)
      ..writeByte(1)
      ..write(obj.teshisTarihi)
      ..writeByte(2)
      ..write(obj.doktorNotu)
      ..writeByte(3)
      ..write(obj.devamEdiyorMu)
      ..writeByte(4)
      ..write(obj.resimBytes);
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
