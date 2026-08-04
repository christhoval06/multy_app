import 'package:flutter/material.dart';
import 'package:multy_app/configs/profile_avatar_catalog.dart';
import 'package:multy_app/l10n/app_localizations.dart';
import 'package:multy_app/models/profile.dart';

class ProfileFormResult {
  const ProfileFormResult({
    required this.name,
    required this.avatarKey,
    required this.colorValue,
  });

  final String name;
  final String avatarKey;
  final int colorValue;
}

class ProfileFormSheet extends StatefulWidget {
  const ProfileFormSheet({super.key, this.initialProfile});

  final Profile? initialProfile;

  static const List<int> colorOptions = <int>[
    0xFFFFAB40,
    0xFF42A5F5,
    0xFFF06292,
    0xFF81C784,
    0xFF9575CD,
    0xFFFF8A65,
  ];

  static IconData iconForAvatarKey(String avatarKey) {
    return ProfileAvatarCatalog.iconForKey(avatarKey);
  }

  @override
  State<ProfileFormSheet> createState() => _ProfileFormSheetState();
}

class _ProfileFormSheetState extends State<ProfileFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String _selectedAvatarKey;
  late int _selectedColorValue;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialProfile?.name ?? '');
    _selectedAvatarKey =
        widget.initialProfile?.avatarKey ?? ProfileAvatarCatalog.options.first.key;
    _selectedColorValue =
        widget.initialProfile?.colorValue ?? ProfileFormSheet.colorOptions.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.initialProfile != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing
                    ? l10n.profileFormEditTitle
                    : l10n.profileFormCreateTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _ProfilePreviewCard(
                name: _nameController.text.trim(),
                avatarKey: _selectedAvatarKey,
                colorValue: _selectedColorValue,
              ),
              const SizedBox(height: 20),
              TextFormField(
                key: const Key('profile-form-name-field'),
                controller: _nameController,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: l10n.profileFormNameLabel,
                  hintText: l10n.profileFormNameHint,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.profileFormNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                l10n.profileFormAvatarLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final option in ProfileAvatarCatalog.options)
                    ChoiceChip(
                      key: Key('profile-avatar-${option.key}'),
                      label: Text(
                        option.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                      avatar: Icon(option.icon, size: 18),
                      selected: _selectedAvatarKey == option.key,
                      onSelected: (_) {
                        setState(() {
                          _selectedAvatarKey = option.key;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                l10n.profileFormColorLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (var index = 0; index < ProfileFormSheet.colorOptions.length; index++)
                    InkWell(
                      key: Key('profile-color-$index'),
                      borderRadius: BorderRadius.circular(999),
                      onTap: () {
                        setState(() {
                          _selectedColorValue = ProfileFormSheet.colorOptions[index];
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(ProfileFormSheet.colorOptions[index]),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedColorValue ==
                                    ProfileFormSheet.colorOptions[index]
                                ? Colors.black87
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.settingsCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      key: const Key('profile-form-submit-button'),
                      onPressed: _submit,
                      child: Text(
                        isEditing
                            ? l10n.profileFormSaveButton
                            : l10n.profileFormCreateButton,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      ProfileFormResult(
        name: _nameController.text.trim(),
        avatarKey: _selectedAvatarKey,
        colorValue: _selectedColorValue,
      ),
    );
  }
}

class _ProfilePreviewCard extends StatelessWidget {
  const _ProfilePreviewCard({
    required this.name,
    required this.avatarKey,
    required this.colorValue,
  });

  final String name;
  final String avatarKey;
  final int colorValue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final backgroundColor = Color(colorValue);
    final foregroundColor =
        ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark
        ? Colors.white
        : Colors.black87;
    final displayName = name.isEmpty ? l10n.profileFormPreviewPlaceholder : name;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: backgroundColor.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            child: Icon(ProfileFormSheet.iconForAvatarKey(avatarKey)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.profileFormPreviewLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ProfileAvatarCatalog.emojiForKey(avatarKey),
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
