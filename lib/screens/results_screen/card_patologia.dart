import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../providers/moduli.dart';
import '../../utility/mindblooming_color_scheme.dart';
import '../../utility/mindblooming_text_style.dart';
import './fixed_dialog.dart';
import './full_dialog.dart';
import './info_dialog.dart';

class CardPatologia extends StatelessWidget {
  const CardPatologia({
    super.key,
    required this.fixed,
    required this.patologia,
    required this.livello,
    required this.choice,
  });

  final bool fixed;
  final String patologia;
  final String livello;
  final bool choice;

  @override
  Widget build(BuildContext context) {
    final mProvider = Provider.of<Moduli>(context);
    final bool hasModulo = mProvider.hasModulo(patologia);

    // final isMobile = MindBloomingTextStyle.returnMobile();
    // final isDesktop = MindBloomingTextStyle.returnDesktop();

    return Container(
      decoration: BoxDecoration(
        color: hasModulo
            ? MindBloomingColorScheme.secondary1shadow
            : MindBloomingColorScheme.primary1shadow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasModulo
              ? MindBloomingColorScheme.secondary3shadow
              : MindBloomingColorScheme.primary3shadow,
          width: 0.75,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: !hasModulo
              ? MindBloomingColorScheme.secondary4shadow
              : MindBloomingColorScheme.primary3shadow,
          onTap: () {
            if (choice) {
              if (hasModulo && !fixed) {
                mProvider.removeModulo(patologia);
              } else if (!mProvider.full()) {
                mProvider.addModulo(patologia, livello);
              }

              if (fixed) {
                showDialog(
                  context: context,
                  builder: (context) => FixedDialog(
                    patologia: patologia,
                  ),
                  barrierColor: MindBloomingColorScheme.dialogBg,
                );
              }

              if (!mProvider.hasModulo(patologia) && mProvider.full()) {
                showDialog(
                  context: context,
                  builder: (context) => FullDialog(
                    patologia: patologia,
                  ),
                  barrierColor: MindBloomingColorScheme.dialogBg,
                );
              }
            } else {
              showDialog(
                context: context,
                builder: (context) => InfoDialog(
                  patologia: patologia,
                ),
                barrierColor: MindBloomingColorScheme.dialogBg,
              );
            }
          },
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      "assets/pic_${patologia.toLowerCase()}.svg",
                      height: 60.sp,
                    ),
                    // const SizedBox(height: 10),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          mProvider.prettyName[patologia] ?? '',
                          style: MindBloomingTextStyle.conditionName,
                        ),
                      ),
                      InkWell(
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) => InfoDialog(
                            patologia: patologia,
                          ),
                          barrierColor: MindBloomingColorScheme.dialogBg,
                        ),
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2, right: 2),
                          child: SvgPicture.asset(
                            "assets/icon_info.svg",
                            height: 5.sp,
                            width: 5.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
