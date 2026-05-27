import 'package:flutter/material.dart';
import '../../../utility/mindblooming_text_style.dart';
import 'safety_planning_card_type.dart';

class SafetyPlanningListScreen extends StatelessWidget {
  const SafetyPlanningListScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text('Safety Plan', style: MindBloomingTextStyle.header2),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
      ),
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const SafetyPlanningCardType(
              safetyPlanningType: "segnalidiavvertimento",
            ),
            const SizedBox(height: 20),
            const SafetyPlanningCardType(
              safetyPlanningType: "strategiedicopinginterne",
            ),
            const SizedBox(height: 20),
            const SafetyPlanningCardType(
              safetyPlanningType: "strategiedicopingesterne",
            ),
            const SizedBox(height: 20),
            const SafetyPlanningCardType(
              safetyPlanningType: "contattipersonali",
            ),
            const SizedBox(height: 20),
            const SafetyPlanningCardType(
              safetyPlanningType: "contattiprofessionali",
            ),
            const SizedBox(height: 20),
            const SafetyPlanningCardType(
              safetyPlanningType: "ambientesicuro",
            ),
            const SizedBox(height: 20),
            const SafetyPlanningCardType(
              safetyPlanningType: "ragionidivita",
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
