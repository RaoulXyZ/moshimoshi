import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class SafetyPlanning with ChangeNotifier {
  late Box hive;

  late Map<String, String> moduli;

  Map<String, String> prettyName = {
    "segnalidiavvertimento": "Segnali di Avvertimento",
    "strategiedicopinginterne": "Strategie di Coping Interne",
    "strategiedicopingesterne": "Strategie di Coping Esterne",
    "contattipersonali": "Contatti Personali",
    "contattiprofessionali": "Contatti Professionali",
    "ambientesicuro": "Rendere l'Ambiente Sicuro",
    "ragionidivita": "Ragioni di vita",
  };

  Map<String, String> descrizioni = {
    "segnalidiavvertimento":
        "I segnali di avvertimento sono indizi iniziali di peggioramento del benessere emotivo, come pensieri negativi, cambiamenti comportamentali, o sentimenti intensi di tristezza e disperazione. ",
    "strategiedicopinginterne":
        "Le strategie di coping interne sono tecniche che una persona può utilizzare da sola per gestire lo stress e ridurre il rischio di una crisi, come la meditazione, l'esercizio fisico, o attività che portano calma e benessere.",
    "strategiedicopingesterne":
        "Le strategie di coping esterne coinvolgono il supporto di altre persone, come amici, familiari o professionisti, e l'uso di risorse comunitarie per affrontare lo stress e prevenire una crisi.",
    "contattipersonali":
        "I contatti personali sono individui di fiducia, come amici e familiari, che una persona può chiamare in caso di bisogno per ottenere supporto emotivo e aiuto durante una situazione di crisi.",
    "contattiprofessionali":
        "I contatti professionali sono figure esperte, come terapeuti, medici o operatori dei servizi di emergenza, che una persona può contattare per ricevere supporto specializzato e interventi durante una crisi.",
    "ambientesicuro":
        "Rendere l'ambiente sicuro significa identificare e rimuovere oggetti o situazioni pericolose dall'ambiente, come farmaci non necessari, armi o sostanze che potrebbero essere utilizzate per autolesionismo, per prevenire atti impulsivi durante una crisi.",
    "ragionidivita":
        "Le ragioni di vita sono tutte quelle piccole o grandi cose che hanno valore per te, come persone, animali o attività che ami. Ricordarle nei momenti difficili può aiutarti a ritrovare forza e speranza.",
  };

  String getPrettyName(String surveyName) {
    return prettyName[surveyName] ?? "No pretty name for $surveyName";
  }
}
