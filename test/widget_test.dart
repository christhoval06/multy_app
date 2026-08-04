import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multy_app/l10n/app_localizations.dart';
import 'package:multy_app/models/quiz_attemp.dart';
import 'package:multy_app/widgets/stats/session_history_list.dart';

void main() {
  testWidgets('session history renders attempts and empty state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const _HistoryTestApp(
        history: <QuizAttemp>[],
        emptyMessage: 'No saved sessions yet for this profile.',
      ),
    );

    expect(find.text('No saved sessions yet for this profile.'), findsOneWidget);

    await tester.pumpWidget(
      _HistoryTestApp(
        history: <QuizAttemp>[
          QuizAttemp(
            timestamp: DateTime(2026, 7, 5, 10, 30),
            profileId: 1,
            tableNumber: 4,
            correctAnswers: 8,
            totalQuestions: 10,
            durationInSeconds: 18,
          ),
          QuizAttemp(
            timestamp: DateTime(2026, 7, 5, 11, 0),
            profileId: 1,
            tableNumber: 7,
            correctAnswers: 10,
            totalQuestions: 10,
            durationInSeconds: 15,
          ),
        ],
        emptyMessage: 'No saved sessions yet for this profile.',
      ),
    );

    final context = tester.element(find.byType(SessionHistoryList));
    final l10n = AppLocalizations.of(context)!;

    expect(find.text(l10n.tableNumberHeader(4)), findsOneWidget);
    expect(find.text(l10n.tableNumberHeader(7)), findsOneWidget);
    expect(find.text(l10n.sessionHistoryScore(8, 10)), findsOneWidget);
    expect(find.text(l10n.sessionHistoryScore(10, 10)), findsOneWidget);
    expect(find.text(l10n.sessionHistoryAccuracy('80.0')), findsOneWidget);
    expect(find.text(l10n.sessionHistoryAccuracy('100.0')), findsOneWidget);
    expect(find.text('00:18'), findsOneWidget);
    expect(find.text('00:15'), findsOneWidget);
  });

  testWidgets('session history renders only the latest ten attempts', (
    WidgetTester tester,
  ) async {
    final history = List<QuizAttemp>.generate(12, (index) {
      final quizNumber = 12 - index;
      return QuizAttemp(
        timestamp: DateTime(2026, 7, 5, 12, index),
        profileId: 1,
        tableNumber: quizNumber,
        correctAnswers: 10,
        totalQuestions: 10,
        durationInSeconds: quizNumber,
      );
    });

    await tester.pumpWidget(
      _HistoryTestApp(
        history: history,
        emptyMessage: 'No saved sessions yet for this profile.',
      ),
    );

    final context = tester.element(find.byType(SessionHistoryList));
    final l10n = AppLocalizations.of(context)!;

    expect(find.byType(ListTile), findsNWidgets(10));
    expect(find.text('00:12'), findsOneWidget);
    expect(find.text('00:03'), findsOneWidget);
    expect(find.text('00:02'), findsNothing);
    expect(find.text('00:01'), findsNothing);
    expect(find.text(l10n.sessionHistoryShowAll(12)), findsOneWidget);

    await tester.ensureVisible(find.text(l10n.sessionHistoryShowAll(12)));
    await tester.tap(find.text(l10n.sessionHistoryShowAll(12)));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNWidgets(12));
    expect(find.text('00:02'), findsOneWidget);
    expect(find.text('00:01'), findsOneWidget);
    expect(find.text(l10n.sessionHistoryShowLess), findsOneWidget);

    await tester.ensureVisible(find.text(l10n.sessionHistoryShowLess));
    await tester.tap(find.text(l10n.sessionHistoryShowLess));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNWidgets(10));
    expect(find.text('00:02'), findsNothing);
    expect(find.text('00:01'), findsNothing);
  });
}

class _HistoryTestApp extends StatelessWidget {
  const _HistoryTestApp({
    required this.history,
    required this.emptyMessage,
  });

  final List<QuizAttemp> history;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: SessionHistoryList(
            history: history,
            emptyMessage: emptyMessage,
          ),
        ),
      ),
    );
  }
}
