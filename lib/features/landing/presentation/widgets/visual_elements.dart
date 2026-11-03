import 'package:flutter/material.dart';
import 'package:multy_app/core/constants/app_colors.dart';
import '../../data/landing_content.dart';
import '../theme/landing_theme.dart';

class BadgePill extends StatelessWidget {
  const BadgePill({
    super.key,
    required this.label,
    this.color = AppColors.primaryFixed,
    this.foreground = AppColors.onPrimaryFixed,
    this.icon,
  });
  final String label;
  final Color color;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label.toUpperCase(),
            style: LandingTheme.badge.copyWith(color: foreground),
          ),
        ),
      ],
    ),
  );
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          LandingContent.icon,
          width: 34,
          height: 34,
          excludeFromSemantics: true,
        ),
      ),
      const SizedBox(width: 10),
      Flexible(
        child: Text(
          'Multy',
          style: LandingTheme.cardTitle.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
    ],
  );
}

class FeatureIcon extends StatelessWidget {
  const FeatureIcon({
    super.key,
    required this.icon,
    this.color = AppColors.primaryContainer,
  });
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Icon(icon, color: Colors.white, size: 25),
  );
}
