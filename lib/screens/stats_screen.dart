import 'package:flutter/material.dart';
import 'package:multy_app/l10n/app_localizations.dart';
import 'package:multy_app/providers/quiz_attemp_provider.dart';
import 'package:multy_app/widgets/stats/table_stats_widget.dart';
import 'package:multy_app/widgets/ui/content_unavailable_view.dart';
import 'package:provider/provider.dart'; // Para las traducciones

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreCalculatedStatistics();
  }

  Future<void> _loadPreCalculatedStatistics() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    // Obtener todos los intentos de la base de datos
    final provider = Provider.of<QuizAttempProvider>(context, listen: false);
    provider.loadStatistics();

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
          : provider.overallStats == null ||
                provider.overallStats!.totalQuizzesPlayed == 0 &&
                    provider.allTableStats.every((s) => s.totalAttempts == 0)
          ? ContentUnavailableView(
              icon: Icons.bar_chart,
              // title: 'Invalid argument',
              message: l10n.noStatsAvailable,
            )
          : _buildStatsContent(provider, l10n),
    );
  }

  Widget _buildStatsContent(
    QuizAttempProvider provider,
    AppLocalizations l10n,
  ) {
    return RefreshIndicator(
      // Para poder recargar las estadísticas
      onRefresh: _loadPreCalculatedStatistics,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Sección de Estadísticas Generales
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

          // Sección de Estadísticas por Tabla
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
          }).toList(),
        ],
      ),
    );
  }
}
