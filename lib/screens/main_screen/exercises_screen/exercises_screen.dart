import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/exercise.dart';
import '../../../providers/progress.dart';
import '../../../utility/mindblooming_text_style.dart';
import './exercise_card.dart';

class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<Progress>(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text("Percorso", style: MindBloomingTextStyle.header1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text("Introduzione", style: MindBloomingTextStyle.header3),
          ),
          ExerciseCard(
            exercise: exerciseAt(0, progress),
            date: dateAt(0, progress),
            tappa: "Introduzione",
          ),
          ExerciseCard(
            exercise: exerciseAt(0, progress, second: true),
            date: dateAt(0, progress),
            tappa: "Introduzione",
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child:
                Text("Prima settimana", style: MindBloomingTextStyle.header3),
          ),
          ExerciseCard(
            exercise: exerciseAt(1, progress),
            date: dateAt(1, progress),
            tappa: "Prima settimana",
          ),
          ExerciseCard(
            exercise: exerciseAt(1, progress, second: true),
            date: dateAt(1, progress),
            tappa: "Prima settimana",
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child:
                Text("Seconda settimana", style: MindBloomingTextStyle.header3),
          ),
          ExerciseCard(
            exercise: exerciseAt(2, progress),
            date: dateAt(2, progress),
            tappa: "Seconda settimana",
          ),
          ExerciseCard(
            exercise: exerciseAt(2, progress, second: true),
            date: dateAt(2, progress),
            tappa: "Seconda settimana",
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child:
                Text("Terza settimana", style: MindBloomingTextStyle.header3),
          ),
          ExerciseCard(
            exercise: exerciseAt(3, progress),
            date: dateAt(3, progress),
            tappa: "Terza settimana",
          ),
          ExerciseCard(
            exercise: exerciseAt(3, progress, second: true),
            date: dateAt(3, progress),
            tappa: "Terza settimana",
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child:
                Text("Quarta settimana", style: MindBloomingTextStyle.header3),
          ),
          ExerciseCard(
            exercise: exerciseAt(4, progress),
            date: dateAt(4, progress),
            tappa: "Quarta settimana",
          ),
          ExerciseCard(
            exercise: exerciseAt(4, progress, second: true),
            date: dateAt(4, progress),
            tappa: "Quarta settimana",
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child:
                Text("Quinta settimana", style: MindBloomingTextStyle.header3),
          ),
          ExerciseCard(
            exercise: exerciseAt(5, progress),
            date: dateAt(5, progress),
            tappa: "Quinta settimana",
          ),
          ExerciseCard(
            exercise: exerciseAt(5, progress, second: true),
            date: dateAt(5, progress),
            tappa: "Quinta settimana",
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Exercise exerciseAt(
    int index,
    Progress progress, {
    bool second = false,
  }) {
    final ex = progress.weeklyExercises.entries;

    return second
        ? ex.elementAt(index).value[1]
        : ex.elementAt(index).value.first;
  }

  String dateAt(int index, Progress progress) {
    final ex = progress.weeklyExercises.entries;

    return ex.elementAt(index).key;
  }
}
