import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/answers.dart';
import '../../../utility/mindblooming_color_scheme.dart';
import '../../../utility/mindblooming_text_style.dart';
import '../general_optional_text_entry.dart';
import '../question_text.dart';

class MatrixProfileDropdown extends StatefulWidget {
  final String questionText;
  final Map<String, dynamic> choices;
  final Map<String, dynamic> answers;
  final String surveyID;
  final String blockID;
  final String questionID;
  final bool disabled;

  MatrixProfileDropdown({
    required this.questionText,
    required this.choices,
    required this.answers,
    required this.surveyID,
    required this.blockID,
    required this.questionID,
    required this.disabled,
  }) : super(key: Key(questionID));

  @override
  _MatrixProfileDropdownState createState() => _MatrixProfileDropdownState();
}

class _MatrixProfileDropdownState extends State<MatrixProfileDropdown> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QuestionText(
          questionText: widget.questionText,
          surveyID: widget.surveyID,
          blockID: widget.blockID,
          questionID: widget.questionID,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              ...widget.choices.entries.map(
                (choice) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: MindBloomingColorScheme.primary1shadow,
                    border: Border.all(
                      color: MindBloomingColorScheme.primary3shadow,
                      width: 0.5,
                    ),
                  ),
                  child: Risposte(
                    choice,
                    Map<String, dynamic>.from(widget.answers[choice.key]),
                    widget.questionID,
                    widget.surveyID,
                    widget.disabled,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Padding(padding: const EdgeInsets.only(bottom: 10.0)),
      ],
    );
  }
}

class Risposte extends StatefulWidget {
  final MapEntry<String, dynamic> choice;
  final Map<String, dynamic> answers;
  final String questionID;
  final String surveyID;
  final bool disabled;

  Risposte(
    this.choice,
    this.answers,
    this.questionID,
    this.surveyID,
    this.disabled,
  );
  @override
  _RisposteState createState() => _RisposteState();
}

class _RisposteState extends State<Risposte> {
  bool expanded = false;
  String? _selectedChoice;

  @override
  void initState() {
    super.initState();
    final answers = Provider.of<Answers>(context, listen: false);
    final qid = widget.questionID;
    final cid = widget.choice.key;
    final answer = answers.getAnswer(widget.surveyID, "${qid}_$cid");
    if (answer != null) {
      _selectedChoice = answer.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final answers = Provider.of<Answers>(context);
    final value = widget.choice.value;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4.0,
        horizontal: 20,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
              bottom: 16,
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                        right: 10,
                        top: 5.5,
                      ),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: answers.hasAnswerChoice(
                          widget.surveyID,
                          widget.questionID,
                          widget.choice.key,
                        )
                            ? MindBloomingColorScheme.secondary
                            : MindBloomingColorScheme.tertiary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    Expanded(
                      child: CustomHtmlWidget(
                        questionText: value['Display'],
                      ),
                    ),
                  ],
                ),
                if (value.containsKey('Image')) ...{
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        'https://psicologiaunimib.qualtrics.com/CP/Graphic.php?IM=' +
                            value['Image']['ImageLocation'],
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                },
                if (value.containsKey('TextEntry')) ...{
                  GeneralOptionalTextEntry(
                    choice: widget.choice,
                    questionID: widget.questionID,
                    padding: const EdgeInsets.only(
                      top: 8,
                    ),
                    surveyID: widget.surveyID,
                    disabled: widget.disabled,
                  ),
                },
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                const BoxShadow(
                  color: Color.fromARGB(64, 9, 23, 18),
                ),
                const BoxShadow(
                  color: Color.fromARGB(64, 9, 23, 18),
                  spreadRadius: -0.1,
                  blurStyle: BlurStyle.inner,
                  blurRadius: 2,
                  offset: Offset(1, 1),
                ),
                const BoxShadow(
                  color: MindBloomingColorScheme.primary,
                  spreadRadius: -0.1,
                  blurRadius: 2,
                  offset: Offset(1, 1),
                ),
              ],
            ),
            child: SizedBox(
              height: _textSize(
                    _selectedChoice != null
                        ? widget.answers[_selectedChoice]['Display']
                        : " ",
                    context,
                    170,
                  ).height +
                  28,
              child: DropdownButtonHideUnderline(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: DropdownButton2(
                    isDense: true,
                    style: MindBloomingTextStyle.normal,
                    menuItemStyleData: MenuItemStyleData(
                      customHeights: [
                        for (var i = 0; i < widget.answers.length; i++)
                          _textSize(
                                widget.answers.entries
                                    .elementAt(i)
                                    .value['Display'],
                                context,
                                140,
                              ).height +
                              20,
                      ],
                    ),
                    items: widget.answers.entries
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(
                              e.value['Display'],
                              style: MindBloomingTextStyle.normal,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: widget.disabled
                        ? null
                        : (String? val) {
                            if (val != null) {
                              _selectedChoice = val;
                              answers.addAnswer(
                                widget.surveyID,
                                "${widget.questionID}_${widget.choice.key}",
                                int.parse(_selectedChoice!),
                              );
                            }
                          },
                    value: _selectedChoice,
                    iconStyleData: const IconStyleData(
                      icon: Icon(
                        Icons.expand_more,
                      ),
                    ),
                    isExpanded: true,
                  ),
                ),
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.only(bottom: 8.0)),
        ],
      ),
    );
  }
}

Size _textSize(String text, context, int offset) {
  return (TextPainter(
    text: TextSpan(text: text, style: MindBloomingTextStyle.normal),
    textScaler: MediaQuery.of(context).textScaler,
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: MediaQuery.of(context).size.width - offset))
      .size;
}
