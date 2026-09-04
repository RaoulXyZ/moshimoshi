import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../../chiamate.dart';
import '../../../login/pages/loading_screen.dart';
import '../../../login/widget/toast.dart';
import '../../../providers/moduli.dart';
import '../../../providers/progress.dart';
import '../../../providers/questions.dart';
import '../../../providers/user_settings.dart';
import '../../../utility/local_user.dart';
import './card_categoria.dart';
import '../../../utility/mindblooming_text_style.dart';
import 'generali/generali.dart';
import 'generali/notifiche/notifiche.dart';
import 'moshimoshi/moshimoshi.dart';
import 'preferiti/preferiti.dart';
import 'tutorial/tutorial.dart';
import '../../../utility/mindblooming_color_scheme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<PackageInfo> _packageInfoFuture;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    final pp = Provider.of<Progress>(context, listen: false);
    final qProvider = Provider.of<Questions>(context, listen: false);
    final mProvider = Provider.of<Moduli>(context, listen: false);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      'Impostazioni',
                      style: MindBloomingTextStyle.header1,
                    ),
                  ),
                  const SizedBox(height: 30),
                  CardCategoria(
                    title: "Generali",
                    subtitle: "Compagno di viaggio",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const Generali(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  CardCategoria(
                    title: "Notifiche",
                    subtitle: "Promemoria giornalieri e settimanali",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const Notifiche(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  CardCategoria(
                    title: "MoshiMoshi",
                    subtitle: "Dettagli e crediti",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MoshiMoshi(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  CardCategoria(
                    title: "Preferiti",
                    subtitle: "I moduli che hai salvato",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const Preferiti(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  CardCategoria(
                    title: "Tutorial",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const Tutorial(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  CardCategoria(
                    title: "Esci dall'Account",
                    onTap: () {
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.warning,
                        showCancelBtn: true,
                        title: 'Esci dall\'Account',
                        text: 'Sei sicuro di voler uscire dall\'Account?',
                        confirmBtnText: 'Esci',
                        confirmBtnColor: Colors.red,
                        cancelBtnText: 'Annulla',
                        onConfirmBtnTap: () async {
                          await LocalUser.clear();
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoadingScreen(),
                            ),
                          );
                          showToast(
                            message: 'Utente disconnesso con successo.',
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        splashFactory: NoSplash.splashFactory,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                      child: Consumer<UserSettings>(
                        builder: (context, settings, _) {
                          return SwitchListTile(
                            title: Text(
                              "Debug",
                              style: MindBloomingTextStyle.subtitle,
                            ),
                            value: settings.debug,
                            onChanged: (v) async {
                              if (v) {
                                final TextEditingController _pwController =
                                    TextEditingController();
                                bool success = false;

                                await showDialog<void>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (ctx) {
                                    return AlertDialog(
                                      title: const Text('Conferma Password'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'Inserisci la password admin per abilitare la modalità debug.',
                                          ),
                                          const SizedBox(height: 12),
                                          TextField(
                                            controller: _pwController,
                                            obscureText: true,
                                            decoration: const InputDecoration(
                                              labelText: 'Password',
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                          },
                                          child: const Text('Annulla'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            final pw =
                                                _pwController.text.trim();
                                            final envPw = dotenv
                                                .env['ADMIN_DEBUG_PASSWORD'];
                                            Navigator.of(ctx).pop();

                                            if (envPw == null ||
                                                envPw.isEmpty) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'La password admin non è configurata sul server.',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }

                                            if (pw == envPw) {
                                              success = true;
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Password admin errata.'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text('Conferma'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (success) settings.setDebug(true);
                              } else {
                                settings.setDebug(false);
                              }
                            },
                            activeTrackColor: MindBloomingColorScheme.secondary,
                            trackOutlineColor: WidgetStateProperty.all(
                              MindBloomingColorScheme.secondary,
                            ),
                            activeThumbColor: Colors.white,
                            inactiveThumbColor:
                                MindBloomingColorScheme.secondary,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Consumer<UserSettings>(
                    builder: (context, settings, _) {
                      if (!settings.debug) return const SizedBox.shrink();

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 30),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 0.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 25,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 8.0,
                                ),
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: 'Data di inizio: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: DateFormat('dd-MM-yyyy')
                                            .format(pp.start),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 8.0,
                                ),
                                child: Text(
                                  "Daily Screenings",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              for (var ds in pp.dailyScreenings.entries)
                                for (var d in ds.value)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      '${ds.key} - ${d.surveyName} - ${d.done}',
                                    ),
                                  ),
                              const SizedBox(height: 20),
                              const Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 8.0,
                                ),
                                child: Text(
                                  "Weekly Screenings",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              for (var ws in pp.weeklyScreenings.entries)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                    vertical: 8.0,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Key
                                      Flexible(
                                        flex: 2,
                                        child: Text(
                                          ws.key,
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      // Moduli (uno accanto all'altro). Uso Wrap per andare a capo se sono troppi.
                                      Flexible(
                                        flex: 5,
                                        child: Wrap(
                                          spacing: 8,
                                          runSpacing: 6,
                                          children: ws.value.map<Widget>((ex) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                right: 4.0,
                                              ),
                                              child: Text(
                                                "${ex.surveyName}: ${ex.done}",
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 20),
                              const Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 8.0,
                                ),
                                child: Text(
                                  "Weekly Exercises",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              for (var ws in pp.weeklyExercises.entries)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                    vertical: 8.0,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Key
                                      Flexible(
                                        flex: 2,
                                        child: Text(
                                          ws.key,
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      // Moduli (uno accanto all'altro). Uso Wrap per andare a capo se sono troppi.
                                      Flexible(
                                        flex: 5,
                                        child: Wrap(
                                          spacing: 8,
                                          runSpacing: 6,
                                          children: ws.value.map<Widget>((ex) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                right: 4.0,
                                              ),
                                              child: Text(
                                                "${ex.surveyName}: ${ex.done}",
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 8.0,
                                ),
                                child: Text(
                                  "Stato survey moduli",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                ),
                                child: Builder(
                                  builder: (context) {
                                    if (mProvider.moduli.isEmpty) {
                                      return const Text(
                                        "Nessun modulo selezionato.",
                                      );
                                    }

                                    final m1 = mProvider.moduli.keys.first;
                                    final m2 = mProvider.moduli.length >= 2
                                        ? mProvider.moduli.keys.last
                                        : m1;
                                    final required =
                                        getRequiredSurveyNames(m1, m2);
                                    final loaded = qProvider.getSurveys();
                                    final missing = required
                                        .where(
                                          (name) => !loaded.contains(name),
                                        )
                                        .toList();

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Moduli: $m1, $m2",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Richieste: ${required.length} | "
                                          "Presenti: ${required.length - missing.length} | "
                                          "Mancanti: ${missing.length}",
                                          style: TextStyle(
                                            color: missing.isEmpty
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (missing.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          ...missing.map(
                                            (name) => Text(
                                              "- $name",
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          FutureBuilder<PackageInfo>(
            future: _packageInfoFuture,
            builder: (context, snapshot) {
              String version = '';
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                version = snapshot.data!.version;
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Versione: $version',
                    style: MindBloomingTextStyle.normal.copyWith(fontSize: 14),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
