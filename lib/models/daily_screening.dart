import 'package:hive/hive.dart';
part 'daily_screening.g.dart';

@HiveType(typeId: 0)
class DailyScreening {
  @HiveField(0)
  final String blockName;
  @HiveField(1)
  final String surveyName;
  @HiveField(2)
  final String modulo;
  @HiveField(3)
  final int index;
  @HiveField(4)
  bool done;

  DailyScreening({
    required this.blockName,
    required this.surveyName,
    required this.modulo,
    required this.index,
    required this.done,
  });

  void setDone() {
    done = true;
  }
}
