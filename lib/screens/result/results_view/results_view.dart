import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:rice_nutri_sense/core/data_types.dart';
import '../result_screen/result_screen.dart';
import 'alternative_minimal_card.dart';
import 'bounded_card_image.dart';
import 'collapsible_logic_panel.dart';
import 'deficiency_impact_block.dart';
import 'diagnosis_status_card.dart';
import 'parameters_summary_bar.dart';
import 'treatment_prescription_card.dart';
import 'yield_predictor/yield_predictor_ui.dart';
import 'agent_assessment_card.dart';

class ResultsView extends StatelessWidget {
  const ResultsView({
    super.key,
    required this.nativeImage,
    required this.widget,
    required this.detectedBoxes,
    required this.advice,
    required this.isHealthy,
    required this.statusIcon,
    required this.primaryStatusColor,
    required this.isWarning,
  });

  final ui.Image? nativeImage;
  final ResultScreen widget;
  final List<StringDynamicMap> detectedBoxes;
  final Map<String, String> advice;
  final bool isHealthy;
  final IconData statusIcon;
  final Color primaryStatusColor;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final mainContent = [
      BoundedCardImage(
        nativeImage: nativeImage,
        widget: widget,
        detectedBoxes: detectedBoxes,
      ),
      const SizedBox(height: 12),
      ParametersSummaryBar(widget: widget),

      if (advice.containsKey('predicted'))
        YieldPredictorUI(isHealthy: isHealthy, advice: advice),

      const SizedBox(height: 20),
      DiagnosisStatusCard(
        statusIcon: statusIcon,
        primaryStatusColor: primaryStatusColor,
        advice: advice,
      ),
      const SizedBox(height: 20),

      if (advice.containsKey('impact') && !isWarning)
        DeficiencyImpactBlock(advice: advice),

      const SizedBox(height: 20),

      // The Local PhilRice Rules Engine Treatment
      if (!isHealthy && !isWarning) TreatmentPrescriptionCard(advice: advice),

      // Alternative minimal card for Healthy, Warning, or TOO EARLY states
      if (isHealthy || isWarning) AlternativeMinimalCard(advice: advice),

      // The Cloud-Based AI Financial Risk & Loan Assessor
      AgentAssessmentCard(advice: advice),

      const SizedBox(height: 24),
      CollapsibleLogicPanel(advice: advice),
      const SizedBox(height: 40),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(crossAxisAlignment: .stretch, children: mainContent),
    );
  }
}
