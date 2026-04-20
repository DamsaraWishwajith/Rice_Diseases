import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'dart:convert';

class DiseaseService {
  static final DiseaseService _instance = DiseaseService._internal();
  factory DiseaseService() => _instance;
  DiseaseService._internal();

  Interpreter? _interpreter;
  final List<String> labels = [
    'Bacterialblight',
    'Brownspot',
    'Healthy',
    'Others',
    'Sheath_blight'
  ];

  bool get isLoaded => _interpreter != null;

  Future<void> initModel() async {
    if (_interpreter != null) return;
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/model.tflite');
      debugPrint('AI Model loaded successfully');
    } catch (e) {
      debugPrint('Error loading AI model: $e');
    }
  }

  Future<Map<String, dynamic>> predict(File imageFile) async {
    if (_interpreter == null) await initModel();
    if (_interpreter == null) throw Exception("Model not loaded");

    try {
      // 1. Read and decode image
      final imageBytes = await imageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) throw Exception("Failed to decode image");

      // 2. Resize to 224x224 (standard for this model)
      img.Image resizedImage = img.copyResize(originalImage, width: 224, height: 224);

      // 3. Convert to Float32List and Normalize (0-1)
      // Input shape: [1, 224, 224, 3]
      var input = Float32List(1 * 224 * 224 * 3);
      
      int index = 0;
      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = resizedImage.getPixel(x, y);
          // NEW: Using raw pixel values (0-255) as most Keras MobileNetV3 models 
          // have an internal Rescaling layer. If normalization is needed, 
          // it would happen inside the model.
          input[index++] = pixel.r.toDouble();
          input[index++] = pixel.g.toDouble();
          input[index++] = pixel.b.toDouble();
        }
      }

      // Convert to shaped list for the interpreter
      final inputReshaped = input.reshape([1, 224, 224, 3]);

      // 4. Prepare Output [1, labels.length]
      var output = List.generate(1, (i) => List.filled(labels.length, 0.0));

      // 5. Run Inference
      _interpreter!.run(inputReshaped, output);
      debugPrint("Raw Output Tensor: ${output[0]}");

      // 6. Process Results
      List<double> probabilities = output[0];
      int maxIdx = 0;
      double maxProb = probabilities[0];
      
      for (int i = 1; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIdx = i;
        }
      }

      final probs = <String, int>{};
      for (int i = 0; i < labels.length; i++) {
        probs[labels[i]] = (probabilities[i] * 100).round();
      }

      return {
        'disease': labels[maxIdx],
        'confidence': (maxProb * 100).round(),
        'probabilities': probs,
      };
    } catch (e) {
      debugPrint("Inference error: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getDiseaseInfo(String label) async {
    // Map internal label to user-friendly label if needed
    String searchLabel = label;
    if (label == 'Bacterialblight') searchLabel = 'Bacterial Blight';
    if (label == 'Brownspot') searchLabel = 'Brown Spot';
    if (label == 'Sheath_blight') searchLabel = 'Sheath Blight';

    try {
      final response = await http.post(
        Uri.parse('http://192.168.8.133:8002/api/disease-info'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': searchLabel}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('API Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching disease info: $e');
      return null;
    }
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
