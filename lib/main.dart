import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // Initialize Hive for local storage
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('scanHistory');

  runApp(const RiceSenseApp());
}

class RiceSenseApp extends StatelessWidget {
  const RiceSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RiceNutriSense',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        fontFamily: 'Roboto',
      ),
      home: const InputScreen(),
    );
  }
}

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});
  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();
  XFile? _imageFile;
  final picker = ImagePicker();

  String cropAge = "35";
  String targetYield = "5.0";
  String fieldSize = "1.5";

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 85,
      );
      setState(() {
        if (pickedFile != null) _imageFile = pickedFile;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Camera Error: $e")));
    }
  }

  void _analyzeData() {
    if (_imageFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            age: int.tryParse(cropAge) ?? 30,
            yield: double.tryParse(targetYield) ?? 5.0,
            area: double.tryParse(fieldSize) ?? 1.0,
            imageFile: _imageFile!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Please capture or select a leaf image.",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showHistory() {
    var box = Hive.box('scanHistory');
    List history = box.get('scans', defaultValue: []);

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allows the sheet to take up more than 50% of the screen
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          // Limits the max height to 80% of the screen so it doesn't cover the app bar
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Recent Scans",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              history.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        "No previous scans found.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : Flexible(
                      // Wraps the list to make it scrollable without overflowing
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          var scan = history[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: Colors.green[100],
                              child: Icon(
                                Icons.history,
                                color: Colors.green[800],
                              ),
                            ),
                            title: Text(
                              scan['diagnosis'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "Date: ${scan['date']}\nYield Target: ${scan['yield']} T/Ha",
                            ),
                            isThreeLine: true,
                          );
                        },
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    String label,
    String initialValue,
    IconData icon,
    Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green[700]),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green[400]!, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.grass_rounded, color: Colors.green[700], size: 28),
            const SizedBox(width: 8),
            const Text(
              "RiceNutriSense",
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        shadowColor: Colors.black26,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Field Parameters",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Enter crop details to calibrate PhilRice guidelines.",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),

              _buildTextField(
                "Crop Age (DAT)",
                cropAge,
                Icons.calendar_today,
                (val) => cropAge = val,
              ),
              _buildTextField(
                "Target Yield (Tons/Ha)",
                targetYield,
                Icons.scale,
                (val) => targetYield = val,
              ),
              _buildTextField(
                "Field Size (Hectares)",
                fieldSize,
                Icons.map_outlined,
                (val) => fieldSize = val,
              ),

              const SizedBox(height: 10),
              const Divider(height: 30, thickness: 1, color: Colors.black12),

              const Text(
                "Leaf Sample",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Upload a clear, well-lit image of the rice leaf.",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 15),

              GestureDetector(
                onTap: () => _pickImage(ImageSource.camera),
                child: Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _imageFile == null
                          ? Colors.green[300]!
                          : Colors.transparent,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _imageFile == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_a_photo_rounded,
                                size: 40,
                                color: Colors.green[600],
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Tap to Capture Image",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "or use the gallery button below",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(
                                File(_imageFile!.path),
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: Icon(
                      Icons.photo_library_rounded,
                      color: Colors.green[700],
                    ),
                    label: Text(
                      "Browse Gallery",
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      backgroundColor: Colors.green[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  gradient: LinearGradient(
                    colors: [Colors.green[600]!, Colors.green[800]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 65),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _analyzeData,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "START ANALYSIS",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // New History Button
              Center(
                child: TextButton.icon(
                  onPressed: _showHistory,
                  icon: const Icon(Icons.history, color: Colors.blueGrey),
                  label: const Text(
                    "View Recent Scans",
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

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

        if (mounted) {
          setState(() {
            _advice = _calculateExpertRules(deficiency);
            _isLoading = false;
          });
          _saveToHistory(_advice['diagnosis']!);
        }
      } else {
        if (mounted) {
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
      }
    } catch (e) {
      if (mounted) {
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
  }

  // Save the record to Hive storage
  void _saveToHistory(String diagnosis) {
    if (diagnosis == "No Leaf Found" ||
        diagnosis == "System Error" ||
        diagnosis == "TOO EARLY") {
      return;
    }

    var box = Hive.box('scanHistory');
    List history = box.get('scans', defaultValue: []);

    DateTime now = DateTime.now();
    String formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    Map scanData = {
      'date': formattedDate,
      'diagnosis': diagnosis,
      'age': widget.age,
      'yield': widget.yield,
    };

    history.insert(0, scanData);
    if (history.length > 5) {
      history = history.sublist(0, 5); // Keep only the top 5
    }
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

  Widget _buildParamChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.blueGrey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[900],
            fontSize: 13,
          ),
        ),
      ],
    );
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
        : (isWarning ? Colors.blueGrey : Colors.orange[800]!);
    IconData statusIcon = isHealthy
        ? Icons.check_circle
        : (isWarning ? Icons.info_outline : Icons.warning_rounded);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Analysis Report",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.green),
                  const SizedBox(height: 24),
                  Text(
                    _debugLog,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. IMAGE CARD WITH BOUNDING BOX
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      height: 240,
                      decoration: const BoxDecoration(color: Colors.black),
                      child: _nativeImage == null
                          ? Image.file(
                              File(widget.imageFile.path),
                              fit: BoxFit.cover,
                            )
                          : CustomPaint(
                              foregroundPainter: BoundingBoxPainter(
                                _detectedBoxes,
                                _nativeImage!,
                              ),
                              child: Image.file(
                                File(widget.imageFile.path),
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. PARAMETERS SUMMARY BAR
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueGrey[100]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildParamChip(
                          Icons.calendar_month,
                          "${widget.age} DAT",
                        ),
                        _buildParamChip(Icons.scale, "${widget.yield} T/Ha"),
                        _buildParamChip(Icons.map, "${widget.area} Ha"),
                      ],
                    ),
                  ),

                  // NEW YIELD PREDICTOR UI
                  if (_advice.containsKey('predicted'))
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: isHealthy ? Colors.green[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isHealthy
                              ? Colors.green[200]!
                              : Colors.red[200]!,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.trending_down,
                                size: 18,
                                color: isHealthy
                                    ? Colors.green[700]
                                    : Colors.red[700],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Untreated Yield Forecast:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isHealthy
                                      ? Colors.green[900]
                                      : Colors.red[900],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _advice['predicted']!,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: isHealthy
                                  ? Colors.green[800]
                                  : Colors.red[800],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // 3. DIAGNOSIS STATUS CARD
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(statusIcon, color: primaryStatusColor, size: 32),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _advice['diagnosis']!.toUpperCase(),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: primaryStatusColor,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // NEW DEFICIENCY IMPACT BLOCK
                  if (_advice.containsKey('impact') && !isWarning)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange[200]!,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange[800],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "AGRONOMIC IMPACT",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.orange[900],
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _advice['impact']!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    height: 1.4,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // 4. TREATMENT PRESCRIPTION CARD
                  if (!isHealthy && !isWarning)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green[50]!, Colors.green[100]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.green[200]!,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.medical_services_outlined,
                                color: Colors.green[800],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "TREATMENT PLAN",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.green[800],
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                            color: Colors.black12,
                            height: 24,
                            thickness: 1,
                          ),
                          Text(
                            _advice['recommendation']!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "REQUIRED QTY: ",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  _advice['qty']!,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.orange[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Alternative minimal card for Healthy, Warning, or TOO EARLY states
                  if (isHealthy || isWarning)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Center(
                        child: Text(
                          _advice['recommendation']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // 5. COLLAPSIBLE LOGIC PANEL
                  Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      collapsedBackgroundColor: Colors.blueGrey[50],
                      backgroundColor: Colors.blueGrey[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      collapsedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: const Icon(
                        Icons.psychology,
                        color: Colors.blueGrey,
                      ),
                      title: const Text(
                        "View System Inference Logic",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            bottom: 16.0,
                          ),
                          child: Text(
                            _advice['rule']!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}

class BoundingBoxPainter extends CustomPainter {
  final List<Map<String, dynamic>> boxes;
  final ui.Image originalImage;

  BoundingBoxPainter(this.boxes, this.originalImage);

  @override
  void paint(Canvas canvas, Size size) {
    if (boxes.isEmpty) return;

    final double scaleX = size.width / originalImage.width;
    final double scaleY = size.height / originalImage.height;

    final Paint boxPaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final Paint textBgPaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.fill;

    for (var boxData in boxes) {
      List<dynamic> box = boxData['box'];

      double left = box[0] * scaleX;
      double top = box[1] * scaleY;
      double right = box[2] * scaleX;
      double bottom = box[3] * scaleY;

      double score = box[4] * 100;

      String tag = boxData['tag'] ?? "Leaf";

      final rect = Rect.fromLTRB(left, top, right, bottom);
      canvas.drawRect(rect, boxPaint);

      String label = "$tag: ${score.toStringAsFixed(1)}%";

      TextSpan span = TextSpan(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        text: label,
      );
      TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );
      tp.layout();

      double labelTop = top - 18 < 0 ? 0 : top - 18;
      canvas.drawRect(
        Rect.fromLTWH(left, labelTop, tp.width + 4, 18),
        textBgPaint,
      );
      tp.paint(canvas, Offset(left + 2, labelTop + 1));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
