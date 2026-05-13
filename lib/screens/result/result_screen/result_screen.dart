import 'dart:convert';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'triage_dialog.dart';
import '../loading_results_view.dart';
import '../results_view/results_view.dart';

part 'analysis.dart';
part 'history.dart';
part 'assessment.dart';

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
  State<ResultScreen> createState() => ResultScreenState();
}

class ResultScreenState extends State<ResultScreen> {
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

        final Map<String, dynamic> analysisResult = await compute(
          runBackgroundAnalysis,
          imageBytes,
        );

        // --- PHASE 2: INTERCEPTOR LOGIC ---
        // CATCH CRITICAL ERRORS FIRST
        if (analysisResult['status'] == 'error') {
          if (!mounted) return;
          setState(() {
            _advice = _calculateExpertRules(
              analysisResult['local_diagnosis'] as String,
            );
            _isLoading = false;
          });
          return; // Stop execution here so it doesn't hit the proxy
        }

        // THE TRIAGE LOGIC
        bool useVision = false;
        if (analysisResult['status'] == 'uncertain') {
          setState(() => _debugLog = "Awaiting Verification Choice...");
          bool? useDeepScan = await _showTriageDialog(analysisResult);
          useVision = useDeepScan == true;
        }

        if (useVision) {
          debugPrint(">>> ROUTING TO DEEP VISION PROXY");
          setState(() => _debugLog = "Running Deep Vision Verification...");
        } else {
          debugPrint(">>> ROUTING TO FAST AI PROXY");
          setState(() => _debugLog = "Generating Financial Risk Assessment...");
        }

        // EXECUTE CLEANED NETWORK REQUEST
        final aiData = await _fetchAIAssessment(
          analysisResult: analysisResult,
          useVision: useVision,
          imageBytes: imageBytes,
        );

        String aiAssessment = aiData['financial_assessment'];
        int cropScore = aiData['crop_score'];

        // --- TEMPORARY UI RESOLVE (Testing Phase) ---
        if (!mounted) return;
        setState(() {
          // Keep the local logic for diagnosis and yield tracking
          _advice = _calculateExpertRules(
            analysisResult['local_diagnosis'] as String,
          );

          // INJECT the AI's financial assessment
          if (aiAssessment.isNotEmpty) {
            if (analysisResult['status'] == 'confident') {
              _advice['recommendation'] =
                  "FINTECH YIELD & LOAN PREDICTION:\n\n$aiAssessment";
            } else {
              _advice['recommendation'] =
                  "AI DIAGNOSIS & RISK ASSESSMENT:\n\n$aiAssessment";
            }
          }

          _isLoading = false;
        });

        _saveToHistory(_advice['diagnosis']!, cropScore);
      } else {
        if (!mounted) return;
        setState(() {
          _debugLog = "No Leaf Detected.";
          _advice = {
            "diagnosis": "No Leaf Found",
            "impact":
                "The AI could not confidently identify a rice leaf in the image.",
            "predicted": "N/A",
            "recommendation":
                "Please ensure the camera is focused clearly on a rice leaf and try again.",
            "qty": "N/A",
            "rule": "Vision Model Error: 0 objects detected.",
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

  Future<bool?> _showTriageDialog(Map<String, dynamic> data) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // Forces the user to make a choice
      builder: (context) => TriageDialog(data: data),
    );
  }
}
