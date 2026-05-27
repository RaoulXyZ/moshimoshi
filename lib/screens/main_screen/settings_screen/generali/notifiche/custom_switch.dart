import 'package:flutter/material.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';

import '../../../../../utility/mindblooming_color_scheme.dart';

class CustomSwitch extends StatefulWidget {
  final bool value;
  final Color enableColor;
  final Color disableColor;
  final double width;
  final double height;
  final double switchHeight;
  final double switchWidth;
  final ValueChanged<bool> onChanged;
  final AnimationController animationController;

  CustomSwitch({
    super.key,
    required this.value,
    required this.enableColor,
    required this.disableColor,
    required this.width,
    required this.height,
    required this.switchHeight,
    required this.switchWidth,
    required this.onChanged,
    required this.animationController,
  });

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch>
    with SingleTickerProviderStateMixin {
  late Animation _circleAnimation;

  @override
  void initState() {
    super.initState();
    _circleAnimation = AlignmentTween(
      begin: widget.value ? Alignment.centerRight : Alignment.centerLeft,
      end: widget.value ? Alignment.centerLeft : Alignment.centerRight,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            !widget.value ? widget.onChanged(true) : widget.onChanged(false);
          },
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(200),
            ),
            child: Stack(
              children: [
                InnerShadow(
                  shadows: [
                    BoxShadow(
                      color: MindBloomingColorScheme.shadow,
                      blurRadius: 2,
                      offset: const Offset(-1.5, 3),
                    ),
                  ],
                  child: Container(
                    width: widget.width,
                    height: widget.height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(200),
                      color: _circleAnimation.value == Alignment.centerLeft
                          ? widget.disableColor
                          : widget.enableColor,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(2.0),
                  alignment: _circleAnimation.value,
                  child: Container(
                    width: widget.switchWidth,
                    height: widget.switchHeight,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: MindBloomingColorScheme.primary1shadow,
                      boxShadow: [
                        BoxShadow(
                          color: MindBloomingColorScheme.shadow,
                          blurRadius: 1,
                          offset: _circleAnimation.value == Alignment.centerLeft
                              ? const Offset(3, 1.5)
                              : const Offset(-3, 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
