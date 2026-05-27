import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../utility/mindblooming_text_style.dart';

class NoData extends StatelessWidget {
  const NoData({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset('assets/plant_no_data.svg'),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "Oops!\nSembra che al momento non ci siano progressi da mostrare! Torna più tardi.",
            style: MindBloomingTextStyle.noDataText,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
