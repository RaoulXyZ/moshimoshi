import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utility/mindblooming_color_scheme.dart';
import '../utility/mindblooming_text_style.dart';

//import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    this.pdf = false,
    this.onPdf,
  });

  final String title;
  final String subtitle;
  final String buttonText;
  final bool pdf;
  final void Function()? onPdf;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: MindBloomingColorScheme.secondary5shadow,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 18,
          left: 24,
          right: 24,
          bottom: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minimumSize: Size.zero,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: SvgPicture.asset("assets/icon_left_arrow.svg"),
                  ),
                  Text(
                    buttonText,
                    style: MindBloomingTextStyle.pretitle.copyWith(
                      color: MindBloomingColorScheme.textColorLight,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10.0,
                left: 16,
              ),
              child: Text(
                title,
                style: MindBloomingTextStyle.header2.copyWith(
                  color: MindBloomingColorScheme.textColorLight,
                ),
              ),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        subtitle,
                        style: MindBloomingTextStyle.header3.copyWith(
                          color: MindBloomingColorScheme.textColorLight,
                        ),
                      ),
                    ),
                    if (pdf) ...[
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onPdf,
                          borderRadius: BorderRadius.circular(100),
                          splashColor: MindBloomingColorScheme.secondary4shadow,
                          highlightColor: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: SvgPicture.asset(
                              "assets/icon_download_pdf.svg",
                              height: 40,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ] else ...[
                      const SizedBox(width: 16, height: 40),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


/*
class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  CustomAppBar({
    required this.title,
    this.visible = true,
    this.actions = const [],
  }) : preferredSize = Size.fromHeight(kToolbarHeight);

  @override
  final Size preferredSize;

  final bool visible;
  final String title;
  final List<Widget> actions;

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      height: widget.visible
          ? widget.preferredSize.height + MediaQuery.of(context).padding.top
          : 0.0,
      child: AppBar(
        backgroundColor: Colors.transparent,
        actions: widget.actions,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        toolbarHeight: widget.visible ? widget.preferredSize.height : 0,
        elevation: 3,
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        flexibleSpace: Container(
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            gradient: LinearGradient(
              colors: [
                Color(0xFF33C58E),
                Color(0xFF63FD88),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/