import 'package:flutter/material.dart';

import 'mindblooming_color_scheme.dart';
import 'mindblooming_text_style.dart';

Function errorAlert = (context, err) => showGeneralDialog(
      barrierLabel: "Error",
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 500),
      context: context,
      pageBuilder: (_, __, ___) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Align(
            alignment: Alignment.center,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.8,
              child: ScrollConfiguration(
                behavior: ErrorAlert(),
                child: ListView(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: const Icon(
                            Icons.warning,
                            color: MindBloomingColorScheme.tertiary,
                            size: 100,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Whoops",
                                style: MindBloomingTextStyle.header1.copyWith(
                                  color: MindBloomingColorScheme.shadow,
                                ),
                              ),
                              Text(
                                "Qualcosa è andato storto",
                                style: MindBloomingTextStyle.subtitle,
                              ),
                              Text(
                                "Per favore controlla la tua connessione e riprova.",
                                style: MindBloomingTextStyle.subtitle,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        err,
                        style: MindBloomingTextStyle.small,
                      ),
                    ),
                  ],
                ),
              ),
              margin: const EdgeInsets.only(bottom: 50, left: 12, right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        );
      },
    );

class ErrorAlert extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
