import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FooterIllustration extends StatelessWidget {
  const FooterIllustration({super.key, this.variant = 0});

  final int variant;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  AppColors.primary.withValues(alpha: 0.08),
                ],
              ),
            ),
          ),
          if (variant == 0) ...[
            Positioned(
              left: 24,
              bottom: 20,
              child: _boxStack(),
            ),
            Positioned(
              right: 40,
              bottom: 16,
              child: Icon(Icons.two_wheeler, size: 56, color: AppColors.primaryLight),
            ),
            Positioned(
              left: 80,
              bottom: 8,
              child: Icon(Icons.local_shipping_outlined, size: 72, color: AppColors.primary),
            ),
          ] else
            Positioned(
              bottom: 24,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.landscape_outlined, size: 40, color: Colors.green.shade400),
                  const SizedBox(width: 8),
                  Icon(Icons.local_shipping, size: 64, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Icon(Icons.park_outlined, size: 40, color: Colors.green.shade600),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _boxStack() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.inventory_2_outlined, size: 36, color: Colors.brown.shade400),
        Icon(Icons.inventory_2_outlined, size: 28, color: Colors.brown.shade300),
      ],
    );
  }
}
