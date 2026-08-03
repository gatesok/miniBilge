import 'package:flutter/material.dart';

/// Günlük plan ilerleme çubuğu. Dashboard kartında ve detay ekranında kullanılır.
class DailyPlanProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color backgroundColor;
  final Color foregroundColor;

  const DailyPlanProgressBar({
    super.key,
    required this.progress,
    this.height = 10,
    this.backgroundColor = const Color(0x33000000),
    this.foregroundColor = const Color(0xFF6C63FF),
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(height: height, color: backgroundColor),
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                height: height,
                width: constraints.maxWidth * clamped,
                decoration: BoxDecoration(
                  color: foregroundColor,
                  borderRadius: BorderRadius.circular(height),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
