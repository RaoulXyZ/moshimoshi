import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:provider/provider.dart';

import '../../../providers/answers.dart';
import '../../../utility/mindblooming_color_scheme.dart';
import '../../../utility/mindblooming_text_style.dart';
import '../../mindblooming_button.dart';
import '../question_text.dart';
import '../general_optional_text_entry.dart';

class PickGroupRank extends StatefulWidget {
  final String questionText;
  final Map<String, dynamic> choices;
  final List<String> groups;
  final String surveyID;
  final String blockID;
  final String questionID;
  final bool disabled;

  PickGroupRank({
    required this.questionText,
    required this.choices,
    required this.groups,
    required this.surveyID,
    required this.blockID,
    required this.questionID,
    required this.disabled,
  }) : super(key: Key(questionID));

  @override
  _PickGroupRank createState() => _PickGroupRank();
}

class _PickGroupRank extends State<PickGroupRank> {
  Map<String, List<MapEntry<String, dynamic>>> _items = {};

  @override
  void initState() {
    super.initState();
    final answers = Provider.of<Answers>(context, listen: false);
    final List<MapEntry<String, dynamic>> _remainingChoices =
        widget.choices.entries.toList();

    widget.groups.forEach((group) {
      final int _groupIndex = widget.groups.indexOf(group);
      final List<String> _choicesID = answers.getAnswer(
            widget.surveyID,
            "${widget.questionID}_${_groupIndex}_GROUP",
          ) ??
          [];

      _items[group] = List.filled(
        _choicesID.length,
        const MapEntry("", {}),
        growable: true,
      );

      _choicesID.forEach((choiceID) {
        final choice = widget.choices.entries
            .firstWhere((element) => element.key == choiceID);
        _remainingChoices.removeWhere((e) => e.key == choice.key);
        final int _index = answers.getAnswer(
          widget.surveyID,
          "${widget.questionID}_G${_groupIndex}_${choice.key}_RANK",
        );
        _items[group]![_index - 1] = choice;
      });
    });

    _items['items'] = List.filled(
      _remainingChoices.length,
      const MapEntry("", {}),
      growable: true,
    );
    _remainingChoices.forEach((choice) {
      _items['items']![_remainingChoices.indexOf(choice)] = choice;
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = _items['items'];

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
              Container(
                margin: const EdgeInsets.only(bottom: 20),
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
                  children: [
                    const ListHeader(title: "Items"),
                    if (items!.length == 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "Ben fatto!",
                          style: MindBloomingTextStyle.small.copyWith(
                            color: MindBloomingColorScheme.primary3shadow,
                          ),
                        ),
                      )
                    else
                      for (var item in items) ...{
                        PickGroupRankItem(
                          item: item,
                          index: items.indexOf(item),
                          listIndex: 0,
                          length: items.length,
                          group: "items",
                          onArrowDown: _onArrowDown,
                          onArrowUp: _onArrowUp,
                          onTap: _onTap,
                          disabled: widget.disabled,
                          questionID: widget.questionID,
                          surveyID: widget.surveyID,
                        ),
                        items.indexOf(item) < (items.length - 1)
                            ? const Divider(height: 1, thickness: 1)
                            : Container(),
                      },
                  ],
                ),
              ),
              ...widget.groups.map((group) {
                final length = _items[group]!.length;

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
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
                    children: [
                      ListHeader(title: group),
                      if (length == 0)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "Insieme vuoto. Premi su un elemento per cambiarne l'insieme.",
                            style: MindBloomingTextStyle.small.copyWith(
                              color: MindBloomingColorScheme.primary3shadow,
                            ),
                          ),
                        )
                      else
                        for (var item in _items[group]!) ...{
                          PickGroupRankItem(
                            item: item,
                            listIndex: widget.groups.indexOf(group) + 1,
                            index: _items[group]!.indexOf(item),
                            length: length,
                            onArrowDown: _onArrowDown,
                            onArrowUp: _onArrowUp,
                            onTap: _onTap,
                            group: group,
                            disabled: widget.disabled,
                            questionID: widget.questionID,
                            surveyID: widget.surveyID,
                          ),
                          _items[group]!.indexOf(item) < (length - 1)
                              ? const Divider(height: 1, thickness: 1)
                              : Container(),
                        },
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  void _onItemReorder(String group, String choiceKey) {
    final answers = Provider.of<Answers>(context, listen: false);

    final int groupIndex = widget.groups.indexOf(group);
    if (answers.hasAnswerPGR(
      widget.surveyID,
      "${widget.questionID}_G${groupIndex}_${choiceKey}_RANK",
    )) {
      answers.removeAnswer(
        widget.surveyID,
        "${widget.questionID}_G${groupIndex}_${choiceKey}_RANK",
      );
    }

    widget.groups.forEach((group) {
      final int _groupIndex = widget.groups.indexOf(group);
      final List<String> _choicesID = [];

      _items[group]!.forEach((item) {
        _choicesID.add(item.key);
      });
      answers.addAnswerSilently(
        widget.surveyID,
        "${widget.questionID}_${_groupIndex}_GROUP",
        _choicesID,
      );
    });

    _items.forEach((group, items) {
      if (group != "items") {
        items.forEach((item) {
          final int _groupIndex = widget.groups.indexOf(group);
          answers.addAnswerSilently(
            widget.surveyID,
            "${widget.questionID}_G${_groupIndex}_${item.key}_RANK",
            _items[group]!.indexOf(item) + 1,
          );
        });
      }
    });
  }

  void _onArrowUp(String group, int index, String choiceKey) {
    setState(() {
      final _temp = _items[group]![index - 1];
      _items[group]![index - 1] = _items[group]![index];
      _items[group]![index] = _temp;
    });

    _onItemReorder(group, choiceKey);
  }

  void _onArrowDown(String group, int index, String choiceKey) {
    setState(() {
      final _temp = _items[group]![index + 1];
      _items[group]![index + 1] = _items[group]![index];
      _items[group]![index] = _temp;
    });

    _onItemReorder(group, choiceKey);
  }

  void _onTap(BuildContext context, int oldListIndex, int itemIndex) {
    final List<String> _groups = List.from(widget.groups);
    _groups.insert(0, 'items');

    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: MindBloomingColorScheme.tertiary1shadow,
          title: Center(
            child: Text(
              'Seleziona il gruppo',
              style: MindBloomingTextStyle.header2,
            ),
          ),
          content: Container(
            constraints: const BoxConstraints(maxHeight: 300),
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: _groups[oldListIndex] == _groups[index]
                          ? MindBloomingColorScheme.secondary
                              .withValues(alpha: 0.5)
                          : MindBloomingColorScheme.primary3shadow
                              .withValues(alpha: 0.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: HtmlWidget(
                        _groups[index],
                        textStyle: TextStyle(
                          color: _groups[oldListIndex] == _groups[index]
                              ? Colors.white70
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  onTap: _groups[oldListIndex] == _groups[index]
                      ? null
                      : () {
                          setState(() {
                            final _temp =
                                _items[_groups[oldListIndex]]![itemIndex];
                            _items[_groups[oldListIndex]]!.removeAt(itemIndex);
                            _items[_groups[index]]!.insert(0, _temp);

                            _onItemReorder(_groups[oldListIndex], _temp.key);
                          });
                          Navigator.of(context).pop();
                        },
                ),
              ),
              itemCount: _groups.length,
              shrinkWrap: true,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MindBloomingButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'ANNULLA',
                  style: MindBloomingTextStyle.button,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListHeader extends StatelessWidget {
  const ListHeader({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        color: MindBloomingColorScheme.primary2shadow,
      ),
      child: Column(
        children: [
          const Padding(padding: const EdgeInsets.only(top: 5)),
          Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    style: MindBloomingTextStyle.small.copyWith(
                      color: MindBloomingColorScheme.textColorDark1shadow,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Divider(
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class PickGroupRankItem extends StatelessWidget {
  const PickGroupRankItem({
    super.key,
    required this.index,
    required this.listIndex,
    required this.length,
    required this.onArrowDown,
    required this.onArrowUp,
    required this.onTap,
    required this.item,
    required this.group,
    required this.questionID,
    required this.surveyID,
    required this.disabled,
  });

  final MapEntry<String, dynamic> item;
  final int index;
  final int listIndex;
  final int length;
  final Function onArrowDown;
  final Function onArrowUp;
  final Function onTap;
  final String group;
  final String questionID;
  final String surveyID;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        child: InkWell(
          onTap: () => onTap(context, listIndex, index),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 10),
                        child: CircleAvatar(
                          backgroundColor:
                              MindBloomingColorScheme.secondary4shadow,
                          maxRadius: 10,
                          child: Text(
                            '${index + 1}',
                            style:
                                MindBloomingTextStyle.rankOrderNumber.copyWith(
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
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;

                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
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
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Row(
                          children: [
                            ClipOval(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: index > 0
                                      ? () {
                                          onArrowUp(group, index, item.key);
                                        }
                                      : null,
                                  child: Icon(
                                    Icons.expand_less,
                                    color: index > 0
                                        ? MindBloomingColorScheme
                                            .secondary4shadow
                                        : MindBloomingColorScheme
                                            .secondary2shadow,
                                  ),
                                ),
                              ),
                            ),
                            ClipOval(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: index < (length - 1)
                                      ? () {
                                          onArrowDown(group, index, item.key);
                                        }
                                      : null,
                                  child: Icon(
                                    Icons.expand_more,
                                    color: index < (length - 1)
                                        ? MindBloomingColorScheme
                                            .secondary4shadow
                                        : MindBloomingColorScheme
                                            .secondary2shadow,
                                  ),
                                ),
                              ),
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
        ),
      ),
    );
  }
}
