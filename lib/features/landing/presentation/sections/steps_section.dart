import 'package:flutter/material.dart';
import 'package:multy_app/core/constants/app_colors.dart';
import '../theme/landing_theme.dart';
import '../widgets/section_layout.dart';

class StepsSection extends StatelessWidget {
  const StepsSection({super.key});
  @override
  Widget build(BuildContext context) => const SectionShell(
    color: AppColors.surfaceContainerLow,
    child: Column(
      children: [
        ConstrainedHeading(),
        SizedBox(height: 48),
        ResponsiveCards(
          children: [
            _StepCard(
              number: '1',
              eyebrow: 'Pick & focus',
              title: 'Choose Your Table',
              description:
                  'Select any times table from 1 through 12. Focus on tackling tricky tables like 7s, 8s, or 9s one friendly chunk at a time.',
              color: AppColors.primaryFixed,
              foreground: AppColors.primary,
            ),
            _StepCard(
              number: '2',
              eyebrow: 'Internalize patterns',
              title: 'Flip & Remember',
              description:
                  'Watch smooth auto-flip study cards reveal the relationship between factors and products, paired with tactile tap controls.',
              color: AppColors.secondaryFixed,
              foreground: AppColors.secondary,
            ),
            _StepCard(
              number: '3',
              eyebrow: 'Build rapid recall',
              title: 'Beat The 60s Clock',
              description:
                  'Jump into 10 rapid multiple-choice questions. Celebrate your progress and build calculation speed with every practice.',
              color: AppColors.tertiaryFixed,
              foreground: AppColors.tertiary,
            ),
          ],
        ),
      ],
    ),
  );
}

class ConstrainedHeading extends StatelessWidget {
  const ConstrainedHeading({super.key});
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 760),
    child: const SectionHeading(
      badge: 'Effortless learning',
      badgeColor: AppColors.secondaryFixed,
      title: 'Three Easy Steps to Mastery',
      description:
          'Simple, bite-sized practice that helps kids build confidence, one times table at a time.',
    ),
  );
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.number,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.color,
    required this.foreground,
  });
  final String number;
  final String eyebrow;
  final String title;
  final String description;
  final Color color;
  final Color foreground;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(32),
    constraints: const BoxConstraints(minHeight: 320),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(32),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            number,
            style: LandingTheme.cardTitle.copyWith(color: foreground),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          eyebrow.toUpperCase(),
          style: LandingTheme.badge.copyWith(color: foreground),
        ),
        const SizedBox(height: 8),
        Text(title, style: LandingTheme.cardTitle),
        const SizedBox(height: 12),
        Text(description, style: LandingTheme.body),
      ],
    ),
  );
}
