import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../../models/exercise.dart';
import '../../../../providers/moduli.dart';
import '../../../../providers/progress.dart';
import '../../../../providers/user_settings.dart';
import '../../../../utility/mindblooming_color_scheme.dart';
import '../../../../utility/mindblooming_text_style.dart';
import '../../../blocks_screen/blocks_screen.dart';

class Preferiti extends StatelessWidget {
  const Preferiti({super.key});

  static const List<String> _sezioni = [
    'Introduzione',
    'Prima settimana',
    'Seconda settimana',
    'Terza settimana',
    'Quarta settimana',
    'Quinta settimana',
  ];

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<Progress>(context);
    final settings = Provider.of<UserSettings>(context);

    final entries = progress.weeklyExercises.entries.toList();
    final List<Widget> cards = [];
    for (var i = 0; i < entries.length; i++) {
      final sezione = i < _sezioni.length ? _sezioni[i] : 'Settimana ${i + 1}';
      for (final ex in entries[i].value) {
        if (!settings.isFavorite(ex.surveyName)) {
          continue;
        }
        cards.add(_FavoriteCard(exercise: ex, tappa: sezione));
      }
    }

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
                "Preferiti",
                style: MindBloomingTextStyle.header1,
              ),
            ),
            const SizedBox(height: 30),
            if (cards.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  "Non hai ancora aggiunto moduli ai preferiti. Tocca il cuoricino su un modulo sbloccato nella sezione Percorso per salvarlo qui.",
                  style: MindBloomingTextStyle.normal,
                ),
              )
            else
              ...cards,
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.exercise,
    required this.tappa,
  });

  final Exercise exercise;
  final String tappa;

  @override
  Widget build(BuildContext context) {
    final moduli = Provider.of<Moduli>(context, listen: false);
    final settings = Provider.of<UserSettings>(context, listen: false);
    final String displayModulo =
        moduli.prettyName[exercise.modulo] ?? exercise.modulo;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      decoration: BoxDecoration(
        color: exercise.done
            ? MindBloomingColorScheme.secondary2shadow
            : MindBloomingColorScheme.tertiary1shadow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: exercise.done
              ? MindBloomingColorScheme.secondary
              : MindBloomingColorScheme.tertiary,
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          highlightColor: Colors.transparent,
          splashColor: exercise.done
              ? MindBloomingColorScheme.secondary
              : MindBloomingColorScheme.tertiary,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocksScreen(
                exercise: exercise,
                tappa: tappa,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayModulo,
                        style: MindBloomingTextStyle.subtitle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tappa,
                        style: MindBloomingTextStyle.small,
                      ),
                    ],
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    highlightColor: Colors.transparent,
                    splashColor: MindBloomingColorScheme.tertiary,
                    onTap: () => settings.toggleFavorite(exercise.surveyName),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.favorite,
                        size: 22,
                        color: MindBloomingColorScheme.secondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                SvgPicture.asset("assets/icon_right_arrow.svg"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
