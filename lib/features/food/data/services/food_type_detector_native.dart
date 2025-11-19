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

      final orientedImage = img.bakeOrientation(decodedImage);
      final preprocessCandidates = <_PreprocessedInput>[
        _PreprocessedInput(
          strategyName: 'center_crop_square',
          image: img.copyResizeCropSquare(orientedImage, size: _inputSize),
        ),
      ];

      final needsAlternateResize =
          decodedImage.width != decodedImage.height ||
          decodedImage.width != _inputSize ||
          decodedImage.height != _inputSize;

      if (needsAlternateResize) {
        preprocessCandidates.add(
          _PreprocessedInput(
            strategyName: 'uniform_resize',
            image: img.copyResize(
              orientedImage,
              width: _inputSize,
              height: _inputSize,
              interpolation: img.Interpolation.cubic,
            ),
          ),
        );
      }

      preprocessCandidates.add(
        _PreprocessedInput(
          strategyName: 'uniform_resize_vibrant',
          image: img.adjustColor(
            img.copyResize(
              orientedImage,
              width: _inputSize,
              height: _inputSize,
              interpolation: img.Interpolation.linear,
            ),
            saturation: 1.08,
            gamma: 0.95,
          ),
        ),
      );

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

      _InferenceAttemptResult? bestResult;
      for (final candidate in preprocessCandidates) {
        final result = _runInferenceAttempt(
          interpreter: interpreter,
          image: candidate.image,
          strategyName: candidate.strategyName,
          expectsQuantizedInput: expectsQuantizedInput,
          producesQuantizedOutput: producesQuantizedOutput,
          numClasses: numClasses,
          outputTensor: outputTensor,
        );
        if (bestResult == null ||
            result.maxProbability > bestResult.maxProbability + 1e-6) {
          bestResult = result;
        }
      }

      if (bestResult == null) {
        debugPrint('Food type detection: no inference results were produced.');
        return null;
      }

      if (bestResult.maxIndex >= _modelLabels.length) {
        debugPrint(
          'Food type detection: predicted index ${bestResult.maxIndex} but only ${_modelLabels.length} labels are defined.',
        );
        return null;
      }

      final rawLabel = _modelLabels[bestResult.maxIndex];
      debugPrint(
        'Winning strategy: ${bestResult.strategyName} -> $rawLabel (${bestResult.maxProbability.toStringAsFixed(4)})',
      );
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

class _PreprocessedInput {
  _PreprocessedInput({required this.strategyName, required this.image});

  final String strategyName;
  final img.Image image;
}

class _InferenceAttemptResult {
  _InferenceAttemptResult({
    required this.strategyName,
    required this.maxIndex,
    required this.maxProbability,
    required this.probabilities,
  });

  final String strategyName;
  final int maxIndex;
  final double maxProbability;
  final List<double> probabilities;
}

_InferenceAttemptResult _runInferenceAttempt({
  required Interpreter interpreter,
  required img.Image image,
  required String strategyName,
  required bool expectsQuantizedInput,
  required bool producesQuantizedOutput,
  required int numClasses,
  required Tensor outputTensor,
}) {
  final input = _buildInput(
    image,
    expectsQuantizedInput,
    FoodTypeDetector._inputSize,
  );
  final output = [
    producesQuantizedOutput
        ? List<int>.filled(numClasses, 0)
        : List<double>.filled(numClasses, 0.0),
  ];

  interpreter.run(input, output);

  final probabilities = producesQuantizedOutput
      ? _dequantize(output.first as List<int>, outputTensor.params)
      : List<double>.from(output.first as List<double>);

  final maxIndex = _argMax(probabilities);
  final maxProb = probabilities[maxIndex];
  debugPrint(
    '[$strategyName] Raw probabilities: ${probabilities.map((p) => p.toStringAsFixed(4)).join(', ')}',
  );
  debugPrint(
    '[$strategyName] Max probability: ${maxProb.toStringAsFixed(4)} at index $maxIndex',
  );

  return _InferenceAttemptResult(
    strategyName: strategyName,
    maxIndex: maxIndex,
    maxProbability: maxProb,
    probabilities: probabilities,
  );
}

List<List<List<List<num>>>> _buildInput(
  img.Image image,
  bool expectsQuantizedInput,
  int size,
) {
  final bytes = image.getBytes(order: img.ChannelOrder.rgb);
  var offset = 0;
  return [
    List.generate(size, (_) {
      return List.generate(size, (_) {
        final r = bytes[offset++];
        final g = bytes[offset++];
        final b = bytes[offset++];
        if (expectsQuantizedInput) {
          return <int>[r, g, b];
        }
        return <double>[r / 255.0, g / 255.0, b / 255.0];
      });
    }),
  ];
}

List<double> _dequantize(List<int> values, QuantizationParams params) {
  return values
      .map((value) => params.scale * (value - params.zeroPoint))
      .toList(growable: false);
}

int _argMax(List<double> values) {
  var maxIndex = 0;
  var maxValue = values[0];
  for (var i = 1; i < values.length; i++) {
    if (values[i] > maxValue) {
      maxValue = values[i];
      maxIndex = i;
    }
  }
  return maxIndex;
}
