// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_screening.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyScreeningAdapter extends TypeAdapter<DailyScreening> {
  @override
  final int typeId = 0;

  @override
  DailyScreening read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyScreening(
      blockName: fields[0] as String,
      surveyName: fields[1] as String,
      modulo: fields[2] as String,
      index: fields[3] as int,
      done: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DailyScreening obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.blockName)
      ..writeByte(1)
      ..write(obj.surveyName)
      ..writeByte(2)
      ..write(obj.modulo)
      ..writeByte(3)
      ..write(obj.index)
      ..writeByte(4)
      ..write(obj.done);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyScreeningAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
