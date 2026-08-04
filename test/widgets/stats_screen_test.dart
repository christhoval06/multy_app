import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multy_app/l10n/app_localizations.dart';
import 'package:multy_app/models/profile.dart';
import 'package:multy_app/models/quiz_attemp.dart';
import 'package:multy_app/models/table_overall_stats.dart';
import 'package:multy_app/providers/profile_provider.dart';
import 'package:multy_app/providers/quiz_attemp_provider.dart';
import 'package:multy_app/screens/stats_screen.dart';
import 'package:multy_app/widgets/stats/session_history_list.dart';
import 'package:provider/provider.dart';

void main() {
  group('StatsScreen', () {
    testWidgets('shows active profile history entries', (tester) async {
      final quizProvider = _FakeQuizAttempProvider(
        overallStats: OverallStatsData(
          totalQuizzesPlayed: 2,
          overallAccuracy: 80.0,
        ),
        allTableStats: <TableOverallStats>[
          TableOverallStats(
            tableNumber: 4,
            profileId: 101,
            totalAttempts: 1,
            totalCorrectAnswersSum: 9,
            totalQuestionsSum: 10,
            bestTimeInSeconds: 18,
            bestScoreCorrect: 9,
            bestScoreTotal: 10,
          ),
          TableOverallStats(
            tableNumber: 7,
            profileId: 101,
            totalAttempts: 1,
            totalCorrectAnswersSum: 7,
            totalQuestionsSum: 10,
            bestTimeInSeconds: 22,
            bestScoreCorrect: 7,
            bestScoreTotal: 10,
          ),
        ],
        sessionHistory: <QuizAttemp>[
          QuizAttemp(
            timestamp: DateTime(2026, 7, 5, 10, 30),
            profileId: 101,
            tableNumber: 4,
            correctAnswers: 9,
            totalQuestions: 10,
            durationInSeconds: 18,
          ),
          QuizAttemp(
            timestamp: DateTime(2026, 7, 5, 9, 0),
            profileId: 101,
            tableNumber: 7,
            correctAnswers: 7,
            totalQuestions: 10,
            durationInSeconds: 22,
          ),
        ],
      );
      final profileProvider = _FakeProfileProvider.persistent(
        Profile(
          id: 101,
          name: 'Mateo',
          avatarKey: 'lion',
          colorValue: 0xFF42A5F5,
        ),
      );

      await tester.pumpWidget(
        _TestApp(
          quizProvider: quizProvider,
          profileProvider: profileProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mateo'), findsOneWidget);
      expect(find.byType(SessionHistoryList, skipOffstage: false), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('00:18', skipOffstage: false),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Score 9/10', skipOffstage: false), findsOneWidget);
      expect(find.textContaining('90.0%', skipOffstage: false), findsWidgets);
      expect(find.text('00:18', skipOffstage: false), findsOneWidget);
    });

    testWidgets('renders guest stats gracefully without history', (tester) async {
      final quizProvider = _FakeQuizAttempProvider(
        overallStats: OverallStatsData(
          totalQuizzesPlayed: 0,
          overallAccuracy: 0,
        ),
        allTableStats: List<TableOverallStats>.generate(
          12,
          (index) => TableOverallStats(
            tableNumber: index + 1,
            profileId: -1,
          ),
        ),
        sessionHistory: const <QuizAttemp>[],
      );
      final profileProvider = _FakeProfileProvider.guest();

      await tester.pumpWidget(
        _TestApp(
          quizProvider: quizProvider,
          profileProvider: profileProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Guest session'), findsOneWidget);
      expect(
        find.text('Guest sessions are not saved, so there is no history yet.'),
        findsOneWidget,
      );
      expect(find.text('Session History'), findsNothing);
    });
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.quizProvider,
    required this.profileProvider,
  });

  final QuizAttempProvider quizProvider;
  final ProfileProvider profileProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<QuizAttempProvider>.value(value: quizProvider),
        ChangeNotifierProvider<ProfileProvider>.value(value: profileProvider),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const StatsScreen(),
      ),
    );
  }
}

class _FakeQuizAttempProvider extends ChangeNotifier
    implements QuizAttempProvider {
  _FakeQuizAttempProvider({
    required this.overallStats,
    required this.allTableStats,
    required this.sessionHistory,
  });

  @override
  final OverallStatsData? overallStats;

  @override
  final List<TableOverallStats> allTableStats;

  @override
  final List<QuizAttemp> sessionHistory;

  @override
  List<int> get tablesToDisplay => List<int>.generate(12, (index) => index + 1);

  @override
  Future<void> loadStatistics() async {}

  @override
  Future<void> loadStatisticsForSelection({
    required ProfileSelectionMode selectionMode,
    required int? activeProfileId,
  }) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProfileProvider extends ChangeNotifier implements ProfileProvider {
  _FakeProfileProvider.persistent(Profile profile)
    : activeProfile = profile,
      mode = ProfileSelectionMode.persistent;

  _FakeProfileProvider.guest()
    : activeProfile = null,
      mode = ProfileSelectionMode.guest;

  @override
  final Profile? activeProfile;

  @override
  final ProfileSelectionMode mode;

  @override
  bool get hasPersistentSelection =>
      mode == ProfileSelectionMode.persistent && activeProfile != null;

  @override
  bool get isGuestSelected => mode == ProfileSelectionMode.guest;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
