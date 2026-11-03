import 'package:flutter/material.dart';
import 'package:multy_app/core/constants/app_colors.dart';
import '../theme/landing_theme.dart';
import '../widgets/section_layout.dart';
import '../widgets/visual_elements.dart';

class PrivacySection extends StatelessWidget {
  const PrivacySection({super.key, required this.onPrivacy});
  final VoidCallback onPrivacy;
  @override
  Widget build(BuildContext context) => SectionShell(
    child: Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 830),
          child: const SectionHeading(
            badge: 'Made for kids. Trusted by parents.',
            title: 'Privacy First. No Tricks. No Distractions.',
            description:
                'A calm space to learn, with progress stored on your device and no account required.',
          ),
        ),
        const SizedBox(height: 48),
        const ResponsiveCards(
          maxColumns: 4,
          minCardWidth: 235,
          children: [
            _PrivacyCard(
              icon: Icons.lock_outline_rounded,
              title: 'No Account Needed',
              description:
                  'No mandatory signups, phone numbers, or email addresses. Install and start multiplying.',
              color: AppColors.primaryContainer,
            ),
            _PrivacyCard(
              icon: Icons.sd_storage_outlined,
              title: 'Local Progress',
              description:
                  'Quiz scores, personal bests, and learning profiles stay on your device. Delete local data from Settings.',
              color: AppColors.secondaryContainer,
            ),
            _PrivacyCard(
              icon: Icons.block_rounded,
              title: 'Ad-Free & Calm',
              description:
                  'No third-party banners or popup video interruptions. Just space to focus and learn.',
              color: AppColors.error,
            ),
            _PrivacyCard(
              icon: Icons.language_rounded,
              title: 'Bilingual Design',
              description:
                  'Practice in English or Spanish. A familiar learning experience for more families.',
              color: AppColors.tertiary,
            ),
          ],
        ),
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed: onPrivacy,
          icon: const Icon(Icons.description_outlined),
          label: const Text('Read our Privacy Policy'),
        ),
      ],
    ),
  );
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 300),
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(32),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FeatureIcon(icon: icon, color: color),
        const SizedBox(height: 20),
        Text(title, style: LandingTheme.cardTitle),
        const SizedBox(height: 12),
        Text(description, style: LandingTheme.body),
      ],
    ),
  );
}
