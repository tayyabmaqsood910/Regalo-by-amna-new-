import 'package:flutter/material.dart';

/// Floral palette for Regalo by Amna: forest, sage, cream, and blush.
abstract final class AppColors {
  static const forest = Color(0xFF1E3A2F);
  static const forestDeep = Color(0xFF14281F);
  static const sage = Color(0xFF8AA386);
  static const sageDeep = Color(0xFF5E735C);
  static const sageLight = Color(0xFFDCE6D8);
  static const cream = Color(0xFFF6F1E8);
  static const card = Color(0xFFFFFCF8);
  static const blush = Color(0xFFF3D5D8);
  static const blushDeep = Color(0xFFB76E78);
  static const ink = Color(0xFF24302A);
  static const muted = Color(0xFF6D776F);
  static const line = Color(0xFFE4DCD0);
  static const danger = Color(0xFF8E3B3B);

  static const cardShadow = [
    BoxShadow(color: Color(0x1424302A), blurRadius: 18, offset: Offset(0, 8)),
  ];
}
