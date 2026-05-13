import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:rice_nutri_sense/screens/input/profile_header.dart';
import 'package:rice_nutri_sense/screens/input/profile_setup_dialog.dart';
import 'history_dialog.dart';
import 'styled_text_field.dart';
import 'image_display.dart';
import 'new_history_button.dart';
import 'start_analysis_button.dart';
import 'browse_gallery_button.dart';
import 'custom_app_bar.dart';
import '../result/result_screen/result_screen.dart';

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

  @override
  void initState() async {
    super.initState();
    // Check if the user has a profile as soon as the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkProfileSetup());
    await _fetchMarketPrices();
  }

  void _checkProfileSetup() {
    Box<dynamic> box = Hive.box('userProfile');
    // If the name is null, it's a new user
    if (box.get('name') == null) _showProfileSetupDialog();
  }

  void _showProfileSetupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Force them to set it up
      builder: (context) => ProfileSetupDialog(),
    );
  }

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
            style: TextStyle(fontWeight: .bold),
          ),
          backgroundColor: Colors.orange.shade800,
          behavior: .floating,
        ),
      );
    }
  }

  void _showHistory() {
    Box<dynamic> box = Hive.box('scanHistory');
    List history = box.get('scans', defaultValue: []);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: .vertical(top: .circular(20)),
      ),
      builder: (context) => SafeArea(child: HistoryDialog(history: history)),
    );
  }

  Future<void> _fetchMarketPrices() async {
    try {
      final response = await http.get(
        Uri.parse('https://agri-fintech-proxy.onrender.com/market-prices'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        Box<dynamic> box = Hive.box('marketData');

        box.put('palay_fresh_kg', data['palay_fresh_kg']);
        box.put('urea_46_0_0_bag', data['urea_46_0_0_bag']);
        box.put('solophos_0_18_0_bag', data['solophos_0_18_0_bag']);
        box.put('mop_0_0_60_bag', data['mop_0_0_60_bag']);

        debugPrint("📊 Market prices synced successfully.");
      }
    } catch (e) {
      debugPrint("⚠️ Network offline. Using cached market prices.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainContent = [
      const ProfileHeader(),
      const Text(
        "Field Parameters",
        style: TextStyle(
          fontSize: 18,
          fontWeight: .bold,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        "Enter crop details to calibrate PhilRice guidelines.",
        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
      ),
      const SizedBox(height: 20),

      StyledTextField(
        label: "Crop Age (DAT)",
        initialValue: cropAge,
        icon: Icons.calendar_today,
        onChanged: (val) => cropAge = val,
      ),
      StyledTextField(
        label: "Target Yield (Tons/Ha)",
        initialValue: targetYield,
        icon: Icons.scale,
        onChanged: (val) => targetYield = val,
      ),
      StyledTextField(
        label: "Field Size (Hectares)",
        initialValue: fieldSize,
        icon: Icons.map_outlined,
        onChanged: (val) => fieldSize = val,
      ),

      const SizedBox(height: 10),
      const Divider(height: 30, thickness: 1, color: Colors.black12),

      const Text(
        "Leaf Sample",
        style: TextStyle(
          fontSize: 18,
          fontWeight: .bold,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        "Upload a clear, well-lit image of the rice leaf.",
        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
      ),
      const SizedBox(height: 15),

      ImageDisplay(
        imageFile: _imageFile,
        onTapImage: () => _pickImage(.camera),
      ),
      const SizedBox(height: 15),
      BrowseGalleryButton(onBrowseGallery: () => _pickImage(.gallery)),
      const SizedBox(height: 25),
      StartAnalysisButton(onStartAnalysis: _analyzeData),
      const SizedBox(height: 15),
      NewHistoryButton(onShowHistory: _showHistory),
      const SizedBox(height: 20),
    ];
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomAppBar(),
      body: SafeArea(
        top: false,
        left: false,
        right: false,
        bottom: true,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const .all(20.0),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: .start, children: mainContent),
          ),
        ),
      ),
    );
  }
}
