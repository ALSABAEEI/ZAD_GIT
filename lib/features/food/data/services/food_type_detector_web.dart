import 'dart:typed_data';

class FoodTypeDetector {
  FoodTypeDetector._();

  static final FoodTypeDetector _instance = FoodTypeDetector._();

  factory FoodTypeDetector() => _instance;

  bool get isLoaded => false;

  Future<String?> detectFoodType({required Uint8List bytes}) async => null;
}
