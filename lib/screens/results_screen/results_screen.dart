import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../chiamate.dart';
import '../../providers/progress.dart';

import '../../utility/mindblooming_color_scheme.dart';
import '../../utility/mindblooming_text_style.dart';
import '../../widgets/mindblooming_button.dart';
import '../../providers/moduli.dart';
import '../before_finishing_screen/before_finishing_screen.dart';
import './card_patologia.dart';
import './not_enough_modules_dialog.dart';

class ResultsScreen extends StatefulWidget {
  final Map<String, String> scelte;
  final Map<String, String> daScegliere;

  const ResultsScreen({
    super.key,
    required this.scelte,
    required this.daScegliere,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late RichText bodyText;
  late Map<String, String> moduli;

  @override
  void initState() {
    super.initState();

    final bold = MindBloomingTextStyle.normal.copyWith(
      fontWeight: FontWeight.bold,
    );

    bodyText = RichText(
      text: TextSpan(
        style: MindBloomingTextStyle.normal,
        children:
            // widget.daScegliere.isEmpty
            //     ? [
            //         const TextSpan(text: "Finalmente ti abbiamo inquadrato!\n"),
            //         const TextSpan(
            //           text:
            //               "Sulla base delle risposte che ci hai appena fornito MindBlooming ti ha ",
            //         ),
            //         TextSpan(
            //           text: "assegnato",
            //           style: bold,
            //         ),
            //         const TextSpan(text: " questi due moduli.\n\n"),
            //         const TextSpan(
            //           text:
            //               "Questo percorso è creato su misura per te e le tue esigenze. Crediamo che questa scelta possa esserti d’aiuto. Speriamo che MindBlooming possa accompagnarti in questo cammino e offrirti il giusto ",
            //         ),
            //         TextSpan(
            //           text: "supporto psicologico",
            //           style: bold,
            //         ),
            //         const TextSpan(text: " di cui hai bisogno.\n\n"),
            //         const TextSpan(
            //           text:
            //               "Ricorda,  il nostro obiettivo è quello di aiutarti a comprendere e gestire al meglio  le tue difficoltà. Ti guideremo e saremo al tuo fianco, ma se ciò non dovesse bastare ",
            //         ),
            //         TextSpan(
            //           text: "non aver timore",
            //           style: bold,
            //         ),
            //         const TextSpan(text: " di chiedere aiuto.\n"),
            //       ]
            //     :
            [
          const TextSpan(
            text:
                "Benvenuto! Di seguito sono mostrati i sei moduli che MoshiMoshi supporta. \nScegli i ",
          ),
          TextSpan(
            text: "due",
            style: bold,
          ),
          const TextSpan(
            text:
                " più adatti a te, tenendo in considerazione il livello di rilevanza che ti ha assegnato l’algoritmo dopo il questionario iniziale:",
          ),
        ],
      ),
    );

    final mProvider = Provider.of<Moduli>(context, listen: false);
    for (MapEntry<String, String> e in widget.scelte.entries) {
      mProvider.addModulo(e.key, e.value, notify: false);
    }

    if (!mProvider.full()) {
      mProvider.addModulo("depressioneansia", "Minimo", notify: false);
    }

    moduli = {};
    moduli.addAll(widget.scelte);
    moduli.addAll(widget.daScegliere);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MindBloomingTextStyle.returnMobile();
    final isDesktop = MindBloomingTextStyle.returnDesktop();

    return Scaffold(
      backgroundColor: MindBloomingColorScheme.primary,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: CustomScrollView(
          shrinkWrap: true,
          slivers: [
            const SliverPadding(
              padding: EdgeInsets.only(top: 30),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Seleziona due moduli",
                    style: MindBloomingTextStyle.header1,
                  ),
                  const SizedBox(height: 10),
                  IgnorePointer(
                    ignoring: _isLoading,
                    child: AnimatedOpacity(
                      opacity: _isLoading ? 0.5 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: isMobile ? 2 : (isDesktop ? 3 : 2),
                        crossAxisSpacing: isMobile ? 20 : (isDesktop ? 40 : 20),
                        mainAxisSpacing: isMobile ? 15 : (isDesktop ? 30 : 15),
                        childAspectRatio:
                            isMobile ? 0.85 : (isDesktop ? 0.55 : 0.70),
                        shrinkWrap: true,
                        children: [
                          for (MapEntry<String, String> e
                              in moduli.entries) ...{
                            CardPatologia(
                              patologia: e.key,
                              livello: e.value,
                              fixed: widget.scelte.containsKey(e.key),
                              choice: widget.daScegliere.isNotEmpty,
                            ),
                          },
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                    bottom: 20,
                    left: 10,
                    right: 10,
                  ),
                  child: MindBloomingButton(
                    onPressed: _isLoading ? null : _onProsegui,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            "PROSEGUI",
                            style: MindBloomingTextStyle.button,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isLoading = false;

  Future<void> _onProsegui() async {
    // final mProvider = Provider.of<Moduli>(context, listen: false);
    // final pProvider = Provider.of<Progress>(context, listen: false);

    // if (mProvider.full()) {
    //   final String m1 = mProvider.moduli.keys.first;
    //   final String m2 = mProvider.moduli.keys.last;
    //   pProvider.initEvents(m1, m2);

    //   Navigator.of(context).push(
    //     MaterialPageRoute(
    //       builder: (context) => const BeforeFinishingScreen(),
    //     ),
    //   );
    // } else {
    //   showDialog(
    //     context: context,
    //     builder: (context) => const NotEnoughModulesDialog(),
    //     barrierColor: MindBloomingColorScheme.dialogBg,
    //   );
    // }

    final mProvider = Provider.of<Moduli>(context, listen: false);
    final pProvider = Provider.of<Progress>(context, listen: false);

    if (mProvider.full()) {
      final String m1 = mProvider.moduli.keys.first;
      final String m2 = mProvider.moduli.keys.last;
      pProvider.initEvents(m1, m2);

      // Scarica le survey dei moduli scelti prima di navigare
      setState(() => _isLoading = true);
      try {
        await loadModuleSurveys(context, m1, m2);
      } catch (e) {
        // Network error (e.g. Qualtrics unreachable) — proceed anyway.
        // Surveys will be downloaded on the next successful connection.
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const BeforeFinishingScreen(),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => const NotEnoughModulesDialog(),
        barrierColor: MindBloomingColorScheme.dialogBg,
      );
    }
  }
}
