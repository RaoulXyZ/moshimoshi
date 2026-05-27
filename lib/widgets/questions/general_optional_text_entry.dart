import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/answers.dart';
import '../../utility/mindblooming_color_scheme.dart';
import '../../utility/mindblooming_text_style.dart';

class GeneralOptionalTextEntry extends StatefulWidget {
  final String questionID;
  final MapEntry<String, dynamic> choice;
  final EdgeInsets padding;
  final String surveyID;
  final bool disabled;

  const GeneralOptionalTextEntry({
    super.key,
    required this.questionID,
    required this.choice,
    required this.padding,
    required this.surveyID,
    required this.disabled,
  });

  @override
  _GeneralOptionalTextEntryState createState() =>
      _GeneralOptionalTextEntryState();
}

class _GeneralOptionalTextEntryState extends State<GeneralOptionalTextEntry> {
  final myController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final answers = Provider.of<Answers>(context, listen: false);
    myController.text = answers.getAnswer(
          widget.surveyID,
          "${widget.questionID}_${widget.choice.key}_TEXT",
        ) ??
        '';
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final answers = Provider.of<Answers>(context);
    // final value = widget.choice.value;

    return Container(
      margin: widget.padding,
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
          enabled: !widget.disabled,
          minLines: 1,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          style: MindBloomingTextStyle.normal,
          decoration: InputDecoration(
            hintText: "Inserisci la risposta...",
            hintStyle: MindBloomingTextStyle.normal.copyWith(
              color: MindBloomingColorScheme.textColorDark1shadow,
            ),
            border: InputBorder.none,
          ),
          onChanged: (value) => answers.addAnswer(
            widget.surveyID,
            "${widget.questionID}_${widget.choice.key}_TEXT",
            value,
          ),
          controller: myController,
        ),
      ),
    );
  }
}
