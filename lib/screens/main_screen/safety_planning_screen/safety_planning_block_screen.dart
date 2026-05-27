import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timelines_plus/timelines_plus.dart';

import '../../../providers/questions.dart';
import '../../../providers/progress.dart';
import '../../../utility/mindblooming_color_scheme.dart';
import '../../questions_screen/questions_screen.dart';

class SafetyPlanningBlockScreen extends StatefulWidget {
  final String surveyName;
  final String tappa;
  final bool disabled;

  const SafetyPlanningBlockScreen({
    required this.surveyName,
    required this.tappa,
    this.disabled = false,
  });

  @override
  _SafetyPlanningBlockScreenState createState() =>
      _SafetyPlanningBlockScreenState();
}

class _SafetyPlanningBlockScreenState extends State<SafetyPlanningBlockScreen> {
  Map<String, dynamic> blocks = {};

  @override
  void initState() {
    super.initState();

    final questions = Provider.of<Questions>(context, listen: false);
    blocks = questions.blocks(widget.surveyName);
  }

  @override
  Widget build(BuildContext context) {
    final pp = Provider.of<Progress>(context);
    final qp = Provider.of<Questions>(context, listen: false);
    // final ap = Provider.of<Answers>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header(exercise: widget.exercise),
            // const SizedBox(height: 30),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 30),
            //   child: Text(
            //     widget.tappa.contains('screening')
            //         ? widget.tappa
            //         : "Esercizi - ${widget.tappa}",
            //     style: MindBloomingTextStyle.header2,
            //   ),
            // ),
            // const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: Column(
                children: [
                  ...blocks.entries.map((block) {
                    // COMPUTE VARIABLES
                    final int idx = blocks.keys.toList().indexOf(block.key);
                    final String surveyName = widget.surveyName;
                    // final String name = qp.getBlockPrettyName(
                    //   "$surveyName",
                    //   block.key,
                    // );
                    final String surveyID = qp.surveyID(surveyName);

                    final bool done = pp.isDoneBlock(
                      "$surveyName",
                      block.key,
                    );

                    final bool current = idx == 0 ||
                        pp.isDoneBlock(
                          "$surveyName",
                          blocks.keys.elementAt(idx - 1),
                        );
                    final bool beforeCurrent = idx < blocks.length - 1 &&
                        done &&
                        !pp.isDoneBlock(
                          "$surveyName",
                          blocks.keys.elementAt(idx + 1),
                        );

                    // final question = block.value['questions'];
                    final List<String> keys = List<String>.from(
                      block.value['questions'].keys.toList(),
                    );
                    // int tot = question.length;
                    // final int ans = ap.getAnswerCountKeys(surveyID, keys);

                    // for (var key in keys) {
                    // final bool skip = qp.isSkip(
                    //   Map<String, dynamic>.from(qp.questions(
                    //     surveyName,
                    //     block.key,
                    //   )[key]),
                    //   context,
                    //   surveyID,
                    // );

                    // if (!skip) {
                    //   tot--;
                    // }
                    // }

                    // final String icon = widget.tappa.contains('screening')
                    //     ? 'assets/icon_survey.svg'
                    //     : idx == 0
                    //         ? 'assets/icon_lesson.svg'
                    //         : idx == 1
                    //             ? 'assets/icon_exercise.svg'
                    //             : 'assets/icon_survey.svg';

                    // String pic;
                    // Color color;
                    // Color bcolor;

                    // if (done) {
                    //   pic = 'assets/icon_done.svg';
                    //   color = MindBloomingColorScheme.secondary2shadow;
                    //   bcolor = MindBloomingColorScheme.secondary4shadow;
                    // } else if (idx == 0) {
                    //   pic = 'assets/icon_current.svg';
                    //   color = MindBloomingColorScheme.tertiary1shadow;
                    //   bcolor = MindBloomingColorScheme.tertiary;
                    // } else if (current) {
                    //   pic = 'assets/icon_current.svg';
                    //   color = MindBloomingColorScheme.tertiary1shadow;
                    //   bcolor = MindBloomingColorScheme.tertiary;
                    // } else {
                    //   pic = 'assets/icon_locked.svg';
                    //   color = MindBloomingColorScheme.primary2shadow;
                    //   bcolor = MindBloomingColorScheme.primary3shadow;
                    // }

                    // RENDER
                    return TimelineTile(
                      // nodeAlign: TimelineNodeAlign.start,
                      contents: Padding(
                        padding: const EdgeInsets.only(
                          left: 30,
                          bottom: 10,
                          right: 40,
                          top: 10,
                        ),
                        child: InkWell(
                          // child: Ink(
                          //   // decoration: BoxDecoration(
                          //   //   color: color,
                          //   //   borderRadius: BorderRadius.circular(20),
                          //   //   border: Border.all(
                          //   //     color: bcolor,
                          //   //     width: 0.5,
                          //   //   ),
                          //   // ),
                          //   child: Row(
                          //     children: [
                          //       const Expanded(
                          //         child: Padding(
                          //           padding: EdgeInsets.symmetric(
                          //             horizontal: 20,
                          //             vertical: 15,
                          //           ),
                          //           child: Column(
                          //             crossAxisAlignment:
                          //                 CrossAxisAlignment.start,
                          //             children: [
                          //               // Expanded(
                          //               //   child: Row(
                          //               //     children: [
                          //               //       SvgPicture.asset(icon),
                          //               //       const SizedBox(width: 12),
                          //               //       Expanded(
                          //               //         child: Text(
                          //               //           name,
                          //               //           style: MindBloomingTextStyle
                          //               //               .subtitle,
                          //               //         ),
                          //               //       ),
                          //               //     ],
                          //               //   ),
                          //               // ),
                          //               // Padding(
                          //               //   padding:
                          //               //       const EdgeInsets.only(top: 5.0),
                          //               //   child: Row(
                          //               //     children: [
                          //               //       Text(
                          //               //         '$tot',
                          //               //         style: MindBloomingTextStyle
                          //               //             .pretitle,
                          //               //       ),
                          //               //       idx == 0
                          //               //           ? Text(
                          //               //               tot == 1
                          //               //                   ? ' modulo'
                          //               //                   : ' moduli',
                          //               //               style:
                          //               //                   MindBloomingTextStyle
                          //               //                       .pretitle,
                          //               //             )
                          //               //           : Text(
                          //               //               tot == 1
                          //               //                   ? ' domanda'
                          //               //                   : ' domande',
                          //               //               style:
                          //               //                   MindBloomingTextStyle
                          //               //                       .pretitle,
                          //               //             ),
                          //               //     ],
                          //               //   ),
                          //               // ),
                          //               // Padding(
                          //               //   padding:
                          //               //       const EdgeInsets.only(top: 5.0),
                          //               //   child: (done || current)
                          //               //       ? ClipRRect(
                          //               //           borderRadius:
                          //               //               BorderRadius.circular(
                          //               //             50,
                          //               //           ),
                          //               //           child: Container(
                          //               //             decoration: BoxDecoration(
                          //               //               borderRadius:
                          //               //                   BorderRadius.circular(
                          //               //                 50,
                          //               //               ),
                          //               //               border: Border.all(
                          //               //                 color:
                          //               //                     MindBloomingColorScheme
                          //               //                         .dialogBg,
                          //               //                 width: 0.5,
                          //               //               ),
                          //               //             ),
                          //               //             child:
                          //               //                 LinearProgressIndicator(
                          //               //               value: ans / tot,
                          //               //               color: done
                          //               //                   ? MindBloomingColorScheme
                          //               //                       .secondary
                          //               //                   : MindBloomingColorScheme
                          //               //                       .tertiary,
                          //               //               minHeight: 5,
                          //               //             ),
                          //               //           ),
                          //               //         )
                          //               //       : null,
                          //               // ),
                          //             ],
                          //           ),
                          //         ),
                          //       ),
                          //       Padding(
                          //         padding: const EdgeInsets.only(right: 20),
                          //         child: (done || current)
                          //             ? Padding(
                          //                 padding: const EdgeInsets.only(
                          //                   left: 4.0,
                          //                 ),
                          //                 child: SvgPicture.asset(
                          //                   'assets/icon_right_arrow.svg',
                          //                 ),
                          //               )
                          //             : null,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // borderRadius: BorderRadius.circular(20),
                          // splashColor: done
                          //     ? MindBloomingColorScheme.secondary4shadow
                          //     : MindBloomingColorScheme.tertiary,
                          // highlightColor: Colors.transparent,
                          onTap: (done || current)
                              ? () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => QuestionsScreen(
                                        // Il terzo parametro, il contesto, serve nello screening
                                        onDone: (surveyName, blockName, _) {
                                          pp.addDoneBlock(
                                            surveyName,
                                            blockName,
                                          );
                                        },
                                        surveyName: surveyName,
                                        blockName: block.key,
                                        buttonText: "Indietro",
                                        title: qp.getBlockPrettyName(
                                          surveyName,
                                          "survey_root_name",
                                        ),
                                        subtitle: qp.getBlockPrettyName(
                                          surveyName,
                                          block.key,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              : null,
                        ),
                      ),
                      node: TimelineNode(
                        // indicator: Padding(
                        //   padding: const EdgeInsets.symmetric(vertical: 5),
                        //   child: SvgPicture.asset(
                        //     pic,
                        //     width: MindBloomingTextStyle.returnMobile()
                        //         ? 15.sp
                        //         : (MindBloomingTextStyle.returnDesktop()
                        //             ? 9.sp
                        //             : 14.sp),
                        //   ),
                        // ),
                        startConnector: idx != 0
                            ? DashedLineConnector(
                                dash: 4,
                                gap: 2,
                                color: done
                                    ? MindBloomingColorScheme.secondary2shadow
                                    : current
                                        ? MindBloomingColorScheme
                                            .tertiary2shadow
                                        : MindBloomingColorScheme
                                            .primary2shadow,
                              )
                            : null,
                        endConnector: idx != blocks.length - 1
                            ? DashedLineConnector(
                                dash: 4,
                                gap: 2,
                                color: beforeCurrent
                                    ? MindBloomingColorScheme.tertiary2shadow
                                    : done
                                        ? MindBloomingColorScheme
                                            .secondary2shadow
                                        : MindBloomingColorScheme
                                            .primary2shadow,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),

      // SliverPadding(
      //   padding: const EdgeInsets.all(8.0),
      //   sliver: SliverList(
      //     delegate: SliverChildBuilderDelegate(
      //       (context, index) {
      //         return ListTile(
      //           onTap: (index == 0 ||
      //                   progress.isDoneBlock(
      //                     surveyName,
      //                     blocks.keys.elementAt(
      //                       index - 1,
      //                     ),
      //                   ))
      //               ? () {
      //                   Navigator.of(context).push(
      //                     MaterialPageRoute(
      //                       builder: (context) => QuestionsScreen(
      //                         onDone: progress.addDoneBlock,
      //                         surveyName: surveyName,
      //                         blockName: blocks.keys.elementAt(index),
      //                         disabled: widget.disabled,
      //                         buttonText: 'torna agli Esercizi',
      //                       ),
      //                     ),
      //                   );
      //                 }
      //               : () {
      //                   ScaffoldMessenger.of(context).showSnackBar(
      //                     const SnackBar(
      //                       content: Text(
      //                         "Per favore completa il modulo precedente prima di procedere",
      //                       ),
      //                     ),
      //                   );
      //                 },
      //           title: Text(
      //             qProvider.names[surveyName][blocks.keys.toList()[index]],
      //           ),
      //           leading: Column(
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             children: [
      //               Container(
      //                 padding: EdgeInsets.only(right: 12.0),
      //                 child: progress.isDoneBlock(
      //                         surveyName, blocks.keys.elementAt(index))
      //                     ? Icon(Icons.inventory_rounded,
      //                         color: Colors.green)
      //                     : (index == 0 ||
      //                             progress.isDoneBlock(surveyName,
      //                                 blocks.keys.elementAt(index - 1)))
      //                         ? Icon(
      //                             Icons.assignment_late_outlined,
      //                             color: Colors.amber,
      //                           )
      //                         : Icon(
      //                             Icons.assignment_outlined,
      //                             color: Colors.grey,
      //                           ),
      //               ),
      //             ],
      //           ),
      //           trailing: Icon(Icons.keyboard_arrow_right),
      //           subtitle: Row(
      //             children: [
      //               Text(
      //                   '${blocks.values.elementAt(index)['questions'].length}'),
      //               blocks.values.elementAt(index)['questions'].length == 1
      //                   ? Text(' domanda')
      //                   : Text(' domande')
      //             ],
      //           ),
      //         );
      //       },
      //       childCount: blocks.length,
      //     ),
      //   ),
      // ),
    );
  }
}
