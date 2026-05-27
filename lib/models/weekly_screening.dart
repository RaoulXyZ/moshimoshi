import 'package:hive/hive.dart';
part 'weekly_screening.g.dart';

@HiveType(typeId: 2)
class WeeklyScreening {
  @HiveField(9)
  final String blockName;
  @HiveField(10)
  final String surveyName;
  @HiveField(11)
  final String modulo;
  // @HiveField(12)
  // final int blockIndex;
  @HiveField(12)
  bool done;

  WeeklyScreening({
    required this.blockName,
    required this.surveyName,
    required this.modulo,
    // required this.blockIndex,
    required this.done,
  });

  void setDone() {
    done = true;
  }
}
