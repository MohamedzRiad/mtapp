import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';

class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? fontSize;

  const CalculatorButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.fontSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      height: double.infinity,
      width: double.infinity,
      borderRadius: BorderRadius.circular(24),
      blur: 10,
      color: Colors.white.withOpacity(0.1),
      borderColor: Colors.white.withOpacity(0.2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
