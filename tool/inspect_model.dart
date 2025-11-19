import 'dart:io';

import 'package:tflite_flutter/tflite_flutter.dart';

Future<void> main() async {
  final file = File('assets/models/food_classifier.tflite');
  if (!file.existsSync()) {
    stderr.writeln('Model file not found at \\${file.path}');
    exit(1);
  }

  final interpreter = Interpreter.fromFile(file);
  final inputTensor = interpreter.getInputTensor(0);
  final outputTensor = interpreter.getOutputTensor(0);

  print('Input tensor type: \\${inputTensor.type}');
  print('Input tensor shape: \\${inputTensor.shape}');
  print('Output tensor type: \\${outputTensor.type}');
  print('Output tensor shape: \\${outputTensor.shape}');

  interpreter.close();
}
