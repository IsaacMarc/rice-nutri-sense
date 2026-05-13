part of 'result_screen.dart';

extension Assessment on ResultScreenState {
  Future<Map<String, dynamic>> _fetchAIAssessment({
    required Map<String, dynamic> analysisResult,
    required bool useVision,
    Uint8List? imageBytes,
  }) async {
    final String endpoint = useVision ? 'analyze-vision' : 'analyze-fast';
    final Uri url = Uri.parse(
      'https://agri-fintech-proxy.onrender.com/$endpoint',
    );
    final int fallbackScore = analysisResult['confidence'] ?? 50;

    try {
      final Map<String, dynamic> payload;
      if (useVision && imageBytes != null) {
        payload = {'image_base64': base64Encode(imageBytes)};
      } else {
        payload = analysisResult;
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        return {
          'financial_assessment':
              resData['financial_assessment'] ?? "Assessment unavailable.",
          'crop_score': resData['crop_score'] ?? fallbackScore,
        };
      } else {
        return {
          'financial_assessment': "AI Server Error: ${response.statusCode}",
          'crop_score': fallbackScore,
        };
      }
    } catch (e) {
      return {
        'financial_assessment': "Network connection failed.",
        'crop_score': fallbackScore,
      };
    }
  }
}
