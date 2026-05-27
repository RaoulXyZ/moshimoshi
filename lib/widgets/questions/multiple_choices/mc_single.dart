import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utility/mindblooming_color_scheme.dart';
import '../../../providers/answers.dart';
import '../question_text.dart';
import './multiplechoice_optional_text_entry.dart';

class MCSingle extends StatefulWidget {
  final String questionText;
  final Map<String, dynamic> choices;
  final String surveyID;
  final String blockID;
  final String questionID;
  final bool disabled;
  final Map<dynamic, dynamic> recodeValues;

  MCSingle({
    required this.questionText,
    required this.choices,
    required this.surveyID,
    required this.blockID,
    required this.questionID,
    required this.disabled,
    required this.recodeValues,
  }) : super(key: Key(questionID));

  @override
  _MCSingleState createState() => _MCSingleState();
}

class _MCSingleState extends State<MCSingle> {
  late String _selectedChoice;

  @override
  void initState() {
    super.initState();
    final answers = Provider.of<Answers>(context, listen: false);
    final stored = answers.getAnswer(widget.surveyID, widget.questionID);
    String initialKey = "";

    if (stored != null && widget.recodeValues.isNotEmpty) {
      // cerco la key il cui valore ricodificato è uguale a stored
      widget.recodeValues.forEach((k, v) {
        if (v.toString() == stored.toString()) initialKey = k;
      });
    } else if (stored != null) {
      initialKey = stored.toString();
    }

    _selectedChoice = initialKey;
    log('Initial selected for ${widget.questionID}: $_selectedChoice');
  }

  @override
  Widget build(BuildContext context) {
    final answers = Provider.of<Answers>(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: answers.isWrong(widget.questionID)
            ? Colors.red.shade100
            : Colors.white.withValues(alpha: 0),
      ),
      child: Column(
        children: [
          QuestionText(
            questionText: widget.questionText,
            surveyID: widget.surveyID,
            blockID: widget.blockID,
            questionID: widget.questionID,
          ),
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 30.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: MindBloomingColorScheme.primary1shadow,
              border: Border.all(
                color: MindBloomingColorScheme.primary3shadow,
                width: 0.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  ...widget.choices.entries.map(
                    (choice) => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 20,
                      ),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          minimumSize: Size.zero,
                          foregroundColor: MindBloomingColorScheme.secondary,
                        ),
                        onPressed: widget.disabled
                            ? null
                            : () {
                                if (_selectedChoice == choice.key) {
                                  if (choice.value.containsKey('TextEntry')) {
                                    answers.removeAnswer(
                                      widget.surveyID,
                                      "${widget.questionID}_${choice.key}_TEXT",
                                    );
                                  }
                                  log('Deselected choice: ${choice.key}');
                                  _selectedChoice = '';
                                  answers.removeAnswer(
                                    widget.surveyID,
                                    widget.questionID,
                                  );
                                } else {
                                  if (widget.choices
                                      .containsKey(_selectedChoice)) {
                                    if (widget.choices[_selectedChoice]
                                        .containsKey('TextEntry')) {
                                      answers.removeAnswer(
                                        widget.surveyID,
                                        "${widget.questionID}_${_selectedChoice}_TEXT",
                                      );
                                    }
                                  }

                                  final recodedChoice =
                                      widget.recodeValues.isNotEmpty
                                          ? widget.recodeValues[choice.key]
                                              .toString()
                                          : choice.key;

                                  log('Selected choice: ${recodedChoice}');
                                  _selectedChoice = choice.key;
                                  answers.addAnswer(
                                    widget.surveyID,
                                    widget.questionID,
                                    int.parse(recodedChoice),
                                  );
                                }
                              },
                        child: Ink(
                          decoration: BoxDecoration(
                            color: _selectedChoice == choice.key
                                ? MindBloomingColorScheme.secondary2shadow
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: 20,
                                      width: 20,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        border: Border.all(
                                          color: MindBloomingColorScheme
                                              .textColorDark1shadow,
                                          width: 1,
                                        ),
                                      ),
                                      child: Container(
                                        margin: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          color: _selectedChoice == choice.key
                                              ? MindBloomingColorScheme
                                                  .secondary
                                              : Colors.transparent,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 10.0,
                                          right: 8,
                                        ),
                                        child: CustomHtmlWidget(
                                          questionText: choice.value['Display'],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (choice.value.containsKey('Image')) ...{
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        'https://psicologiaunimib.qualtrics.com/CP/Graphic.php?IM=' +
                                            choice.value['Image']
                                                ['ImageLocation'],
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }

                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : 0,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                },
                                if (choice.value.containsKey('TextEntry')) ...{
                                  MultipleChoiceOptionalTextEntry(
                                    selected: _selectedChoice == choice.key,
                                    choice: choice,
                                    questionID: widget.questionID,
                                    surveyID: widget.surveyID,
                                    disabled: widget.disabled,
                                  ),
                                },
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(padding: const EdgeInsets.only(bottom: 20.0)),
        ],
      ),
    );
  }
}
