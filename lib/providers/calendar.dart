import 'package:flutter/material.dart';

class Calendar with ChangeNotifier {
  DateTime today = DateTime.now();
  DateTime focusedDay = DateTime.now();

  void setFocusedDay(DateTime day, {notify = true}) {
    focusedDay = day;
    if (notify) {
      notifyListeners();
    }
  }

  void setToday(DateTime day) {
    today = day;
  }
}
