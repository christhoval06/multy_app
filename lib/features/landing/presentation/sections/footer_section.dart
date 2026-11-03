import 'package:flutter/material.dart';
import 'package:multy_app/core/constants/app_colors.dart';
import '../../data/landing_content.dart';
import '../theme/landing_theme.dart';
import '../widgets/section_layout.dart';
import '../widgets/visual_elements.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({
    super.key,
    required this.onNavigate,
    required this.onPrivacy,
    required this.onDeveloper,
    required this.onContact,
    required this.onDownload,
  });
  final ValueChanged<LandingSection> onNavigate;
  final VoidCallback onPrivacy;
  final VoidCallback onDeveloper;
  final VoidCallback onContact;
  final VoidCallback onDownload;
  @override
  Widget build(BuildContext context) => SectionShell(
    color: AppColors.surfaceContainerLow,
    verticalPadding: 48,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveCards(
          maxColumns: 4,
          minCardWidth: 220,
          spacing: 32,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BrandMark(),
                SizedBox(height: 16),
                Text(
                  'The joyful, tactile multiplication adventure for young, curious minds.',
                  style: LandingTheme.body,
                ),
              ],
            ),
            _FooterGroup(
              title: 'Product',
              children: [
                for (final section in [
                  LandingSection.features,
                  LandingSection.howItWorks,
                  LandingSection.story,
                ])
                  TextButton(
                    onPressed: () => onNavigate(section),
                    child: Text(section.label),
                  ),
                TextButton(
                  onPressed: onDownload,
                  child: const Text('App Store ↗'),
                ),
              ],
            ),
            _FooterGroup(
              title: 'Trust & family',
              children: [
                TextButton(
                  onPressed: () => onNavigate(LandingSection.privacy),
                  child: const Text('Privacy & Safety'),
                ),
                TextButton(
                  onPressed: onPrivacy,
                  child: const Text('Privacy Policy'),
                ),
                TextButton(
                  onPressed: onDeveloper,
                  child: const Text('Meet the Developer ↗'),
                ),
              ],
            ),
            _FooterGroup(
              title: 'Get in touch',
              children: [
                TextButton(
                  onPressed: onContact,
                  child: const Text('Support & Feedback'),
                ),
                TextButton(
                  onPressed: onContact,
                  child: const Text('Educator Inquiries'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 36),
        const Divider(color: AppColors.surfaceContainerHigh),
        const SizedBox(height: 16),
        Text(
          '© ${DateTime.now().year} Multy by Christhoval Barba. Crafted with joy for kids everywhere.',
          style: LandingTheme.body.copyWith(fontSize: 12),
        ),
      ],
    ),
  );
}

class _FooterGroup extends StatelessWidget {
  const _FooterGroup({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title.toUpperCase(),
        style: LandingTheme.badge.copyWith(color: AppColors.onSurfaceVariant),
      ),
      const SizedBox(height: 12),
      ...children,
    ],
  );
}
