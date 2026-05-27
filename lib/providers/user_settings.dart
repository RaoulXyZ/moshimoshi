import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../utility/notification_api.dart';

class UserSettings with ChangeNotifier {
  static const int _settimanaleBaseId = 100;
  static const int _lezioniBaseId = 200;
  static const int _weeklyOccurrencesAhead = 8;

  late Box hive;
  late TimeOfDay timeOfDay;
  late bool canSend;
  late bool notifica_giornaliera;
  late bool notSettimanale;
  late bool notEsercizi;
  late bool demo;
  late bool debug;

  late int settimanaleWeekday;
  late int settimanaleHour;
  late int settimanaleMinute;
  late int lezioniWeekday;
  late int lezioniHour;
  late int lezioniMinute;

  List<String> plants = [
    'assets/plant.png',
    'assets/plant_2.png',
    'assets/plant_3.png',
  ];
  late String selectedPlant;

  Future<void> init({bool isDemo = false, bool canSend = true}) async {
    await Hive.openBox("MoshiMoshi").then((value) => hive = value);
    selectedPlant = hive.get('plant', defaultValue: '0');
    this.canSend = hive.get('canSend', defaultValue: canSend);
    demo = hive.get('demo', defaultValue: isDemo);
    debug = hive.get('debug', defaultValue: false);

    notifica_giornaliera =
        hive.get('notifica_giornaliera', defaultValue: false);
    notSettimanale = hive.get('notifica_settimanale', defaultValue: false);
    notEsercizi = hive.get('notifica_esercizi', defaultValue: false);

    timeOfDay = TimeOfDay(
      hour: hive.get('hour', defaultValue: 8),
      minute: hive.get('minute', defaultValue: 0),
    );

    final defaultWeekday = DateTime.now().weekday;
    settimanaleWeekday =
        hive.get('settimanale_weekday', defaultValue: defaultWeekday) as int;
    settimanaleHour =
        hive.get('settimanale_hour', defaultValue: timeOfDay.hour) as int;
    settimanaleMinute =
        hive.get('settimanale_minute', defaultValue: timeOfDay.minute) as int;
    lezioniWeekday =
        hive.get('lezioni_weekday', defaultValue: defaultWeekday) as int;
    lezioniHour = hive.get('lezioni_hour', defaultValue: timeOfDay.hour) as int;
    lezioniMinute =
        hive.get('lezioni_minute', defaultValue: timeOfDay.minute) as int;

    if (!hive.get('weekly_legacy_ids_cleaned', defaultValue: false)) {
      await NotificationAPI.cancelNotification(1);
      await NotificationAPI.cancelNotification(2);
      hive.put('weekly_legacy_ids_cleaned', true);
    }

    await _reconcileNotificationFlagsWithOs();
    notifyListeners();
  }

  Future<void> _reconcileNotificationFlagsWithOs() async {
    if (!notifica_giornaliera && !notSettimanale && !notEsercizi) return;

    final granted = await NotificationAPI.hasPermissions();
    if (granted) {
      if (notifica_giornaliera) scheduleDaily();
      if (notSettimanale) _scheduleWeeklyReminder();
      if (notEsercizi) _scheduleLezioniReminder();

      return;
    }

    if (notifica_giornaliera) {
      notifica_giornaliera = false;
      hive.put('notifica_giornaliera', false);
    }
    if (notSettimanale) {
      notSettimanale = false;
      hive.put('notifica_settimanale', false);
    }
    if (notEsercizi) {
      notEsercizi = false;
      hive.put('notifica_esercizi', false);
    }
  }

  void setPlant(plant) {
    selectedPlant = plant;
    hive.put("plant", plant);
    notifyListeners();
  }

  void setCanSend(canSend) {
    this.canSend = canSend;
    hive.put("canSend", canSend);
    notifyListeners();
  }

  Future<void> setTime(int hour, int minute) async {
    timeOfDay = TimeOfDay(hour: hour, minute: minute);
    hive.put("hour", hour);
    hive.put("minute", minute);
    if (notifica_giornaliera) {
      if (await NotificationAPI.hasPermissions()) {
        scheduleDaily();
      } else {
        notifica_giornaliera = false;
        hive.put('notifica_giornaliera', false);
      }
    }
    notifyListeners();
  }

  Future<NotifPermissionResult> attivaNotificaGiornaliera() async {
    final result = await NotificationAPI.requestPermissions();

    if (result != NotifPermissionResult.granted) {
      notifica_giornaliera = false;
      hive.put("notifica_giornaliera", false);
      notifyListeners();
      log("Notifica giornaliera non attivata: permesso $result");

      return result;
    }

    notifica_giornaliera = true;
    scheduleDaily();
    hive.put("notifica_giornaliera", true);
    notifyListeners();

    log("Notifica giornaliera attivata");

    return result;
  }

  void disattivaNotificaGiornaliera() {
    notifica_giornaliera = false;
    NotificationAPI.cancelNotification(0);
    hive.put("notifica_giornaliera", false);
    notifyListeners();

    log("Notifica giornaliera disattivata");
  }

  void scheduleDaily() {
    NotificationAPI.scheduleDaily(
      title: "Daily Screening",
      body: "Ciao! Ricorda di completare il tuo daily screening!",
      hour: timeOfDay.hour,
      minute: timeOfDay.minute,
      channel: NotificationChannel.daily,
    );
  }

  Future<NotifPermissionResult> attivaNotificaSettimanale() async {
    final result = await NotificationAPI.requestPermissions();

    if (result != NotifPermissionResult.granted) {
      notSettimanale = false;
      hive.put("notifica_settimanale", false);
      notifyListeners();
      log("Notifica settimanale non attivata: permesso $result");

      return result;
    }

    hive.put('settimanale_weekday', settimanaleWeekday);
    hive.put('settimanale_hour', settimanaleHour);
    hive.put('settimanale_minute', settimanaleMinute);
    notSettimanale = true;
    hive.put("notifica_settimanale", true);
    _scheduleWeeklyReminder();
    notifyListeners();

    log("Notifica settimanale attivata");

    return result;
  }

  Future<void> setSettimanaleSchedule(
    int weekday,
    int hour,
    int minute,
  ) async {
    settimanaleWeekday = weekday;
    settimanaleHour = hour;
    settimanaleMinute = minute;
    hive.put('settimanale_weekday', weekday);
    hive.put('settimanale_hour', hour);
    hive.put('settimanale_minute', minute);
    if (notSettimanale) {
      if (await NotificationAPI.hasPermissions()) {
        _scheduleWeeklyReminder();
      } else {
        notSettimanale = false;
        hive.put('notifica_settimanale', false);
      }
    }
    notifyListeners();
  }

  void _scheduleWeeklyReminder() {
    NotificationAPI.scheduleWeeklyOccurrences(
      baseId: _settimanaleBaseId,
      title: "Weekly Screening",
      body: "Ciao! Ricorda di completare il tuo weekly screening!",
      weekday: settimanaleWeekday,
      hour: settimanaleHour,
      minute: settimanaleMinute,
      weeksAhead: _weeklyOccurrencesAhead,
      channel: NotificationChannel.weekly,
    );
  }

  void disattivaNotificaSettimanale() {
    notSettimanale = false;
    NotificationAPI.cancelWeeklyOccurrences(
      _settimanaleBaseId,
      weeksAhead: _weeklyOccurrencesAhead,
    );
    hive.put("notifica_settimanale", false);
    notifyListeners();

    log("Notifica settimanale disattivata");
  }

  Future<NotifPermissionResult> attivaNotificaLezioni() async {
    final result = await NotificationAPI.requestPermissions();

    if (result != NotifPermissionResult.granted) {
      notEsercizi = false;
      hive.put("notifica_esercizi", false);
      notifyListeners();
      log("Notifica lezioni non attivata: permesso $result");

      return result;
    }

    hive.put('lezioni_weekday', lezioniWeekday);
    hive.put('lezioni_hour', lezioniHour);
    hive.put('lezioni_minute', lezioniMinute);
    notEsercizi = true;
    hive.put("notifica_esercizi", true);
    _scheduleLezioniReminder();
    notifyListeners();

    log("Notifica lezioni attivata");

    return result;
  }

  Future<void> setLezioniSchedule(
    int weekday,
    int hour,
    int minute,
  ) async {
    lezioniWeekday = weekday;
    lezioniHour = hour;
    lezioniMinute = minute;
    hive.put('lezioni_weekday', weekday);
    hive.put('lezioni_hour', hour);
    hive.put('lezioni_minute', minute);
    if (notEsercizi) {
      if (await NotificationAPI.hasPermissions()) {
        _scheduleLezioniReminder();
      } else {
        notEsercizi = false;
        hive.put('notifica_esercizi', false);
      }
    }
    notifyListeners();
  }

  void _scheduleLezioniReminder() {
    NotificationAPI.scheduleWeeklyOccurrences(
      baseId: _lezioniBaseId,
      title: "Lezioni",
      body: "Ciao! Ricorda di completare le tue lezioni!",
      weekday: lezioniWeekday,
      hour: lezioniHour,
      minute: lezioniMinute,
      weeksAhead: _weeklyOccurrencesAhead,
      channel: NotificationChannel.lessons,
    );
  }

  void disattivaNotificaLezioni() {
    notEsercizi = false;
    NotificationAPI.cancelWeeklyOccurrences(
      _lezioniBaseId,
      weeksAhead: _weeklyOccurrencesAhead,
    );
    hive.put("notifica_esercizi", false);
    notifyListeners();

    log("Notifica lezioni disattivata");
  }

  void setDebug(bool v) {
    debug = v;
    hive.put('debug', v);
    notifyListeners();
  }
}
