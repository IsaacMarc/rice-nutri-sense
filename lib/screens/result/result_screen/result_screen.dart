import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../loading_results_view.dart';
import '../results_view/results_view.dart';

part 'analysis.dart';

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
