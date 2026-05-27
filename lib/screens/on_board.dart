import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';

import '../utility/mindblooming_text_style.dart';
import '../utility/mindblooming_color_scheme.dart';
import '../widgets/mindblooming_button.dart';
import 'screening_screen.dart';

class OnBoard extends StatefulWidget {
  const OnBoard({
    super.key,
    this.fromSettings = false,
  });

  final bool fromSettings;

  @override
  State<OnBoard> createState() => _OnBoardState();
}

class _OnBoardState extends State<OnBoard> {
  late PageController _pageController;
  int _pageIndex = 0;
  List<OnBoardPage> pages = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    pages = [
      OnBoardPage(
        img: 'assets/OnBoard_1.svg',
        title: Text(
          'Benvenuta/o su MoshiMoshi!',
          style: MindBloomingTextStyle.header1,
        ),
        body: Padding(
          padding: const EdgeInsets.only(
            left: 50.0,
            right: 32,
            top: 20,
            //bottom: 25,
          ),
          child: Text(
            "L'app che ti aiuta a gestire le difficoltà psicologiche nella quotidianità.",
            style: MindBloomingTextStyle.pretitle,
          ),
        ),
        first: true,
        pc: _pageController,
        fromSettings: widget.fromSettings,
      ),
      OnBoardPage(
        img: 'assets/OnBoard_2.svg',
        title: Text(
          'Il percorso',
          style: MindBloomingTextStyle.header1,
        ),
        body: Padding(
          padding: const EdgeInsets.only(
            left: 50.0,
            right: 32,
            top: 20,
            //bottom: 25,
          ),
          child: Text(
            "All'interno dell'app troverai ogni settimana a tua disposizione nuovi contenuti dedicati ai pensieri autodistruttivi e a una tematica personalizzata, scelta in accordo con i tuoi referenti di cura.",
            style: MindBloomingTextStyle.pretitle,
          ),
        ),
        pc: _pageController,
        fromSettings: widget.fromSettings,
      ),
      OnBoardPage(
        img: 'assets/OnBoard_3.svg',
        title: Text(
          'La valutazione iniziale',
          style: MindBloomingTextStyle.header1,
        ),
        body: Padding(
          padding: const EdgeInsets.only(
            left: 50.0,
            right: 32,
            top: 20,
            //bottom: 25,
          ),
          child: Text(
            "All'inizio del percorso ti verrà chiesto di compilare alcuni questionari. È importante che tu risponda con attenzione e impegno. Questa valutazione ti permetterà di personalizzare il percorso in base ai tuoi bisogni e di monitorare i tuoi cambiamenti nel tempo.",
            style: MindBloomingTextStyle.pretitle,
          ),
        ),
        pc: _pageController,
        fromSettings: widget.fromSettings,
      ),
      OnBoardPage(
        img: 'assets/OnBoard_4.svg',
        title: Text(
          'La valutazione giornaliera',
          style: MindBloomingTextStyle.header1,
        ),
        body: Padding(
          padding: const EdgeInsets.only(
            left: 50.0,
            right: 32,
            top: 20,
            //bottom: 25,
          ),
          child: Text(
            "Ogni giorno accedendo all'app, ti verranno poste alcune domande su come ti senti in quel momento. È importante che tu risponda a queste domande più giorni possibile, così da poter monitorare l'andamento del tuo percorso.",
            style: MindBloomingTextStyle.pretitle,
          ),
        ),
        pc: _pageController,
        fromSettings: widget.fromSettings,
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: pages.length,
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _pageIndex = index;
                });
              },
              itemBuilder: (context, index) => pages[index],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 10,
              left: 32,
              right: 32,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(
                  pages.length,
                  (index) => DotIndicator(isActive: index == _pageIndex),
                ),
              ],
            ),
          ),
          if (!widget.fromSettings)
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: MindBloomingColorScheme.primary3shadow,
              ),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => ScreeningScreen(),
                  ),
                );
              },
              child: Text(
                "Salta intro",
                style: MindBloomingTextStyle.pretitle.copyWith(
                  color: MindBloomingColorScheme.textColorDark1shadow,
                ),
              ),
            ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10.0),
            child: MindBloomingButton(
              onPressed: () {
                if (_pageIndex == 3) {
                  if (widget.fromSettings) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => ScreeningScreen(),
                      ),
                    );
                  }
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                }
              },
              child: _pageIndex == 3
                  ? Text(
                      "INIZIAMO",
                      style: MindBloomingTextStyle.button,
                    )
                  : Text(
                      'PROSEGUI',
                      style: MindBloomingTextStyle.button,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class DotIndicator extends StatelessWidget {
  const DotIndicator({
    super.key,
    this.isActive = false,
  });

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 12,
      width: 12,
      decoration: BoxDecoration(
        color: this.isActive
            ? MindBloomingColorScheme.tertiary
            : MindBloomingColorScheme.primary,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(
          width: 2,
          color: MindBloomingColorScheme.tertiary3shadow,
        ),
      ),
    );
  }
}

class OnBoardPage extends StatelessWidget {
  const OnBoardPage({
    super.key,
    required this.img,
    required this.title,
    required this.body,
    required this.pc,
    required this.fromSettings,
    this.first = false,
  });

  final String img;
  final Widget title;
  final Widget body;
  final bool first;
  final PageController pc;
  final bool fromSettings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 30.0,
            top: 20,
            bottom: 20,
          ),
          child: first && !fromSettings
              ? null
              : GestureDetector(
                  onTap: () {
                    if (first) {
                      Navigator.of(context).pop();
                    } else {
                      pc.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_back_ios),
                      Text("Indietro", style: MindBloomingTextStyle.pretitle),
                    ],
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 50.0,
            right: 32,
          ),
          child: this.title,
        ),
        this.body,
        Expanded(
          child: Center(
            child: SvgPicture.asset(
              this.img,
              height: 35.h,
            ),
          ),
        ),
      ],
    );
  }
}
