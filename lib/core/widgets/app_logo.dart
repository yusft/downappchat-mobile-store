import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double? size;
  final double? width;
  final double? height;
  final BoxFit fit;

  const AppLogo({
    super.key,
    this.size,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: size ?? width,
      height: size ?? height,
      fit: fit,
    );
  }
}
