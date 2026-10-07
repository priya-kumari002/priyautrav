import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ShifterLogo extends StatelessWidget {
  const ShifterLogo({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.local_shipping_rounded, color: AppColors.primary, size: size),
        const SizedBox(width: 6),
        Text(
          'priyashifter',
          style: TextStyle(
            fontSize: size * 0.85,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
