import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'finance_row.dart';
import 'untreated_yield_header.dart';

class YieldPredictorUI extends StatelessWidget {
  const YieldPredictorUI({
    super.key,
    required this.isHealthy,
    required this.advice,
  });

  final bool isHealthy;
  final Map<String, String> advice;

  @override
  Widget build(BuildContext context) {
    // Extract Physical Values
    double predictedYield =
        double.tryParse(
          advice['predicted']?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0',
        ) ??
        0.0;
    double requiredQtyKg =
        double.tryParse(
          advice['qty']?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0',
        ) ??
        0.0;

    // Pull Dynamic Market Rates from Cache
    Box marketBox = Hive.box('marketData');
    double palayFreshPriceKg =
        (marketBox.get('palay_fresh_kg', defaultValue: 19.00) as num)
            .toDouble();

    // Dynamically match the fertilizer cost to the diagnosis
    String recommendation = advice['recommendation'] ?? "";
    double fertilizerBagPrice = 1150.00; // Default Urea
    String fertilizerName = "Urea";

    if (recommendation.contains("Solophos")) {
      fertilizerBagPrice =
          (marketBox.get('solophos_0_18_0_bag', defaultValue: 950.00) as num)
              .toDouble();
      fertilizerName = "Solophos";
    } else if (recommendation.contains("Muriate") ||
        recommendation.contains("Potash")) {
      fertilizerBagPrice =
          (marketBox.get('mop_0_0_60_bag', defaultValue: 1050.00) as num)
              .toDouble();
      fertilizerName = "Potash";
    }

    // Financial Calculations
    double expectedHarvestKg = predictedYield * 1000;
    double grossRevenue = expectedHarvestKg * palayFreshPriceKg;
    double fertilizerBagsRequired = (requiredQtyKg / 50).ceilToDouble();
    double treatmentCost = fertilizerBagsRequired * fertilizerBagPrice;
    double projectedNet = grossRevenue - treatmentCost;

    // --- Top Half Layout ---
    final topHalfContent = [
      UntreatedYieldHeader(isHealthy: isHealthy),
      Text(
        advice['predicted'] ?? "N/A",
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: isHealthy ? Colors.green.shade800 : Colors.red.shade800,
          fontSize: 16,
        ),
      ),
    ];

    // --- Combined Main Layout ---
    return _YieldPredictorUILayout(
      isHealthy: isHealthy,
      topHalfContent: topHalfContent,
      grossRevenue: grossRevenue,
      fertilizerBagsRequired: fertilizerBagsRequired,
      treatmentCost: treatmentCost,
      projectedNet: projectedNet,
      fertilizerName: fertilizerName,
      palayFreshPriceKg: palayFreshPriceKg,
    );
  }
}

class _YieldPredictorUILayout extends StatelessWidget {
  const _YieldPredictorUILayout({
    required this.isHealthy,
    required this.topHalfContent,
    required this.grossRevenue,
    required this.fertilizerBagsRequired,
    required this.treatmentCost,
    required this.projectedNet,
    required this.fertilizerName,
    required this.palayFreshPriceKg,
  });

  final bool isHealthy;
  final List<StatelessWidget> topHalfContent;
  final double grossRevenue;
  final double fertilizerBagsRequired;
  final double treatmentCost;
  final double projectedNet;
  final String fertilizerName;
  final double palayFreshPriceKg;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const .only(top: 12),
      decoration: BoxDecoration(
        color: isHealthy ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: .circular(12),
        border: .all(
          color: isHealthy ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Column(
        children: [
          // Top portion
          _physicalYield(),
          // Bottom portion
          _financialForecast(),
        ],
      ),
    );
  }

  Container _financialForecast() => Container(
    padding: const .all(16),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.6),
      borderRadius: const .only(
        bottomLeft: .circular(12),
        bottomRight: .circular(12),
      ),
    ),
    child: _FinanceRows(
      grossRevenue: grossRevenue,
      fertilizerBagsRequired: fertilizerBagsRequired,
      treatmentCost: treatmentCost,
      projectedNet: projectedNet,
      isHealthy: isHealthy,
      fertilizerName: fertilizerName,
      palayPrice: palayFreshPriceKg,
    ),
  );

  Padding _physicalYield() => Padding(
    padding: const .symmetric(vertical: 12, horizontal: 16),
    child: Row(mainAxisAlignment: .spaceBetween, children: topHalfContent),
  );
}

class _FinanceRows extends StatelessWidget {
  const _FinanceRows({
    required this.grossRevenue,
    required this.fertilizerBagsRequired,
    required this.treatmentCost,
    required this.projectedNet,
    required this.isHealthy,
    required this.fertilizerName,
    required this.palayPrice,
  });

  final double grossRevenue;
  final double fertilizerBagsRequired;
  final double treatmentCost;
  final double projectedNet;
  final bool isHealthy;
  final String fertilizerName;
  final double palayPrice;

  String _formatCurrency(double amount) {
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String mathFunc(Match match) => '${match[1]},';
    return amount.toStringAsFixed(2).replaceAllMapped(reg, mathFunc);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FinanceRow(
          label: "Gross Revenue (@ ₱${palayPrice.toStringAsFixed(2)}/kg)",
          amount: "₱${_formatCurrency(grossRevenue)}",
          amountColor: Colors.black87,
        ),
        if (!isHealthy)
          Padding(
            padding: const .only(top: 8),
            child: FinanceRow(
              label: "Treatment Cost (${fertilizerBagsRequired.toInt()} bags)",
              amount: "- ₱${_formatCurrency(treatmentCost)}",
              amountColor: Colors.red.shade700,
            ),
          ),
        const Padding(
          padding: .symmetric(vertical: 8),
          child: Divider(height: 1, color: Colors.black12),
        ),
        FinanceRow(
          label: "Projected Net Income",
          amount: "₱${_formatCurrency(projectedNet)}",
          amountColor: Colors.green.shade800,
          isBold: true,
        ),
        FinanceRow(
          label:
              "Treatment Cost (${fertilizerBagsRequired.toInt()} bags $fertilizerName)",
          amount: "- ₱${_formatCurrency(treatmentCost)}",
          amountColor: Colors.red.shade700,
        ),
      ],
    );
  }
}
