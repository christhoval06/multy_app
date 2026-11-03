import 'package:flutter/material.dart';
import 'package:multy_app/core/constants/app_colors.dart';

class PhoneMockup extends StatelessWidget {
  const PhoneMockup({
    super.key,
    required this.asset,
    required this.label,
    this.width = 250,
    this.angle = 0,
  });
  final String asset;
  final String label;
  final double width;
  final double angle;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: angle,
    child: Container(
      width: width,
      padding: EdgeInsets.all(width * .027),
      decoration: BoxDecoration(
        color: AppColors.inverseSurface,
        borderRadius: BorderRadius.circular(width * .17),
        border: Border.all(color: const Color(0xFF595A56), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E1B1830),
            blurRadius: 40,
            spreadRadius: -15,
            offset: Offset(0, 20),
          ),
          BoxShadow(
            color: Color(0x26206D00),
            blurRadius: 70,
            spreadRadius: -20,
            offset: Offset(0, 35),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width * .14),
        child: AspectRatio(
          aspectRatio: 1206 / 2622,
          child: Image.asset(
            asset,
            semanticLabel: label,
            fit: BoxFit.cover,
            cacheWidth: (width * MediaQuery.devicePixelRatioOf(context))
                .round(),
          ),
        ),
      ),
    ),
  );
}
