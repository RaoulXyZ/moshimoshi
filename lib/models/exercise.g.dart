// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseAdapter extends TypeAdapter<Exercise> {
  @override
  final int typeId = 1;

  @override
  Exercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Exercise(
      surveyName: fields[6] as String,
      modulo: fields[7] as String,
      done: fields[8] as bool,
      assessment: fields[13] as bool,
      tappa: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Exercise obj) {
    writer
      ..writeByte(5)
      ..writeByte(6)
      ..write(obj.surveyName)
      ..writeByte(7)
      ..write(obj.modulo)
      ..writeByte(8)
      ..write(obj.done)
      ..writeByte(13)
      ..write(obj.assessment)
      ..writeByte(14)
      ..write(obj.tappa);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
