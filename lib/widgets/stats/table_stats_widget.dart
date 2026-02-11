import 'package:flutter/material.dart';
import 'package:multy_app/l10n/app_localizations.dart';

import 'package:multy_app/models/table_overall_stats.dart';

class TableStatsWidget extends StatelessWidget {
  final TableOverallStats stats;
  const TableStatsWidget({super.key, required this.stats});

  String _formatDuration(int? totalSeconds) {
    if (totalSeconds == null || totalSeconds < 0) {
      return '-'; // O un string vacío o "N/A"
    }

    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.tableNumberHeader(stats.tableNumber),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.attempts(stats.totalAttempts)),
                Text(
                  l10n.accuracy(stats.averageAccuracy.toStringAsFixed(1)),
                  style: TextStyle(
                    color: stats.averageAccuracy >= 80
                        ? Colors.green.shade700
                        : stats.averageAccuracy >= 50
                        ? Colors.orange.shade700
                        : Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Solo mostrar mejor puntuación si hubo preguntas
            if (stats.bestScoreTotal > 0)
              Text(
                l10n.bestScore(stats.bestScoreCorrect, stats.bestScoreTotal),
              ),

            if (stats.bestTimeInSeconds != null && stats.bestTimeInSeconds! > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.bestTime(
                        _formatDuration(stats.bestTimeInSeconds),
                      ), // Usaremos l10n
                      // style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
