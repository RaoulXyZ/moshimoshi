import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';

import '../utility/mindblooming_text_style.dart';

class CongratulationScreen extends StatelessWidget {
  const CongratulationScreen({
    super.key,
    required this.blockName,
    required this.surveyName,
  });

  final String blockName;
  final String surveyName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/trophy.svg',
            height: 40.h,
          ),
          const SizedBox(height: 30),
          Text(
            'Ben fatto!',
            style: MindBloomingTextStyle.header1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Continua così!',
            style: MindBloomingTextStyle.subtitle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
