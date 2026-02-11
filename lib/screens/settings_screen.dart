import 'package:flutter/material.dart';
import 'package:multy_app/providers/quiz_attemp_provider.dart'; // Asegúrate que este provider exista y tenga deleteAllData
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

  @override
  Widget build(BuildContext context) {
    // Obtén la instancia de AppLocalizations una vez por build
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: <Widget>[
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
          _buildSectionTitle(l10n.settingsSectionDeveloper, context),
          ListTile(
            leading: const CircleAvatar(
              backgroundImage: AssetImage(
                'assets/images/profile_pic.png',
              ), // Descomenta si tienes la imagen
              backgroundColor: Colors.grey,
              // child: Icon(Icons.person, color: Colors.white), // Placeholder si no hay imagen
            ),
            title: Text(l10n.settingsDeveloperName),
            subtitle: Text(l10n.settingsDeveloperDescription),
          ),
          ListTile(
            leading: const Icon(Icons.public),
            title: Text(l10n.settingsPorfolio),
            subtitle: Text(l10n.settingsPorfolioWeb),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _launchUrl('https://s.christhoval.dev'),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: Text(l10n.settingsGitHubProfile),
            subtitle: Text(l10n.settingsGitHubUsername),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _launchUrl('https://github.com/christhoval06'),
          ),
          ListTile(
            leading: const Icon(Icons.link_outlined),
            title: Text(l10n.settingsLinkedInProfile),
            subtitle: Text(l10n.settingsLinkedInUsername),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _launchUrl('https://www.linkedin.com/in/christhoval/'),
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: Text(l10n.settingsContactDeveloper),
            onTap: () => _launchEmail('christhoval06@gmail.com'),
          ),

          _buildSectionTitle(l10n.settingsSectionSupport, context),
          ListTile(
            leading: const Icon(Icons.bug_report_outlined),
            title: Text(l10n.settingsReportProblem),
            onTap: () => _launchEmail('christhoval06@gmail.com'),
          ),

          _buildSectionTitle(l10n.settingsSectionDataManagement, context),
          ListTile(
            leading: Icon(
              Icons.delete_forever_outlined,
              color: Colors.red.shade700,
            ),
            title: Text(
              l10n.settingsDeleteAllDataTitle,
              style: TextStyle(color: Colors.red.shade700),
            ),
            subtitle: Text(
              // Ajusta este subtítulo según tu app
              // Ejemplo para app de matemáticas:
              "Elimina todos los intentos de quiz y estadísticas.",
              // l10n.settingsDeleteAllDataSubtitle, // Usa la clave adecuada si la tienes
            ),
            onTap: _confirmDeleteAllData,
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
