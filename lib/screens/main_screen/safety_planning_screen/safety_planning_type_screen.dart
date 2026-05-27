import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import '../../../providers/progress.dart';
import '../../../providers/questions.dart';
import '../../../providers/safety_planning.dart';
import '../../questions_screen/questions_screen.dart';

final String mainUrl = dotenv.env['QUALTRICS_URL']!;
final String token = dotenv.env['QUALTRICS_TOKEN']!;

class SafetyPlanningTypeScreen extends StatefulWidget {
  const SafetyPlanningTypeScreen({
    super.key,
    required this.safetyPlanningType,
  });

  final String safetyPlanningType;

  @override
  State<SafetyPlanningTypeScreen> createState() =>
      _SafetyPlanningTypeScreenState();
}

class _SafetyPlanningTypeScreenState extends State<SafetyPlanningTypeScreen> {
  // final TextEditingController _contentController = TextEditingController();
  // final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final pp = Provider.of<Progress>(context);

    final questions = Provider.of<Questions>(context, listen: false);
    final blocks = questions.blocks("MM_SP_${widget.safetyPlanningType}");

    final spProvider = Provider.of<SafetyPlanning>(context);

    return Scaffold(
      // appBar: AppBar(
      //   toolbarHeight: 80,
      //   title: Text(
      //     spProvider.prettyName[widget.safetyPlanningType] ?? 'Titolo',
      //     style: MindBloomingTextStyle.header2,
      //   ),
      //   backgroundColor: const Color.fromARGB(0, 225, 225, 225),
      //   centerTitle: true,
      //   elevation: 0,
      // ),
      body: QuestionsScreen(
        // The third parameter, context, is used in screening
        onDone: (surveyName, blockName, _) {
          pp.addDoneBlock(
            surveyName,
            blockName,
          );
        },
        buttonText: "Indietro",
        title: spProvider.prettyName[widget.safetyPlanningType],
        subtitle: '',
        surveyName: "MM_SP_${widget.safetyPlanningType}",
        blockName: blocks.entries.first.key,
      ),
    );
  }
}
