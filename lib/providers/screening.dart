import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';

import '../utility.dart';
import '../providers/answers.dart';
import '../providers/questions.dart';

class Screening with ChangeNotifier {
  List<String> _doneBlocks = [];
  Map<String, int> _patologie = {};
  Map<String, String> scelte = {};
  Map<String, String> daScegliere = {};
  late String _sesso;
  late bool _anni;
  late bool _terapia;
  // ignore: unused_field
  late bool _bdiAnxiety = false;
  // ignore: unused_field
  late bool _bdiSleep = false;
  // ignore: unused_field
  late bool _psqiPain = false;
  late Box hive;

  void init() async {
    await Hive.openBox("MoshiMoshi").then((value) => hive = value);
    _patologie = Map<String, int>.from(
      hive.get(
        "patologie_selezionate",
        defaultValue: {},
      ),
    );
    _sesso = hive.get("sesso", defaultValue: "");
    _anni = hive.get("anni", defaultValue: false);
    _terapia = hive.get("terapia", defaultValue: false);
  }

  void addDone(String blockName, BuildContext ctx) {
    if (!_doneBlocks.contains(blockName)) {
      _doneBlocks.add(blockName);
      notifyListeners();
    }

    evaluate(blockName, ctx);
  }

  void updateDone(String blockName) {
    if (!_doneBlocks.contains(blockName)) {
      _doneBlocks.add(blockName);
    }
  }

  bool isDone(String blockName) {
    return _doneBlocks.contains(blockName);
  }

  List<String> getDone() {
    return _doneBlocks;
  }

  void doneScreening() {
    /* ****************** FOR TESTING PURPOSE ONLY ******************  */
    /*
    _anni = false;
    _terapia = true;
    _patologie.clear();
    scelte.clear();
    daScegliere.clear();
    _bdiAnxiety = false;
    _bdiSleep = false;
    _psqiPain = false;

    _patologie.putIfAbsent("pensieriautodistruttivi", () => 0);
    _patologie.putIfAbsent("depressione", () => 2);
    _patologie.putIfAbsent("ansia", () => 0);
    _patologie.putIfAbsent("sonno", () => 0);
    _patologie.putIfAbsent("dolorecronico", () => 0);
    _patologie.putIfAbsent("burnout", () => 0);
    */
    /* ****************** FOR TESTING PURPOSE ONLY ******************  */

    final List<String> alto =
        _patologie.keys.where((k) => _patologie[k] == 3).toList();
    final List<String> moderato =
        _patologie.keys.where((k) => _patologie[k] == 2).toList();
    final List<String> lieve =
        _patologie.keys.where((k) => _patologie[k] == 1).toList();
    // List<String> minimo = _patologie.keys.where((k) => _patologie[k] == 0).toList();

    final List<String> priority = [
      // "pensieriautodistruttivi",
      "burnout",
      "depressioneansia",
      "difficoltarelazionali",
      "dolorecronico",
      "stiledivita",
    ];

    // Dopo 08/04/2020 inviano tutti
    if ((alto.length + moderato.length + lieve.length) >= 0) {
      //era >= 2 prima, rimetterlo per farlo funzionare solo dopo screening completo
      /*if (_terapia && _anni) {
        Provider.of<UserSettings>(ctx, listen: false).setCanSend(true);
      } else {
        Provider.of<UserSettings>(ctx, listen: false).setCanSend(false);
      }
      */

      for (String palta in alto) {
        daScegliere.putIfAbsent(palta, () => "Alto");
      }

      for (String pmoderata in moderato) {
        daScegliere.putIfAbsent(pmoderata, () => "Moderato");
      }

      for (String plieve in lieve) {
        daScegliere.putIfAbsent(plieve, () => "Lieve");
      }

      for (String pminima in priority.where((element) =>
          !alto.contains(element) &&
          !moderato.contains(element) &&
          !lieve.contains(element))) {
        daScegliere.putIfAbsent(pminima, () => "Minimo");
      }

      // int i = 0;
      // while (scelte.length < 2) {
      //   if (alto.contains(priority[i])) {
      //     scelte.putIfAbsent(priority[i], () => "Alto");
      //     daScegliere.remove(priority[i]);
      //   } else if (moderato.contains(priority[i])) {
      //     scelte.putIfAbsent(priority[i], () => "Moderato");
      //     daScegliere.remove(priority[i]);
      //   } else if (lieve.contains(priority[i])) {
      //     scelte.putIfAbsent(priority[i], () => "Lieve");
      //     daScegliere.remove(priority[i]);
      //   }

      //   i++;
      // }

      //METTO "PENSIERI AUTODISTRUTTIVI" IN SCELTE

      scelte.putIfAbsent("pensieriautodistruttivi", () => "Alto");

      //VECCHIO METTO "PENSIERI AUTODISTRUTTIVI" IN SCELTE
      // if (alto.contains("pensieriautodistruttivi")) {
      //     scelte.putIfAbsent("pensieriautodistruttivi", () => "Alto");
      //     daScegliere.remove("pensieriautodistruttivi");
      // } else if (moderato.contains("pensieriautodistruttivi")) {
      //     scelte.putIfAbsent("pensieriautodistruttivi", () => "Moderato");
      //     daScegliere.remove("pensieriautodistruttivi");
      // } else if (lieve.contains("pensieriautodistruttivi")) {
      //     scelte.putIfAbsent("pensieriautodistruttivi", () => "Lieve");
      //     daScegliere.remove("pensieriautodistruttivi");
      // }

      // daScegliere.clear();

      log("---------- DONE SCREENING ----------");
      log("PATOLOGIE SCELTE: " + scelte.toString());
    }
    // else {
    //   // Provider.of<UserSettings>(ctx, listen: false).setCanSend(false);

    //   for (int i = 0; i < priority.length; i++) {
    //     if (alto.contains(priority[i])) {
    //       scelte.putIfAbsent(priority[i], () => "Alto");
    //     } else if (moderato.contains(priority[i])) {
    //       scelte.putIfAbsent(priority[i], () => "Moderato");
    //     } else if (lieve.contains(priority[i])) {
    //       scelte.putIfAbsent(priority[i], () => "Lieve");
    //     } else {
    //       daScegliere.putIfAbsent(priority[i], () => "Minimo");
    //     }
    //   }
    // }

    /* ****************** OLD ALGORITHM ******************
    // pensieriautodistruttivi ha la precedenza su tutti e può essere solo Alto o Minimo
    if (alto.contains("pensieriautodistruttivi")) {
      scelte.putIfAbsent("pensieriautodistruttivi", () => "Alto");
      alto.remove("pensieriautodistruttivi");
    }

    _gestisciLista(alto, "Alto");
    _gestisciLista(moderato, "Moderato");
    _gestisciLista(lieve, "Lieve");
    _gestisciLista(minimo, "Minimo");
    */
  }

  /* ****************** OLD ALGORITHM ******************
  void _gestisciLista(List<String> lista, String livello) {
    if (scelte.length < 2 && scelte.length + daScegliere.length < 3) {
      if (livello == "Alto" || livello == "Moderato") {
        if (lista.length > 0) {
          // depressione ha la precedenza
          if (lista.contains("depressione")) {
            scelte.putIfAbsent("depressione", () => livello);
            lista.remove("depressione");
          }
        }
      }

      if (livello != "Minimo") {
        if (lista.contains("ansia") && _bdiAnxiety && scelte.length < 2) {
          scelte.putIfAbsent("ansia", () => livello);
          lista.remove("ansia");
        }

        if (lista.contains("sonno") && _bdiSleep && scelte.length < 2) {
          scelte.putIfAbsent("sonno", () => livello);
          lista.remove("sonno");
        }

        if (lista.contains("dolorecronico") && _psqiPain && scelte.length < 2) {
          scelte.putIfAbsent("dolorecronico", () => livello);
          lista.remove("dolorecronico");
        }
      }

      // Se l'algoritmo ne ha già scelte due stop
      if (scelte.length == 2) {
        return;
      }

      // Se ce ne sono altre con livello alto, l'utente può scegliere
      if (lista.length != 0) {
        while (lista.isNotEmpty) {
          daScegliere.putIfAbsent(lista.first, () => livello);
          lista.remove(lista.first);
        }

        if (scelte.length + daScegliere.length >= 3)
          return;
        else {
          // Se _scelte + _daScegliere <= 2, metto tutto in _scelte
          // Es. ho una scelta dall'algoritmo e una da scegliere
          while (daScegliere.isNotEmpty) {
            scelte.putIfAbsent(daScegliere.keys.first, () => livello);
            daScegliere.remove(daScegliere.keys.first);
          }

          if (scelte.length == 2) return;
        }
      }
    }
  } */

  void check() {
    log("Scelte: " + scelte.toString());
    log("Da Scegliere: " + daScegliere.toString());
  }

  void evaluate(
    String blockName,
    BuildContext context,
  ) {
    log("--- EVALUATE SCREENING ---");
    try {
      final answersProvider = Provider.of<Answers>(context, listen: false);
      final questionsProvider = Provider.of<Questions>(context, listen: false);

      final surveyID =
          questionsProvider.surveyID("MM_baseline_assessment_week1");
      // print(surveyID);

      final answers =
          Map<String, dynamic>.from(answersProvider.answers[surveyID]);

      final questions = questionsProvider.questions(
        "MM_baseline_assessment_week1",
        blockName,
      );

      switch (blockName) {
        case 'criteri_di_inclusione':
          final String anniID = questions.values.elementAt(1)['QuestionID'];
          final String anni = answers["${anniID}_TEXT"].toString();

          if (int.tryParse(anni) != null) {
            _anni = int.parse(anni) <= 29 && int.parse(anni) >= 18;

            hive.put("anni", _anni);
          }

          final String terapiaID = questions.values.elementAt(4)['QuestionID'];
          final String tAns = answers[terapiaID].toString();
          _terapia =
              questions.values.elementAt(4)['Choices'][tAns]['Display'] == "No";
          hive.put("terapia", _terapia);

          break;
        case 'domande_sociodemografiche':
          final String sID = questions.values.first['QuestionID'];
          final String sAns = answers[sID].toString();
          _sesso = questions.values.first['Choices'][sAns]['Display'];
          hive.put("sesso", _sesso);
          break;
        case 'screening_depressione':
          _bdi2(answers, questions);
          break;
        case 'screening_ansia':
          _stai(answers, questions);
          break;
        case 'screening_sonno':
          _psqi(answers, questions);
          break;
        case 'screening_pensieri_autodistruttivi':
          _cssrs(answers, questions);
          break;
        case 'screening_burnout':
          _sbi(answers, questions);
          break;
        case 'screening_sintomi_dolorosi':
          _bpi(answers, questions);
          break;
      }
    } catch (e, stacktrace) {
      log(e.toString());
      log(stacktrace.toString());
    }

    hive.put("patologie_selezionate", _patologie);
  }

  void _bpi(Map<String, dynamic> answers, Map<String, dynamic> questions) {
    int pss = 0, psi = 0;

    for (int i = 0; i < questions.length; i++) {
      final question = questions.values.elementAt(i);
      final String qid = question['QuestionID'];

      switch (i) {
        case 2:
          final int answer = answers[qid];
          final String text = question['Choices'][answer]['Display'];
          pss += int.parse(text);
          break;

        case 3:
          final int answer = answers[qid];
          final String text = question['Choices'][answer]['Display'];
          pss += int.parse(text);
          break;

        case 4:
          final int answer = answers[qid];
          final String text = question['Choices'][answer]['Display'];
          pss += int.parse(text);
          break;

        case 5:
          final int answer = answers[qid];
          final String text = question['Choices'][answer]['Display'];
          pss += int.parse(text);
          break;

        case 8:
          for (var choice in question['Choices'].keys) {
            final String selected = answers["${qid}_$choice"].toString();
            String answer;

            answer = selected != "null"
                ? question['Answers'][selected]['Display']
                : "0";
            answer = answer.replaceAll(RegExp(r'[^0-9]'), '');
            psi += int.parse(answer);
          }
          break;
      }
    }

    pss = (pss / 4).ceil();
    psi = (psi / 7).ceil();

    final int punteggio = math.max(pss, psi);

    if (punteggio < 5) {
      _patologie.putIfAbsent("dolorecronico", () => 0);
    } else if (punteggio < 7) {
      _patologie.putIfAbsent("dolorecronico", () => 1);
    } else if (punteggio < 9) {
      _patologie.putIfAbsent("dolorecronico", () => 2);
    } else {
      _patologie.putIfAbsent("dolorecronico", () => 3);
    }
  }

  void _sbi(Map<String, dynamic> answers, Map<String, dynamic> questions) {
    double esaurimento = 0, cinismo = 0, inadeguatezza = 0;

    for (int i = 1; i < questions.length; i++) {
      final String qid = questions.keys.toList()[i];
      String text =
          questions.values.toList()[i]['Choices']["${answers[qid]}"]['Display'];

      text = text.replaceAll(RegExp(r'[^0-9]'), ''); // levo html
      final double val = double.parse(text.substring(text.length - 1));

      if (i == 1 || i == 4 || i == 7 || i == 9) esaurimento += val;
      if (i == 2 || i == 5 || i == 6) cinismo += val;
      if (i == 3 || i == 8) inadeguatezza += val;
    }

    esaurimento = esaurimento / 4;
    cinismo = cinismo / 3;
    inadeguatezza = inadeguatezza / 2;

    int punteggio = 0;

    if (equalsIgnoreCase(_sesso, "uomo") ||
        equalsIgnoreCase(_sesso, "uomo trans")) {
      if (esaurimento >= 4.307) {
        punteggio = 3;
      } else if (esaurimento >= 3.613 && punteggio < 2) {
        punteggio = 2;
      } else if (esaurimento >= 2.92 && punteggio < 1) {
        punteggio = 1;
      }

      if (cinismo >= 4.4) {
        punteggio = 3;
      } else if (cinismo >= 3.78 && punteggio < 2) {
        punteggio = 2;
      } else if (cinismo >= 3.17 && punteggio < 1) {
        punteggio = 1;
      }

      if (inadeguatezza >= 4.41) {
        punteggio = 3;
      } else if (inadeguatezza >= 3.83 && punteggio < 2) {
        punteggio = 2;
      } else if (inadeguatezza >= 3.23 && punteggio < 1) {
        punteggio = 1;
      }
    } else if (equalsIgnoreCase(_sesso, "donna") ||
        equalsIgnoreCase(_sesso, "donna trans")) {
      if (esaurimento >= 4.35) {
        punteggio = 3;
      } else if (esaurimento >= 3.7 && punteggio < 2) {
        punteggio = 2;
      } else if (esaurimento >= 3.05 && punteggio < 1) {
        punteggio = 1;
      }

      if (cinismo >= 4.353) {
        punteggio = 3;
      } else if (cinismo >= 3.707 && punteggio < 2) {
        punteggio = 2;
      } else if (cinismo >= 3.06 && punteggio < 1) {
        punteggio = 1;
      }

      if (inadeguatezza >= 4.373) {
        punteggio = 3;
      } else if (inadeguatezza >= 3.746 && punteggio < 2) {
        punteggio = 2;
      } else if (inadeguatezza >= 3.12 && punteggio < 1) {
        punteggio = 1;
      }
    } else {
      if (esaurimento >= 4.324) {
        punteggio = 3;
      } else if (esaurimento >= 3.607 && punteggio < 2) {
        punteggio = 2;
      } else if (esaurimento >= 2.98 && punteggio < 1) {
        punteggio = 1;
      }

      if (cinismo >= 4.38) {
        punteggio = 3;
      } else if (cinismo >= 3.74 && punteggio < 2) {
        punteggio = 2;
      } else if (cinismo >= 3.11 && punteggio < 1) {
        punteggio = 1;
      }

      if (inadeguatezza >= 4.39) {
        punteggio = 3;
      } else if (inadeguatezza >= 3.79 && punteggio < 2) {
        punteggio = 2;
      } else if (inadeguatezza >= 3.17 && punteggio < 1) {
        punteggio = 1;
      }
    }

    _patologie.putIfAbsent("burnout", () => punteggio);
  }

  void _cssrs(Map<String, dynamic> answers, Map<String, dynamic> questions) {
    final List<int> peso2 = [2, 3, 4, 5, 6, 10, 11, 12, 13];
    String text;

    _patologie.remove("pensieriautodistruttivi");

    for (int i = 0; i < questions.length; i++) {
      final question = questions.values.elementAt(i);

      text = question['QuestionType'] != "DB" &&
              answers.containsKey(question['QuestionID'])
          ? question['Choices']["${answers[question['QuestionID']]}"]['Display']
          : '';

      if (peso2.contains(i) && text == 'Sì') {
        _patologie.putIfAbsent("pensieriautodistruttivi", () => 3);
        i = questions.length;
      }
    }

    _patologie.putIfAbsent("pensieriautodistruttivi", () => 0);
  }

  void _psqi(Map<String, dynamic> answers, Map<String, dynamic> questions) {
    int c1 = 0, c2 = 0, c3 = 0, c4 = 0, c5 = 0, c6 = 0, c7 = 0;
    int oreDormite = 0, oreLetto = 0;
    int inizio = 0, fine = 0;

    for (int i = 0; i < questions.length; i++) {
      final question = questions.values.elementAt(i);
      final String qid = question['QuestionID'];

      try {
        switch (i) {
          // COMPONENTE 4 - Item 1
          case 1:
            final String cid = question['Choices'].keys.first;
            inizio = int.parse(answers["${qid}_$cid"].substring(
              0,
              answers["${qid}_$cid"].indexOf(RegExp(r'[^0-9]')) - 1,
            ));
            break;

          // COMPONENTE 4 - Item 3
          case 3:
            final String cid = question['Choices'].keys.first;
            fine = int.parse(answers["${qid}_$cid"].substring(
              0,
              answers["${qid}_$cid"].indexOf(RegExp(r'[^0-9]')) - 1,
            ));
            while (inizio != fine) {
              if (inizio == 24) inizio = 0;
              oreLetto++;
              inizio++;
            }

            break;

          // COMPONENTE 2 - Item 2
          case 2:
            final String cid = question['Choices'].keys.first;
            final int answer = int.parse(answers["${qid}_$cid"].substring(
              0,
              answers["${qid}_$cid"].indexOf(RegExp(r'[^0-9]')) - 1,
            ));
            if (answer <= 15) {
              c2 = 0;
            } else if (answer <= 30) {
              c2 = 1;
            } else if (answer <= 60) {
              c2 = 2;
            } else {
              c2 = 3;
            }
            break;

          // COMPONENTI 3, 4 - Item 4
          case 4:
            final String cid = question['Choices'].keys.first;
            oreDormite = int.parse(answers["${qid}_$cid"].substring(
              0,
              answers["${qid}_$cid"].indexOf(RegExp(r'[^0-9]')) - 1,
            ));

            if (oreDormite < 5) {
              c3 = 3;
            } else if (oreDormite < 6) {
              c3 = 2;
            } else if (oreDormite < 7) {
              c3 = 1;
            } else {
              c3 = 0;
            }
            break;

          // COMPONENTI 2 e 5 - Item 5
          case 5:
            for (int i = 1; i < 10; i++) {
              final String id = qid + "_$i";
              final String answer =
                  question['Answers']['${answers[id]}']['Display'];

              if (i == 1) {
                c2 += checkItem5(answer);
              } else {
                c5 += checkItem5(answer);
              }

              if (i == 9) if (checkItem5(answer) >= 3) _psqiPain = true;
            }

            break;

          // COMPONENTE 1 - Item 6
          case 8:
            final String text =
                question['Choices']["${answers[qid]}"]['Display'];

            if (equalsIgnoreCase(text, 'molto buona')) {
              c1 = 0;
            } else if (equalsIgnoreCase(text, 'abbastanza buona')) {
              c1 = 1;
            } else if (equalsIgnoreCase(text, 'abbastanza cattiva')) {
              c1 = 2;
            } else {
              c1 = 3;
            }

            break;

          // COMPONENTE 6 - Item 7
          case 9:
            final String text =
                question['Choices']["${answers[qid]}"]['Display'];
            c6 = checkItem5(text);
            break;

          // COMPONENTE 7 - Item 8
          case 10:
            final String text =
                question['Choices']["${answers[qid]}"]['Display'];
            c7 = checkItem5(text);
            break;

          // COMPONENTE 7 - Item 9
          case 11:
            final String text =
                question['Choices']["${answers[qid]}"]['Display'];

            if (equalsIgnoreCase(text, 'per niente')) {
              c7 += 0;
            } else if (equalsIgnoreCase(text, 'poco')) {
              c7 += 1;
            } else if (equalsIgnoreCase(text, 'abbastanza')) {
              c7 += 2;
            } else {
              c7 += 3;
            }
            break;
        }
      } catch (e) {}
    }

    c2 = (c2 / 2).ceil();

    final double efficaciaSonno = (oreDormite / oreLetto) * 100;
    if (efficaciaSonno < 65) {
      c4 = 3;
    } else if (efficaciaSonno < 75) {
      c4 = 2;
    } else if (efficaciaSonno < 85) {
      c4 = 1;
    } else {
      c4 = 0;
    }

    c5 = (c5 / 9).ceil();

    c7 = (c7 / 2).ceil();

    final int tot = c1 + c2 + c3 + c4 + c5 + c6 + c7;

    if (tot < 5) {
      _patologie.putIfAbsent("sonno", () => 0);
    } else if (tot < 10) {
      _patologie.putIfAbsent("sonno", () => 1);
    } else if (tot < 15) {
      _patologie.putIfAbsent("sonno", () => 2);
    } else {
      _patologie.putIfAbsent("sonno", () => 3);
    }
  }

  void _bdi2(Map<String, dynamic> answers, Map<String, dynamic> questions) {
    int punteggio = 0;

    for (var question in questions.values) {
      try {
        final String text = question['Choices']
            ["${answers[question['QuestionID']]}"]['Display'];
        final int risposta = int.parse(text.substring(0, 1));

        if (question['QuestionText'].contains('Suicidio')) {
          if (risposta >= 1) {
            _patologie.putIfAbsent("pensieriautodistruttivi", () => 3);
          }
        }

        if (question['QuestionText'].contains('Agitazione')) {
          if (risposta >= 2) _bdiAnxiety = true;
        }

        if (question['QuestionText'].contains('sonno')) {
          if (risposta > 1) _bdiSleep = true;
        }

        punteggio += risposta;
      } catch (e) {}
    }

    if (punteggio <= 13) {
      _patologie.putIfAbsent("depressione", () => 0);
    } else if (punteggio <= 19) {
      _patologie.putIfAbsent("depressione", () => 1);
    } else if (punteggio <= 28) {
      _patologie.putIfAbsent("depressione", () => 2);
    } else if (punteggio <= 63) {
      _patologie.putIfAbsent("depressione", () => 3);
    }
  }

  void _stai(Map<String, dynamic> answers, Map<String, dynamic> questions) {
    int sai = 0;
    int tai = 0;
    int punteggio;
    final List<int> reverseCoded = [
      1,
      2,
      5,
      8,
      10,
      11,
      15,
      16,
      19,
      20,
      22,
      24,
      27,
      28,
      31,
      34,
      35,
      37,
      40,
    ];

    for (int i = 0; i < questions.length; i++) {
      final question = questions.values.elementAt(i);
      final String qid = question['QuestionID'];

      try {
        int risposta = 0;
        final String text =
            question['Choices']["${answers[qid]}"]['Display'].substring(0, 1);

        risposta =
            reverseCoded.contains(i) ? 5 - int.parse(text) : int.parse(text);

        if (i > 20) {
          tai += risposta;
        } else {
          sai += risposta;
        }
      } catch (e) {}
    }

    punteggio = math.max(sai, tai);

    if (punteggio < 40) {
      _patologie.putIfAbsent("ansia", () => 0);
    } else if (punteggio < 50) {
      _patologie.putIfAbsent("ansia", () => 1);
    } else if (punteggio < 60) {
      _patologie.putIfAbsent("ansia", () => 2);
    } else if (punteggio <= 80) {
      _patologie.putIfAbsent("ansia", () => 3);
    }
  }
}

int checkItem5(String answer) {
  if (equalsIgnoreCase(answer, 'non durante l’ultimo mese') ||
      equalsIgnoreCase(answer, 'non durante l\'ultimo mese')) {
    return 0;
  } else if (equalsIgnoreCase(answer, 'meno di 1 volta a settimana')) {
    return 1;
  } else if (equalsIgnoreCase(answer, '1 o 2 volte a settimana')) {
    return 2;
  } else {
    return 3;
  }
}
