import 'package:flutter/material.dart';
import 'package:multy_app/core/constants/app_colors.dart';
import '../../data/landing_content.dart';
import '../theme/landing_theme.dart';
import '../widgets/phone_mockup.dart';

class HeroShowcase extends StatelessWidget {
  const HeroShowcase({super.key});
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 460),
    child: AspectRatio(
      aspectRatio: 460 / 650,
      child: LayoutBuilder(
        builder: (context, box) {
          // Scale the decorative composition, not the user's readable page copy.
          return FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: 460,
              height: 650,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primaryFixed.withValues(alpha: .25),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 18,
                    top: 42,
                    child: PhoneMockup(
                      asset: LandingContent.quiz,
                      label: 'Multy timed multiplication quiz',
                      width: 240,
                      angle: .10,
                    ),
                  ),
                  Positioned(
                    left: 14,
                    bottom: 32,
                    child: PhoneMockup(
                      asset: LandingContent.study,
                      label: 'Multy study flashcards for the table of six',
                      width: 260,
                      angle: -.055,
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 4,
                    child: _FloatingChip(
                      icon: Icons.star_rounded,
                      color: AppColors.secondaryContainer,
                      label: 'STREAK BONUS',
                      title: '100% Mastered!',
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: _FloatingChip(
                      icon: Icons.bolt_rounded,
                      color: AppColors.primaryContainer,
                      label: 'QUICK PACE',
                      title: '60s Speed Run',
                    ),
                  ),
                  const Positioned(
                    left: 0,
                    top: 205,
                    child: ExcludeSemantics(
                      child: Text(
                        '×',
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          color: Color(0x5538B000),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}

class _FloatingChip extends StatelessWidget {
  const _FloatingChip({
    required this.icon,
    required this.color,
    required this.label,
    required this.title,
  });
  final IconData icon;
  final Color color;
  final String label;
  final String title;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 24,
            spreadRadius: -6,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                textScaler: TextScaler.noScaling,
                style: LandingTheme.badge.copyWith(fontSize: 10),
              ),
              Text(
                title,
                textScaler: TextScaler.noScaling,
                style: LandingTheme.cardTitle.copyWith(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
