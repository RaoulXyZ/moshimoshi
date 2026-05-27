import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class Moduli with ChangeNotifier {
  late Box hive;
  late Map<String, String> moduli;
  Map<String, String> prettyName = {
    "pensieriautodistruttivi": "Pensieri Autodistruttivi",
    "depressioneansia": "Depressione e Ansia",
    "burnout": "Burnout e Stress Lavoro Correlato",
    "dolorecronico": "Dolore Cronico",
    "difficoltarelazionali": "Difficoltà Relazionali",
    "stiledivita": "Difficoltà nello Stile di Vita",
    "baseline_assessment": "Screening",
    "baseline_assessment_8": "Screening",
    "baseline_assessment_12": "Screening",
    "baseline_assessment_24": "Screening",
  };
  Map<String, Map<String, dynamic>> descrizioni = {
    "depressioneansia": {
      "intro":
          "La depressione è un'alterazione del tono dell'umore che si manifesta con sentimenti intensi di tristezza, vuoto, perdita di interesse ed energia. L'ansia, invece, è uno stato emotivo dominato da preoccupazione, tensione e paura. Entrambe costituiscono condizioni psicologiche complesse che possono influenzare profondamente il modo in cui pensiamo, sentiamo e ci relazioniamo con il mondo.",
      "percorso": "Percorso \"Depressione e Ansia\"",
      "desc_percorso":
          "Un percorso di cinque settimane per comprendere meglio depressione e ansia, riconoscerne i segnali e sviluppare strategie utili per il benessere psicologico. Ogni settimana affronta un tema diverso attraverso brevi contenuti, esempi e strumenti pratici.",
      "settimane": [
        {
          "titolo": "Settimana 1 - Introduzione alla depressione e all'ansia",
          "testo":
              "Scopri cosa sono la depressione e l'ansia, come influenzano i pensieri e le emozioni e in che modo lo stigma può ostacolare la ricerca di aiuto e la cura di sé.",
        },
        {
          "titolo": "Settimana 2 - Conoscere meglio l'ansia",
          "testo":
              "Approfondisci la funzione dell'ansia, impara a riconoscere i tuoi trigger e a comprendere i sintomi fisici che la accompagnano.",
        },
        {
          "titolo": "Settimana 3 - Riconquistare il proprio valore",
          "testo":
              "Esplora il ruolo dell'autostima e della motivazione nella depressione e nell'ansia e scopri nuove strategie per migliorare le tue risorse personali nella vita di ogni giorno.",
        },
        {
          "titolo": "Settimana 4 - Gestire i pensieri e le preoccupazioni",
          "testo":
              "Impara a riconoscere i pensieri negativi ripetitivi, distinguere tra sana preoccupazione e catastrofizzazione e applicare il problem solving per affrontare le difficoltà.",
        },
        {
          "titolo": "Settimana 5 - Facciamo il punto",
          "testo":
              "Rifletti sui progressi raggiunti, impara a prevenire le ricadute e riconosci i cambiamenti e le risorse che hai costruito lungo il percorso.",
        },
      ],
    },
    "burnout": {
      "intro":
          "La Sindrome del Burnout è una condizione che deriva da un'esposizione prolungata a situazioni di stress lavorativo cronico. Si manifesta con esaurimento emotivo, distacco o cinismo nei confronti del lavoro e una riduzione del senso di efficacia personale. Riconoscerne i segnali precoci è fondamentale per prevenire un impatto significativo sul benessere psicologico e professionale.",
      "percorso": "Percorso \"Burnout e Stress Lavoro-Correlato\"",
      "desc_percorso":
          "Un percorso di cinque settimane per comprendere lo stress legato al lavoro, riconoscerne i segnali e sviluppare strategie efficaci per ritrovare equilibrio e benessere. Ogni settimana propone contenuti psicoeducativi e strumenti pratici per gestire la pressione del lavoro e prevenire il burnout.",
      "settimane": [
        {
          "titolo": "Settimana 1 - Introduzione allo stress lavoro-correlato",
          "testo":
              "Scopri cosa sono lo stress e lo stress lavoro-correlato, come si manifesta il burnout e quali sono i segnali a cui prestare attenzione per intervenire in tempo.",
        },
        {
          "titolo": "Settimana 2 - Gestire lo stress lavoro-correlato",
          "testo":
              "Approfondisci il ruolo del perfezionismo e dello stacanovismo e impara a riconoscere le strategie di coping disfunzionali, sostituendole con modalità più sane ed efficaci.",
        },
        {
          "titolo": "Settimana 3 - Raggiungere un equilibrio vita-lavoro",
          "testo":
              "Impara a definire confini chiari tra vita personale e lavorativa e scopri strategie pratiche per preservare il tuo tempo, le tue energie e il tuo benessere.",
        },
        {
          "titolo": "Settimana 4 - Comunicare in modo efficace",
          "testo":
              "Scopri come migliorare la comunicazione, evitando modalità aggressive o passive, e allena l'assertività e la capacità di dire \"no\" in modo costruttivo e rispettoso.",
        },
        {
          "titolo": "Settimana 5 - Facciamo il punto",
          "testo":
              "Rifletti sui progressi compiuti, esplora gli ultimi consigli per mantenere l'equilibrio nel tempo e riconosci i cambiamenti raggiunti nel tuo percorso.",
        },
      ],
    },
    "pensieriautodistruttivi": {
      "intro":
          "Il suicidio e i pensieri suicidari sono condizioni di salute mentale che possono emergere quando una persona sperimenta una sofferenza così intensa da non riuscire più a individuare alternative al proprio dolore. Si tratta di problematiche più diffuse di quanto si possa immaginare. Affrontarle attraverso l'informazione e il supporto adeguato può aiutare a trovare un modo adeguato a gestire il proprio dolore.",
      "percorso": "Percorso \"Pensieri Autodistruttivi\"",
      "desc_percorso":
          "Un percorso di cinque settimane per comprendere, riconoscere e gestire i pensieri suicidari e autodistruttivi. Il programma aiuta a sviluppare consapevolezza e comprensione del dolore psicologico, a costruire strategie di sicurezza e coping e a riscoprire valori, risorse e obiettivi personali per favorire il benessere e la speranza.",
      "settimane": [
        {
          "titolo": "Settimana 1 - Riconoscere e gestire i pensieri suicidari",
          "testo":
              "Impara a riconoscere i pensieri suicidari e autodistruttivi e a comprenderne il significato. Viene introdotto il Safety Plan, uno strumento pratico per affrontare le situazioni di crisi, ridurre il rischio e aumentare la sicurezza personale.",
        },
        {
          "titolo": "Settimana 2 - Comprendere il dolore psicologico",
          "testo":
              "Approfondisci il concetto di dolore mentale e di come sia possibile affrontarlo. Esplora il modo in cui pensieri, comportamenti ed emozioni si influenzano reciprocamente. A partire dalle emozioni, scopri come allenarti ad esserne consapevole, accettarle e utilizzare strategie per gestirle.",
        },
        {
          "titolo":
              "Settimana 3 - Gestire i pensieri negativi e coltivare la mindfulness",
          "testo":
              "Scopri come i pensieri negativi possono alimentare la sofferenza e impara a riportare l'attenzione al momento presente attraverso la mindfulness. Vengono proposte tecniche per ridurre ruminazione e rimuginio e potenziare strategie di coping efficaci.",
        },
        {
          "titolo":
              "Settimana 4 - Riconoscere i propri valori, obiettivi e risorse",
          "testo":
              "Rifletti su ciò che per te ha valore e su come questi elementi possano guidare il tuo percorso di cambiamento. Impara a fissare obiettivi concreti e realistici e a riconoscere le risorse personali e relazionali su cui poter contare.",
        },
        {
          "titolo": "Settimana 5 - Il viaggio continua",
          "testo":
              "Rivedi i contenuti affrontati, consolida le strategie apprese e riconosci i tuoi progressi. Questa settimana ti accompagna a chiudere il percorso con un messaggio di cura e continuità, incoraggiandoti a mantenere l'attenzione al tuo benessere.",
        },
      ],
    },
    "dolorecronico": {
      "intro":
          "Con il termine \"dolore cronico\" si indica un dolore fisico che persiste oltre i normali tempi di guarigione. Questo tipo di dolore presenta caratteristiche tali da poter essere considerato esso stesso una condizione patologica, con impatto significativo sul benessere fisico, emotivo e sociale della persona.",
      "percorso": "Percorso \"Dolore Cronico\"",
      "desc_percorso":
          "Un percorso di cinque settimane dedicato alla comprensione e alla gestione del dolore cronico. Aiuta a esplorare l'esperienza del dolore nelle sue componenti fisiche, emotive e cognitive, offrendo strategie per migliorare la qualità di vita e favorire un senso di controllo e benessere.",
      "settimane": [
        {
          "titolo": "Settimana 1 - Il dolore e il suo impatto sulla vita",
          "testo":
              "Scopri cos'è il dolore, qual è la sua funzione e come può influenzare la vita quotidiana. Impara a comprendere la complessità del dolore cronico e il modo in cui mente e corpo interagiscono nella sua percezione.",
        },
        {
          "titolo": "Settimana 2 - Gestire il dolore",
          "testo":
              "Approfondisci diverse modalità per gestire il dolore in modo attivo. Impara a prenderti cura di te, a riprendere il controllo sulla tua vita e a costruire una routine che favorisca equilibrio e benessere.",
        },
        {
          "titolo": "Settimana 3 - Sentire il dolore",
          "testo":
              "Rifletti sulle emozioni associate al dolore e sul loro impatto psicologico. Attraverso esercizi di consapevolezza e tecniche di rilassamento, imparerai a entrare in contatto con le sensazioni corporee in modo più accogliente e meno reattivo.",
        },
        {
          "titolo": "Settimana 4 - Pensare al dolore",
          "testo":
              "Analizza il ruolo dei pensieri nella gestione del dolore. Impara a riconoscere gli schemi cognitivi tipici del dolore cronico e a sfidare i pensieri automatici che possono amplificarne l'intensità e l'impatto sulla vita.",
        },
        {
          "titolo": "Settimana 5 - Conclusioni",
          "testo":
              "Ripercorri i principali contenuti del percorso, apprendi strategie per gestire le riacutizzazioni e consolida le competenze acquisite. L'obiettivo finale è integrare quanto appreso nel tuo quotidiano e proseguire il viaggio verso un maggiore benessere.",
        },
      ],
    },
    "difficoltarelazionali": {
      "intro":
          "Le difficoltà relazionali si manifestano quando risulta complesso costruire o mantenere rapporti affettivi, emotivi o sociali equilibrati. Possono emergere in ambito sentimentale, familiare o nelle relazioni interpersonali più ampie, influenzando il benessere emotivo e la qualità della vita quotidiana.",
      "percorso": "Percorso \"Difficoltà Relazionali\"",
      "desc_percorso":
          "Un percorso di cinque settimane per esplorare il modo in cui costruiamo, viviamo e manteniamo le nostre relazioni. Aiuta a sviluppare consapevolezza di sé, competenze comunicative ed emotive, e strategie per affrontare la solitudine, i conflitti e i pregiudizi nelle relazioni interpersonali.",
      "settimane": [
        {
          "titolo": "Settimana 1 - Le relazioni: aspetti fondamentali",
          "testo":
              "Scopri perché le relazioni sono essenziali per il benessere psicologico, quali ostacoli possono comprometterle e come sviluppare maggiore efficacia nei rapporti con gli altri.",
        },
        {
          "titolo": "Settimana 2 - Non dimenticare se stessi",
          "testo":
              "Approfondisci il legame tra cura di sé e qualità delle relazioni. Impara a riconoscere e gestire solitudine e isolamento sociale, rafforzando le tue abilità sociali e il rispetto di te stesso nelle interazioni.",
        },
        {
          "titolo": "Settimana 3 - Abilità sociali e gestione dei conflitti",
          "testo":
              "Allena consapevolezza ed empatia, sviluppa una comunicazione più efficace e scopri strategie per gestire i conflitti in modo costruttivo, mantenendo relazioni più equilibrate.",
        },
        {
          "titolo": "Settimana 4 - I pregiudizi e la regolazione emotiva",
          "testo":
              "Esplora il ruolo dei pregiudizi nelle relazioni e impara a riconoscere e regolare le emozioni che emergono nelle interazioni sociali, per favorire comprensione e connessione autentica.",
        },
        {
          "titolo": "Settimana 5 - Facciamo il punto",
          "testo":
              "Rifletti sul percorso svolto, riconosci i tuoi progressi e consolida le competenze acquisite. Ricorda che la relazione perfetta non esiste, ma ogni passo verso l'autenticità migliora la qualità dei legami che costruiamo.",
        },
      ],
    },
    "stiledivita": {
      "intro":
          "Le difficoltà nello stile di vita si riferiscono all'adozione di abitudini poco salutari legate al sonno, all'alimentazione e all'attività fisica. Questi comportamenti possono influire negativamente sull'equilibrio psicofisico, riducendo energia, concentrazione e benessere generale.",
      "percorso": "Percorso \"Difficoltà nello Stile di Vita\"",
      "desc_percorso":
          "Un percorso di cinque settimane per migliorare il proprio stile di vita e promuovere benessere fisico e psicologico attraverso abitudini sane e equilibrate. Il programma aiuta a comprendere il legame tra corpo e mente, e offre strategie pratiche per migliorare il sonno, l'alimentazione e l'attività fisica.",
      "settimane": [
        {
          "titolo": "Settimana 1 - Introduzione a uno stile di vita sano",
          "testo":
              "Scopri cosa significa vivere in modo sano e bilanciato. Rifletti sulla relazione tra salute e benessere, preparati al cambiamento e impara a costruire abitudini quotidiane più funzionali.",
        },
        {
          "titolo": "Settimana 2 - I benefici del sonno",
          "testo":
              "Approfondisci l'importanza del sonno per la salute mentale e fisica. Impara a regolarizzare il ritmo sonno-veglia e a mettere in pratica semplici strategie di igiene del sonno.",
        },
        {
          "titolo": "Settimana 3 - I benefici di una sana alimentazione",
          "testo":
              "Comprendi il valore di una dieta equilibrata per migliorare l'energia e l'umore. Scopri come adottare un'alimentazione più consapevole ed equilibrata, introducendo cambiamenti graduali ma duraturi.",
        },
        {
          "titolo": "Settimana 4 - Mantenere il proprio corpo in salute",
          "testo":
              "Esplora i benefici dell'attività fisica e scopri diverse modalità di movimento adatte alle tue esigenze. Impara nuove strategie per aumentare la motivazione e mantenere la costanza nel tempo.",
        },
        {
          "titolo": "Settimana 5 - Facciamo il punto",
          "testo":
              "Rifletti sul percorso svolto, riconosci i tuoi progressi e identifica i messaggi chiave da portare con te. Impara a mantenere nel tempo le buone abitudini e a valorizzare anche le relazioni come parte del tuo benessere complessivo.",
        },
      ],
    },
  };
  Map<String, String> dailyWeekly = {
    "pensieriautodistruttivi": "MM_pensieriautodistruttivi_daily_weekly",
    "depressioneansia": "MM_depressioneansia_daily_weekly",
    "burnout": "MM_burnout_daily_weekly",
    "dolorecronico": "MM_dolorecronico_daily_weekly",
    "difficoltarelazionali": "MM_difficoltarelazionali_daily_weekly",
    "stiledivita": "MM_stiledivita_daily_weekly",
  };

  Map<String, String> images = {
    "pensieriautodistruttivi": "assets/pensieriautodistruttivi.jpg",
    "depressioneansia": "assets/depressione.jpg",
    "burnout": "assets/burnout.jpg",
    "dolorecronico": "assets/dolorecronico.jpg",
    "difficoltarelazionali": "assets/difficoltàrelazionali.jpg",
    "stiledivita": "assets/sonno.jpg",
    "baseline": "assets/baseline.jpg",
    "User": "assets/user.jpg",
  };

  Map<String, List<String>> esercizi = {
    "pensieriautodistruttivi": [
      "MM_pensieriautodistruttivi_week1",
      "MM_pensieriautodistruttivi_week2",
      "MM_pensieriautodistruttivi_week3",
      "MM_pensieriautodistruttivi_week4",
      "MM_pensieriautodistruttivi_week5",
      "MM_pensieriautodistruttivi_week6",
    ],
    "depressioneansia": [
      "MM_depressioneansia_week1",
      "MM_depressioneansia_week2",
      "MM_depressioneansia_week3",
      "MM_depressioneansia_week4",
      "MM_depressioneansia_week5",
      "MM_depressioneansia_week6",
      // "MM_depressioneansia_week7",
    ],
    "burnout": [
      "MM_burnout_week1",
      "MM_burnout_week2",
      "MM_burnout_week3",
      "MM_burnout_week4",
      "MM_burnout_week5",
      "MM_burnout_week6",
      // "burnout_week7",
    ],
    "dolorecronico": [
      "MM_dolorecronico_week1",
      "MM_dolorecronico_week2",
      "MM_dolorecronico_week3",
      "MM_dolorecronico_week4",
      "MM_dolorecronico_week5",
      "MM_dolorecronico_week6",
      // "dolorecronico_week7",
    ],
    "difficoltarelazionali": [
      "MM_difficoltarelazionali_week1",
      "MM_difficoltarelazionali_week2",
      "MM_difficoltarelazionali_week3",
      "MM_difficoltarelazionali_week4",
      "MM_difficoltarelazionali_week5",
      "MM_difficoltarelazionali_week6",
    ],
    "stiledivita": [
      "MM_stiledivita_week1",
      "MM_stiledivita_week2",
      "MM_stiledivita_week3",
      "MM_stiledivita_week4",
      "MM_stiledivita_week5",
      "MM_stiledivita_week6",
      // "sonno_week7",
    ],
  };

  void init() async {
    await Hive.openBox("MoshiMoshi").then((value) => hive = value);

    moduli = Map<String, String>.from(hive.get("moduli", defaultValue: {}));

    // calendarEvents = Map<String, List<String>>.from(
    //     hive.get("calendarEvents", defaultValue: {}));
    // exerciseScadences = Map<String, List<String>>.from(
    //     hive.get("exerciseScadences", defaultValue: {}));
    // dailyScreenings = Map<String, List<String>>.from(
    //     hive.get("dailyScreenings", defaultValue: {}));
    // weeklyScreenings = Map<String, List<String>>.from(
    //     hive.get("weeklyScreenings", defaultValue: {}));
  }

  void addModulo(String modulo, String livello, {bool notify = true}) {
    if (!moduli.containsKey(modulo)) {
      moduli.putIfAbsent(modulo, () => livello);
      hive.put("moduli", moduli);
      if (notify) {
        notifyListeners();
      }
    }
  }

  void removeModulo(String modulo) {
    if (moduli.containsKey(modulo)) {
      moduli.remove(modulo);
      hive.put("moduli", moduli);
      notifyListeners();
    }
  }

  bool hasModulo(String modulo) {
    return moduli.containsKey(modulo);
  }

  bool full() {
    return moduli.length >= 2;
  }

  // void finalizeEvents() {
  //   final nowTime = DateTime.now();
  //   final now = DateTime(nowTime.year, nowTime.month, nowTime.day, 12);

  //   for (String modulo in moduli.keys) {
  //     for (int i = 0; i <= 4; i++) {
  //       final key = DateFormat('yyyy-MM-dd')
  //           .format(now.add(Duration(days: (7 * (i + 1)) - 1)));
  //       if (!exerciseScadences.containsKey(key))
  //         exerciseScadences.putIfAbsent(key, () => [esercizi[modulo]![i]]);
  //       else
  //         exerciseScadences.update(key, (value) {
  //           value.add(esercizi[modulo]![i]);
  //           return value;
  //         });
  //     }

  //     var key =
  //         DateFormat('yyyy-MM-dd').format(now.add(Duration(days: (7 * 6) - 1)));
  //     exerciseScadences.putIfAbsent(
  //         key, () => [esercizi['difficoltarelazionali']![0]]);

  //     key =
  //         DateFormat('yyyy-MM-dd').format(now.add(Duration(days: (7 * 7) - 1)));

  //     exerciseScadences.putIfAbsent(
  //         key,
  //         () => [
  //               esercizi[moduli.keys.first]![5],
  //               esercizi[moduli.keys.last]![5]
  //             ]);

  //     for (int i = 1; i <= 49; i++) {
  //       final key =
  //           DateFormat('yyyy-MM-dd').format(now.add(Duration(days: i - 1)));

  //       if (i >= 36 && i <= 42) {
  //         // WEEK 6 - DIFFICOLTA RELAZIONALI

  //         if (!dailyScreenings.containsKey(key))
  //           dailyScreenings.putIfAbsent(
  //               key, () => ["daily_difficoltarelazionali_$i"]);
  //         else
  //           dailyScreenings.update(key, (value) {
  //             if (!value.contains("daily_difficoltarelazionali_$i"))
  //               value.add("daily_difficoltarelazionali_$i");
  //             return value;
  //           });

  //         if (i % 7 == 0 && i != 0) {
  //           int j = (i / 7).ceil();

  //           if (!weeklyScreenings.containsKey(key))
  //             weeklyScreenings.putIfAbsent(
  //                 key, () => ["weekly_difficoltarelazionali_$j"]);
  //           else
  //             weeklyScreenings.update(key, (value) {
  //               if (!value.contains("weekly_difficoltarelazionali_$j"))
  //                 value.add("weekly_difficoltarelazionali_$j");
  //               return value;
  //             });
  //         }
  //       } else {
  //         // WEEK 1-5 E 7, MODULI SCELTI

  //         if (!dailyScreenings.containsKey(key))
  //           dailyScreenings.putIfAbsent(key, () => ["daily_${modulo}_$i"]);
  //         else
  //           dailyScreenings.update(key, (value) {
  //             value.add("daily_${modulo}_$i");
  //             return value;
  //           });

  //         if (i % 7 == 0 && i != 0) {
  //           int j = (i / 7).ceil();

  //           if (!weeklyScreenings.containsKey(key))
  //             weeklyScreenings.putIfAbsent(key, () => ["weekly_${modulo}_$j"]);
  //           else
  //             weeklyScreenings.update(key, (value) {
  //               value.add("weekly_${modulo}_$j");
  //               return value;
  //             });
  //         }
  //       }
  //     }
  //   }

  //   var key = DateFormat('yyyy-MM-dd').format(now.add(Duration(days: (7 * 7))));
  //   exerciseScadences.putIfAbsent(
  //       key, () => ["user_experience_assessment_finale"]);

  //   key = DateFormat('yyyy-MM-dd').format(now.add(Duration(days: (7 * 8) - 1)));
  //   exerciseScadences.putIfAbsent(key, () => ["baseline_assessment_8"]);

  //   key =
  //       DateFormat('yyyy-MM-dd').format(now.add(Duration(days: (7 * 12) - 1)));
  //   exerciseScadences.putIfAbsent(key, () => ["baseline_assessment_12"]);

  //   key =
  //       DateFormat('yyyy-MM-dd').format(now.add(Duration(days: (7 * 24) - 1)));
  //   exerciseScadences.putIfAbsent(key, () => ["baseline_assessment_24"]);

  //   hive.put("exerciseScadences", exerciseScadences);
  //   hive.put("weeklyScreenings", weeklyScreenings);
  //   hive.put("dailyScreenings", dailyScreenings);
  //   print(exerciseScadences);
  // }

  String getPrettyName(String surveyName) {
    return prettyName[surveyName] ?? "No pretty name for $surveyName";
  }
}
