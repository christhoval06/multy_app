import 'package:flutter/material.dart';
import 'package:multy_app/l10n/app_localizations.dart';
import 'package:multy_app/providers/profile_provider.dart';
import 'package:multy_app/providers/quiz_attemp_provider.dart';
import 'package:multy_app/widgets/stats/session_history_list.dart';
import 'package:multy_app/widgets/stats/table_stats_widget.dart';
import 'package:provider/provider.dart'; // Para las traducciones

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _isLoading = true;
  ProfileSelectionMode? _lastSelectionMode;
  int? _lastProfileId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profileProvider = Provider.of<ProfileProvider>(context);
    final activeProfileId = profileProvider.activeProfile?.id;
    final shouldReload =
        _lastSelectionMode != profileProvider.mode ||
        _lastProfileId != activeProfileId;

    if (!shouldReload) {
      return;
    }

    _lastSelectionMode = profileProvider.mode;
    _lastProfileId = activeProfileId;
    _loadPreCalculatedStatistics();
  }

  Future<void> _loadPreCalculatedStatistics() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final quizProvider = Provider.of<QuizAttempProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    await quizProvider.loadStatisticsForSelection(
      selectionMode: profileProvider.mode,
      activeProfileId: profileProvider.activeProfile?.id,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<QuizAttempProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statisticsTitle), centerTitle: true),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(l10n.loadingStats),
                ],
              ),
            )
          : _buildStatsContent(provider, profileProvider, l10n),
    );
  }

  Widget _buildStatsContent(
    QuizAttempProvider provider,
    ProfileProvider profileProvider,
    AppLocalizations l10n,
  ) {
    final hasSavedStats =
        provider.overallStats != null &&
        (provider.overallStats!.totalQuizzesPlayed > 0 ||
            provider.allTableStats.any((stats) => stats.totalAttempts > 0));

    return RefreshIndicator(
      onRefresh: _loadPreCalculatedStatistics,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildProfileContextCard(profileProvider, l10n),
          const SizedBox(height: 24),
          if (hasSavedStats) ...[
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.overallStats,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const Icon(
                        Icons.assessment_outlined,
                        color: Colors.blueAccent,
                      ),
                      title: Text(
                        l10n.totalQuizzesPlayed(
                          provider.overallStats!.totalQuizzesPlayed,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.pie_chart_outline_outlined,
                        color: Colors.green,
                      ),
                      title: Text(
                        l10n.overallAccuracy(
                          provider.overallStats!.overallAccuracy.toStringAsFixed(
                            1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.statsByTable,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...provider.allTableStats.map((stats) {
              if (stats.totalAttempts == 0) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(l10n.tableNumberHeader(stats.tableNumber)),
                    subtitle: Text(l10n.noAttemptsYet),
                  ),
                );
              }
              return TableStatsWidget(stats: stats);
            }),
          ] else if (profileProvider.hasPersistentSelection)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_emptyStateMessage(profileProvider, l10n)),
              ),
            ),
          const SizedBox(height: 24),
          if (profileProvider.hasPersistentSelection) ...[
            Text(
              l10n.sessionHistoryTitle,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.sessionHistorySubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            SessionHistoryList(
              history: provider.sessionHistory,
              emptyMessage: l10n.sessionHistoryEmpty,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileContextCard(
    ProfileProvider profileProvider,
    AppLocalizations l10n,
  ) {
    final title = profileProvider.isGuestSelected
        ? l10n.statsGuestTitle
        : profileProvider.hasPersistentSelection
        ? profileProvider.activeProfile!.name
        : l10n.statsNoProfileTitle;
    final subtitle = profileProvider.isGuestSelected
        ? l10n.statsGuestSubtitle
        : profileProvider.hasPersistentSelection
        ? l10n.statsForProfile(profileProvider.activeProfile!.name)
        : l10n.statsNoProfileSubtitle;
    final icon = profileProvider.isGuestSelected
        ? Icons.person_outline
        : profileProvider.hasPersistentSelection
        ? Icons.badge_outlined
        : Icons.person_search_outlined;

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
        ),
      ),
    );
  }

  String _emptyStateMessage(
    ProfileProvider profileProvider,
    AppLocalizations l10n,
  ) {
    if (profileProvider.hasPersistentSelection) {
      return l10n.noStatsAvailable;
    }
    return l10n.statsNoProfileSubtitle;
  }
}
