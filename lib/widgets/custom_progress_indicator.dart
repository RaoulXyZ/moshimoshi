import 'package:flutter/material.dart';

import '../utility/mindblooming_color_scheme.dart';

class CustomProgressIndicator extends StatelessWidget {
  const CustomProgressIndicator({
    super.key,
    required this.idx,
    required this.max,
  });

  final int idx;
  final int max;

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      minHeight: 5,
      color: MindBloomingColorScheme.tertiary3shadow,
      value: (idx + 1) / max,
    );
  }
}
