part of 'result_screen.dart';

extension History on ResultScreenState {
  // Save the record to Hive storage
  void _saveToHistory(String diagnosis, int aiCropScore) {
    if (diagnosis == "No Leaf Found" ||
        diagnosis == "System Error" ||
        diagnosis == "TOO EARLY") {
      return;
    }

    Box<dynamic> historyBox = Hive.box('scanHistory');
    List history = historyBox.get('scans', defaultValue: []);

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
      'cropScore': aiCropScore,
    };

    history.insert(0, scanData);
    if (history.length > 5) history = history.sublist(0, 5);
    historyBox.put('scans', history);

    // --- FINTECH SCORING ENGINE ---
    Box<dynamic> profileBox = Hive.box('userProfile');

    // Standard credit scores start at 600
    int currentCreditScore = profileBox.get('credit_score', defaultValue: 600);

    // Calculate Delta:
    // If the plant is super healthy (AI score 90), they gain points.
    // If the plant is dying (AI score 20), they lose points.
    // Formula scales the 0-100 AI score into a -6 to +10 credit point jump.
    int delta = ((aiCropScore - 50) / 5).round();

    // Standard credit score bounds (300 to 850)
    int newCreditScore = (currentCreditScore + delta).clamp(300, 850);

    profileBox.put('credit_score', newCreditScore);

    debugPrint(
      "FINTECH ENGINE: AI Score = $aiCropScore | "
      "Credit Delta = $delta | New Credit Score = $newCreditScore",
    );
  }
}
