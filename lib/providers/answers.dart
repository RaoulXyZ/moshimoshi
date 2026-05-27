import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../questionHandlers/file_uploader_handler.dart';
import '../utility/local_user.dart';
import './user_settings.dart';

class Answers with ChangeNotifier {
  late Box hive;
  late Map<String, Map> _answers;
  List<String> _wrong = [];
  late List<String> _alreadySent;
  late String? uuid;

  void init() async {
    await Hive.openBox("MoshiMoshi").then((value) => hive = value);
    _answers = Map<String, Map>.from(hive.get("answers", defaultValue: {}));
    _alreadySent = List<String>.from(hive.get("alreadySent", defaultValue: []));

    uuid = LocalUser.currentUid();
  }

  void addWrong(String id) {
    if (!_wrong.contains(id)) {
      _wrong.add(id);
      notifyListeners();
    }
  }

  void removeWrong(String id) {
    if (_wrong.contains(id)) {
      _wrong.remove(id);
      notifyListeners();
    }
  }

  bool isWrong(String questionID) {
    return _wrong.contains(questionID);
  }

  Map<String, dynamic> get answers {
    return _answers;
  }

  void addAnswer(String surveyID, String questionID, dynamic answer) {
    addAnswerSilently(surveyID, questionID, answer);
    notifyListeners();
  }

  void addAnswerSilently(String surveyID, String questionID, dynamic answer) {
    _answers.update(
      surveyID,
      (value) {
        value.update(questionID, (value) => answer, ifAbsent: () => answer);

        return value;
      },
      ifAbsent: () => {questionID: answer},
    );

    hive.put("answers", _answers);
  }

  void removeAnswer(String surveyID, String questionID) {
    if (_answers.containsKey(surveyID) && _answers[surveyID] != null) {
      _answers[surveyID]!.remove(questionID);

      hive.put("answers", _answers);
      notifyListeners();
    }
  }

  dynamic getAnswer(String surveyID, String questionID) {
    if (_answers.containsKey(surveyID) && _answers[surveyID] != null) {
      if (_answers[surveyID]!.containsKey(questionID) &&
          _answers[surveyID] != null) {
        return _answers[surveyID]![questionID];
      }
    }

    return null;
  }

  bool hasAnswer(String surveyID, String questionID) {
    if (_answers.containsKey(surveyID) && _answers[surveyID] != null) {
      for (var key in _answers[surveyID]!.keys) {
        String k = key;
        if (key.contains('_')) {
          k = key.substring(0, key.indexOf('_'));
        }

        if (k == questionID) {
          return true;
        }
      }
    }

    return false;
  }

  bool hasAllAnswers(
    String surveyID,
    String questionID,
    List<String> choices,
    String answerID,
  ) {
    for (String choice in choices) {
      final String key = "${questionID}_${choice}_$answerID";
      if (answers[surveyID][key] == null) {
        return false;
      }
    }

    return true;
  }

  bool hasAnswerPGR(String surveyID, String questionID) {
    if (_answers.containsKey(surveyID) && _answers[surveyID] != null) {
      if (_answers[surveyID]!.containsKey(questionID) &&
          _answers[surveyID]![questionID] != null) {
        return true;
      }
    }

    return false;
  }

  bool hasAnswerChoice(
    String surveyID,
    String questionID,
    String choice, {
    bool hasAnswer = false,
    bool show = false,
    String prefix = "",
  }) {
    if (show) {
      log(prefix + " hasAnswerChoice: $surveyID, $questionID, $choice");
    }

    if (_answers.containsKey(surveyID) && _answers[surveyID] != null) {
      for (var key in _answers[surveyID]!.keys) {
        String k = key;

        if (key.startsWith(questionID) && key.contains('_')) {
          if (hasAnswer) {
            final int i = nThIndexOf(key, "_", 1) + 1;
            final int j = nThIndexOf(key, "_", 2);

            k = k.substring(i, j);
          } else {
            k = key.substring(key.lastIndexOf('_') + 1);
          }

          if (k == choice) {
            return true;
          }
        }
      }
    }

    return false;
  }

  int getAnswerCount(String surveyID) {
    if (_answers.containsKey(surveyID) && _answers[surveyID] != null) {
      return _answers[surveyID]!.length;
    }

    return 0;
  }

  int getAnswerCountKeys(String surveyID, List<String> keys) {
    if (_answers.containsKey(surveyID) && _answers[surveyID] != null) {
      final List<String> ans = [];

      for (var key in _answers[surveyID]!.keys) {
        for (var akey in keys) {
          String k = key;
          if (key.contains('_')) {
            k = key.substring(0, key.indexOf('_'));
          }

          if (k == akey && !ans.contains(k)) {
            log("Found matching key: $k");
            ans.add(k);
          }
        }
      }

      return ans.length;
    }

    return 0;
  }

  Future<String> sendAnswers(String surveyID, BuildContext ctx) async {
    if (Provider.of<UserSettings>(ctx, listen: false).canSend) {
      // && _alreadySent.contains(surveyID)

      final String mainUrl = dotenv.env['QUALTRICS_URL']!;
      final String token = dotenv.env['QUALTRICS_TOKEN']!;

      try {
        final res = await http.post(
          Uri.https(mainUrl, "/API/v3/surveys/$surveyID/responses"),
          headers: {
            'X-API-TOKEN': token,
            "Content-Type": "application/json",
          },
          body: jsonEncode(
            {
              'values': _answers[surveyID],
            },
          ),
        );

        log(jsonEncode({
          'values': _answers[surveyID],
        }));

        log(res.statusCode.toString());
        log(res.reasonPhrase.toString());
        log(res.body);

        if (res.statusCode != 200) return res.body;

        _alreadySent.add(surveyID);
        hive.put("alreadySent", _alreadySent);

        return "OK";
      } catch (e) {
        log(e.toString());

        return e.toString();
      }
    }
    log("********** PRETENDING TO SEND ANSWERS **********");

    return "OK";
  }

  Future<String> sendAnswersWithAttachment(
    String surveyID,
    BuildContext ctx,
  ) async {
    if (!Provider.of<UserSettings>(ctx, listen: false).canSend) {
      return "OK";
    }

    final String mainUrl = dotenv.env['QUALTRICS_URL']!;
    final String token = dotenv.env['QUALTRICS_TOKEN']!;

    try {
      final values = _answers[surveyID];
      final _ = values?.remove('QID3');

      final box = Hive.box('moshimoshi');
      final rawList = box.get('ragionidivita', defaultValue: <dynamic>[]);
      final List<StoredImage> images = (rawList as List)
          .map((e) => StoredImage.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      final unsent = images.where((img) => !img.saved).toList();

      if (unsent.isEmpty) {
        return sendAnswers(surveyID, ctx);
      }

      for (final img in unsent) {
        final sendName = img.deleted ? 'Deleted_${img.name}' : img.name;
        final request = http.MultipartRequest(
          'POST',
          Uri.https(mainUrl, "/API/v3/surveys/$surveyID/responses"),
        )..headers['X-API-TOKEN'] = token;

        request.files.add(
          await http.MultipartFile.fromBytes(
            'file1',
            img.bytes,
            filename: sendName,
          ),
        );
        request.fields['response'] = jsonEncode({'values': values});
        request.fields['fileMapping'] = jsonEncode({'file1': 'QID3'});

        final res = await request.send();
        final body = await res.stream.bytesToString();

        if (res.statusCode != 200) {
          log("❌ Errore API ${res.statusCode}: $body");
        }

        log("✅ Inviato con successo: $sendName");
        img.saved = true;
        final updated = images.map((e) => e.toJson()).toList();
        await box.put('ragionidivita', updated);
      }

      _alreadySent.add(surveyID);
      hive.put("alreadySent", _alreadySent);

      return "OK";
    } catch (e) {
      log("Eccezione during sendAnswersWithAttachment: $e");

      return e.toString();
    }
  }
}

int nThIndexOf(String og, String stringToFind, int n) {
  if (og.indexOf(stringToFind) == -1) return -1;
  if (n == 1) return og.indexOf(stringToFind);
  int subIndex = -1;
  while (n > 0) {
    subIndex = og.indexOf(stringToFind, subIndex + 1);
    n -= 1;
  }

  return subIndex;
}
