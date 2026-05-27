import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import './mindblooming_button.dart';
import '../providers/user_settings.dart';
import '../utility/mindblooming_color_scheme.dart';
import '../utility/mindblooming_text_style.dart';

class CustomTimePicker extends StatelessWidget {
  const CustomTimePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final sProvider = Provider.of<UserSettings>(context);

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
          onTap: () {
            showModalBottomSheet(
              backgroundColor: Colors.transparent,
              barrierColor: MindBloomingColorScheme.dialogBg,
              context: context,
              builder: (context) {
                final List<int> hours = List.generate(24, (index) => index);
                final List<int> minutes =
                    List.generate(12, (index) => index * 5);

                int hour = sProvider.timeOfDay.hour;
                int minute = sProvider.timeOfDay.minute;

                return BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 5,
                    sigmaY: 5,
                  ),
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
                          constraints: const BoxConstraints(
                            maxHeight: 100,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      width: double.infinity,
                                      height: 35,
                                      color: MindBloomingColorScheme
                                          .secondary2shadow,
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
                                      constraints: const BoxConstraints(
                                        maxWidth: 50,
                                      ),
                                      child: ListWheelScrollView.useDelegate(
                                        onSelectedItemChanged: (value) =>
                                            hour = value,
                                        perspective: 0.000001,
                                        controller: FixedExtentScrollController(
                                          initialItem: hour,
                                        ),
                                        // squeeze: 1,
                                        itemExtent: 50,
                                        physics:
                                            const FixedExtentScrollPhysics(),
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
                                      constraints: const BoxConstraints(
                                        maxWidth: 50,
                                      ),
                                      child: ListWheelScrollView.useDelegate(
                                        onSelectedItemChanged: (value) =>
                                            minute = value * 5,
                                        perspective: 0.000001,
                                        // squeeze: ,
                                        itemExtent: 50,
                                        controller: FixedExtentScrollController(
                                          initialItem: minute ~/ 5,
                                        ),
                                        physics:
                                            const FixedExtentScrollPhysics(),
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
                              sProvider.setTime(
                                hour,
                                minute,
                              );
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
          },
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 50,
              vertical: 10,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset("assets/icon_bell.svg"),
                const SizedBox(width: 10),
                Text(
                  sProvider.timeOfDay.hour.toString().padLeft(2, '0') +
                      ":" +
                      sProvider.timeOfDay.minute.toString().padLeft(2, '0'),
                  style: MindBloomingTextStyle.header3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
