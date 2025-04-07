// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocationMessageAdapter extends TypeAdapter<LocationMessage> {
  @override
  final int typeId = 0;

  @override
  LocationMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationMessage(
      lat: (fields[0] as num).toDouble(),
      lon: (fields[1] as num).toDouble(),
      timestamp: (fields[2] as num).toInt(),
      battery: (fields[3] as num).toDouble(),
      speed: (fields[4] as num).toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, LocationMessage obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.lat)
      ..writeByte(1)
      ..write(obj.lon)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.battery)
      ..writeByte(4)
      ..write(obj.speed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
