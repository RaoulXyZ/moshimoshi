import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/answers.dart';
import '../../../utility/mindblooming_color_scheme.dart';
import '../../../utility/mindblooming_text_style.dart';

class MultipleChoiceOptionalTextEntry extends StatefulWidget {
  final String questionID;
  final String surveyID;
  final bool selected;
  final MapEntry<String, dynamic> choice;
  final bool disabled;

  MultipleChoiceOptionalTextEntry({
    required this.surveyID,
    required this.questionID,
    required this.selected,
    required this.choice,
    required this.disabled,
  }) : super(key: Key(questionID));

  @override
  _MultipleChoiceOptionalTextEntryState createState() =>
      _MultipleChoiceOptionalTextEntryState();
}

class _MultipleChoiceOptionalTextEntryState
    extends State<MultipleChoiceOptionalTextEntry> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    // preload eventuale testo salvato
    final answers = Provider.of<Answers>(context, listen: false);
    _controller.text = answers.getAnswer(
          widget.surveyID,
          "${widget.questionID}_${widget.choice.key}_TEXT",
        ) ??
        "";

    // quando il campo prende/perde focus, aggiorno la UI (per lo stato visivo)
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(covariant MultipleChoiceOptionalTextEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se l'opzione diventa selezionata, sincronizzo lo stato corrente in modo silenzioso
    // (senza side-effect in build)
    if (widget.selected && !widget.disabled) {
      Provider.of<Answers>(context, listen: false).addAnswerSilently(
        widget.surveyID,
        "${widget.questionID}_${widget.choice.key}_TEXT",
        _controller.text,
      );
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  // Calcola minLines di base in funzione di TextEntrySize e permette auto-grow oltre
  int get _minLines {
    final value = widget.choice.value;
    if (value is Map && value.containsKey('TextEntrySize')) {
      switch (value['TextEntrySize']) {
        case 'Large':
          return 3;
        case 'Medium':
          return 2;
        default:
          return 1;
      }
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final enabled = !widget.disabled && widget.selected;
    final radius = BorderRadius.circular(10);

    // Ombre coerenti (niente doppi inner-shadow che “sporcano” il bordo).
    const baseShadows = <BoxShadow>[
      BoxShadow(
        color: const Color.fromARGB(28, 0, 0, 0),
        blurRadius: 8,
        spreadRadius: 1,
        offset: const Offset(0, 2),
      ),
    ];

    const hoverShadows = <BoxShadow>[
      BoxShadow(
        color: const Color.fromARGB(40, 0, 0, 0),
        blurRadius: 8,
        spreadRadius: 1,
        offset: const Offset(0, 2),
      ),
    ];

    final focusedBorderColor = MindBloomingColorScheme.secondary;
    final idleBorderColor = MindBloomingColorScheme.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color:
              enabled ? Colors.white : MindBloomingColorScheme.primary1shadow,
          borderRadius: radius,
          border: Border.all(
            width: _focusNode.hasFocus ? 1.5 : 1,
            color: _focusNode.hasFocus ? focusedBorderColor : idleBorderColor,
          ),
          boxShadow:
              _hovering || _focusNode.hasFocus ? hoverShadows : baseShadows,
        ),
        child: ClipRRect(
          borderRadius: radius, // assicura che hover/focus seguano il raggio
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: enabled,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              // --- AUTO-GROW ---
              minLines: _minLines,
              maxLines: null, // <- permette la crescita verticale illimitata
              // ---------------

              style: MindBloomingTextStyle.normal.copyWith(
                color: enabled
                    ? MindBloomingColorScheme.textColorDark
                    : MindBloomingColorScheme.textColorDark1shadow,
              ),
              decoration: InputDecoration(
                hintText: "Inserisci la risposta...",
                hintStyle: MindBloomingTextStyle.normal.copyWith(
                  color: MindBloomingColorScheme.textColorDark1shadow,
                ),
                isDense: true,
                border: InputBorder.none,
              ),
              onChanged: (text) {
                // salva solo se l'opzione è selezionata
                if (enabled) {
                  Provider.of<Answers>(context, listen: false).addAnswer(
                    widget.surveyID,
                    "${widget.questionID}_${widget.choice.key}_TEXT",
                    text,
                  );
                }
                // se non è selezionata, non persisto (niente “sporcare” le risposte)
              },
            ),
          ),
        ),
      ),
    );
  }
}
