import 'package:flutter/material.dart';
import 'package:multy_app/configs/profile_avatar_catalog.dart';
import 'package:multy_app/l10n/app_localizations.dart';
import 'package:multy_app/models/profile.dart';
import 'package:multy_app/providers/profile_provider.dart';
import 'package:multy_app/widgets/profiles/profile_form_sheet.dart';
import 'package:provider/provider.dart';

class ProfileManagementScreen extends StatelessWidget {
  const ProfileManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileManagementTitle),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          final profiles = profileProvider.allProfiles;
          final canRemoveProfile = profileProvider.profiles.length > 1;
          final l10n = AppLocalizations.of(context)!;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                l10n.profileManagementSubtitle,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              _ProfileManagementOverview(
                savedProfilesCount: profiles.length,
                maxProfiles: profileProvider.maxProfiles,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  key: const Key('profile-management-create-button'),
                  onPressed: profileProvider.canCreateProfile
                      ? () => _showCreateSheet(context)
                      : null,
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: Text(l10n.profileManagementCreateAction),
                ),
              ),
              const SizedBox(height: 12),
              if (!profileProvider.canCreateProfile)
                Text(
                  l10n.profileManagementMaxProfiles(profileProvider.maxProfiles),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(height: 16),
              for (final profile in profiles) ...[
                _ProfileCard(
                  profile: profile,
                  isActive: profileProvider.activeProfile?.id == profile.id,
                  canRemove: canRemoveProfile,
                  onEdit: () => _showEditSheet(context, profile),
                  onArchive: (!profile.isArchived && canRemoveProfile)
                      ? () => _confirmArchive(context, profile)
                      : null,
                  onDelete: canRemoveProfile
                      ? () => _confirmDelete(context, profile)
                      : null,
                ),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _showCreateSheet(BuildContext context) async {
    final result = await showModalBottomSheet<ProfileFormResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ProfileFormSheet(),
    );
    if (result == null || !context.mounted) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    try {
      await context.read<ProfileProvider>().createProfile(
        name: result.name,
        avatarKey: result.avatarKey,
        colorValue: result.colorValue,
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileManagementCreateError)),
      );
    }
  }

  Future<void> _showEditSheet(BuildContext context, Profile profile) async {
    final result = await showModalBottomSheet<ProfileFormResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ProfileFormSheet(initialProfile: profile),
    );
    if (result == null || !context.mounted) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    try {
      await context.read<ProfileProvider>().updateProfile(
        profileId: profile.id,
        name: result.name,
        avatarKey: result.avatarKey,
        colorValue: result.colorValue,
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileManagementEditError)),
      );
    }
  }

  Future<void> _confirmArchive(BuildContext context, Profile profile) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.profileManagementArchiveTitle),
          content: Text(l10n.profileManagementArchiveMessage(profile.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.settingsCancel),
            ),
            FilledButton(
              key: const Key('profile-confirm-archive-button'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.profileManagementArchiveAction),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await context.read<ProfileProvider>().archiveProfile(profile.id);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileManagementArchiveError)),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, Profile profile) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.profileManagementDeleteTitle),
          content: Text(l10n.profileManagementDeleteMessage(profile.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.settingsCancel),
            ),
            FilledButton(
              key: const Key('profile-confirm-delete-button'),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.profileManagementDeleteAction),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await context.read<ProfileProvider>().deleteProfile(profile.id);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileManagementDeleteError)),
      );
    }
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.profile,
    required this.isActive,
    required this.canRemove,
    required this.onEdit,
    required this.onArchive,
    required this.onDelete,
  });

  final Profile profile;
  final bool isActive;
  final bool canRemove;
  final VoidCallback onEdit;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final color = Color(profile.colorValue);
    final foreground = ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black87;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color,
              foregroundColor: foreground,
              child: Text(
                ProfileAvatarCatalog.emojiForKey(profile.avatarKey),
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        profile.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (isActive)
                        _ProfileBadge(
                          label: l10n.profileManagementActiveBadge,
                          backgroundColor: Colors.green.shade100,
                          foregroundColor: Colors.green.shade900,
                        ),
                      if (profile.isArchived)
                        _ProfileBadge(
                          label: l10n.profileManagementArchivedBadge,
                          backgroundColor: Colors.blueGrey.shade100,
                          foregroundColor: Colors.blueGrey.shade800,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile.isArchived
                        ? l10n.profileManagementArchivedSummary
                        : l10n.profileManagementProfileSummary,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            PopupMenuButton<_ProfileMenuAction>(
              key: Key('profile-actions-${profile.id}'),
              onSelected: (action) {
                switch (action) {
                  case _ProfileMenuAction.edit:
                    if (profile.isArchived) return;
                    onEdit();
                    break;
                  case _ProfileMenuAction.archive:
                    if (!profile.isArchived && onArchive != null) {
                      onArchive!();
                    }
                    break;
                  case _ProfileMenuAction.delete:
                    if (onDelete != null) {
                      onDelete!();
                    }
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<_ProfileMenuAction>(
                  key: Key('profile-action-edit-${profile.id}'),
                  value: _ProfileMenuAction.edit,
                  enabled: !profile.isArchived,
                  child: Text(l10n.profileManagementEditAction),
                ),
                if (!profile.isArchived)
                  PopupMenuItem<_ProfileMenuAction>(
                    key: Key('profile-action-archive-${profile.id}'),
                    value: _ProfileMenuAction.archive,
                    enabled: canRemove,
                    child: Text(l10n.profileManagementArchiveAction),
                  ),
                PopupMenuItem<_ProfileMenuAction>(
                  key: Key('profile-action-delete-${profile.id}'),
                  value: _ProfileMenuAction.delete,
                  enabled: canRemove,
                  child: Text(
                    l10n.profileManagementDeleteAction,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileManagementOverview extends StatelessWidget {
  const _ProfileManagementOverview({
    required this.savedProfilesCount,
    required this.maxProfiles,
  });

  final int savedProfilesCount;
  final int maxProfiles;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.onSecondaryContainer.withValues(
              alpha: 0.1,
            ),
            foregroundColor: colorScheme.onSecondaryContainer,
            child: const Icon(Icons.groups_rounded),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.profileManagementSavedCount(
                    savedProfilesCount,
                    maxProfiles,
                  ),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.profileManagementGuestHint,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSecondaryContainer.withValues(
                      alpha: 0.92,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

enum _ProfileMenuAction { edit, archive, delete }
