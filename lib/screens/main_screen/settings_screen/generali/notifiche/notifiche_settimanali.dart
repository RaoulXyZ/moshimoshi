import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../providers/user_settings.dart';
import '../../../../../utility/notification_api.dart';
import '../../../../../widgets/custom_day_time_picker.dart';
import './custom_switch.dart';
import '../../../../../utility/mindblooming_color_scheme.dart';
import '../../../../../utility/mindblooming_text_style.dart';

class NotificheSettimanali extends StatefulWidget {
  const NotificheSettimanali({super.key});

  @override
  State<NotificheSettimanali> createState() => _NotificheSettimanaliState();
}

class _NotificheSettimanaliState extends State<NotificheSettimanali>
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
    _initialOn = settings.notSettimanale;
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
    final settimanali = settings.notSettimanale;

    return Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          children: [
            Text(
              "Attività settimanali",
              style: MindBloomingTextStyle.subtitle,
            ),
            const Spacer(),
            CustomSwitch(
              value: settimanali,
              enableColor: MindBloomingColorScheme.secondary,
              disableColor: MindBloomingColorScheme.secondary2shadow,
              width: 60,
              height: 30,
              switchHeight: 25,
              switchWidth: 25,
              animationController: animationController,
              onChanged: (v) async {
                if (!v) {
                  _animateTo(false);
                  settings.disattivaNotificaSettimanale();
                } else {
                  final result = await settings.attivaNotificaSettimanale();
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
          "Le notifiche relative agli esercizi settimanali ti ricorderanno questi esercizi una volta alla settimana.",
          style: MindBloomingTextStyle.small,
        ),
      ),
      const SizedBox(height: 30),
      CustomDayTimePicker(
        initialWeekday: settings.settimanaleWeekday,
        initialHour: settings.settimanaleHour,
        initialMinute: settings.settimanaleMinute,
        onConfirm: settings.setSettimanaleSchedule,
      ),
    ]);
  }
}
