import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/answers.dart';
import '../../../utility/mindblooming_color_scheme.dart';
import '../question_text.dart';
import 'multiplechoice_optional_text_entry.dart';

class MCMultiple extends StatefulWidget {
  final String questionText;
  final Map<String, dynamic> choices;
  final String surveyID;
  final String blockID;
  final String questionID;
  final bool disabled;

  MCMultiple({
    required this.choices,
    required this.questionText,
    required this.surveyID,
    required this.blockID,
    required this.questionID,
    required this.disabled,
  }) : super(key: Key(questionID));

  @override
  _MCMultipleState createState() => _MCMultipleState();
}

class _MCMultipleState extends State<MCMultiple> {
  List<String> _selectedChoices = [];

  @override
  void initState() {
    super.initState();

    final answers = Provider.of<Answers>(context, listen: false);
    _selectedChoices =
        answers.getAnswer(widget.surveyID, widget.questionID) ?? [];
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
                    (choice) {
                      final bool cnts = _selectedChoices.contains(choice.key);

                      return Padding(
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
                                  {
                                    if (cnts) {
                                      _selectedChoices.remove(choice.key);
                                      answers.removeAnswer(
                                        widget.surveyID,
                                        "${widget.questionID}_${choice.key}_TEXT",
                                      );
                                    } else {
                                      _selectedChoices.add(choice.key);
                                    }

                                    if (_selectedChoices.isEmpty) {
                                      answers.removeAnswer(
                                        widget.surveyID,
                                        "${widget.questionID}_${choice.key}_TEXT",
                                      );
                                    } else {
                                      answers.addAnswer(
                                        widget.surveyID,
                                        widget.questionID,
                                        _selectedChoices,
                                      );
                                    }
                                  }
                                },
                          child: Ink(
                            decoration: BoxDecoration(
                              color: cnts
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
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
                                                BorderRadius.circular(2.5),
                                            color: _selectedChoices
                                                    .contains(choice.key)
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
                                            questionText:
                                                choice.value['Display'],
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
                                          loadingBuilder: (
                                            context,
                                            child,
                                            loadingProgress,
                                          ) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
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
                                  if (choice.value
                                      .containsKey('TextEntry')) ...{
                                    MultipleChoiceOptionalTextEntry(
                                      selected: cnts,
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
                      );
                    },
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
