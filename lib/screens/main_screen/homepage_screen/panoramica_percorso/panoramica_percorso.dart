import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import './no_data.dart';
import './grafico.dart';
import '../../../../providers/moduli.dart';
import '../../../../providers/progress.dart';
import '../../../../utility/mindblooming_color_scheme.dart';
import '../../../../utility/mindblooming_text_style.dart';

class PanoramicaPercorso extends StatefulWidget {
  const PanoramicaPercorso({
    super.key,
  });

  @override
  State<PanoramicaPercorso> createState() => _PanoramicaPercorsoState();
}

class _PanoramicaPercorsoState extends State<PanoramicaPercorso> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final pp = Provider.of<Progress>(context);
    final mp = Provider.of<Moduli>(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        color: MindBloomingColorScheme.primary1shadow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MindBloomingColorScheme.primary3shadow,
          width: 1,
        ),
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        alignment: Alignment.topCenter,
        child: Column(
          key: ValueKey(_expanded),
          children: [
            Row(
              children: [
                const SizedBox(width: 20),
                SvgPicture.asset(
                  'assets/icon_panoramica.svg',
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Panoramica del percorso",
                    style: MindBloomingTextStyle.subtitle,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Material(
                    shape: const CircleBorder(),
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() => _expanded = !_expanded),
                      borderRadius: BorderRadius.circular(2000),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 25,
                          horizontal: 20,
                        ),
                        child: SvgPicture.asset(
                          'assets/icon_expand_${_expanded ? "less" : "more"}.svg',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_expanded)
              if (pp.isPanoramicaEmpty()) ...{
                const NoData(),
              } else ...{
                Grafico(pp: pp, mp: mp),
              },
          ],
        ),
      ),
    );
  }
}
