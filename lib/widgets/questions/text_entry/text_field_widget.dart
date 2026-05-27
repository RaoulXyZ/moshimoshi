import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/answers.dart';
import '../../../utility/mindblooming_color_scheme.dart';
import '../../../utility/mindblooming_text_style.dart';

class TextFieldWidget extends StatefulWidget {
  final String questionText;
  final String questionID;
  final String? label;
  final String surveyID;
  final bool disabled;

  TextFieldWidget({
    required this.questionText,
    required this.questionID,
    required this.surveyID,
    required this.disabled,
    this.label,
  });

  @override
  _TextFieldWidgetState createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final answers = Provider.of<Answers>(context, listen: false);
    textController.text = answers.getAnswer(
          widget.surveyID,
          "${widget.questionID}_TEXT",
        ) ??
        "";
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final answers = Provider.of<Answers>(context);

    return Container(
      margin: const EdgeInsets.only(
        bottom: 20.0,
        left: 30,
        right: 30,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: MindBloomingColorScheme.primary1shadow,
        border: Border.all(
          color: MindBloomingColorScheme.primary3shadow,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text(
                widget.label!,
                style: MindBloomingTextStyle.normal,
              ),
            )
          else
            const Padding(padding: const EdgeInsets.only(top: 16)),
          Container(
            margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
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
                maxLines: null,
                minLines: 1,
                enabled: !widget.disabled,
                decoration: InputDecoration(
                  hintText: "Inserisci la risposta...",
                  hintStyle: MindBloomingTextStyle.normal.copyWith(
                    color: MindBloomingColorScheme.textColorDark1shadow,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  if (value != "") {
                    answers.addAnswer(
                      widget.surveyID,
                      "${widget.questionID}_TEXT",
                      value,
                    );
                  } else {
                    answers.removeAnswer(
                      widget.surveyID,
                      "${widget.questionID}_TEXT",
                    );
                  }
                },
                controller: textController,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
