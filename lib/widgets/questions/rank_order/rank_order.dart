import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utility/mindblooming_color_scheme.dart';
import '../../../utility/mindblooming_text_style.dart';
import '../../../providers/answers.dart';
import '../question_text.dart';
import '../general_optional_text_entry.dart';

class RankOrder extends StatefulWidget {
  final String questionText;
  final Map<String, dynamic> choices;
  final String surveyID;
  final String blockID;
  final String questionID;
  final bool disabled;

  RankOrder({
    required this.questionText,
    required this.choices,
    required this.surveyID,
    required this.blockID,
    required this.questionID,
    required this.disabled,
  }) : super(key: Key(questionID));

  @override
  _RankOrder createState() => _RankOrder();
}

class _RankOrder extends State<RankOrder> {
  late List<MapEntry<String, dynamic>> _items;

  @override
  void initState() {
    super.initState();
    _items = List.filled(widget.choices.length, const MapEntry("", {}));
    final answers = Provider.of<Answers>(context, listen: false);

    widget.choices.entries.forEach(
      (choice) {
        int _savedIndex;
        final int? _ans = answers.getAnswer(
          widget.surveyID,
          "${widget.questionID}_${choice.key}",
        );

        _savedIndex = _ans != null
            ? _ans - 1
            : widget.choices.values.toList().indexOf(choice.value);

        _items[_savedIndex] = choice; //value['Display'];

        answers.addAnswerSilently(
          widget.surveyID,
          "${widget.questionID}_${choice.key}",
          _savedIndex + 1,
        );
      },
    );
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
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30.0),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: MindBloomingColorScheme.primary1shadow,
            border: Border.all(
              color: MindBloomingColorScheme.primary3shadow,
              width: 0.5,
            ),
          ),
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(padding: const EdgeInsets.only(bottom: 10)),
              for (MapEntry<String, dynamic> item in _items) ...{
                RankOrderItem(
                  item: item,
                  index: _items.indexOf(item),
                  length: _items.length,
                  onArrowDown: _onArrowDown,
                  onArrowUp: _onArrowUp,
                  questionID: widget.questionID,
                  surveyID: widget.surveyID,
                  disabled: widget.disabled,
                ),
                _items.indexOf(item) < (_items.length - 1)
                    ? const Divider(height: 20, thickness: 1)
                    : Container(),
              },
              const Padding(padding: const EdgeInsets.only(bottom: 10)),
            ],
          ),
        ),
        const Padding(padding: const EdgeInsets.only(bottom: 20)),
      ],
    );
  }

  void _onItemReorder() {
    final answers = Provider.of<Answers>(context, listen: false);

    for (MapEntry<String, dynamic> item in _items) {
      final int _savedIndex = _items.indexOf(item);
      answers.addAnswerSilently(
        widget.surveyID,
        "${widget.questionID}_${item.key}",
        _savedIndex + 1,
      );
    }
  }

  void _onArrowDown(int index) {
    setState(() {
      final MapEntry<String, dynamic> _temp = _items[index - 1];

      _items[index - 1] = _items[index];

      _items[index] = _temp;
    });

    _onItemReorder();
  }

  void _onArrowUp(int index) {
    setState(() {
      final MapEntry<String, dynamic> _temp = _items[index + 1];
      _items[index + 1] = _items[index];
      _items[index] = _temp;
    });

    _onItemReorder();
  }
}

class RankOrderItem extends StatelessWidget {
  const RankOrderItem({
    super.key,
    required this.item,
    required this.index,
    required this.length,
    required this.onArrowDown,
    required this.onArrowUp,
    required this.questionID,
    required this.surveyID,
    required this.disabled,
  });

  final MapEntry<String, dynamic> item;
  final int index;
  final int length;
  final Function onArrowDown;
  final Function onArrowUp;
  final String questionID;
  final String surveyID;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 10),
                child: CircleAvatar(
                  backgroundColor: MindBloomingColorScheme.secondary4shadow,
                  maxRadius: 10,
                  child: Text(
                    '${index + 1}',
                    style: MindBloomingTextStyle.rankOrderNumber.copyWith(
                      color: MindBloomingColorScheme.primary,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomHtmlWidget(
                      questionText: item.value['Display'],
                    ),
                    if (item.value.containsKey('Image')) ...{
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          'https://psicologiaunimib.qualtrics.com/CP/Graphic.php?IM=' +
                              item.value['Image']['ImageLocation'],
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
                    if (item.value.containsKey('TextEntry')) ...{
                      if (item.value['TextEntry'] == 'true') ...{
                        GeneralOptionalTextEntry(
                          choice: item,
                          questionID: questionID,
                          padding: const EdgeInsets.only(
                            top: 8,
                          ),
                          surveyID: surveyID,
                          disabled: disabled,
                        ),
                      },
                    },
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Row(
            children: [
              ClipOval(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: index > 0 ? () => onArrowDown(index) : null,
                    child: Icon(
                      Icons.expand_less,
                      color: index > 0
                          ? MindBloomingColorScheme.secondary4shadow
                          : MindBloomingColorScheme.secondary2shadow,
                    ),
                  ),
                ),
              ),
              ClipOval(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: index < (length - 1) ? () => onArrowUp(index) : null,
                    child: Icon(
                      Icons.expand_more,
                      color: index < (length - 1)
                          ? MindBloomingColorScheme.secondary4shadow
                          : MindBloomingColorScheme.secondary2shadow,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
