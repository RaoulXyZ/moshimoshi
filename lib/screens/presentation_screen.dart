import 'package:flutter/material.dart';
import '../widgets/mindblooming_button.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import '../providers/answers.dart';
import '../providers/questions.dart';
import '../providers/screening.dart';
import '../providers/progress.dart';
import '../utility.dart';
import '../screens/screening_screen.dart';
import '../widgets/custom_yt_adapter.dart';
import '../utility/mindblooming_color_scheme.dart';
import '../utility/mindblooming_text_style.dart';

class PresentationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Questions>(
      builder: (context, value, child) {
        return Scaffold(
          body: Container(
            color: MindBloomingColorScheme.primary,
            child: Introduzione(
              value
                  .questions(
                    'MM_baseline_assessment_week1',
                    'presentazione_generale',
                  )
                  .entries
                  .first,
            ),
          ),
        );
      },
    );
  }
}

class Introduzione extends StatefulWidget {
  Introduzione(this.question);

  final MapEntry<String, dynamic> question;

  @override
  _IntroduzioneState createState() => _IntroduzioneState();
}

class _IntroduzioneState extends State<Introduzione> {
  List<String> _imgSources = [];
  List<String> _videoSources = [];
  List<String> _ytSources = [];
  List<String> _audioSources = [];

  @override
  void initState() {
    super.initState();
    extractImgs(_imgSources, widget.question.value['QuestionText']);
    extractVideos(
      _videoSources,
      _ytSources,
      widget.question.value['QuestionText'],
    );
    extractAudios(_audioSources, widget.question.value['QuestionText']);

    final qProvider = Provider.of<Questions>(context, listen: false);
    final String surveyID = qProvider.surveyID('MM_baseline_assessment_week1');

    final answers = Provider.of<Answers>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      answers.addAnswer(surveyID, widget.question.key, '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              ..._ytSources.map(
                (src) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomYTAdapter(url: src),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: HtmlWidget(
                  '<div style = "text-align: center">' +
                      widget.question.value['QuestionText'] +
                      '</div>',
                  textStyle: MindBloomingTextStyle.introductionText,
                ),
              ),
            ],
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          fillOverscroll: true,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 16,
                left: 32,
                right: 32,
              ),
              child: MindBloomingButton(
                child: Text(
                  "INIZIAMO",
                  style: MindBloomingTextStyle.button,
                ),
                onPressed: () {
                  Provider.of<Screening>(context, listen: false)
                      .addDone('presentazione_generale', context);
                  Provider.of<Progress>(context, listen: false).addDoneBlock(
                    "MM_baseline_assessment_week1",
                    "presentazione_generale",
                  );
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => ScreeningScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
