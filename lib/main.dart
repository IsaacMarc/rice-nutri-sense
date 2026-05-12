import 'package:RiceNutriSense/screens/input/input_screen.dart';
import 'package:flutter/material.dart';
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
