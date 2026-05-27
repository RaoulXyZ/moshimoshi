import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import './mindblooming_button.dart';
import '../utility/mindblooming_color_scheme.dart';
import '../utility/mindblooming_text_style.dart';

const _weekdayLabels = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];

String weekdayLabel(int weekday) =>
    _weekdayLabels[(weekday - 1).clamp(0, 6)];

class CustomDayTimePicker extends StatelessWidget {
  final int initialWeekday;
  final int initialHour;
  final int initialMinute;
  final void Function(int weekday, int hour, int minute) onConfirm;

  const CustomDayTimePicker({
    super.key,
    required this.initialWeekday,
    required this.initialHour,
    required this.initialMinute,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MindBloomingColorScheme.primary1shadow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MindBloomingColorScheme.primary3shadow,
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPicker(context),
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 10,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset("assets/icon_bell.svg"),
                const SizedBox(width: 10),
                Text(
                  "${weekdayLabel(initialWeekday)} "
                  "${initialHour.toString().padLeft(2, '0')}:"
                  "${initialMinute.toString().padLeft(2, '0')}",
                  style: MindBloomingTextStyle.header3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    final List<int> hours = List.generate(24, (i) => i);
    final List<int> minutes = List.generate(12, (i) => i * 5);
    final List<int> weekdays = List.generate(7, (i) => i + 1);

    int weekday = initialWeekday;
    int hour = initialHour;
    int minute = initialMinute;

    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      barrierColor: MindBloomingColorScheme.dialogBg,
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: MindBloomingColorScheme.primary2shadow,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: MindBloomingColorScheme.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 80),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 100),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 5),
                            Container(
                              width: double.infinity,
                              height: 35,
                              color:
                                  MindBloomingColorScheme.secondary2shadow,
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ConstrainedBox(
                              constraints:
                                  const BoxConstraints(maxWidth: 60),
                              child: ListWheelScrollView.useDelegate(
                                onSelectedItemChanged: (value) =>
                                    weekday = value + 1,
                                perspective: 0.000001,
                                controller: FixedExtentScrollController(
                                  initialItem: weekday - 1,
                                ),
                                itemExtent: 50,
                                physics: const FixedExtentScrollPhysics(),
                                childDelegate:
                                    ListWheelChildLoopingListDelegate(
                                  children: weekdays
                                      .map(
                                        (w) => Text(
                                          _weekdayLabels[w - 1],
                                          style: MindBloomingTextStyle
                                              .header3,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            ConstrainedBox(
                              constraints:
                                  const BoxConstraints(maxWidth: 50),
                              child: ListWheelScrollView.useDelegate(
                                onSelectedItemChanged: (value) =>
                                    hour = value,
                                perspective: 0.000001,
                                controller: FixedExtentScrollController(
                                  initialItem: hour,
                                ),
                                itemExtent: 50,
                                physics: const FixedExtentScrollPhysics(),
                                childDelegate:
                                    ListWheelChildLoopingListDelegate(
                                  children: hours
                                      .map(
                                        (e) => Text(
                                          "$e".padLeft(2, "0"),
                                          style: MindBloomingTextStyle
                                              .header3,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                            Text(
                              ":",
                              style: MindBloomingTextStyle.header3,
                            ),
                            ConstrainedBox(
                              constraints:
                                  const BoxConstraints(maxWidth: 50),
                              child: ListWheelScrollView.useDelegate(
                                onSelectedItemChanged: (value) =>
                                    minute = value * 5,
                                perspective: 0.000001,
                                controller: FixedExtentScrollController(
                                  initialItem: minute ~/ 5,
                                ),
                                itemExtent: 50,
                                physics: const FixedExtentScrollPhysics(),
                                childDelegate:
                                    ListWheelChildLoopingListDelegate(
                                  children: minutes
                                      .map(
                                        (e) => Text(
                                          "$e".padLeft(2, "0"),
                                          style: MindBloomingTextStyle
                                              .header3,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: MindBloomingButton(
                    onPressed: () {
                      onConfirm(weekday, hour, minute);
                      Navigator.pop(context);
                    },
                    child: Text(
                      "FATTO",
                      style: MindBloomingTextStyle.button,
                    ),
                  ),
                ),
                const SizedBox(height: 35),
              ],
            ),
          ),
        );
      },
    );
  }
}
