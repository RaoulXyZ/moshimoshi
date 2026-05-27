import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/answers.dart';
import '../../../utility/mindblooming_color_scheme.dart';
import '../question_text.dart';

class MatrixMaxDiff extends StatefulWidget {
  final String questionText;
  final Map<String, dynamic> choices;
  final Map<String, dynamic> answers;
  final String surveyID;
  final String blockID;
  final String questionID;
  final bool disabled;

  MatrixMaxDiff({
    required this.questionText,
    required this.choices,
    required this.answers,
    required this.surveyID,
    required this.blockID,
    required this.questionID,
    required this.disabled,
  }) : super(key: Key(questionID));

  @override
  _MatrixMaxDiffState createState() => _MatrixMaxDiffState();
}

class _MatrixMaxDiffState extends State<MatrixMaxDiff> {
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
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...widget.answers.entries.map(
                    (answer) => Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width / 2.4,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 20,
                        ),
                        child: Column(
                          children: [
                            CustomHtmlWidget(
                              questionText: answer.value['Display'],
                            ),
                            if (answer.value.containsKey('Image')) ...{
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    'https://psicologiaunimib.qualtrics.com/CP/Graphic.php?IM=' +
                                        answer.value['Image']['ImageLocation'],
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;

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
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            },
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  children: [
                    ...widget.choices.entries.map(
                      (choice) => Column(
                        children: [
                          const Divider(),
                          CustomRadio(
                            answers: widget.answers,
                            choice: choice,
                            questionID: widget.questionID,
                            surveyID: widget.surveyID,
                            disabled: widget.disabled,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Padding(padding: const EdgeInsets.only(bottom: 20.0)),
      ],
    );
  }
}

class CustomRadio extends StatefulWidget {
  final Map<String, dynamic> answers;
  final MapEntry<String, dynamic> choice;
  final String questionID;
  final String surveyID;
  final bool disabled;

  CustomRadio({
    super.key,
    required this.answers,
    required this.choice,
    required this.questionID,
    required this.surveyID,
    required this.disabled,
  });

  @override
  _CustomRadioState createState() => _CustomRadioState();
}

class _CustomRadioState extends State<CustomRadio> {
  late String _selectedChoice;

  @override
  void initState() {
    super.initState();
    final answers = Provider.of<Answers>(context, listen: false);
    final qid = widget.questionID;
    final cid = widget.choice.key;
    _selectedChoice =
        "${answers.getAnswer(widget.surveyID, "${qid}_$cid") ?? ''}";
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minimumSize: Size.zero,
              foregroundColor: MindBloomingColorScheme.secondary,
            ),
            child: Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: MindBloomingColorScheme.textColorDark1shadow,
                  width: 1,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: _selectedChoice == '1'
                      ? MindBloomingColorScheme.secondary
                      : Colors.transparent,
                ),
              ),
            ),
            onPressed: widget.disabled
                ? null
                : () {
                    _selectedChoice = '1';
                    answers.addAnswer(
                      widget.surveyID,
                      "${widget.questionID}_${widget.choice.key}",
                      int.parse(_selectedChoice),
                    );
                  },
          ),
          Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Column(
                  children: [
                    Center(
                      child: CustomHtmlWidget(
                        questionText: value['Display'],
                      ),
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
            ],
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minimumSize: Size.zero,
              foregroundColor: MindBloomingColorScheme.secondary,
            ),
            child: Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: MindBloomingColorScheme.textColorDark1shadow,
                  width: 1,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: _selectedChoice == '2'
                      ? MindBloomingColorScheme.secondary
                      : Colors.transparent,
                ),
              ),
            ),
            onPressed: widget.disabled
                ? null
                : () {
                    _selectedChoice = '2';
                    answers.addAnswer(
                      widget.surveyID,
                      "${widget.questionID}_${widget.choice.key}",
                      int.parse(_selectedChoice),
                    );
                  },
          ),
        ],
      ),
    );
  }
}
