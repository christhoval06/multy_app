import 'package:flutter/material.dart';
import 'package:multy_app/core/constants/app_colors.dart';
import '../../data/landing_content.dart';
import '../theme/landing_theme.dart';
import '../widgets/phone_mockup.dart';
import '../widgets/section_layout.dart';
import '../widgets/visual_elements.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});
  @override
  Widget build(BuildContext context) => SectionShell(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, box) {
            final heading = ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 630),
              child: const SectionHeading(
                badge: 'Features kids love',
                title: 'Built for Joy, Retaining, and Speed',
                centered: false,
              ),
            );
            const description = Text(
              'No boring worksheets. Multy transforms daily memorization into an interactive playground with instant audio-visual payoffs.',
              style: LandingTheme.body,
            );
            if (box.maxWidth < 850) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [heading, const SizedBox(height: 20), description],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(flex: 7, child: heading),
                const SizedBox(width: 64),
                const Expanded(flex: 4, child: description),
              ],
            );
          },
        ),
        const SizedBox(height: 48),
        LayoutBuilder(
          builder: (context, box) {
            final wide =
                box.maxWidth >= 760 &&
                MediaQuery.textScalerOf(context).scale(15) < 24;
            const study = _FeatureCard(
              title: 'Step-by-Step Study Cards',
              description:
                  'Auto-cycling times table cards with clear visual typography, countdown rings, and memory cues. Pause any time or glide through numbers 1 to 12.',
              icon: Icons.style_outlined,
              asset: LandingContent.tables,
              imageLabel: 'Choose a multiplication table to study',
              color: AppColors.surfaceContainer,
              accent: AppColors.primaryContainer,
              featured: true,
            );
            const quiz = _FeatureCard(
              title: '60-Second Timed Quizzes',
              description:
                  'Test your speed and accuracy with 10-question multiple-choice challenges. Build confidence with immediate, encouraging feedback.',
              icon: Icons.timer_outlined,
              asset: LandingContent.quiz,
              imageLabel: 'A timed Multy multiplication quiz',
              color: Color(0xFFF3F0FB),
              accent: AppColors.tertiary,
              featured: true,
            );
            const scores = _FeatureCard(
              title: 'Joyful Score Celebrations',
              description:
                  'Instant feedback with encouraging messages, personal bests, and progress you can see. Every practice is a step forward.',
              icon: Icons.emoji_events_outlined,
              asset: LandingContent.results,
              imageLabel: 'Multy quiz results and personal best',
              color: Color(0xFFFFF0E2),
              accent: AppColors.secondaryContainer,
            );
            const profiles = _FeatureCard(
              title: 'Profiles for Every Sibling',
              description:
                  'Create individual profiles for siblings or classmates. Keep scores, progress, and practice settings organized locally on your device.',
              icon: Icons.group_outlined,
              asset: LandingContent.profiles,
              imageLabel: 'Multy local learning profiles and settings',
              color: AppColors.surfaceContainer,
              accent: AppColors.primaryContainer,
            );
            if (!wide) {
              return const Column(
                children: [
                  study,
                  SizedBox(height: 24),
                  quiz,
                  SizedBox(height: 24),
                  scores,
                  SizedBox(height: 24),
                  profiles,
                ],
              );
            }
            return const Column(
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 7, child: study),
                      SizedBox(width: 24),
                      Expanded(flex: 5, child: quiz),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: scores),
                      SizedBox(width: 24),
                      Expanded(child: profiles),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    ),
  );
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.asset,
    required this.imageLabel,
    required this.color,
    required this.accent,
    this.featured = false,
  });
  final String title;
  final String description;
  final IconData icon;
  final String asset;
  final String imageLabel;
  final Color color;
  final Color accent;
  final bool featured;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(32),
    child: ColoredBox(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FeatureIcon(icon: icon, color: accent),
            const SizedBox(height: 16),
            Text(title, style: LandingTheme.cardTitle),
            const SizedBox(height: 12),
            Text(description, style: LandingTheme.body),
            const SizedBox(height: 32),
            Align(
              alignment: featured ? Alignment.bottomRight : Alignment.center,
              child: SizedBox(
                height: featured ? 390 : 300,
                child: OverflowBox(
                  alignment: Alignment.topCenter,
                  minHeight: 0,
                  maxHeight: 700,
                  maxWidth: featured ? 280 : 210,
                  child: PhoneMockup(
                    asset: asset,
                    label: imageLabel,
                    width: featured ? 280 : 210,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
