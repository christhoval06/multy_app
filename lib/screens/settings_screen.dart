import 'package:flutter/material.dart';
import 'package:multy_app/configs/settings.dart';
import 'package:multy_app/configs/profile_avatar_catalog.dart';
import 'package:multy_app/configs/route_paths.dart';
import 'package:multy_app/providers/profile_provider.dart';
import 'package:multy_app/providers/quiz_attemp_provider.dart'; // Asegúrate que este provider exista y tenga deleteAllData
import 'package:multy_app/services/feedback_service.dart';
import 'package:multy_app/services/timer_settings_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// Importa la clase de localizaciones generada
import 'package:multy_app/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = ''; // Se inicializará con el texto localizado
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  int _studyAutoSwipeSeconds = Settings.defaultStudyAutoSwipeSeconds;
  int _quizDurationSeconds = Settings.defaultQuizDurationSeconds;
  bool _timerSettingsLoaded = false;
  TimerSettingsService? _timerSettingsService;

  @override
  void initState() {
    super.initState();
    // No es necesario llamar a _loadAppVersion aquí si lo hacemos en didChangeDependencies
    // o si AppLocalizations está disponible en initState (lo cual suele ser así si el contexto ya está listo)
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Es un buen lugar para inicializar textos que dependen de AppLocalizations
    // si el contexto aún no estaba listo en initState.
    if (_appVersion.isEmpty) {
      // Solo cargar si no se ha cargado aún
      _appVersion = AppLocalizations.of(context)!.settingsLoading;
      _loadAppVersion();
    }
    if (!_timerSettingsLoaded) {
      _timerSettingsService = context.read<TimerSettingsService>();
      _timerSettingsLoaded = true;
      _loadTimerSettings();
    }
    _soundEnabled = FeedbackService.instance.soundEnabled;
    _vibrationEnabled = FeedbackService.instance.vibrationEnabled;
  }

  void _loadTimerSettings() {
    final timerSettings = _timerSettingsService;
    if (timerSettings == null) {
      return;
    }

    _studyAutoSwipeSeconds = timerSettings.readStudyAutoSwipeSeconds();
    _quizDurationSeconds = timerSettings.readQuizDurationSeconds();
  }

  Future<void> _loadAppVersion() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion =
              '${packageInfo.version} (Build ${packageInfo.buildNumber})';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _appVersion = l10n.settingsVersionNotAvailable;
        });
      }
    }
  }

  Future<void> _launchEmail(String email) async {
    final l10n = AppLocalizations.of(context)!;
    // Asunto del correo (podría ser localizado también si es genérico)
    final String emailSubject =
        'Soporte App de Multiplicaciones'; // Ajusta si es necesario

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': emailSubject},
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.settingsCouldNotOpenEmail)));
      }
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final l10n = AppLocalizations.of(context)!;
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsCouldNotOpenLink(urlString))),
        );
      }
    }
  }

  Future<void> _confirmDeleteAllData() async {
    final l10n = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.settingsDestructiveActionTitle),
          content: Text(l10n.settingsDestructiveActionContent),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.settingsCancel),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n.settingsConfirmDeleteAll),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      if (!mounted) {
        return;
      }
      final bool? finalConfirmation = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) {
          String confirmationText = "";
          return StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                title: Text(l10n.settingsFinalConfirmationTitle),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.settingsFinalConfirmationContent),
                    TextField(
                      onChanged: (value) {
                        confirmationText = value;
                      },
                      decoration: InputDecoration(
                        hintText: l10n.settingsFinalConfirmationHint,
                      ),
                      autofocus: true,
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(l10n.settingsCancel),
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: Text(l10n.settingsDeleteDataNow),
                    onPressed: () {
                      // Comparar con el texto esperado (en mayúsculas para ser indulgente)
                      if (confirmationText.trim().toUpperCase() ==
                          l10n.settingsFinalConfirmationHint.toUpperCase()) {
                        Navigator.of(dialogContext).pop(true);
                      } else {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.settingsIncorrectConfirmationText,
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                  ),
                ],
              );
            },
          );
        },
      );

      if (finalConfirmation == true) {
        _performDeleteAllData();
      }
    }
  }

  Future<void> _performDeleteAllData() async {
    final l10n = AppLocalizations.of(context)!;
    // Asumiendo que QuizAttempProvider tiene un método deleteAllData
    // que interactúa con tu ObjectBox store.
    // Asegúrate que este provider esté disponible en el árbol de widgets.
    try {
      await Provider.of<QuizAttempProvider>(
        context,
        listen: false,
      ).deleteAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.settingsAllDataDeleted),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al borrar datos: $e',
            ), // Considera localizar este error también
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    // Aquí podrías refrescar otras partes de la UI si es necesario,
    // por ejemplo, si tienes una pantalla de estadísticas visible,
    // podrías notificarla para que se recargue.
  }

  Future<void> _selectStudyTimer() async {
    final selectedValue = await _showTimerOptionsDialog(
      title: AppLocalizations.of(context)!.settingsStudyTimerTitle,
      options: Settings.studyAutoSwipeOptions,
      currentValue: _studyAutoSwipeSeconds,
    );

    if (selectedValue == null || !mounted) {
      return;
    }

    final timerSettings = _timerSettingsService;
    if (timerSettings == null) {
      return;
    }
    await timerSettings.updateStudyAutoSwipeSeconds(selectedValue);

    if (!mounted) {
      return;
    }

    setState(() {
      _studyAutoSwipeSeconds = selectedValue;
    });
  }

  Future<void> _selectQuizTimer() async {
    final selectedValue = await _showTimerOptionsDialog(
      title: AppLocalizations.of(context)!.settingsQuizTimerTitle,
      options: Settings.quizDurationOptions,
      currentValue: _quizDurationSeconds,
    );

    if (selectedValue == null || !mounted) {
      return;
    }

    final timerSettings = _timerSettingsService;
    if (timerSettings == null) {
      return;
    }
    await timerSettings.updateQuizDurationSeconds(selectedValue);

    if (!mounted) {
      return;
    }

    setState(() {
      _quizDurationSeconds = selectedValue;
    });
  }

  Future<void> _restoreTimerDefaults() async {
    final timerSettings = _timerSettingsService;
    if (timerSettings == null) {
      return;
    }
    await timerSettings.restoreDefaults();

    if (!mounted) {
      return;
    }

    setState(() {
      _studyAutoSwipeSeconds = Settings.defaultStudyAutoSwipeSeconds;
      _quizDurationSeconds = Settings.defaultQuizDurationSeconds;
    });
  }

  Future<int?> _showTimerOptionsDialog({
    required String title,
    required List<int> options,
    required int currentValue,
  }) {
    return showDialog<int>(
      context: context,
      builder: (BuildContext dialogContext) {
        return SimpleDialog(
          title: Text(title),
          children: options.map((option) {
            final isSelected = option == currentValue;
            return SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop(option),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                  ),
                  const SizedBox(width: 12),
                  Text('${option}s'),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtén la instancia de AppLocalizations una vez por build
    final l10n = AppLocalizations.of(context)!;
    final profileProvider = context.watch<ProfileProvider?>();
    final savedProfilesCount = profileProvider?.allProfiles.length ?? 0;
    final activeProfileName = profileProvider?.activeProfile?.name;
    final activeAvatarKey = profileProvider?.activeProfile?.avatarKey;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: _SettingsOverviewCard(
              appName: l10n.settingsAppName,
              activeProfileName: activeProfileName,
              activeAvatarKey: activeAvatarKey,
              profilesCount: savedProfilesCount,
              soundEnabled: _soundEnabled,
              vibrationEnabled: _vibrationEnabled,
            ),
          ),
          _buildSectionTitle(l10n.settingsSectionAppInfo, context),
          ListTile(
            leading: const Icon(
              Icons.apps,
            ), // O un icono más específico de tu app si tienes
            title: Text(l10n.settingsAppName),
            subtitle: Text(l10n.settingsAppDescription),
            isThreeLine:
                true, // Para permitir más espacio si la descripción es larga
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.settingsAppVersion),
            subtitle: Text(
              _appVersion,
            ), // _appVersion ya maneja su estado de carga
          ),

          _buildSectionTitle(l10n.settingsSectionProfiles, context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: _ProfilesSettingsCard(
              profilesCount: savedProfilesCount,
              maxProfiles: profileProvider?.maxProfiles ?? 4,
              activeProfileName: activeProfileName,
              activeAvatarKey: profileProvider?.activeProfile?.avatarKey,
              onTap: () {
                Navigator.of(context).pushNamed(RoutePaths.profileManagement);
              },
            ),
          ),
          _buildSectionTitle(l10n.settingsSectionTiming, context),
          ListTile(
            key: const Key('settings-study-timer-tile'),
            leading: const Icon(Icons.style_outlined),
            title: Text(l10n.settingsStudyTimerTitle),
            subtitle: Text(
              '${l10n.settingsStudyTimerSubtitle}\n${_studyAutoSwipeSeconds}s',
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
            onTap: _selectStudyTimer,
          ),
          ListTile(
            key: const Key('settings-quiz-timer-tile'),
            leading: const Icon(Icons.timer_outlined),
            title: Text(l10n.settingsQuizTimerTitle),
            subtitle: Text(
              '${l10n.settingsQuizTimerSubtitle}\n${_quizDurationSeconds}s',
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
            onTap: _selectQuizTimer,
          ),
          ListTile(
            key: const Key('settings-restore-timers-tile'),
            leading: const Icon(Icons.restart_alt),
            title: Text(l10n.settingsRestoreTimerDefaultsTitle),
            subtitle: Text(l10n.settingsRestoreTimerDefaultsSubtitle),
            onTap: _restoreTimerDefaults,
          ),

          // ListTile(
          //   leading: const Icon(Icons.article_outlined),
          //   title: Text(l10n.settingsTermsAndConditions),
          //   onTap: () { /* Lógica para abrir URL de Términos */ },
          //   trailing: const Icon(Icons.chevron_right),
          // ),
          // ListTile(
          //   leading: const Icon(Icons.privacy_tip_outlined),
          //   title: Text(l10n.settingsPrivacyPolicy),
          //   onTap: () { /* Lógica para abrir URL de Privacidad */ },
          //   trailing: const Icon(Icons.chevron_right),
          // ),
          _buildSectionTitle(l10n.settingsSectionFeedback, context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: _FeedbackSettingsCard(
              soundEnabled: _soundEnabled,
              vibrationEnabled: _vibrationEnabled,
              onSoundChanged: (value) async {
                await FeedbackService.instance.setSoundEnabled(value);
                if (!mounted) return;
                setState(() {
                  _soundEnabled = value;
                });
              },
              onVibrationChanged: (value) async {
                await FeedbackService.instance.setVibrationEnabled(value);
                if (!mounted) return;
                setState(() {
                  _vibrationEnabled = value;
                });
              },
            ),
          ),
          _buildSectionTitle(l10n.settingsSectionSupport, context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: _SupportSettingsCard(
              onReportTap: () => _launchEmail('christhoval06@gmail.com'),
            ),
          ),

          _buildSectionTitle(l10n.settingsSectionDeveloper, context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: _DeveloperSettingsCard(
              onPortfolioTap: () => _launchUrl('https://s.christhoval.dev'),
              onGithubTap: () => _launchUrl('https://github.com/christhoval06'),
              onLinkedInTap: () => _launchUrl(
                'https://www.linkedin.com/in/christhoval/',
              ),
              onEmailTap: () => _launchEmail('christhoval06@gmail.com'),
            ),
          ),

          _buildSectionTitle(l10n.settingsSectionDataManagement, context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: _DangerSettingsCard(
              onTap: _confirmDeleteAllData,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20.0,
        left: 16.0,
        right: 16.0,
        bottom: 8.0,
      ),
      child: Text(
        title.toUpperCase(), // El título ya viene localizado
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _ProfilesSettingsCard extends StatelessWidget {
  const _ProfilesSettingsCard({
    required this.profilesCount,
    required this.maxProfiles,
    required this.activeProfileName,
    required this.activeAvatarKey,
    required this.onTap,
  });

  final int profilesCount;
  final int maxProfiles;
  final String? activeProfileName;
  final String? activeAvatarKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final avatarEmoji = ProfileAvatarCatalog.emojiForKey(
      activeAvatarKey ?? 'star',
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('settings-manage-profiles-tile'),
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primaryContainer,
                colorScheme.secondaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.38),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(avatarEmoji, style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.settingsManageProfilesTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Container(
                          key: const Key('settings-profiles-badge'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '$profilesCount/$maxProfiles',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.settingsManageProfilesSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.settingsProfilesSummary(profilesCount),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (activeProfileName != null && activeProfileName!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          l10n.settingsProfilesActiveSummary(activeProfileName!),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSecondaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsOverviewCard extends StatelessWidget {
  const _SettingsOverviewCard({
    required this.appName,
    required this.activeProfileName,
    required this.activeAvatarKey,
    required this.profilesCount,
    required this.soundEnabled,
    required this.vibrationEnabled,
  });

  final String appName;
  final String? activeProfileName;
  final String? activeAvatarKey;
  final int profilesCount;
  final bool soundEnabled;
  final bool vibrationEnabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final avatarEmoji = ProfileAvatarCatalog.emojiForKey(
      activeAvatarKey ?? 'star',
    );
    final l10n = AppLocalizations.of(context)!;

    return Container(
      key: const Key('settings-overview-card'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.tertiary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(avatarEmoji, style: const TextStyle(fontSize: 30)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                    if (activeProfileName != null && activeProfileName!.isNotEmpty)
                      Text(
                        activeProfileName!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _OverviewPill(label: l10n.settingsOverviewProfiles(profilesCount)),
              _OverviewPill(
                label: soundEnabled
                    ? l10n.settingsSoundOn
                    : l10n.settingsSoundOff,
              ),
              _OverviewPill(
                label: vibrationEnabled
                    ? l10n.settingsVibrationOn
                    : l10n.settingsVibrationOff,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewPill extends StatelessWidget {
  const _OverviewPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FeedbackSettingsCard extends StatelessWidget {
  const _FeedbackSettingsCard({
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.onSoundChanged,
    required this.onVibrationChanged,
  });

  final bool soundEnabled;
  final bool vibrationEnabled;
  final ValueChanged<bool> onSoundChanged;
  final ValueChanged<bool> onVibrationChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      key: const Key('settings-feedback-card'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.tertiaryContainer,
            colorScheme.surfaceContainerHighest,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: colorScheme.tertiary.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.42),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.tune_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.settingsSectionFeedback,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${soundEnabled ? l10n.settingsSoundOn : l10n.settingsSoundOff} • ${vibrationEnabled ? l10n.settingsVibrationOn : l10n.settingsVibrationOff}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SwitchListTile(
            key: const Key('settings-sound-toggle'),
            secondary: const Icon(Icons.volume_up_outlined),
            title: Text(l10n.settingsSoundTitle),
            subtitle: Text(l10n.settingsSoundSubtitle),
            value: soundEnabled,
            onChanged: onSoundChanged,
          ),
          SwitchListTile(
            key: const Key('settings-vibration-toggle'),
            secondary: const Icon(Icons.vibration_outlined),
            title: Text(l10n.settingsVibrationTitle),
            subtitle: Text(l10n.settingsVibrationSubtitle),
            value: vibrationEnabled,
            onChanged: onVibrationChanged,
          ),
        ],
      ),
    );
  }
}

class _DangerSettingsCard extends StatelessWidget {
  const _DangerSettingsCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('settings-delete-data-card'),
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red.shade50,
                Colors.orange.shade50,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.red.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.red.shade100.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.delete_forever_outlined,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsDeleteAllDataTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.red.shade800,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.settingsDeleteProgressSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeveloperSettingsCard extends StatelessWidget {
  const _DeveloperSettingsCard({
    required this.onPortfolioTap,
    required this.onGithubTap,
    required this.onLinkedInTap,
    required this.onEmailTap,
  });

  final VoidCallback onPortfolioTap;
  final VoidCallback onGithubTap;
  final VoidCallback onLinkedInTap;
  final VoidCallback onEmailTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      key: const Key('settings-developer-card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.surfaceContainerHighest,
            colorScheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundImage: AssetImage('assets/images/profile_pic.png'),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsDeveloperName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.settingsDeveloperDescription,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ActionRow(
            icon: Icons.public,
            title: l10n.settingsPorfolio,
            subtitle: l10n.settingsPorfolioWeb,
            onTap: onPortfolioTap,
          ),
          _ActionRow(
            icon: Icons.code,
            title: l10n.settingsGitHubProfile,
            subtitle: l10n.settingsGitHubUsername,
            onTap: onGithubTap,
          ),
          _ActionRow(
            icon: Icons.link_outlined,
            title: l10n.settingsLinkedInProfile,
            subtitle: l10n.settingsLinkedInUsername,
            onTap: onLinkedInTap,
          ),
          _ActionRow(
            icon: Icons.email_outlined,
            title: l10n.settingsContactDeveloper,
            onTap: onEmailTap,
          ),
        ],
      ),
    );
  }
}

class _SupportSettingsCard extends StatelessWidget {
  const _SupportSettingsCard({required this.onReportTap});

  final VoidCallback onReportTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('settings-support-card'),
        borderRadius: BorderRadius.circular(22),
        onTap: onReportTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.secondaryContainer,
                colorScheme.surfaceContainerHighest,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.bug_report_outlined),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsReportProblem,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.settingsSupportSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSecondaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
