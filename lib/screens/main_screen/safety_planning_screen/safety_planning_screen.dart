import 'package:flutter/material.dart';
import '../../../utility/mindblooming_text_style.dart';
import 'lista_attivita_piacevoli_card.dart';
import 'safety_planning_card.dart';

class SafetyPlanningScreen extends StatelessWidget {
  const SafetyPlanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text("Area Sicura", style: MindBloomingTextStyle.header1),
          ),
          const SizedBox(height: 20),
          const SafetyPlanningCard(),
          const SizedBox(height: 20),
          const ListaAttivitaPiacevoliCard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
