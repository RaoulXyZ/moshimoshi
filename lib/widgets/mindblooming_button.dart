import 'package:flutter/material.dart';

import '../utility/mindblooming_color_scheme.dart';

class MindBloomingButton extends StatelessWidget {
  const MindBloomingButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.width = double.infinity,
    this.backgroundColor = MindBloomingColorScheme.tertiary,
    this.disabledColor = MindBloomingColorScheme.tertiary2shadow,
    this.borderColor = MindBloomingColorScheme.tertiary3shadow,
  });

  final void Function()? onPressed;
  final Widget child;
  final double width;
  final Color backgroundColor;
  final Color disabledColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: MindBloomingColorScheme.primary,
          backgroundColor: onPressed == null ? disabledColor : backgroundColor,
          side: BorderSide(
            color: borderColor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: child,
        ),
      ),
    );
  }
}
