import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fwfh_url_launcher/fwfh_url_launcher.dart';
import 'package:provider/provider.dart';

import '../../../../providers/questions.dart';
import '../../../../utility/mindblooming_color_scheme.dart';
import '../../../../utility/mindblooming_text_style.dart';

class MoshiMoshi extends StatelessWidget {
  const MoshiMoshi({super.key});

  @override
  Widget build(BuildContext context) {
    final qProvider = Provider.of<Questions>(context);

    return Scaffold(
      backgroundColor: MindBloomingColorScheme.primary,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 20),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () => Navigator.of(context).pop(),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icon_left_arrow.svg',
                          colorFilter: const ColorFilter.mode(
                            MindBloomingColorScheme.textColorDark,
                            BlendMode.srcATop,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Indietro",
                          style: MindBloomingTextStyle.pretitle,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "MoshiMoshi",
                style: MindBloomingTextStyle.header1,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: HtmlWidget(
                qProvider.profileAbout,
                textStyle: MindBloomingTextStyle.normal,
                factoryBuilder: MyWidgetFactory.new,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Crediti",
                style: MindBloomingTextStyle.header3,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                qProvider.profileCredits,
                style: MindBloomingTextStyle.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyWidgetFactory extends WidgetFactory with UrlLauncherFactory {}
