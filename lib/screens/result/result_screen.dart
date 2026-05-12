import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'loading_results_view.dart';
import 'results_view/results_view.dart';

class ResultScreen extends StatefulWidget {
  final int age;
  final double yield;
  final double area;
  final XFile imageFile;

  const ResultScreen({
    super.key,
    required this.age,
    required this.yield,
    required this.area,
    required this.imageFile,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late FlutterVision vision;
  bool _isLoading = true;
  String _debugLog = "Initializing AI Engine...";
  Map<String, String> _advice = {};

  List<Map<String, dynamic>> _detectedBoxes = [];
  ui.Image? _nativeImage;

  @override
  void initState() {
    super.initState();
    vision = FlutterVision();
    _runFullPipeline();
  }

  @override
  void dispose() {
    vision.closeYoloModel();
    super.dispose();
  }

  Future<void> _runFullPipeline() async {
    try {
      setState(() => _debugLog = "Loading YOLOv8...");

      await vision.loadYoloModel(
        labels: 'assets/labels.txt',
        modelPath: 'assets/best_float32.tflite',
        modelVersion: "yolov8",
        numThreads: 2,
        useGpu: false,
      );

      setState(() => _debugLog = "Decoding Dimensions Natively...");
      Uint8List imageBytes = await widget.imageFile.readAsBytes();

      ui.Image nativeImage = await decodeImageFromList(imageBytes);
      _nativeImage = nativeImage;

      setState(() => _debugLog = "YOLOv8 Localizing Leaf...");
      final yoloResults = await vision.yoloOnImage(
        bytesList: imageBytes,
        imageHeight: nativeImage.height,
        imageWidth: nativeImage.width,
        iouThreshold: 0.4,
        confThreshold: 0.83,
        classThreshold: 0.83,
      );

      if (yoloResults.isNotEmpty) {
        _detectedBoxes = List<Map<String, dynamic>>.from(yoloResults);
        setState(() => _debugLog = "Leaf Confirmed. Extracting Pigments...");

        final String deficiency = await compute(
          _backgroundAnalysis,
          imageBytes,
        );

        if (!mounted) return;
        setState(() {
          _advice = _calculateExpertRules(deficiency);
          _isLoading = false;
        });
        _saveToHistory(_advice['diagnosis']!);
      } else {
        if (!mounted) return;
        setState(() {
          _advice = {
            "diagnosis": "No Leaf Found",
            "impact": "System could not locate a leaf.",
            "predicted": "N/A",
            "recommendation": "YOLOv8 confidence below 70%.",
            "qty": "0 kg",
            "rule": "Ensure the leaf is well-lit and centered.",
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _advice = {
          "diagnosis": "System Error",
          "impact": "Hardware exception.",
          "predicted": "N/A",
          "recommendation": e.toString(),
          "qty": "N/A",
          "rule": "Hardware or Model fault.",
        };
        _isLoading = false;
      });
    }
  }

  // Save the record to Hive storage
  void _saveToHistory(String diagnosis) {
    if (diagnosis == "No Leaf Found" ||
        diagnosis == "System Error" ||
        diagnosis == "TOO EARLY") {
      return;
    }

    Box<dynamic> box = Hive.box('scanHistory');
    List history = box.get('scans', defaultValue: []);

    DateTime now = DateTime.now();
    String formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-"
        "${now.day.toString().padLeft(2, '0')} "
        "${now.hour.toString().padLeft(2, '0')}:"
        "${now.minute.toString().padLeft(2, '0')}";

    Map scanData = {
      'date': formattedDate,
      'diagnosis': diagnosis,
      'age': widget.age,
      'yield': widget.yield,
    };

    history.insert(0, scanData);

    // Keep only the top 5
    if (history.length > 5) history = history.sublist(0, 5);

    box.put('scans', history);
  }

  static Future<String> _backgroundAnalysis(Uint8List bytes) async {
    try {
      img.Image? image = img.decodeImage(bytes);
      if (image == null) return "ERROR";

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

      if (count == 0) return "Healthy";

      double purplePct = (purpleCount / count) * 100;
      double brownPct = (brownCount / count) * 100;
      double yellowPct = (yellowCount / count) * 100;

      if (purplePct >= 50.0) {
        return "P";
      }
      if (brownPct >= 12.0 || (brownPct >= 4.0 && yellowPct >= 15.0)) {
        return "K";
      }
      if (yellowPct >= 30.0) {
        return "N_Severe";
      }
      if (yellowPct >= 12.0) {
        return "N_Early";
      }

      return "Healthy";
    } catch (e) {
      return "ERROR";
    }
  }

  Map<String, String> _calculateExpertRules(String type) {
    if (widget.age < 15) {
      return {
        "diagnosis": "TOO EARLY",
        "impact":
            "The plant is still relying entirely on basal fertilizer applied during planting.",
        "predicted": "${widget.yield} T/Ha",
        "recommendation":
            "Maintain water levels. Rely on standard basal fertilizer.",
        "qty": "N/A",
        "rule":
            "Crop age (${widget.age} DAT) is too early for visual nutrient diagnosis. Wait until active tillering stage (15+ DAT).",
      };
    }

    double yieldMultiplier = widget.yield > 5.0 ? 1.25 : 1.0;
    bool isEarlyStage = widget.age <= 40;
    bool isHighDemand = widget.yield >= 6.0;

    String timingAdvice = "";
    if (isEarlyStage && isHighDemand) {
      timingAdvice =
          "CRITICAL: High yield target (${widget.yield}T). Apply split-dose to maximize tillers.";
    } else if (isEarlyStage) {
      timingAdvice = "Apply early topdress to support vegetative growth.";
    } else {
      timingAdvice = "Apply immediately to protect grain weight.";
    }

    // Include the new yield predictor and impact explanations
    if (type == "P") {
      return {
        "diagnosis": "Phosphorus (P) Deficiency",
        "impact":
            "Stunted growth, delayed maturity, and reduced tiller formation. Grain filling will be severely compromised if untreated.",
        "predicted": "${(widget.yield * 0.75).toStringAsFixed(1)} T/Ha",
        "recommendation": "Apply Solophos (0-18-0). $timingAdvice",
        "qty":
            "${(40.0 * yieldMultiplier * widget.area).toStringAsFixed(1)} kg",
        "rule":
            "Rule 08: Violet discoloration detected. Dose dynamically scaled for ${widget.area} Ha.",
      };
    }

    if (type == "N_Severe") {
      return {
        "diagnosis": "Severe Nitrogen Deficiency",
        "impact":
            "Massive reduction in active tillering and chlorophyll production. Panicle size and overall grain yield will be significantly stunted.",
        "predicted": "${(widget.yield * 0.65).toStringAsFixed(1)} T/Ha",
        "recommendation": "Urgent: Apply Urea (46-0-0). $timingAdvice",
        "qty":
            "${(50.0 * yieldMultiplier * widget.area).toStringAsFixed(1)} kg",
        "rule":
            "Rule 05: V-shaped chlorosis at ${widget.age} DAT. Dose adjusted for ${widget.yield}T target.",
      };
    }

    if (type == "N_Early") {
      return {
        "diagnosis": "Early Nitrogen Warning",
        "impact":
            "Early signs of chlorophyll breakdown. Minor reduction in growth momentum which can easily be corrected.",
        "predicted": "${(widget.yield * 0.85).toStringAsFixed(1)} T/Ha",
        "recommendation": "Preventative Topdress with Urea (46-0-0).",
        "qty":
            "${(25.0 * yieldMultiplier * widget.area).toStringAsFixed(1)} kg",
        "rule":
            "Early Warning: Chlorophyll shift detected. Light dose calculated for ${widget.area} Ha.",
      };
    }

    if (type == "K") {
      return {
        "diagnosis": "Potassium (K) Deficiency",
        "impact":
            "Weak stems leading to crop lodging. Decreased resistance to pests and diseases with reduced final grain weight.",
        "predicted": "${(widget.yield * 0.80).toStringAsFixed(1)} T/Ha",
        "recommendation": "Apply Muriate of Potash (0-0-60). $timingAdvice",
        "qty":
            "${(30.0 * yieldMultiplier * widget.area).toStringAsFixed(1)} kg",
        "rule":
            "Rule 12: Marginal necrosis. Yield multiplier ($yieldMultiplier x) applied for ${widget.yield}T goal.",
      };
    }

    return {
      "diagnosis": "Healthy Condition",
      "impact":
          "Optimal growth trajectory. The plant has adequate nutrients to support tiller production and maximum grain weight.",
      "predicted": "${widget.yield} T/Ha",
      "recommendation": "Standard maintenance. Keep water levels optimal.",
      "qty": "0 kg",
      "rule":
          "Pigmentation normal for ${widget.age} DAT. Target yield of ${widget.yield}T on track.",
    };
  }

  @override
  Widget build(BuildContext context) {
    bool isHealthy = _advice['diagnosis'] == "Healthy Condition";
    bool isWarning =
        _advice['diagnosis'] == "TOO EARLY" ||
        _advice['diagnosis'] == "System Error" ||
        _advice['diagnosis'] == "No Leaf Found";

    Color primaryStatusColor = isHealthy
        ? Colors.green
        : (isWarning ? Colors.blueGrey : Colors.orange.shade800);
    IconData statusIcon = isHealthy
        ? Icons.check_circle
        : (isWarning ? Icons.info_outline : Icons.warning_rounded);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Analysis Report",
          style: TextStyle(fontWeight: .bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
      ),
      body: _isLoading
          ? LoadingResultsView(debugLog: _debugLog)
          : ResultsView(
              nativeImage: _nativeImage,
              widget: widget,
              detectedBoxes: _detectedBoxes,
              advice: _advice,
              isHealthy: isHealthy,
              statusIcon: statusIcon,
              primaryStatusColor: primaryStatusColor,
              isWarning: isWarning,
            ),
    );
  }
}
