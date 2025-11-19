import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FoodTypeDetector {
  FoodTypeDetector._();

  static final FoodTypeDetector _instance = FoodTypeDetector._();

  factory FoodTypeDetector() => _instance;

  static const _modelPath = 'assets/models/food_classifier.tflite';
  static const _inputSize = 224;
  static const List<String> _modelLabels = [
    'Burger',
    'Donut',
    'Pizza',
    'Roasted Chicken',
    'club sandwich',
  ];

  Interpreter? _interpreter;

  bool get isLoaded => _interpreter != null;

  Future<void> _ensureLoaded() async {
    if (_interpreter != null) return;
    try {
      final options = InterpreterOptions();
      if (!kIsWeb) {
        options.threads = 2;
      }
      debugPrint('Loading TFLite model from $_modelPath ...');
      _interpreter = await Interpreter.fromAsset(_modelPath, options: options);
      debugPrint('TFLite model loaded successfully.');
    } catch (e) {
      debugPrint('Failed to load TFLite model: $e');
      rethrow;
    }
  }

  Future<String?> detectFoodType({required Uint8List bytes}) async {
    try {
      await _ensureLoaded();
    } catch (_) {
      return null;
    }

    try {
      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) return null;

      final resized = img.copyResizeCropSquare(decodedImage, size: _inputSize);

      final interpreter = _interpreter!;
      final inputTensor = interpreter.getInputTensor(0);
      final outputTensor = interpreter.getOutputTensor(0);
      debugPrint(
        'Input tensor => shape: ${inputTensor.shape}, type: ${inputTensor.type}',
      );
      debugPrint(
        'Output tensor => shape: ${outputTensor.shape}, type: ${outputTensor.type}',
      );
      final expectsQuantizedInput = inputTensor.type == TensorType.uint8;
      final producesQuantizedOutput = outputTensor.type == TensorType.uint8;
      final numClasses = outputTensor.shape.isNotEmpty
          ? outputTensor.shape.last
          : _modelLabels.length;

      final input = List.generate(1, (_) {
        return List.generate(_inputSize, (y) {
          return List.generate(_inputSize, (x) {
            final pixel = resized.getPixel(x, y);
            if (expectsQuantizedInput) {
              return <int>[pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()];
            }
            return <double>[
              pixel.r.toDouble() / 255.0,
              pixel.g.toDouble() / 255.0,
              pixel.b.toDouble() / 255.0,
            ];
          });
        });
      });

      final output = List.generate(1, (_) {
        if (producesQuantizedOutput) {
          return List<int>.filled(numClasses, 0);
        }
        return List<double>.filled(numClasses, 0.0);
      });

      interpreter.run(input, output);

      final probabilities = <double>[];
      if (producesQuantizedOutput) {
        final params = outputTensor.params;
        for (final value in output.first as List<int>) {
          probabilities.add(params.scale * (value - params.zeroPoint));
        }
      } else {
        probabilities.addAll(output.first as List<double>);
      }
      debugPrint(
        'Raw probabilities: ${probabilities.map((p) => p.toStringAsFixed(4)).join(', ')}',
      );
      var maxIndex = 0;
      var maxProb = probabilities[0];
      for (var i = 1; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }
      debugPrint(
        'Max probability: ${maxProb.toStringAsFixed(4)} at index $maxIndex',
      );

      if (maxIndex >= _modelLabels.length) {
        debugPrint(
          'Food type detection: predicted index $maxIndex but only ${_modelLabels.length} labels are defined.',
        );
        return null;
      }
      final rawLabel = _modelLabels[maxIndex];
      debugPrint('Mapped label: $rawLabel');
      return _mapModelLabelToAppLabel(rawLabel);
    } catch (e) {
      debugPrint('Food type detection failed: $e');
      return null;
    }
  }

  String? _mapModelLabelToAppLabel(String label) {
    final normalized = label.trim().toLowerCase();
    switch (normalized) {
      case 'burger':
        return 'Burger';
      case 'donut':
        return 'Donut';
      case 'pizza':
        return 'Pizza';
      case 'roasted chicken':
      case 'chicken':
        return 'Chicken';
      case 'club sandwich':
      case 'sandwich':
        return 'Sandwich';
      default:
        return null;
    }
  }
}
