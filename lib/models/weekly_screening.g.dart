// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_screening.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeeklyScreeningAdapter extends TypeAdapter<WeeklyScreening> {
  @override
  final int typeId = 2;

  @override
  WeeklyScreening read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeeklyScreening(
      blockName: fields[9] as String,
      surveyName: fields[10] as String,
      modulo: fields[11] as String,
      done: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, WeeklyScreening obj) {
    writer
      ..writeByte(4)
      ..writeByte(9)
      ..write(obj.blockName)
      ..writeByte(10)
      ..write(obj.surveyName)
      ..writeByte(11)
      ..write(obj.modulo)
      ..writeByte(12)
      ..write(obj.done);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyScreeningAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
