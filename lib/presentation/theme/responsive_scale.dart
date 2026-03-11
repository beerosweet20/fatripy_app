import 'package:flutter/material.dart';

class AppScale {
  static const double _baseWidth = 390.0;
  static const double _minScale = 0.85;
  static const double _maxScale = 1.2;

  static double fromSize(Size size) {
    final shortestSide = size.shortestSide;
    return (shortestSide / _baseWidth).clamp(_minScale, _maxScale).toDouble();
  }

  static double of(BuildContext context) {
    return fromSize(MediaQuery.of(context).size);
  }
}
