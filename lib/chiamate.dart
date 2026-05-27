// import 'dart:developer';
// import 'dart:io';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:get/utils.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:provider/provider.dart';
// import 'package:moshi_moshi/utility/error_logger.dart';

// import 'providers/questions.dart';
// import 'providers/answers.dart';
// import 'providers/user_settings.dart';
// import 'providers/moduli.dart';
// import 'providers/progress.dart';
// import 'providers/screening.dart';

// final String mainUrl = dotenv.env['QUALTRICS_URL']!;
// final String token = dotenv.env['QUALTRICS_TOKEN']!;

// // logger centralizzato in lib/utility/error_logger.dart

// Future<String> initQuestions(
//   BuildContext ctx,
//   bool isDemo,
//   bool canSend,
// ) async {
//   log('initQuestions started');

//   // Initialize settings and answers
//   Provider.of<UserSettings>(ctx, listen: false).init(
//     isDemo: isDemo,
//     canSend: canSend,
//   );
//   Provider.of<Answers>(ctx, listen: false).init();

//   final _questions = Provider.of<Questions>(ctx, listen: false);
//   final pProvider = Provider.of<Progress>(ctx, listen: false);
//   final mProvider = Provider.of<Moduli>(ctx, listen: false);
//   final sProvider = Provider.of<Screening>(ctx, listen: false);

//   // Initialize providers
//   mProvider.init();
//   pProvider.init();
//   sProvider.init();

//   final bool _saved = await _questions.areQuestionsSaved();
//   log('Questions saved to local? $_saved');

//   if (!_saved) {
//     try {
//       final surveys = await getSurveys();
//       log('Fetched ${surveys.length} surveys: ${surveys.map((s) => s['name']).join(", ")}');

//       for (var survey in surveys) {
//         final id = survey['id'];
//         final name = survey['name'];
//         log('Processing survey: id=$id, name=$name');

//         if (name == "MM_settings") {
//           log('Loading MM_settings definitions');
//           http.get(
//             Uri.https(mainUrl, "/API/v3/survey-definitions/$id"),
//             headers: {'X-API-TOKEN': token},
//           ).then((value) {
//             final Map<String, dynamic> result =
//                 json.decode(utf8.decode(value.bodyBytes, allowMalformed: true))
//                     as Map<String, dynamic>;
//             final blocks =
//                 Map<String, dynamic>.from(result['result']['Blocks']);
//             blocks.removeWhere((key, value) => value['Type'] == 'Trash');
//             log('MM_settings blocks count after cleanup: ${blocks.length}');

//             blocks.forEach((key, value) {
//               final description = value['Description'];
//               log('MM_settings block: key=$key, description=$description');
//               final List<dynamic> questionsList = value['BlockElements'];

//               if (description == "survey_names") {
//                 for (var q in questionsList) {
//                   final qid = q['QuestionID'];
//                   final names =
//                       result['result']['Questions'][qid]['QuestionText'];
//                   final Map<String, dynamic> namesMap =
//                       Map<String, dynamic>.from(json.decode(names));
//                   _questions.names.addEntries(
//                     namesMap.entries.map((e) => MapEntry(e.key, e.value)),
//                   );
//                 }
//                 log('Loaded survey_names count: ${_questions.names.length}');
//               } else if (description == "testi_profilo") {
//                 final aboutQ = questionsList[0];
//                 final aboutId = aboutQ['QuestionID'];
//                 _questions.profileAbout =
//                     result['result']['Questions'][aboutId]['QuestionText'];
//                 final creditsQ = questionsList[1];
//                 final creditsId = creditsQ['QuestionID'];
//                 _questions.profileCredits = result['result']['Questions']
//                         [creditsId]['QuestionText']
//                     .replaceAll("<br>", "");
//                 log('Loaded testi_profilo: about and credits');
//               } else if (description == "exercise_images") {
//                 final imgQ = questionsList.first;
//                 final imgId = imgQ['QuestionID'];
//                 final imgStr =
//                     result['result']['Questions'][imgId]['QuestionText'];
//                 final Map<String, dynamic> imgMap =
//                     Map<String, dynamic>.from(json.decode(imgStr));
//                 _questions.images = imgMap;
//                 log('Loaded exercise_images count: ${_questions.images.length}');
//               }
//             });
//           });
//           continue;
//         }

//         // Prepare structures for blocks and questions
//         final Map<String, dynamic> questionsMap = {};
//         final Map<String, dynamic> blocksMap = {};

//         // Register survey
//         _questions.addSurvey(id, name);
//         log('Registered survey in provider: name=$name, id=$id');

//         if (ctx.mounted) {
//           await getBlocksQuestions(
//             id,
//             blocksMap,
//             questionsMap,
//             ctx,
//           );
//           log('Fetched blocks and questions for $name: '
//               'blocks=${blocksMap.length}, questions=${questionsMap.length}');
//         }

//         // Process each block
//         for (var entry in blocksMap.entries) {
//           final blockId = entry.key;
//           final blocco = entry.value;
//           if (blocco != null && blocco['BlockElements'] != null) {
//             final description = blocco['Description'];
//             final elements = blocco['BlockElements'] as List<dynamic>;
//             log('Processing block id=$blockId, description=$description, elements=${elements.length}');

//             _questions.addBlock(name, blockId, description);

//             for (var el in elements) {
//               final qid = el['QuestionID'];
//               final qData = questionsMap[qid];
//               if (el['Type'] != "Page Break" &&
//                   qData['QuestionType'] != "Timing") {
//                 _questions.addQuestion(
//                   name,
//                   description,
//                   qid,
//                   qData,
//                 );
//                 log('Added question: id=$qid, type=${qData['QuestionType']}');
//               }
//             }
//             log('Finished block $blockId for survey $name');
//           }
//         }

//         // Persist local
//         await _questions.writeToLocal();
//         log('Wrote survey $name to local storage');
//       }

//       // log('==================================================');
//       // await verifyAndSyncQuestions(ctx);
//       // log('==================================================');
//     } catch (e, st) {
//       log('Error in initQuestions: $e', stackTrace: st);
//       await logErrorToFirestore(e, st);

//       return e.toString();
//     }
//   } else {
//     await _questions.readFromLocal();

//     final testimonianze = await _questions
//         .getSurveys()
//         .firstWhereOrNull((t) => t == "MM_testimonianze");

//     if (testimonianze != null) {
//       try {
//         final String testimID = _questions.surveyID("MM_testimonianze");
//         log('Forzo aggiornamento MM_testimonianze, surveyID: $testimID');

//         // Creo due mappe vuote per blocchi e domande
//         final Map<String, dynamic> blocksMap = {};
//         final Map<String, dynamic> questionsMap = {};

//         if (ctx.mounted) {
//           await getBlocksQuestions(
//             testimID,
//             blocksMap,
//             questionsMap,
//             ctx,
//           );
//           log('Fetched blocks/questions per MM_testimonianze: '
//               'blocks=${blocksMap.length}, questions=${questionsMap.length}');
//         }

//         // Rimuovo la vecchia entrata di MM_testimonianze
//         await _questions.removeSurvey("MM_testimonianze");

//         // Ricreo "MM_testimonianze" nel provider, usando lo stesso nome e ID
//         _questions.addSurvey(testimID, "MM_testimonianze");
//         log('Re-registered survey MM_testimonianze nel provider');

//         // Aggiungo i blocchi e le domande nuove
//         for (var entry in blocksMap.entries) {
//           final blockId = entry.key;
//           final blocco = entry.value;
//           if (blocco != null && blocco['BlockElements'] != null) {
//             final description = blocco['Description'];
//             final elements = blocco['BlockElements'] as List<dynamic>;
//             log('Processing block id=$blockId (MM_testimonianze), description=$description');

//             _questions.addBlock("MM_testimonianze", blockId, description);

//             for (var el in elements) {
//               final qid = el['QuestionID'];
//               final qData = questionsMap[qid];
//               if (el['Type'] != "Page Break" &&
//                   qData['QuestionType'] != "Timing") {
//                 _questions.addQuestion(
//                   "MM_testimonianze",
//                   description,
//                   qid,
//                   qData,
//                 );
//                 log('Added question MM_testimonianze: id=$qid, type=${qData['QuestionType']}');
//               }
//             }
//             log('Finished block $blockId for survey MM_testimonianze');
//           }
//         }

//         // Riscrivo in locale l'intero _questions (includendo la versione aggiornata)
//         await _questions.writeToLocal();
//         await _questions.readFromLocal();
//         log('MM_testimonianze sovrascritto nei dati locali');
//       } catch (e, st) {
//         log('Errore nel forzare update MM_testimonianze: $e', stackTrace: st);
//         await logErrorToFirestore(e, st);
//         // Se qualcosa va storto, non interrompo l’esecuzione: proseguo comunque
//       }
//     } else {
//       log('MM_testimonianze non esiste tra i sondaggi locali, skippo l’override.');
//     }
//   }

//   // Determine next screen
//   final next =
//       (pProvider.doneSurveys.contains("MM_baseline_assessment_week1") &&
//               mProvider.moduli.length == 2)
//           ? "Home"
//           : "Screening";

//   log('initQuestions complete, navigating to $next');

//   return next;
// }

// Future<List<Map<String, dynamic>>> getSurveys() async {
//   log('Sto prendendo le survey...');
//   final List<Map<String, dynamic>> surveys = [];
//   // Inizializza nextPageUrl con il path relativo
//   String? nextPageUrl = '/API/v3/surveys';

//   while (nextPageUrl != null) {
//     try {
//       // Costruisci l'URI: se nextPageUrl è un URL assoluto, parse diretto, altrimenti usa host + path
//       final Uri uri = Uri.tryParse(nextPageUrl)?.hasScheme == true
//           ? Uri.parse(nextPageUrl)
//           : Uri.https(mainUrl, nextPageUrl);
//       log('Fetching surveys from $uri');

//       final response = await http.get(
//         uri,
//         headers: {'X-API-TOKEN': token},
//       );
//       if (response.statusCode != 200) {
//         throw HttpException(
//           'Failed to load surveys: HTTP ${response.statusCode}',
//         );
//       }

//       // Decodifica JSON
//       final Map<String, dynamic> jsonData = json.decode(
//         utf8.decode(response.bodyBytes, allowMalformed: true),
//       ) as Map<String, dynamic>;
//       // Elements sono sotto result
//       final data = jsonData['result'] as Map<String, dynamic>;

//       // Aggiungi gli elementi ricevuti
//       final elements =
//           (data['elements'] as List<dynamic>).cast<Map<String, dynamic>>();
//       surveys.addAll(elements);
//       log('Ricevuti ${elements.length} elementi, totale: ${surveys.length}');

//       // nextPage può trovarsi a livello superiore o dentro 'result'
//       String? rawNext;
//       if (jsonData.containsKey('nextPage')) {
//         rawNext = jsonData['nextPage'] as String?;
//       } else if (data.containsKey('nextPage')) {
//         rawNext = data['nextPage'] as String?;
//       }

//       // Aggiorna nextPageUrl o termina
//       nextPageUrl = rawNext != null && rawNext.isNotEmpty ? rawNext : null;
//     } catch (e, st) {
//       log('Errore durante getSurveys: $e', stackTrace: st);
//       await logErrorToFirestore(e, st);
//       break;
//     }
//   }

//   log('getSurveys completato: trovate ${surveys.length} survey');

//   return surveys;
// }

// Future<void> getBlocksQuestions(
//   String surveyID,
//   Map<String, dynamic> blocks,
//   Map<String, dynamic> questions,
//   BuildContext ctx,
// ) async {
//   try {
//     final res = await http.get(
//       Uri.https(mainUrl, "/API/v3/survey-definitions/$surveyID"),
//       headers: {
//         'X-API-TOKEN': token,
//       },
//     );

//     if (ctx.mounted) {
//       final Map<String, dynamic> result =
//           json.decode(utf8.decode(res.bodyBytes, allowMalformed: true))
//               as Map<String, dynamic>;
//       final Map<String, dynamic> unorderedBlocks = result['result']['Blocks'];

//       // Cancello il blocco Trash/Cestino
//       unorderedBlocks.removeWhere((key, value) => value['Type'] == 'Trash');

//       // Prendi blocchi UUID
//       final uuidBlocks = List.from(unorderedBlocks.entries
//           .where((element) => element.value['Description'] == 'UUID')
//           .toList());

//       // Scrivi UUID nelle relative domande fittizie
//       final ap = Provider.of<Answers>(ctx, listen: false);
//       // final box = await Hive.openBox("MoshiMoshi");

//       final String? uuid =
//           FirebaseAuth.instance.currentUser?.uid; //  box.get("UUID");

//       uuidBlocks.forEach((element) {
//         final qid = element.value["BlockElements"][0]["QuestionID"];
//         ap.addAnswer(surveyID, "${qid}_TEXT", uuid);

//         // Evita di mostrare il blocco UUID nell'app
//         unorderedBlocks.remove(element.key);
//       });

//       final List<dynamic> flow = result['result']['SurveyFlow']['Flow'];

//       flow.forEach((element) {
//         blocks.putIfAbsent(element['ID'], () => unorderedBlocks[element['ID']]);
//       });

//       result['result']['Questions'].forEach((key, value) {
//         questions.putIfAbsent(key, () => value);
//       });
//     }
//   } catch (e, st) {
//     log(e.toString());
//     await logErrorToFirestore(e, st);
//   }
// }

// Future<dynamic> getDiaryContent(String surveyID) async {
//   // Ottieni l'UUID dell'utente loggato
//   final uuid = FirebaseAuth.instance.currentUser?.uid;
//   if (uuid == null) {
//     final err = "Utente non autenticato";
//     await logErrorToFirestore(err);
//     throw Exception(err);
//   }

//   // Iniziamo la richiesta di esportazione
//   final exportUri =
//       Uri.https(mainUrl, "/API/v3/surveys/$surveyID/export-responses");
//   final exportResponse = await http.post(
//     exportUri,
//     headers: {
//       'X-API-TOKEN': token,
//       'Content-Type': 'application/json',
//     },
//     body: jsonEncode({
//       "format": "json",
//       "compress": false,
//     }),
//   );

//   if (exportResponse.statusCode != 200) {
//     final err = "Errore nell'avvio dell'export: ${exportResponse.statusCode}";
//     await logErrorToFirestore(err);
//     throw Exception(err);
//   }

//   // Estraiamo il progressId dalla risposta
//   final exportResult = jsonDecode(exportResponse.body)['result'];
//   final progressId = exportResult['progressId'];
//   if (progressId == null) {
//     final err = "ProgressId non trovato nella risposta di export.";
//     await logErrorToFirestore(err);
//     throw Exception(err);
//   }

//   // Polling: Continuiamo a controllare lo stato dell'export finché non è completato
//   final progressUri = Uri.https(
//     mainUrl,
//     "/API/v3/surveys/$surveyID/export-responses/$progressId",
//   );

//   bool exportComplete = false;
//   int attempts = 0;
//   const int maxAttempts = 60;
//   Map<String, dynamic> progressResult = {};

//   while (!exportComplete && attempts < maxAttempts) {
//     final progressResponse = await http.get(
//       progressUri,
//       headers: {
//         'X-API-TOKEN': token,
//       },
//     );
//     if (progressResponse.statusCode != 200) {
//       final err =
//           "Errore nel recupero del progresso dell'export: ${progressResponse.statusCode}";
//       await logErrorToFirestore(err);
//       throw Exception(err);
//     }

//     progressResult = jsonDecode(progressResponse.body)['result'];
//     final percentComplete = progressResult['percentComplete'] ?? 0;
//     if (percentComplete >= 100) {
//       exportComplete = true;
//       break;
//     }
//     await Future.delayed(const Duration(seconds: 1));
//     attempts++;
//   }

//   if (!exportComplete) {
//     final err = "Timeout: l'export non è stato completato in tempo.";
//     await logErrorToFirestore(err);
//     throw Exception(err);
//   }

//   final fileId = progressResult['fileId'];
//   if (fileId == null) {
//     final err =
//         "FileId non trovato. L'export potrebbe non essere ancora completato.";
//     await logErrorToFirestore(err);
//     throw Exception(err);
//   }

//   // Recuperiamo il file contenente i dati esportati
//   final fileUri = Uri.https(
//     mainUrl,
//     "/API/v3/surveys/$surveyID/export-responses/$fileId/file",
//   );
//   final fileResponse = await http.get(
//     fileUri,
//     headers: {
//       'X-API-TOKEN': token,
//     },
//   );
//   if (fileResponse.statusCode != 200) {
//     final err =
//         "Errore nel recupero del file esportato: ${fileResponse.statusCode}";
//     await logErrorToFirestore(err);
//     throw Exception(err);
//   }

//   final jsonData = jsonDecode(fileResponse.body);

//   // Filtra le risposte per trovare quella che appartiene all'utente (UUID uguale a QID6_TEXT)
//   if (jsonData['responses'] != null && jsonData['responses'] is List) {
//     final responses = jsonData['responses'] as List<dynamic>;
//     Map<String, dynamic>? matchingResponse;
//     for (final response in responses) {
//       if (response['values'] != null &&
//           response['values']['QID6_TEXT'] == uuid) {
//         matchingResponse = response;
//         break;
//       }
//     }

//     // Se abbiamo trovato la risposta dell'utente, decodifica le note
//     if (matchingResponse != null &&
//         matchingResponse['values'] != null &&
//         matchingResponse['values']['QID5_TEXT'] != null) {
//       final diaryString = matchingResponse['values']['QID5_TEXT'];
//       if (diaryString is String) {
//         final List<dynamic> entriesJson = jsonDecode(diaryString);

//         return entriesJson
//             .map<Map<String, String>>((entry) => {
//                   "timestamp": entry["timestamp"] as String,
//                   "content": entry["content"] as String,
//                 })
//             .toList();
//       }
//     }
//   }

//   return [];
// }

// Future<void> verifyAndSyncQuestions(
//   BuildContext ctx,
// ) async {
//   log('verifyAndSyncQuestions START');
//   final questionsProvider = Provider.of<Questions>(ctx, listen: false);

//   // 1. Se non ci sono domande locali, inizializza completamente
//   // final saved = await questionsProvider.areQuestionsSaved();
//   // log('Domande salvate in locale? $saved');
//   // if (!saved) {
//   //   log('Nessun dato locale, inizializzo completamente');
//   //   await initQuestions(ctx, isDemo, canSend);
//   //   log('initQuestions completato in verifyAndSyncQuestions');
//   //   return;
//   // }

//   // 2. Carica le domande salvate
//   await questionsProvider.readFromLocal();
//   log('Dati locali caricati: ${questionsProvider.getSurveys().length} sondaggi');

//   // 3. Recupera lista sondaggi remoti
//   final remoteSurveys = await getSurveys();
//   log('Sondaggi remoti trovati: ${remoteSurveys.length}');

//   // 4. Per ogni sondaggio remoto, sincronizza solo ciò che manca
//   for (var survey in remoteSurveys) {
//     final name = survey['name']?.toString();
//     final id = survey['id']?.toString();
//     log('Processo sondaggio remoto: name=$name, id=$id');
//     if (name == null || id == null || name.isEmpty || id.isEmpty) {
//       log('Skipping sondaggio con dati null o vuoti');
//       continue;
//     }

//     // 4a. Se il sondaggio manca, aggiungi completamente
//     if (!questionsProvider.getSurveys().contains(name)) {
//       log('Aggiungo sondaggio mancante: $name');
//       questionsProvider.addSurvey(id, name);
//     }

//     // 4b. Scarica definizioni remote
//     final Map<String, dynamic> blocksMap = {};
//     final Map<String, dynamic> questionsMap = {};
//     if (ctx.mounted) {
//       log('Richiedo blocchi e domande per $name');
//       await getBlocksQuestions(
//         id,
//         blocksMap,
//         questionsMap,
//         ctx,
//       );
//       log('Ricevuti ${blocksMap.length} blocchi e ${questionsMap.length} domande per $name');
//     }

//     // 4c. Sincronizza blocchi
//     for (var entry in blocksMap.entries) {
//       final blockId = entry.key;
//       final block = entry.value as Map<String, dynamic>?;
//       if (block == null) {
//         log('Blocco null per id $blockId, skip');
//         continue;
//       }

//       final elements = block['BlockElements'] as List<dynamic>?;
//       final desc = block['Description']?.toString() ?? 'unknown';
//       if (elements == null) {
//         log('Elemento BlockElements null per blocco $blockId, skip');
//         continue;
//       }

//       if (!questionsProvider.hasBlock(name, blockId)) {
//         log('Aggiungo blocco mancante $blockId ($desc) al sondaggio $name');
//         questionsProvider.addBlock(name, blockId, desc);
//       }

//       // 4d. Sincronizza domande del blocco
//       for (var el in elements) {
//         final qid = el['QuestionID']?.toString();
//         final qData =
//             qid != null ? questionsMap[qid] as Map<String, dynamic>? : null;
//         final type = el['Type']?.toString();
//         final isPageBreak = type == 'Page Break';
//         final isTiming = qData?['QuestionType'] == 'Timing';

//         if (qid == null) {
//           log('QuestionID null in blocco $blockId, skip');
//           continue;
//         }
//         if (isPageBreak) {
//           log('Page Break question $qid in blocco $blockId, skip');
//           continue;
//         }
//         if (qData == null) {
//           log('Dati domanda null per $qid, skip');
//           continue;
//         }
//         if (isTiming) {
//           log('Timing question $qid in blocco $blockId, skip');
//           continue;
//         }

//         if (!questionsProvider.hasQuestion(name, qid)) {
//           log('Aggiungo domanda mancante $qid al blocco $blockId del sondaggio $name');
//           questionsProvider.addQuestion(
//             name,
//             desc,
//             qid,
//             qData,
//           );
//         }
//       }
//     }
//   }

//   // 5. Salva le modifiche locali
//   await questionsProvider.writeToLocal();
//   log('Modifiche salvate in locale');
//   log('verifyAndSyncQuestions END');
// }

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

import 'providers/questions.dart';
import 'providers/answers.dart';
import 'providers/user_settings.dart';
import 'providers/moduli.dart';
import 'providers/progress.dart';
import 'providers/screening.dart';
import 'utility/local_user.dart';

final String mainUrl = dotenv.env['QUALTRICS_URL']!;
final String token = dotenv.env['QUALTRICS_TOKEN']!;

// logger centralizzato in lib/utility/error_logger.dart

/// Mappa name→id di tutte le survey Qualtrics, costruita al primo avvio
/// e riutilizzata da loadModuleSurveys.
Map<String, String> _surveyIndex = {};

/// Survey comuni da scaricare sempre insieme ai moduli scelti.
const List<String> _commonSurveys = [
  "MM_SP_segnalidiavvertimento",
  "MM_SP_strategiedicopinginterne",
  "MM_SP_strategiedicopingesterne",
  "MM_SP_contattipersonali",
  "MM_SP_contattiprofessionali",
  "MM_SP_ambientesicuro",
  "MM_SP_ragionidivita",
  "MM_lista_attivita_piacevoli",
  "MM_testimonianze",
  "MM_diariopersonale",
];

/// Calcola la lista di nomi survey necessari per la coppia di moduli scelti.
List<String> getRequiredSurveyNames(String modulo1, String modulo2) {
  final Set<String> names = {};

  // Daily screenings: week 1-5,7 per i moduli scelti + week 6 per difficoltarelazionali
  // for (final modulo in [modulo1, modulo2]) {
  for (int week = 1; week <= 7; week++) {
    // if (week == 6) continue;
    for (int day = 1; day <= 7; day++) {
      names.add("MM_${modulo1}_${modulo2}_daily_w${week}_d$day");
    }
  }
  // }
  // for (int day = 1; day <= 7; day++) {
  //   names.add("MM_difficoltarelazionali_daily_w6_d$day");
  // }

  // Weekly screenings: week 2-5,7 per i moduli + week 6 per difficoltarelazionali
  for (final modulo in [modulo1, modulo2]) {
    for (int week = 2; week <= 7; week++) {
      // if (week == 6) continue;
      names.add("MM_${modulo}_weekly_w$week");
    }
  }
  // names.add("MM_difficoltarelazionali_weekly_w6");

  // Exercises: week 1-5 per i moduli + week 6 per difficoltarelazionali
  for (final modulo in [modulo1, modulo2]) {
    for (int week = 1; week <= 6; week++) {
      names.add("MM_${modulo}_week$week");
    }
  }
  // names.add("MM_difficoltarelazionali_week6");

  // Daily/weekly survey per i moduli
  // names.add("MM_${modulo1}_daily_weekly");
  // names.add("MM_${modulo2}_daily_weekly");
  // names.add("MM_difficoltarelazionali_daily_weekly");

  // Baseline assessment futuri
  names.add("MM_baseline_assessment_8");
  names.add("MM_baseline_assessment_12");
  names.add("MM_baseline_assessment_24");

  // Survey comuni (safety planning, testimonianze, etc.)
  names.addAll(_commonSurveys);

  return names.toList();
}

/// Scarica e processa una singola survey dato il suo nome e id.
Future<void> _fetchAndProcessSurvey(
  String name,
  String id,
  Questions questionsProvider,
  BuildContext ctx,
) async {
  final Map<String, dynamic> questionsMap = {};
  final Map<String, dynamic> blocksMap = {};

  questionsProvider.addSurvey(id, name);
  log('Registered survey in provider: name=$name, id=$id');

  if (ctx.mounted) {
    await getBlocksQuestions(id, blocksMap, questionsMap, ctx);
    log('Fetched blocks and questions for $name: '
        'blocks=${blocksMap.length}, questions=${questionsMap.length}');
  }

  for (var entry in blocksMap.entries) {
    final blockId = entry.key;
    final blocco = entry.value;
    if (blocco != null && blocco['BlockElements'] != null) {
      final description = blocco['Description'];
      final elements = blocco['BlockElements'] as List<dynamic>;

      questionsProvider.addBlock(name, blockId, description);

      for (var el in elements) {
        final qid = el['QuestionID'];
        final qData = questionsMap[qid];
        if (el['Type'] != "Page Break" && qData['QuestionType'] != "Timing") {
          questionsProvider.addQuestion(name, description, qid, qData);
        }
      }
    }
  }
}

/// Scarica le impostazioni (MM_mindblooming_settings) dal survey Qualtrics.
Future<void> _loadSettings(String id, Questions questionsProvider) async {
  log('Loading MM_settings definitions');
  final value = await http.get(
    Uri.https(mainUrl, "/API/v3/survey-definitions/$id"),
    headers: {'X-API-TOKEN': token},
  );
  final Map<String, dynamic> result =
      json.decode(utf8.decode(value.bodyBytes, allowMalformed: true))
          as Map<String, dynamic>;
  final blocks = Map<String, dynamic>.from(result['result']['Blocks']);
  blocks.removeWhere((key, value) => value['Type'] == 'Trash');

  blocks.forEach((key, value) {
    final description = value['Description'];
    final List<dynamic> questionsList = value['BlockElements'];

    if (description == "survey_names") {
      for (var q in questionsList) {
        final qid = q['QuestionID'];
        final names = result['result']['Questions'][qid]['QuestionText'];
        final Map<String, dynamic> namesMap =
            Map<String, dynamic>.from(json.decode(names));
        questionsProvider.names.addEntries(
          namesMap.entries.map((e) => MapEntry(e.key, e.value)),
        );
      }
      log('Loaded survey_names count: ${questionsProvider.names.length}');
    } else if (description == "testi_profilo") {
      final aboutQ = questionsList.first;
      final aboutId = aboutQ['QuestionID'];
      questionsProvider.profileAbout =
          result['result']['Questions'][aboutId]['QuestionText'];
      final creditsQ = questionsList[1];
      final creditsId = creditsQ['QuestionID'];
      questionsProvider.profileCredits = result['result']['Questions']
              [creditsId]['QuestionText']
          .replaceAll("<br>", "");
      log('Loaded testi_profilo: about and credits');
    } else if (description == "exercise_images") {
      final imgQ = questionsList.first;
      final imgId = imgQ['QuestionID'];
      final imgStr = result['result']['Questions'][imgId]['QuestionText'];
      final Map<String, dynamic> imgMap =
          Map<String, dynamic>.from(json.decode(imgStr));
      questionsProvider.images = imgMap;
      log('Loaded exercise_images count: ${questionsProvider.images.length}');
    }
  });
}

/// Costruisce l'indice name→id delle survey Qualtrics.
Future<Map<String, String>> _buildSurveyIndex() async {
  if (_surveyIndex.isNotEmpty) {
    return _surveyIndex;
  }
  final surveys = await getSurveys();
  log('Fetched ${surveys.length} surveys for index');
  for (var survey in surveys) {
    final name = survey['name']?.toString();
    final id = survey['id']?.toString();
    if (name != null && id != null) {
      _surveyIndex[name] = id;
    }
  }

  return _surveyIndex;
}

Future<String> initQuestions(
  BuildContext ctx,
  bool isDemo,
  bool canSend,
) async {
  log('initQuestions started');

  // Initialize settings and answers
  Provider.of<UserSettings>(ctx, listen: false).init(
    isDemo: isDemo,
    canSend: canSend,
  );
  Provider.of<Answers>(ctx, listen: false).init();

  final _questions = Provider.of<Questions>(ctx, listen: false);
  final pProvider = Provider.of<Progress>(ctx, listen: false);
  final mProvider = Provider.of<Moduli>(ctx, listen: false);
  final sProvider = Provider.of<Screening>(ctx, listen: false);

  // Initialize providers
  mProvider.init();
  pProvider.init();
  sProvider.init();

  final bool _saved = await _questions.areQuestionsSaved();
  log('Questions saved to local? $_saved');

  if (!_saved) {
    try {
      // Costruisci l'indice name→id e scarica solo settings + baseline
      final index = await _buildSurveyIndex();

      // Scarica MM_mindblooming_settings
      final settingsId = index["MM_settings"];
      if (settingsId != null) {
        await _loadSettings(settingsId, _questions);
      }

      // Scarica MM_baseline_assessment (screening iniziale)
      final baselineId = index["MM_baseline_assessment_week1"];
      if (baselineId != null && ctx.mounted) {
        await _fetchAndProcessSurvey(
          "MM_baseline_assessment",
          baselineId,
          _questions,
          ctx,
        );
      }

      // Scarica MM_baseline_assessment_week1 (necessario per check navigazione)
      final baselineWeek1Id = index["MM_baseline_assessment_week1"];
      if (baselineWeek1Id != null && ctx.mounted) {
        await _fetchAndProcessSurvey(
          "MM_baseline_assessment_week1",
          baselineWeek1Id,
          _questions,
          ctx,
        );
      }

      await _questions.writeToLocal();
      log('Wrote initial surveys to local storage');
    } catch (e, st) {
      log('Error in initQuestions (Qualtrics unreachable): $e', stackTrace: st);
      // Providers are already initialized from Hive — fall through to
      // navigation logic so the user reaches the app instead of NoInternetScreen.
    }
  } else {
    await _questions.readFromLocal();

    // Forza aggiornamento MM_testimonianze ad ogni avvio (contenuto dinamico)
    final testimonianze = _questions
        .getSurveys()
        .firstWhereOrNull((t) => t == "MM_testimonianze");

    if (testimonianze != null) {
      try {
        final String testimID = _questions.surveyID("MM_testimonianze");
        log('Forzo aggiornamento MM_testimonianze, surveyID: $testimID');

        final Map<String, dynamic> blocksMap = {};
        final Map<String, dynamic> questionsMap = {};

        if (ctx.mounted) {
          await getBlocksQuestions(testimID, blocksMap, questionsMap, ctx);
        }

        await _questions.removeSurvey("MM_testimonianze");
        _questions.addSurvey(testimID, "MM_testimonianze");

        for (var entry in blocksMap.entries) {
          final blockId = entry.key;
          final blocco = entry.value;
          if (blocco != null && blocco['BlockElements'] != null) {
            final description = blocco['Description'];
            final elements = blocco['BlockElements'] as List<dynamic>;

            _questions.addBlock("MM_testimonianze", blockId, description);

            for (var el in elements) {
              final qid = el['QuestionID'];
              final qData = questionsMap[qid];
              if (el['Type'] != "Page Break" &&
                  qData['QuestionType'] != "Timing") {
                _questions.addQuestion(
                  "MM_testimonianze",
                  description,
                  qid,
                  qData,
                );
              }
            }
          }
        }

        await _questions.writeToLocal();
        await _questions.readFromLocal();
        log('MM_testimonianze sovrascritto nei dati locali');
      } catch (e, st) {
        log('Errore nel forzare update MM_testimonianze: $e', stackTrace: st);
      }
    }
  }

  // Determine next screen
  final next =
      (pProvider.doneSurveys.contains("MM_baseline_assessment_week1") &&
              mProvider.moduli.length == 2)
          ? "Home"
          : "Screening";

  log('initQuestions complete, navigating to $next');

  return next;
}

/// Scarica da Qualtrics solo le survey necessarie per i moduli scelti.
/// Da chiamare dopo la selezione dei moduli, prima di navigare alla Home.
Future<void> loadModuleSurveys(
  BuildContext ctx,
  String modulo1,
  String modulo2,
) async {
  log('loadModuleSurveys started for $modulo1, $modulo2');

  final questionsProvider = Provider.of<Questions>(ctx, listen: false);
  final index = await _buildSurveyIndex();
  final requiredNames = getRequiredSurveyNames(modulo1, modulo2);

  log('Survey da scaricare: ${requiredNames.length}');

  for (final name in requiredNames) {
    // Salta se già scaricata in locale
    if (questionsProvider.getSurveys().contains(name)) {
      log('Survey $name già presente, skip');
      continue;
    }

    final id = index[name];
    if (id == null) {
      log('Survey $name non trovata nell\'indice Qualtrics, skip');
      continue;
    }

    if (!ctx.mounted) break;

    await _fetchAndProcessSurvey(name, id, questionsProvider, ctx);
  }

  await questionsProvider.writeToLocal();
  log('loadModuleSurveys complete');
}

Future<List<Map<String, dynamic>>> getSurveys() async {
  log('Sto prendendo le survey...');
  final List<Map<String, dynamic>> surveys = [];
  // Inizializza nextPageUrl con il path relativo
  String? nextPageUrl = '/API/v3/surveys';

  while (nextPageUrl != null) {
    try {
      // Costruisci l'URI: se nextPageUrl è un URL assoluto, parse diretto, altrimenti usa host + path
      final Uri uri = Uri.tryParse(nextPageUrl)?.hasScheme == true
          ? Uri.parse(nextPageUrl)
          : Uri.https(mainUrl, nextPageUrl);
      log('Fetching surveys from $uri');

      final response = await http.get(
        uri,
        headers: {'X-API-TOKEN': token},
      );
      if (response.statusCode != 200) {
        throw HttpException(
          'Failed to load surveys: HTTP ${response.statusCode}',
        );
      }

      // Decodifica JSON
      final Map<String, dynamic> jsonData = json.decode(
        utf8.decode(response.bodyBytes, allowMalformed: true),
      ) as Map<String, dynamic>;
      // Elements sono sotto result
      final data = jsonData['result'] as Map<String, dynamic>;

      // Aggiungi gli elementi ricevuti
      final elements =
          (data['elements'] as List<dynamic>).cast<Map<String, dynamic>>();
      surveys.addAll(elements);
      log('Ricevuti ${elements.length} elementi, totale: ${surveys.length}');

      // nextPage può trovarsi a livello superiore o dentro 'result'
      String? rawNext;
      if (jsonData.containsKey('nextPage')) {
        rawNext = jsonData['nextPage'] as String?;
      } else if (data.containsKey('nextPage')) {
        rawNext = data['nextPage'] as String?;
      }

      // Aggiorna nextPageUrl o termina
      nextPageUrl = rawNext != null && rawNext.isNotEmpty ? rawNext : null;
    } catch (e, st) {
      log('Errore durante getSurveys: $e', stackTrace: st);
      // await logErrorToFirestore(e, st);
      break;
    }
  }

  log('getSurveys completato: trovate ${surveys.length} survey');

  return surveys;
}

Future<void> getBlocksQuestions(
  String surveyID,
  Map<String, dynamic> blocks,
  Map<String, dynamic> questions,
  BuildContext ctx,
) async {
  try {
    final res = await http.get(
      Uri.https(mainUrl, "/API/v3/survey-definitions/$surveyID"),
      headers: {
        'X-API-TOKEN': token,
      },
    );

    if (ctx.mounted) {
      final Map<String, dynamic> result =
          json.decode(utf8.decode(res.bodyBytes, allowMalformed: true))
              as Map<String, dynamic>;
      final Map<String, dynamic> unorderedBlocks = result['result']['Blocks'];

      // Cancello il blocco Trash/Cestino
      unorderedBlocks.removeWhere((key, value) => value['Type'] == 'Trash');

      // Prendi blocchi UUID
      final uuidBlocks = List.from(unorderedBlocks.entries
          .where((element) => element.value['Description'] == 'UUID')
          .toList());

      // Scrivi UUID nelle relative domande fittizie
      final ap = Provider.of<Answers>(ctx, listen: false);
      // final box = await Hive.openBox("MindBlooming");

      final String? uuid = LocalUser.currentUid();

      uuidBlocks.forEach((element) {
        final qid = element.value["BlockElements"][0]["QuestionID"];
        ap.addAnswer(surveyID, "${qid}_TEXT", uuid);

        // Evita di mostrare il blocco UUID nell'app
        unorderedBlocks.remove(element.key);
      });

      final List<dynamic> flow = result['result']['SurveyFlow']['Flow'];

      flow.forEach((element) {
        blocks.putIfAbsent(element['ID'], () => unorderedBlocks[element['ID']]);
      });

      result['result']['Questions'].forEach((key, value) {
        questions.putIfAbsent(key, () => value);
      });
    }
  } catch (e) {
    log(e.toString());
    // await logErrorToFirestore(e, st);
  }
}

Future<dynamic> getDiaryContent(String surveyID) async {
  final uuid = LocalUser.currentUid();
  if (uuid == null) {
    final err = "Utente non autenticato";
    // await logErrorToFirestore(err);
    throw Exception(err);
  }

  // Iniziamo la richiesta di esportazione
  final exportUri =
      Uri.https(mainUrl, "/API/v3/surveys/$surveyID/export-responses");
  final exportResponse = await http.post(
    exportUri,
    headers: {
      'X-API-TOKEN': token,
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      "format": "json",
      "compress": false,
    }),
  );

  if (exportResponse.statusCode != 200) {
    final err = "Errore nell'avvio dell'export: ${exportResponse.statusCode}";
    // await logErrorToFirestore(err);
    throw Exception(err);
  }

  // Estraiamo il progressId dalla risposta
  final exportResult = jsonDecode(exportResponse.body)['result'];
  final progressId = exportResult['progressId'];
  if (progressId == null) {
    final err = "ProgressId non trovato nella risposta di export.";
    // await logErrorToFirestore(err);
    throw Exception(err);
  }

  // Polling: Continuiamo a controllare lo stato dell'export finché non è completato
  final progressUri = Uri.https(
    mainUrl,
    "/API/v3/surveys/$surveyID/export-responses/$progressId",
  );

  bool exportComplete = false;
  int attempts = 0;
  const int maxAttempts = 60;
  Map<String, dynamic> progressResult = {};

  while (!exportComplete && attempts < maxAttempts) {
    final progressResponse = await http.get(
      progressUri,
      headers: {
        'X-API-TOKEN': token,
      },
    );
    if (progressResponse.statusCode != 200) {
      final err =
          "Errore nel recupero del progresso dell'export: ${progressResponse.statusCode}";
      // await logErrorToFirestore(err);
      throw Exception(err);
    }

    progressResult = jsonDecode(progressResponse.body)['result'];
    final percentComplete = progressResult['percentComplete'] ?? 0;
    if (percentComplete >= 100) {
      exportComplete = true;
      break;
    }
    await Future.delayed(const Duration(seconds: 1));
    attempts++;
  }

  if (!exportComplete) {
    final err = "Timeout: l'export non è stato completato in tempo.";
    // await logErrorToFirestore(err);
    throw Exception(err);
  }

  final fileId = progressResult['fileId'];
  if (fileId == null) {
    final err =
        "FileId non trovato. L'export potrebbe non essere ancora completato.";
    // await logErrorToFirestore(err);
    throw Exception(err);
  }

  // Recuperiamo il file contenente i dati esportati
  final fileUri = Uri.https(
    mainUrl,
    "/API/v3/surveys/$surveyID/export-responses/$fileId/file",
  );
  final fileResponse = await http.get(
    fileUri,
    headers: {
      'X-API-TOKEN': token,
    },
  );
  if (fileResponse.statusCode != 200) {
    final err =
        "Errore nel recupero del file esportato: ${fileResponse.statusCode}";
    // await logErrorToFirestore(err);
    throw Exception(err);
  }

  final jsonData = jsonDecode(fileResponse.body);

  // Filtra le risposte per trovare quella che appartiene all'utente (UUID uguale a QID6_TEXT)
  if (jsonData['responses'] != null && jsonData['responses'] is List) {
    final responses = jsonData['responses'] as List<dynamic>;
    Map<String, dynamic>? matchingResponse;
    for (final response in responses) {
      if (response['values'] != null &&
          response['values']['QID6_TEXT'] == uuid) {
        matchingResponse = response;
        break;
      }
    }

    // Se abbiamo trovato la risposta dell'utente, decodifica le note
    if (matchingResponse != null &&
        matchingResponse['values'] != null &&
        matchingResponse['values']['QID5_TEXT'] != null) {
      final diaryString = matchingResponse['values']['QID5_TEXT'];
      if (diaryString is String) {
        final List<dynamic> entriesJson = jsonDecode(diaryString);

        return entriesJson
            .map<Map<String, String>>((entry) => {
                  "timestamp": entry["timestamp"] as String,
                  "content": entry["content"] as String,
                })
            .toList();
      }
    }
  }

  return [];
}

Future<void> verifyAndSyncQuestions(
  BuildContext ctx,
) async {
  log('verifyAndSyncQuestions START');
  final questionsProvider = Provider.of<Questions>(ctx, listen: false);

  // 1. Se non ci sono domande locali, inizializza completamente
  // final saved = await questionsProvider.areQuestionsSaved();
  // log('Domande salvate in locale? $saved');
  // if (!saved) {
  //   log('Nessun dato locale, inizializzo completamente');
  //   await initQuestions(ctx, isDemo, canSend);
  //   log('initQuestions completato in verifyAndSyncQuestions');
  //   return;
  // }

  // 2. Carica le domande salvate
  await questionsProvider.readFromLocal();
  log('Dati locali caricati: ${questionsProvider.getSurveys().length} sondaggi');

  // 3. Recupera lista sondaggi remoti
  final remoteSurveys = await getSurveys();
  log('Sondaggi remoti trovati: ${remoteSurveys.length}');

  // 4. Per ogni sondaggio remoto, sincronizza solo ciò che manca
  for (var survey in remoteSurveys) {
    final name = survey['name']?.toString();
    final id = survey['id']?.toString();
    log('Processo sondaggio remoto: name=$name, id=$id');
    if (name == null || id == null || name.isEmpty || id.isEmpty) {
      log('Skipping sondaggio con dati null o vuoti');
      continue;
    }

    // 4a. Se il sondaggio manca, aggiungi completamente
    if (!questionsProvider.getSurveys().contains(name)) {
      log('Aggiungo sondaggio mancante: $name');
      questionsProvider.addSurvey(id, name);
    }

    // 4b. Scarica definizioni remote
    final Map<String, dynamic> blocksMap = {};
    final Map<String, dynamic> questionsMap = {};
    if (ctx.mounted) {
      log('Richiedo blocchi e domande per $name');
      await getBlocksQuestions(
        id,
        blocksMap,
        questionsMap,
        ctx,
      );
      log('Ricevuti ${blocksMap.length} blocchi e ${questionsMap.length} domande per $name');
    }

    // 4c. Sincronizza blocchi
    for (var entry in blocksMap.entries) {
      final blockId = entry.key;
      final block = entry.value as Map<String, dynamic>?;
      if (block == null) {
        log('Blocco null per id $blockId, skip');
        continue;
      }

      final elements = block['BlockElements'] as List<dynamic>?;
      final desc = block['Description']?.toString() ?? 'unknown';
      if (elements == null) {
        log('Elemento BlockElements null per blocco $blockId, skip');
        continue;
      }

      if (!questionsProvider.hasBlock(name, blockId)) {
        log('Aggiungo blocco mancante $blockId ($desc) al sondaggio $name');
        questionsProvider.addBlock(name, blockId, desc);
      }

      // 4d. Sincronizza domande del blocco
      for (var el in elements) {
        final qid = el['QuestionID']?.toString();
        final qData =
            qid != null ? questionsMap[qid] as Map<String, dynamic>? : null;
        final type = el['Type']?.toString();
        final isPageBreak = type == 'Page Break';
        final isTiming = qData?['QuestionType'] == 'Timing';

        if (qid == null) {
          log('QuestionID null in blocco $blockId, skip');
          continue;
        }
        if (isPageBreak) {
          log('Page Break question $qid in blocco $blockId, skip');
          continue;
        }
        if (qData == null) {
          log('Dati domanda null per $qid, skip');
          continue;
        }
        if (isTiming) {
          log('Timing question $qid in blocco $blockId, skip');
          continue;
        }

        if (!questionsProvider.hasQuestion(name, qid)) {
          log('Aggiungo domanda mancante $qid al blocco $blockId del sondaggio $name');
          questionsProvider.addQuestion(
            name,
            desc,
            qid,
            qData,
          );
        }
      }
    }
  }

  // 5. Salva le modifiche locali
  await questionsProvider.writeToLocal();
  log('Modifiche salvate in locale');
  log('verifyAndSyncQuestions END');
}
