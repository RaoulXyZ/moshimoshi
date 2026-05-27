import 'package:hive/hive.dart';
part 'exercise.g.dart';

@HiveType(typeId: 1)
class Exercise {
  @HiveField(6)
  final String surveyName;
  @HiveField(7)
  final String modulo;
  @HiveField(8)
  bool done;
  @HiveField(13)
  bool assessment;
  @HiveField(14)
  String? tappa;

  Exercise({
    required this.surveyName,
    required this.modulo,
    required this.done,
    required this.assessment,
    required this.tappa,
  });

  void setDone() {
    done = true;
  }
}
