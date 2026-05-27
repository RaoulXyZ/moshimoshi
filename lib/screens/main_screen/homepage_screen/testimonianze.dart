import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../providers/progress.dart';
import '../../../utility/mindblooming_color_scheme.dart';
import '../../../utility/mindblooming_text_style.dart';
import '../../questions_screen/questions_screen.dart';

class Testimonianze extends StatelessWidget {
  const Testimonianze({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Le nostre testimonianze",
            style: MindBloomingTextStyle.header3,
          ),
          const SizedBox(height: 10),
          const Indicator(),
        ],
      ),
    );
  }
}

class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final pp = Provider.of<Progress>(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: MindBloomingColorScheme.secondary2shadow,
        border: Border.all(
          color: MindBloomingColorScheme.secondary,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => QuestionsScreen(
                  onDone: (surveyName, blockName, _) {
                    pp.addDoneBlock(
                      surveyName,
                      blockName,
                    );
                  },
                  surveyName: "MM_testimonianze",
                  blockName: "testimonianze",
                  buttonText: "Torna alla Home",
                  title: "Le nostre testimonianze",
                  subtitle: "",
                ),
              ),
            ),
          },
          borderRadius: BorderRadius.circular(20),
          splashColor: MindBloomingColorScheme.secondary3shadow,
          highlightColor: Colors.transparent,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const SizedBox(width: 20),
                        Text(
                          "Leggi ora!",
                          style: MindBloomingTextStyle.subtitle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                child: SvgPicture.asset("assets/icon_right_arrow.svg"),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
