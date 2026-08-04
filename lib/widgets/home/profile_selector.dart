import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multy_app/configs/profile_avatar_catalog.dart';
import 'package:multy_app/l10n/app_localizations.dart';
import 'package:multy_app/providers/profile_provider.dart';
import 'package:multy_app/services/feedback_service.dart';
import 'package:multy_app/theme/app_fonts.dart';
import 'package:provider/provider.dart';

class ProfileSelector extends StatelessWidget {
  const ProfileSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber.shade50,
                Colors.orange.shade50,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.amber.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.shade100.withValues(alpha: 0.65),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.groups_rounded,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.homeProfileSelectorTitle,
                      style: const TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _CountBadge(count: profileProvider.profiles.length),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                l10n.homeProfileSelectorSubtitle,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                key: const Key('home-profile-selector'),
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final profile in profileProvider.profiles)
                    _ProfileOptionChip(
                      key: Key('profile-chip-${profile.id}'),
                      label: profile.name,
                      avatarBackgroundColor: Color(profile.colorValue),
                      avatarForegroundColor: _foregroundForColor(
                        Color(profile.colorValue),
                      ),
                      avatarIcon: ProfileAvatarCatalog.iconForKey(profile.avatarKey),
                      avatarEmoji: ProfileAvatarCatalog.emojiForKey(profile.avatarKey),
                      selected:
                          profileProvider.hasPersistentSelection &&
                          profileProvider.activeProfile?.id == profile.id,
                      onSelected: (_) async {
                        await profileProvider.selectProfileById(profile.id);
                        unawaited(FeedbackService.instance.playProfileSelect());
                      },
                    ),
                  _ProfileOptionChip(
                    key: const Key('profile-chip-guest'),
                    label: l10n.homeProfileGuestLabel,
                    avatarBackgroundColor: Colors.white,
                    avatarForegroundColor: Colors.blueGrey.shade700,
                    avatarIcon: Icons.flash_on_rounded,
                    avatarEmoji: '⚡',
                    selected: profileProvider.isGuestSelected,
                    onSelected: (_) async {
                      await profileProvider.selectGuest();
                      unawaited(FeedbackService.instance.playProfileSelect());
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Color _foregroundForColor(Color backgroundColor) {
    final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);
    return brightness == Brightness.dark ? Colors.white : Colors.black87;
  }
}

class _ProfileOptionChip extends StatelessWidget {
  const _ProfileOptionChip({
    required super.key,
    required this.label,
    required this.avatarBackgroundColor,
    required this.avatarForegroundColor,
    required this.avatarIcon,
    required this.avatarEmoji,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final Color avatarBackgroundColor;
  final Color avatarForegroundColor;
  final IconData avatarIcon;
  final String avatarEmoji;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => onSelected(!selected),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? avatarBackgroundColor : Colors.orange.shade100,
              width: selected ? 2.2 : 1.2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: avatarBackgroundColor.withValues(alpha: 0.22),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : const [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: avatarBackgroundColor,
                foregroundColor: avatarForegroundColor,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(avatarIcon, size: 15),
                    Text(
                      avatarEmoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.orange.shade900 : Colors.black87,
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: avatarBackgroundColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontFamily: AppFonts.display,
          fontSize: 14,
          color: Colors.orange.shade800,
        ),
      ),
    );
  }
}
