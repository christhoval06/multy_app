import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:multy_app/configs/app_prefs.dart';
import 'package:multy_app/models/profile.dart';
import 'package:multy_app/models/quiz_attemp.dart';
import 'package:multy_app/models/table_overall_stats.dart';
import 'package:multy_app/objectbox.g.dart';
import 'package:multy_app/providers/profile_provider.dart';
import 'package:multy_app/providers/quiz_attemp_provider.dart';
import 'package:multy_app/services/objectbox_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('QuizAttempProvider', () {
    test('persists attempts and aggregated stats for the selected profile only', () async {
      await _withStore((service) async {
        final mateo = Profile(
          name: 'Mateo',
          avatarKey: 'lion',
          colorValue: 0xFF42A5F5,
        );
        mateo.id = service.profileBox.put(mateo);

        final lucia = Profile(
          name: 'Lucia',
          avatarKey: 'fox',
          colorValue: 0xFFFFB300,
        );
        lucia.id = service.profileBox.put(lucia);

        SharedPreferences.setMockInitialValues(<String, Object>{
          AppPrefs.activeProfileMode: ProfileSelectionMode.persistent.name,
          AppPrefs.activeProfileId: mateo.id,
        });
        final prefs = await SharedPreferences.getInstance();

        final provider = QuizAttempProvider(
          objectboxService: service,
          prefs: prefs,
        );

        final firstProfileAttempt = QuizAttemp(
          timestamp: DateTime(2026, 7, 4, 10, 0),
          profileId: 0,
          tableNumber: 3,
          correctAnswers: 8,
          totalQuestions: 10,
          durationInSeconds: 20,
        );
        final secondProfileAttempt = QuizAttemp(
          timestamp: DateTime(2026, 7, 4, 11, 0),
          profileId: 0,
          tableNumber: 7,
          correctAnswers: 7,
          totalQuestions: 10,
          durationInSeconds: 25,
        );
        final otherProfileAttempt = QuizAttemp(
          timestamp: DateTime(2026, 7, 4, 12, 0),
          profileId: 0,
          tableNumber: 3,
          correctAnswers: 5,
          totalQuestions: 10,
          durationInSeconds: 30,
        );

        final firstSaveResult = await provider.saveQuizSession(
          quizAttemp: firstProfileAttempt,
        );
        final secondSaveResult = await provider.saveQuizSession(
          quizAttemp: secondProfileAttempt,
        );

        SharedPreferences.setMockInitialValues(<String, Object>{
          AppPrefs.activeProfileMode: ProfileSelectionMode.persistent.name,
          AppPrefs.activeProfileId: lucia.id,
        });
        await SharedPreferences.getInstance();

        final thirdSaveResult = await provider.saveQuizSession(
          quizAttemp: otherProfileAttempt,
        );

        SharedPreferences.setMockInitialValues(<String, Object>{
          AppPrefs.activeProfileMode: ProfileSelectionMode.persistent.name,
          AppPrefs.activeProfileId: mateo.id,
        });
        await SharedPreferences.getInstance();

        await provider.loadStatistics();

        expect(firstSaveResult.wasSaved, isTrue);
        expect(firstSaveResult.profileId, mateo.id);
        expect(firstSaveResult.profileName, 'Mateo');
        expect(secondSaveResult.wasSaved, isTrue);
        expect(secondSaveResult.profileId, mateo.id);
        expect(thirdSaveResult.wasSaved, isTrue);
        expect(thirdSaveResult.profileId, lucia.id);
        expect(thirdSaveResult.profileName, 'Lucia');

        expect(provider.overallStats, isNotNull);
        expect(provider.overallStats!.totalQuizzesPlayed, 2);
        expect(provider.overallStats!.overallAccuracy, closeTo(75.0, 0.001));

        expect(provider.sessionHistory, hasLength(2));
        expect(
          provider.sessionHistory.map((attempt) => attempt.profileId),
          everyElement(mateo.id),
        );
        expect(provider.sessionHistory.first.tableNumber, 7);
        expect(provider.sessionHistory.last.tableNumber, 3);

        final tableThreeStats = provider.allTableStats.firstWhere(
          (stats) => stats.tableNumber == 3,
        );
        final tableSevenStats = provider.allTableStats.firstWhere(
          (stats) => stats.tableNumber == 7,
        );

        expect(tableThreeStats.profileId, mateo.id);
        expect(tableThreeStats.totalAttempts, 1);
        expect(tableThreeStats.totalCorrectAnswersSum, 8);
        expect(tableSevenStats.profileId, mateo.id);
        expect(tableSevenStats.totalAttempts, 1);
        expect(tableSevenStats.totalCorrectAnswersSum, 7);

        final persistedAttempts = service.quizAttempBox.getAll();
        expect(persistedAttempts, hasLength(3));
      });
    });

    test('does not persist attempts or stats for guest sessions', () async {
      await _withStore((service) async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          AppPrefs.activeProfileMode: ProfileSelectionMode.guest.name,
        });
        final prefs = await SharedPreferences.getInstance();

        final provider = QuizAttempProvider(
          objectboxService: service,
          prefs: prefs,
        );
        final guestAttempt = QuizAttemp(
          timestamp: DateTime(2026, 7, 4, 10, 0),
          profileId: 0,
          tableNumber: 6,
          correctAnswers: 9,
          totalQuestions: 10,
          durationInSeconds: 19,
        );

        final saveResult = await provider.saveQuizSession(quizAttemp: guestAttempt);

        expect(saveResult.wasSaved, isFalse);
        expect(saveResult.isGuestSession, isTrue);
        expect(service.quizAttempBox.count(), 0);
        expect(service.tableOverallStats.count(), 0);

        await provider.loadStatisticsForSelection(
          selectionMode: ProfileSelectionMode.guest,
          activeProfileId: null,
        );

        expect(provider.overallStats, isNotNull);
        expect(provider.overallStats!.totalQuizzesPlayed, 0);
        expect(provider.sessionHistory, isEmpty);
        expect(
          provider.allTableStats.every((stats) => stats.totalAttempts == 0),
          isTrue,
        );
      });
    });

    test('throws when persistent selection points to a missing profile', () async {
      await _withStore((service) async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          AppPrefs.activeProfileMode: ProfileSelectionMode.persistent.name,
          AppPrefs.activeProfileId: 9999,
        });
        final prefs = await SharedPreferences.getInstance();

        final provider = QuizAttempProvider(
          objectboxService: service,
          prefs: prefs,
        );
        final attempt = QuizAttemp(
          timestamp: DateTime(2026, 7, 4, 14, 0),
          profileId: 0,
          tableNumber: 8,
          correctAnswers: 6,
          totalQuestions: 10,
          durationInSeconds: 27,
        );

        await expectLater(
          () => provider.saveQuizSession(quizAttemp: attempt),
          throwsStateError,
        );
        expect(service.quizAttempBox.count(), 0);
        expect(service.tableOverallStats.count(), 0);
      });
    });

    test('loadStatistics scopes to the active persisted profile from preferences', () async {
      await _withStore((service) async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          AppPrefs.activeProfileMode: ProfileSelectionMode.persistent.name,
          AppPrefs.activeProfileId: 303,
        });
        final prefs = await SharedPreferences.getInstance();

        service.quizAttempBox.putMany(<QuizAttemp>[
          QuizAttemp(
            timestamp: DateTime(2026, 7, 4, 9, 0),
            profileId: 303,
            tableNumber: 4,
            correctAnswers: 10,
            totalQuestions: 10,
            durationInSeconds: 16,
          ),
          QuizAttemp(
            timestamp: DateTime(2026, 7, 4, 9, 30),
            profileId: 404,
            tableNumber: 4,
            correctAnswers: 4,
            totalQuestions: 10,
            durationInSeconds: 28,
          ),
        ]);
        service.tableOverallStats.putMany(<TableOverallStats>[
          TableOverallStats(
            tableNumber: 4,
            profileId: 303,
            totalAttempts: 1,
            totalCorrectAnswersSum: 10,
            totalQuestionsSum: 10,
            bestTimeInSeconds: 16,
            bestScoreCorrect: 10,
            bestScoreTotal: 10,
          ),
          TableOverallStats(
            tableNumber: 4,
            profileId: 404,
            totalAttempts: 1,
            totalCorrectAnswersSum: 4,
            totalQuestionsSum: 10,
            bestTimeInSeconds: 28,
            bestScoreCorrect: 4,
            bestScoreTotal: 10,
          ),
        ]);

        final provider = QuizAttempProvider(
          objectboxService: service,
          prefs: prefs,
        );

        await provider.loadStatistics();

        expect(provider.sessionHistory, hasLength(1));
        expect(provider.sessionHistory.single.profileId, 303);
        expect(provider.overallStats, isNotNull);
        expect(provider.overallStats!.totalQuizzesPlayed, 1);

        final tableFourStats = provider.allTableStats.firstWhere(
          (stats) => stats.tableNumber == 4,
        );
        expect(tableFourStats.profileId, 303);
        expect(tableFourStats.totalAttempts, 1);
      });
    });
  });
}

Future<void> _withStore(
  Future<void> Function(ObjectBoxService service) body,
) async {
  final tempDirectory = await Directory.systemTemp.createTemp(
    'multy_quiz_attempt_provider_test_',
  );
  Store? store;
  try {
    store = await openStore(directory: tempDirectory.path);
    final service = ObjectBoxService.forTest(store);
    await body(service);
  } on ArgumentError catch (error) {
    if (error.message.toString().contains('Failed to load dynamic library')) {
      markTestSkipped('ObjectBox runtime is unavailable in this environment.');
      return;
    }
    rethrow;
  } finally {
    store?.close();
    await tempDirectory.delete(recursive: true);
  }
}
