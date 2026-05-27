import 'package:hive/hive.dart';

import 'exercise.dart';

class ExerciseSafeAdapter extends TypeAdapter<Exercise> {
  @override
  final int typeId = 1;

  @override
  Exercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final fieldNum = reader.readByte();
      final value = reader.read();
      fields[fieldNum] = value;
    }

    // Lettura difensiva con default se il campo manca o è in un tipo diverso
    String readString(int index, {String defaultValue = ''}) {
      final v = fields[index];
      if (v == null) return defaultValue;
      if (v is String) return v;

      return v.toString();
    }

    bool readBool(int index, {bool defaultValue = false}) {
      final v = fields[index];
      if (v == null) return defaultValue;
      if (v is bool) return v;
      if (v is int) return v != 0;
      final s = v.toString().toLowerCase();
      if (s == 'true') return true;
      if (s == 'false') return false;

      return defaultValue;
    }

    // campi vecchi: 6,7,8 ; nuovi: 13,14
    final surveyName = readString(6);
    final modulo = readString(7);
    final done = readBool(8, defaultValue: false);
    final assessment = readBool(13, defaultValue: false);
    final tappa = fields.containsKey(14) ? (fields[14] as String?) : null;

    return Exercise(
      surveyName: surveyName,
      modulo: modulo,
      done: done,
      assessment: assessment,
      tappa: tappa,
    );
  }

  @override
  void write(BinaryWriter writer, Exercise obj) {
    writer
      ..writeByte(5) // numero di campi
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
}
