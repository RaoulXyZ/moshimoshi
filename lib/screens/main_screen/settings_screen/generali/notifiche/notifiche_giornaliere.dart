import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../providers/user_settings.dart';
import '../../../../../utility/notification_api.dart';
import './custom_switch.dart';
import '../../../../../utility/mindblooming_color_scheme.dart';
import '../../../../../utility/mindblooming_text_style.dart';
import '../../../../../widgets/custom_time_picker.dart';
import './sicuro_dialog.dart';

class NotificheGiornaliere extends StatefulWidget {
  const NotificheGiornaliere({super.key});

  @override
  State<NotificheGiornaliere> createState() => _NotificheGiornaliereState();
}

class _NotificheGiornaliereState extends State<NotificheGiornaliere>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late bool _initialOn;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    final settings = Provider.of<UserSettings>(context, listen: false);
    _initialOn = settings.notifica_giornaliera;
  }

  void _animateTo(bool on) {
    if (on == _initialOn) {
      animationController.reverse();
    } else {
      animationController.forward();
    }
  }

  void _showPermissionFeedback(NotifPermissionResult result) {
    if (!mounted) return;
    if (result == NotifPermissionResult.permanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Permessi notifiche negati. Attivali nelle impostazioni dell'app.",
          ),
          action: SnackBarAction(
            label: 'IMPOSTAZIONI',
            onPressed: NotificationAPI.openSystemSettings,
          ),
          duration: Duration(seconds: 6),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Permessi notifiche negati."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<UserSettings>(context);
    final giornalieri = settings.notifica_giornaliera;

    return Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          children: [
            Text(
              "Esercizi giornalieri",
              style: MindBloomingTextStyle.subtitle,
            ),
            const Spacer(),
            CustomSwitch(
              value: giornalieri,
              enableColor: MindBloomingColorScheme.secondary,
              disableColor: MindBloomingColorScheme.secondary2shadow,
              width: 60,
              height: 30,
              switchHeight: 25,
              switchWidth: 25,
              animationController: animationController,
              onChanged: (v) async {
                if (!v) {
                  showDialog(
                    context: context,
                    builder: (context) => SicuroDialog(conferma: () {
                      _animateTo(false);
                      settings.disattivaNotificaGiornaliera();
                    }),
                  );
                } else {
                  final result =
                      await settings.attivaNotificaGiornaliera();
                  if (!mounted) return;
                  if (result == NotifPermissionResult.granted) {
                    _animateTo(true);
                  } else {
                    _showPermissionFeedback(result);
                  }
                }
              },
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Text(
          "Le notifiche relative agli esercizi giornalieri sono estremamente utili e necessarie ai fini di ricerca. Imposta un orario a te comodo per non dimenticarti di completare gli esercizi!",
          style: MindBloomingTextStyle.small,
        ),
      ),
      const SizedBox(height: 30),
      const CustomTimePicker(),
    ]);
  }
}
