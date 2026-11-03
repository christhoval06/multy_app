import 'package:flutter/material.dart';
import 'package:multy_app/core/constants/app_colors.dart';
import '../../data/landing_content.dart';
import '../theme/landing_theme.dart';
import 'tactile_button.dart';
import 'visual_elements.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({
    super.key,
    required this.onNavigate,
    required this.onDownload,
  });
  final ValueChanged<LandingSection> onNavigate;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final desktop = width >= 1150 && scale <= 1.1;
    final narrow = width < 400 || scale > 1.3;
    return Material(
      color: AppColors.surface.withValues(alpha: .97),
      elevation: 1,
      shadowColor: const Color(0x15000000),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width < 600 ? 20 : 48,
            vertical: 16,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: LandingTheme.maxWidth,
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: BrandMark(),
                    ),
                  ),
                  if (desktop) ...[
                    Flexible(
                      flex: 4,
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        children: [
                          for (final section in LandingSection.values)
                            TextButton(
                              onPressed: () => onNavigate(section),
                              child: Text(section.label),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (!narrow)
                    TactileButton(
                      label: 'Download Free',
                      compact: true,
                      onPressed: onDownload,
                    ),
                  if (!desktop)
                    PopupMenuButton<LandingSection>(
                      tooltip: 'Open navigation',
                      icon: const Icon(Icons.menu_rounded),
                      onSelected: onNavigate,
                      itemBuilder: (_) => [
                        for (final section in LandingSection.values)
                          PopupMenuItem(
                            value: section,
                            child: Text(section.label),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
