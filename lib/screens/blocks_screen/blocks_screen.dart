import 'package\:flutter/material.dart';
import 'package\:flutter\_svg/svg.dart';
import 'package\:provider/provider.dart';
import 'package\:sizer/sizer.dart';
import 'package\:timelines\_plus/timelines\_plus.dart';
import '../../models/exercise.dart';
import '../../providers/answers.dart';
import '../../providers/questions.dart';
import '../../providers/progress.dart';
import '../../utility/mindblooming\_color\_scheme.dart';
import '../../utility/mindblooming\_text\_style.dart';
import '../questions\_screen/questions\_screen.dart';
import './header.dart';

class BlocksScreen extends StatefulWidget {
  final Exercise exercise;
  final String tappa;
  final bool disabled;

  const BlocksScreen({
    Key? key,
    required this.exercise,
    required this.tappa,
    this.disabled = false,
  }) : super(key: key);

  @override
  State<BlocksScreen> createState() => _BlocksScreenState();
}

class _BlocksScreenState extends State<BlocksScreen> {
  late final Map<String, dynamic> blocks;

  @override
  void initState() {
    super.initState();
    final questions = Provider.of<Questions>(context, listen: false);
    blocks = questions.blocks(widget.exercise.surveyName);
  }

  @override
  Widget build(BuildContext context) {
    final progressProvider = Provider.of<Progress>(context);
    final questionsProvider = Provider.of<Questions>(context, listen: false);
    final answersProvider = Provider.of<Answers>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Header(exercise: widget.exercise),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                widget.tappa.contains('screening')
                    ? widget.tappa
                    : 'Percorso - ${widget.tappa}',
                style: MindBloomingTextStyle.header2,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Column(
                children: blocks.entries.map((entry) {
                  final index = blocks.keys.toList().indexOf(entry.key);
                  final surveyName = widget.exercise.surveyName;
                  final blockKey = entry.key;
                  final blockData = entry.value;
                  final blockName = questionsProvider.getBlockPrettyName(
                    surveyName,
                    blockKey,
                  );
                  final surveyID = questionsProvider.surveyID(surveyName);

                  final isDone = progressProvider.isDoneBlock(
                    surveyName,
                    blockKey,
                  );
                  final isCurrent = index == 0 ||
                      progressProvider.isDoneBlock(
                        surveyName,
                        blocks.keys.elementAt(index - 1),
                      );

                  final isBeforeNext = index < blocks.length - 1 &&
                      isDone &&
                      !progressProvider.isDoneBlock(
                        surveyName,
                        blocks.keys.elementAt(index + 1),
                      );

                  // Prepare visible questions
                  final questionsMap =
                      Map<String, dynamic>.from(blockData['questions']);
                  final visibleKeys = questionsMap.entries
                      .where((e) => questionsProvider.isSkip(
                            Map<String, dynamic>.from(e.value),
                            context,
                            surveyID,
                          ))
                      .map((e) => e.key)
                      .toList();
                  final total = visibleKeys.length;
                  final answered = answersProvider.getAnswerCountKeys(
                    surveyID,
                    visibleKeys,
                  );

                  // Icon selection
                  final iconAsset = widget.tappa.contains('screening')
                      ? 'assets/icon_survey.svg'
                      : index == 0
                          ? 'assets/icon_lesson.svg'
                          : index == 1
                              ? 'assets/icon_exercise.svg'
                              : 'assets/icon_survey.svg';

                  // Status styling
                  late final String statusIcon;
                  late final Color backgroundColor;
                  late final Color borderColor;

                  if (isDone) {
                    statusIcon = 'assets/icon_done.svg';
                    backgroundColor = MindBloomingColorScheme.secondary2shadow;
                    borderColor = MindBloomingColorScheme.secondary4shadow;
                  } else if (isCurrent) {
                    statusIcon = 'assets/icon_current.svg';
                    backgroundColor = MindBloomingColorScheme.tertiary1shadow;
                    borderColor = MindBloomingColorScheme.tertiary;
                  } else {
                    statusIcon = 'assets/icon_locked.svg';
                    backgroundColor = MindBloomingColorScheme.primary2shadow;
                    borderColor = MindBloomingColorScheme.primary3shadow;
                  }

                  return TimelineTile(
                    nodeAlign: TimelineNodeAlign.start,
                    contents: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 10, 40, 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        splashColor: isDone
                            ? MindBloomingColorScheme.secondary4shadow
                            : MindBloomingColorScheme.tertiary,
                        highlightColor: Colors.transparent,
                        onTap: (isDone || isCurrent)
                            ? () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => QuestionsScreen(
                                      onDone: (_, blockName, __) async {
                                        progressProvider.addDoneBlock(
                                          surveyName,
                                          blockName,
                                        );

                                        // Dopo aver segnato il blocco corrente come done,
                                        // verifichiamo se tutti i blocchi del survey sono completati.
                                        final allBlocksKeys =
                                            blocks.keys.toList();
                                        final bool allDone = allBlocksKeys
                                            .every((k) => progressProvider
                                                .isDoneBlock(surveyName, k));

                                        if (allDone) {
                                          progressProvider.setExerciseDone(
                                            widget.exercise,
                                          );
                                        }
                                      },
                                      surveyName: surveyName,
                                      blockName: blockKey,
                                      buttonText: 'Torna ai Moduli',
                                      title:
                                          questionsProvider.getBlockPrettyName(
                                        surveyName,
                                        'survey_root_name',
                                      ),
                                      subtitle: blockName,
                                    ),
                                  ),
                                )
                            : null,
                        child: Ink(
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: borderColor,
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 15,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          SvgPicture.asset(iconAsset),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              blockName,
                                              style: MindBloomingTextStyle
                                                  .subtitle,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Text(
                                            '$total',
                                            style:
                                                MindBloomingTextStyle.pretitle,
                                          ),
                                          Text(
                                            total == 1
                                                ? (index == blocks.length - 1 ||
                                                        surveyName.startsWith(
                                                          'MM_baseline_assessment',
                                                        ))
                                                    ? ' domanda'
                                                    : ' contenuti'
                                                : (index == blocks.length - 1 ||
                                                        surveyName.startsWith(
                                                          'MM_baseline_assessment',
                                                        ))
                                                    ? ' domande'
                                                    : ' contenuti',
                                            style:
                                                MindBloomingTextStyle.pretitle,
                                          ),
                                        ],
                                      ),
                                      if (isDone || isCurrent) ...[
                                        const SizedBox(height: 5),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              border: Border.all(
                                                color: MindBloomingColorScheme
                                                    .dialogBg,
                                                width: 0.5,
                                              ),
                                            ),
                                            child: LinearProgressIndicator(
                                              value: total > 0
                                                  ? answered / total
                                                  : 1.0,
                                              minHeight: 5,
                                              color: isDone
                                                  ? MindBloomingColorScheme
                                                      .secondary
                                                  : MindBloomingColorScheme
                                                      .tertiary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              if (isDone || isCurrent)
                                Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: SvgPicture.asset(
                                    'assets/icon_right_arrow.svg',
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    node: TimelineNode(
                      indicator: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: SvgPicture.asset(
                          statusIcon,
                          width: MindBloomingTextStyle.returnMobile()
                              ? 20.sp
                              : (MindBloomingTextStyle.returnDesktop()
                                  ? 11.sp
                                  : 14.sp),
                        ),
                      ),
                      startConnector: index != 0
                          ? DashedLineConnector(
                              dash: 4,
                              gap: 2,
                              color: isDone
                                  ? MindBloomingColorScheme.secondary2shadow
                                  : isCurrent
                                      ? MindBloomingColorScheme.tertiary2shadow
                                      : MindBloomingColorScheme.primary2shadow,
                            )
                          : null,
                      endConnector: index != blocks.length - 1
                          ? DashedLineConnector(
                              dash: 4,
                              gap: 2,
                              color: isBeforeNext
                                  ? MindBloomingColorScheme.tertiary2shadow
                                  : isDone
                                      ? MindBloomingColorScheme.secondary2shadow
                                      : MindBloomingColorScheme.primary2shadow,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
