import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../providers/answers.dart';
import '../../../utility/mindblooming_color_scheme.dart';
import '../../../utility/mindblooming_text_style.dart';
import '../question_text.dart';

class ConstantSum extends StatefulWidget {
  final String questionText;
  final Map<String, dynamic> choices;
  final String surveyID;
  final String blockID;
  final String questionID;
  final bool disabled;

  ConstantSum({
    required this.questionText,
    required this.choices,
    required this.surveyID,
    required this.blockID,
    required this.questionID,
    required this.disabled,
  }) : super(key: Key(questionID));

  @override
  _ConstantSumState createState() => _ConstantSumState();
}

class _ConstantSumState extends State<ConstantSum> {
  @override
  Widget build(BuildContext context) {
    final aProvider = Provider.of<Answers>(context);
    int total = 0;
    widget.choices.forEach((key, value) {
      final answer =
          aProvider.getAnswer(widget.surveyID, "${widget.questionID}_$key");
      if (answer != null) {
        total += answer as int;
      }
    });

    return Column(
      children: [
        QuestionText(
          questionText: widget.questionText,
          surveyID: widget.surveyID,
          blockID: widget.blockID,
          questionID: widget.questionID,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: MindBloomingColorScheme.primary1shadow,
            border: Border.all(
              color: MindBloomingColorScheme.primary3shadow,
              width: 0.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(10),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: MindBloomingTextStyle.small.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$total',
                          style: MindBloomingTextStyle.small.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ...widget.choices.entries.map(
                  (choice) => CSChoice(
                    choice: choice,
                    questionID: widget.questionID,
                    surveyID: widget.surveyID,
                    disabled: widget.disabled,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
        ),
      ],
    );
  }
}

class CSChoice extends StatefulWidget {
  const CSChoice({
    super.key,
    required this.choice,
    required this.disabled,
    required this.questionID,
    required this.surveyID,
  });

  final MapEntry<String, dynamic> choice;
  final String questionID;
  final String surveyID;
  final bool disabled;

  @override
  State<CSChoice> createState() => _CSChoiceState();
}

class _CSChoiceState extends State<CSChoice> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final answers = Provider.of<Answers>(context, listen: false);
    final answer = answers.getAnswer(
      widget.surveyID,
      "${widget.questionID}_${widget.choice.key}",
    );
    if (answer != null) {
      _controller.text = answer.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final answers = Provider.of<Answers>(context);
    final value = widget.choice.value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomHtmlWidget(
                    questionText: value['Display'],
                  ),
                  if (value.containsKey('Image')) ...{
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        'https://psicologiaunimib.qualtrics.com/CP/Graphic.php?IM=' +
                            value['Image']['ImageLocation'],
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;

                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
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
                  },
                ],
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.2,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: TextField(
                controller: _controller,
                enabled: !widget.disabled,
                minLines: 1,
                maxLines: 1,
                keyboardType: TextInputType.number,
                style: MindBloomingTextStyle.normal,
                decoration: InputDecoration(
                  hintText: "...",
                  hintStyle: MindBloomingTextStyle.normal.copyWith(
                    color: MindBloomingColorScheme.textColorDark1shadow,
                  ),
                  border: InputBorder.none,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],

                onChanged: (value) {
                  if (value != '') {
                    answers.addAnswer(
                      widget.surveyID,
                      "${widget.questionID}_${widget.choice.key}",
                      int.parse(value),
                    );
                  } else {
                    answers.removeAnswer(
                      widget.surveyID,
                      "${widget.questionID}_${widget.choice.key}",
                    );
                  }
                },

                //controller: textController,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
