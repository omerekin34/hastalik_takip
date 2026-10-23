// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kullanici_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KullaniciAdapter extends TypeAdapter<Kullanici> {
  @override
  final int typeId = 4;

  @override
  Kullanici read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Kullanici(
      adSoyad: fields[0] as String,
      cinsiyet: fields[1] as String,
      pinKodu: fields[2] as String,
      beniHatirla: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Kullanici obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.adSoyad)
      ..writeByte(1)
      ..write(obj.cinsiyet)
      ..writeByte(2)
      ..write(obj.pinKodu)
      ..writeByte(3)
      ..write(obj.beniHatirla);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KullaniciAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
