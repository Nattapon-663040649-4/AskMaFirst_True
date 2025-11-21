import 'package:flutter/material.dart';

class TrueMoneyIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const TrueMoneyIcon({
    Key? key,
    this.size = 30.0,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/askma.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: color, // ใช้เฉพาะถ้าภาพเป็น monochrome
    );
  }
}
