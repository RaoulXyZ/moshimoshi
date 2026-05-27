import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/answers.dart';
import '../../../utility/mindblooming_color_scheme.dart';
import '../../../utility/mindblooming_text_style.dart';
import '../question_text.dart';

class MCDropdown extends StatefulWidget {
  final String questionText;
  final Map<String, dynamic> choices;
  final String surveyID;
  final String blockID;
  final String questionID;
  final bool disabled;

  MCDropdown({
    required this.questionText,
    required this.choices,
    required this.surveyID,
    required this.blockID,
    required this.questionID,
    required this.disabled,
  }) : super(key: Key(questionID));

  @override
  _MCDropdownState createState() => _MCDropdownState();
}

class _MCDropdownState extends State<MCDropdown> {
  String? _selectedChoice;

  @override
  void initState() {
    super.initState();
    final answers = Provider.of<Answers>(context, listen: false);
    final qid = widget.questionID;
    final answer = answers.getAnswer(widget.surveyID, "$qid");
    if (answer != null) {
      _selectedChoice = "$answer";
    }
  }

  @override
  Widget build(BuildContext context) {
    final answers = Provider.of<Answers>(context);

    return Column(
      children: [
        QuestionText(
          questionText: widget.questionText,
          surveyID: widget.surveyID,
          blockID: widget.blockID,
          questionID: widget.questionID,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: MindBloomingColorScheme.primary1shadow,
            border: Border.all(
              color: MindBloomingColorScheme.primary3shadow,
              width: 0.5,
            ),
          ),
          child: Container(
            margin: const EdgeInsets.all(20),
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
                        ? widget.choices[_selectedChoice]['Display']
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
                        for (var i = 0; i < widget.choices.length; i++)
                          _textSize(
                                widget.choices.entries
                                    .elementAt(i)
                                    .value['Display'],
                                context,
                                140,
                              ).height +
                              20,
                      ],
                    ),
                    items: widget.choices.entries
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value['Display']),
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
                                widget.questionID,
                                int.parse(val),
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
        ),
      ],
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
