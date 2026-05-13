part of 'result_screen.dart';

// --- PURE TOP-LEVEL FUNCTIONS (Safe for Isolates) ---
Future<Map<String, dynamic>> runBackgroundAnalysis(Uint8List bytes) async {
  try {
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return _buildErrorPayload();

    img.Image smallImage = img.copyResize(image, width: 120);
    int count = 0;

    int purpleCount = 0;
    int brownCount = 0;
    int yellowCount = 0;

    for (int i = 0; i < smallImage.length; i += 3) {
      var pixel = smallImage.getPixel(
        i % smallImage.width,
        i ~/ smallImage.width,
      );
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();

      if ((r + g + b) < 60 || (r + g + b) > 700) continue;

      count++;

      if (r > (g * 1.15) && b > (g * 1.15)) {
        purpleCount++;
      } else if (r > (g * 1.1) && g >= b) {
        brownCount++;
      } else if (r > (g * 0.8) && g > b) {
        yellowCount++;
      }
    }

    if (count == 0) return _buildErrorPayload();

    double purplePct = (purpleCount / count) * 100;
    double brownPct = (brownCount / count) * 100;
    double yellowPct = (yellowCount / count) * 100;
    double greenOrOtherPct = 100.0 - (purplePct + brownPct + yellowPct);

    String diagnosis = "Healthy";
    double confidence = 90.0;

    if (purplePct >= 50.0) {
      diagnosis = "P";
      confidence = 80.0 + ((purplePct - 50.0) / 50.0) * 20.0;
    } else if (brownPct >= 12.0 || (brownPct >= 4.0 && yellowPct >= 15.0)) {
      diagnosis = "K";
      confidence = 80.0 + ((brownPct - 12.0).clamp(0, 88) / 88.0) * 20.0;
    } else if (yellowPct >= 30.0) {
      diagnosis = "N_Severe";
      confidence = 85.0 + ((yellowPct - 30.0).clamp(0, 70) / 70.0) * 15.0;
    } else if (yellowPct >= 12.0) {
      diagnosis = "N_Early";
      confidence = 70.0 + ((yellowPct - 12.0).clamp(0, 18) / 18.0) * 15.0;
    }

    if (diagnosis == "Healthy" && (purplePct + brownPct + yellowPct) > 20) {
      confidence -= (purplePct + brownPct + yellowPct) * 0.5;
    }

    int finalConfidence = confidence.clamp(0, 100).toInt();

    return {
      "status": finalConfidence >= 70 ? "confident" : "uncertain",
      "local_diagnosis": diagnosis,
      "confidence": finalConfidence,
      "color_data": {
        "purple": purplePct.toStringAsFixed(1),
        "brown": brownPct.toStringAsFixed(1),
        "yellow": yellowPct.toStringAsFixed(1),
        "green_or_other": greenOrOtherPct.toStringAsFixed(1),
      },
    };
  } catch (e) {
    return _buildErrorPayload();
  }
}

Map<String, dynamic> _buildErrorPayload() {
  return {
    "status": "error",
    "local_diagnosis": "ERROR",
    "confidence": 0,
    "color_data": {
      "purple": "0.0",
      "brown": "0.0",
      "yellow": "0.0",
      "green_or_other": "0.0",
    },
  };
}

extension Analysis on ResultScreenState {
  Map<String, String> _calculateExpertRules(String type) {
    if (widget.age < 15) {
      return {
        "diagnosis": "TOO EARLY",
        "impact":
            "The plant is still relying entirely on basal fertilizer "
            "applied during planting.",
        "predicted": "${widget.yield} T/Ha",
        "recommendation":
            "Maintain water levels. Rely on standard basal fertilizer.",
        "qty": "N/A",
        "rule":
            "Crop age (${widget.age} DAT) is too early for visual nutrient "
            "diagnosis. Wait until active tillering stage (15+ DAT).",
      };
    }

    double yieldMultiplier = widget.yield > 5.0 ? 1.25 : 1.0;
    bool isEarlyStage = widget.age <= 40;
    bool isHighDemand = widget.yield >= 6.0;

    String timingAdvice = "";
    if (isEarlyStage && isHighDemand) {
      timingAdvice =
          "CRITICAL: High yield target (${widget.yield}T). Apply split-dose "
          "to maximize tillers.";
    } else if (isEarlyStage) {
      timingAdvice = "Apply early topdress to support vegetative growth.";
    } else {
      timingAdvice = "Apply immediately to protect grain weight.";
    }

    // Include the new yield predictor and impact explanations
    return _checkType(
      type,
      yieldMultiplier: yieldMultiplier,
      isEarlyStage: isEarlyStage,
      isHighDemand: isHighDemand,
      timingAdvice: timingAdvice,
    );
  }

  Map<String, String> _checkType(
    String type, {
    required double yieldMultiplier,
    required bool isEarlyStage,
    required bool isHighDemand,
    required String timingAdvice,
  }) {
    switch (type) {
      case "P":
        return {
          "diagnosis": "Phosphorus (P) Deficiency",
          "impact":
              "Stunted growth, delayed maturity, and reduced tiller formation. "
              "Grain filling will be severely compromised if untreated.",
          "predicted": "${(widget.yield * 0.75).toStringAsFixed(1)} T/Ha",
          "recommendation": "Apply Solophos (0-18-0). $timingAdvice",
          "qty":
              "${(40.0 * yieldMultiplier * widget.area).toStringAsFixed(1)} kg",
          "rule":
              "Rule 08: Violet discoloration detected. Dose dynamically scaled "
              "for ${widget.area} Ha.",
        };

      case "N_Severe":
        return {
          "diagnosis": "Severe Nitrogen Deficiency",
          "impact":
              "Massive reduction in active tillering and chlorophyll production. "
              "Panicle size and overall grain yield will be significantly stunted.",
          "predicted": "${(widget.yield * 0.65).toStringAsFixed(1)} T/Ha",
          "recommendation": "Urgent: Apply Urea (46-0-0). $timingAdvice",
          "qty":
              "${(50.0 * yieldMultiplier * widget.area).toStringAsFixed(1)} kg",
          "rule":
              "Rule 05: V-shaped chlorosis at ${widget.age} DAT. Dose adjusted "
              "for ${widget.yield}T target.",
        };

      case "N_Early":
        return {
          "diagnosis": "Early Nitrogen Warning",
          "impact":
              "Early signs of chlorophyll breakdown. Minor reduction in growth "
              "momentum which can easily be corrected.",
          "predicted": "${(widget.yield * 0.85).toStringAsFixed(1)} T/Ha",
          "recommendation": "Preventative Topdress with Urea (46-0-0).",
          "qty":
              "${(25.0 * yieldMultiplier * widget.area).toStringAsFixed(1)} kg",
          "rule":
              "Early Warning: Chlorophyll shift detected. Light dose "
              "calculated for ${widget.area} Ha.",
        };

      case "K":
        return {
          "diagnosis": "Potassium (K) Deficiency",
          "impact":
              "Weak stems leading to crop lodging. Decreased resistance to "
              "pests and diseases with reduced final grain weight.",
          "predicted": "${(widget.yield * 0.80).toStringAsFixed(1)} T/Ha",
          "recommendation": "Apply Muriate of Potash (0-0-60). $timingAdvice",
          "qty":
              "${(30.0 * yieldMultiplier * widget.area).toStringAsFixed(1)} kg",
          "rule":
              "Rule 12: Marginal necrosis. Yield multiplier "
              "($yieldMultiplier x) applied for ${widget.yield}T goal.",
        };

      default:
        return {
          "diagnosis": "Healthy Condition",
          "impact":
              "Optimal growth trajectory. The plant has adequate nutrients to "
              "support tiller production and maximum grain weight.",
          "predicted": "${widget.yield} T/Ha",
          "recommendation": "Standard maintenance. Keep water levels optimal.",
          "qty": "0 kg",
          "rule":
              "Pigmentation normal for ${widget.age} DAT. "
              "Target yield of ${widget.yield}T on track.",
        };
    }
  }
}
