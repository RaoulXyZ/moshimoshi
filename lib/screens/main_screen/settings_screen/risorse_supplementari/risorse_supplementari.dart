import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fwfh_url_launcher/fwfh_url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../providers/questions.dart';
import '../../../../utility/mindblooming_color_scheme.dart';
import '../../../../utility/mindblooming_text_style.dart';

class RisorseSupplementari extends StatelessWidget {
  const RisorseSupplementari({super.key});

  @override
  Widget build(BuildContext context) {
    final qProvider = Provider.of<Questions>(context);

    final risorse = qProvider
        .questions("MM_risorse_supplementari", "risorse_supplementari")
        .values
        .first["QuestionText"];

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
              padding: const EdgeInsets.only(left: 30, right: 20),
              child: Text(
                "Risorse supplementari",
                style: MindBloomingTextStyle.header1,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: HtmlWidget(
                risorse,
                textStyle: MindBloomingTextStyle.normal,
                factoryBuilder: MyWidgetFactory.new,
                customWidgetBuilder: (e) {
                  if (e.localName == 'a') {
                    return GestureDetector(
                      onTap: () => launchUrl(
                        Uri.parse(e.attributes["href"]!),
                        mode: LaunchMode.externalApplication,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            e.text,
                            style: MindBloomingTextStyle.link,
                          ),
                          const SizedBox(width: 10),
                          SvgPicture.asset("assets/icon_url.svg"),
                        ],
                      ),
                    );
                  }

                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyWidgetFactory extends WidgetFactory with UrlLauncherFactory {}
