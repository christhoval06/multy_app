import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multy_app/l10n/app_localizations.dart';
import 'package:multy_app/models/quiz_attemp.dart';

class SessionHistoryList extends StatefulWidget {
  static const int maxVisibleItems = 10;

  const SessionHistoryList({
    super.key,
    required this.history,
    required this.emptyMessage,
  });

  final List<QuizAttemp> history;
  final String emptyMessage;

  @override
  State<SessionHistoryList> createState() => _SessionHistoryListState();
}

class _SessionHistoryListState extends State<SessionHistoryList> {
  bool _isExpanded = false;

  String _formatDuration(int? totalSeconds) {
    if (totalSeconds == null || totalSeconds < 0) {
      return '--:--';
    }

    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (widget.history.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(widget.emptyMessage),
        ),
      );
    }

    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final dateFormat = DateFormat.yMMMd(localeTag).add_jm();
    final hasOverflow = widget.history.length > SessionHistoryList.maxVisibleItems;
    final visibleHistory =
        _isExpanded
            ? widget.history
            : widget.history
                .take(SessionHistoryList.maxVisibleItems)
                .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...visibleHistory.map((attempt) {
          final accuracy = attempt.totalQuestions > 0
              ? (attempt.correctAnswers / attempt.totalQuestions) * 100
              : 0.0;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                child: Text(attempt.tableNumber.toString()),
              ),
              title: Text(l10n.tableNumberHeader(attempt.tableNumber)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.sessionHistoryScore(
                      attempt.correctAnswers,
                      attempt.totalQuestions,
                    )),
                    const SizedBox(height: 2),
                    Text(
                      l10n.sessionHistoryAccuracy(accuracy.toStringAsFixed(1)),
                    ),
                    const SizedBox(height: 2),
                    Text(dateFormat.format(attempt.timestamp)),
                  ],
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDuration(attempt.durationInSeconds),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${accuracy.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        }),
        if (hasOverflow)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Text(
                _isExpanded
                    ? l10n.sessionHistoryShowLess
                    : l10n.sessionHistoryShowAll(widget.history.length),
              ),
            ),
          ),
      ],
    );
  }
}
