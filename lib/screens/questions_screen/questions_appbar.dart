import 'package:flutter/material.dart';

import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_progress_indicator.dart';

class QuestionsAppBar extends StatelessWidget {
  const QuestionsAppBar({
    super.key,
    required this.indexData,
    required this.length,
    required this.buttonText,
    required this.title,
    required this.subtitle,
    required this.pdf,
    required this.onPdf,
  });

  final Map<String, dynamic> indexData;
  final int length;
  final String buttonText;
  final String title;
  final String subtitle;
  final bool pdf;
  final void Function()? onPdf;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          if (indexData['index'] < length)
            CustomProgressIndicator(
              idx: indexData['index'],
              max: length,
            ),
          if (indexData['index'] < length)
            CustomAppBar(
              title: title,
              subtitle: subtitle,
              buttonText: buttonText,
              pdf: pdf,
              onPdf: onPdf,
            ),
        ],
      ),
    );
  }
}
