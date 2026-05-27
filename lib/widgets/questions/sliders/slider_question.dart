import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/answers.dart';
import '../../../utility/mindblooming_text_style.dart';
import '../../../utility/mindblooming_color_scheme.dart';
import '../general_optional_text_entry.dart';
import '../question_text.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

class SliderQuestion extends StatefulWidget {
  final String questionText;
  final Map<String, dynamic> choices;
  final int maxValue;
  final int minValue;
  final Map<String, dynamic> startPostion;
  final int divisions;
  final List<String> labels;
  final String surveyID;
  final String blockID;
  final String questionID;
  final bool disabled;

  SliderQuestion({
    required this.questionText,
    required this.choices,
    required this.maxValue,
    required this.minValue,
    required this.startPostion,
    required this.divisions,
    required this.labels,
    required this.surveyID,
    required this.blockID,
    required this.questionID,
    required this.disabled,
  }) : super(key: Key(questionID));

  @override
  _SliderQuestionState createState() => _SliderQuestionState();
}

class _SliderQuestionState extends State<SliderQuestion> {
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
          child: Column(
            children: [
              ...widget.choices.entries.map(
                (choice) => Column(
                  children: [
                    CustomSlider(
                      choice: choice,
                      max: widget.maxValue,
                      min: widget.minValue,
                      startPosition: widget.startPostion.isEmpty
                          ? 0.0
                          : widget.startPostion[choice.key].toDouble(),
                      divisions: widget.divisions,
                      labels: widget.labels,
                      questionID: widget.questionID,
                      surveyID: widget.surveyID,
                      disabled: widget.disabled,
                    ),
                    // if (widget.choices.length > 1 &&
                    //     choice.key != widget.choices.entries.last.key)
                    //   const Divider(),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }
}

class CustomSliderThumbCircle extends SliderComponentShape {
  final double thumbRadius;
  final int min;
  final int max;

  const CustomSliderThumbCircle({
    required this.thumbRadius,
    this.min = 0,
    this.max = 100,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final TextSpan span = TextSpan(
      style: TextStyle(
        fontSize: thumbRadius * .8,
        fontWeight: FontWeight.w700,
        color: sliderTheme.thumbColor,
      ),
      text: getValue(value),
    );

    final TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    final Offset textCenter =
        Offset(center.dx - (tp.width / 2), center.dy - (tp.height / 2));

    canvas.drawCircle(center, thumbRadius * .9, paint);
    tp.paint(canvas, textCenter);
  }

  String getValue(double value) {
    return (min + (max - min) * value).round().toString();
  }
}

class CustomSlider extends StatefulWidget {
  final MapEntry<String, dynamic> choice;
  final int min;
  final int max;
  final double startPosition;
  final int divisions;
  final List<String> labels;
  final String questionID;
  final String surveyID;
  final bool disabled;

  CustomSlider({
    required this.choice,
    required this.max,
    required this.min,
    required this.startPosition,
    required this.divisions,
    required this.labels,
    required this.questionID,
    required this.surveyID,
    required this.disabled,
  }) : super(key: Key(questionID));

  @override
  _CustomSliderState createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  late double sliderValue;

  /// True dopo la prima interazione dell’utente (drag/click sullo slider).
  bool _hasInteracted = false;

  double _snapToDivisions(double v) {
    final min = widget.min.toDouble();
    final max = widget.max.toDouble();
    if (widget.divisions <= 0 || max <= min) return v.clamp(min, max);

    final step = (max - min) / widget.divisions;
    final snapped = (((v - min) / step).round() * step) + min;

    return snapped.clamp(min, max);
  }

  double _computeInitialValue() {
    // startPosition passato al widget è già una frazione [0..1] nelle tue chiamate.
    final fraction =
        widget.startPosition.isNaN ? 0.0 : widget.startPosition.clamp(0.0, 1.0);
    final raw = widget.min + fraction * (widget.max - widget.min);

    return _snapToDivisions(raw);
  }

  @override
  void initState() {
    super.initState();

    final answers = Provider.of<Answers>(context, listen: false);
    final key = "${widget.questionID}_${widget.choice.key}";
    final saved = answers.getAnswer(widget.surveyID, key);

    if (saved == null) {
      // UI alla posizione iniziale ma NON salvo la risposta.
      sliderValue = _computeInitialValue();
      _hasInteracted = false;
      debugPrint(
        "[Slider] init | survey=${widget.surveyID} q=${widget.questionID} choice=${widget.choice.key} "
        "saved=null -> UI at start=${sliderValue.toStringAsFixed(2)} (NOT answered)",
      );
    } else {
      // C’era già una risposta (es. tornando indietro): allineo UI e considero answered.
      sliderValue = (saved is num ? saved.toDouble() : widget.min.toDouble())
          .clamp(widget.min.toDouble(), widget.max.toDouble());
      _hasInteracted = true;
      debugPrint(
        "[Slider] init | survey=${widget.surveyID} q=${widget.questionID} choice=${widget.choice.key} "
        "saved=${sliderValue.round()} -> UI aligned (answered)",
      );
    }
  }

  void _persistAnswer() {
    if (widget.disabled) {
      debugPrint(
        "[Slider] persist skipped (disabled) | survey=${widget.surveyID} q=${widget.questionID} choice=${widget.choice.key}",
      );

      return;
    }
    final key = "${widget.questionID}_${widget.choice.key}";
    Provider.of<Answers>(context, listen: false).addAnswer(
      widget.surveyID,
      key,
      sliderValue.toInt(),
    );
    debugPrint(
      "[Slider] persisted | survey=${widget.surveyID} q=${widget.questionID} choice=${widget.choice.key} "
      "value=${sliderValue.toInt()}",
    );
  }

  @override
  Widget build(BuildContext context) {
    final answers = Provider.of<Answers>(context);
    final value = widget.choice.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.center, // ✅ allineamento verticale
            children: [
              Container(
                margin: const EdgeInsets.only(
                  right: 10,
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
        ),
        if (value.containsKey('Image')) ...{
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 8,
            ),
            child: ClipRRect(
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
                        value: loadingProgress.expectedTotalBytes != null
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
              left: 16,
              right: 16,
            ),
            surveyID: widget.surveyID,
            disabled: widget.disabled,
          ),
        },
        if (widget.labels.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 48.0, right: 48.0, top: 8.0),
            child: Row(
              children: List.generate(widget.labels.length, (i) {
                final isFirst = i == 0;
                final isLast = i == widget.labels.length - 1;

                final align = isFirst
                    ? Alignment.centerLeft
                    : isLast
                        ? Alignment.centerRight
                        : Alignment.center;

                final textAlign = isFirst
                    ? 'left'
                    : isLast
                        ? 'right'
                        : 'center';

                return Expanded(
                  child: Align(
                    alignment: align,
                    child: HtmlWidget(
                      '<div style="text-align:$textAlign">${widget.labels[i]}</div>',
                      textStyle: MindBloomingTextStyle.small
                          .copyWith(color: Colors.grey),
                    ),
                  ),
                );
              }),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(left: 40, right: 40, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.min.toString(),
                textAlign: TextAlign.center,
                style: MindBloomingTextStyle.subtitle,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      // Optional: look “neutro” finché non c'è interazione
                      activeTrackColor: _hasInteracted
                          ? MindBloomingColorScheme.secondary4shadow
                          : MindBloomingColorScheme.secondary2shadow,
                      inactiveTrackColor:
                          MindBloomingColorScheme.secondary2shadow,
                      trackShape: CustomTrackShape(),
                      trackHeight: 8.0,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 8),
                      tickMarkShape: const RoundSliderTickMarkShape(),
                      thumbColor: _hasInteracted
                          ? MindBloomingColorScheme.secondary5shadow
                          : MindBloomingColorScheme.secondary3shadow,
                      valueIndicatorShape:
                          const PaddleSliderValueIndicatorShape(),
                      valueIndicatorTextStyle:
                          const TextStyle(color: Colors.white),
                    ),
                    child: Slider(
                      value: sliderValue,
                      min: widget.min.toDouble(),
                      max: widget.max.toDouble(),
                      divisions: widget.divisions,
                      label: sliderValue.round().toString(),
                      onChangeStart: widget.disabled
                          ? null
                          : (_) {
                              if (!_hasInteracted) {
                                setState(() => _hasInteracted = true);
                                debugPrint(
                                  "[Slider] first interaction | survey=${widget.surveyID} q=${widget.questionID} choice=${widget.choice.key}",
                                );
                              }
                            },
                      onChanged: widget.disabled
                          ? null
                          : (val) {
                              final snapped = _snapToDivisions(val);
                              if (snapped != sliderValue) {
                                setState(() => sliderValue = snapped);
                                debugPrint(
                                  "[Slider] change | survey=${widget.surveyID} q=${widget.questionID} choice=${widget.choice.key} "
                                  "value=${sliderValue.toInt()}",
                                );
                              }
                            },
                      onChangeEnd: widget.disabled
                          ? null
                          : (_) {
                              _persistAnswer();
                            },
                    ),
                  ),
                ),
              ),
              Text(
                widget.max.toString(),
                textAlign: TextAlign.center,
                style: MindBloomingTextStyle.subtitle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    additionalActiveTrackHeight = 0;

    super.paint(
      context,
      offset,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      enableAnimation: enableAnimation,
      textDirection: textDirection,
      thumbCenter: thumbCenter,
      additionalActiveTrackHeight: additionalActiveTrackHeight,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
      secondaryOffset: secondaryOffset,
    );
  }

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight!) / 2;
    final trackWidth = parentBox.size.width;

    return Rect.fromLTWH(
      trackLeft,
      trackTop,
      trackWidth,
      trackHeight,
    );
  }
}
