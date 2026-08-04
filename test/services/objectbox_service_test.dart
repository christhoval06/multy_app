import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:multy_app/configs/app_prefs.dart';
import 'package:multy_app/objectbox.g.dart';
import 'package:multy_app/models/quiz_attemp.dart';
import 'package:multy_app/models/table_overall_stats.dart';
import 'package:multy_app/services/objectbox_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ObjectBoxService legacy best-time repair', () {
    test('repairs stored remaining times and recalculates best times once', () async {
      await _withStore((service) async {
        service.quizAttempBox.putMany(<QuizAttemp>[
          QuizAttemp(
            timestamp: DateTime(2026, 7, 5, 10, 0),
            profileId: 101,
            tableNumber: 4,
            correctAnswers: 9,
            totalQuestions: 10,
            durationInSeconds: 42,
          ),
          QuizAttemp(
            timestamp: DateTime(2026, 7, 5, 11, 0),
            profileId: 101,
            tableNumber: 4,
            correctAnswers: 8,
            totalQuestions: 10,
            durationInSeconds: 35,
          ),
          QuizAttemp(
            timestamp: DateTime(2026, 7, 5, 12, 0),
            profileId: 101,
            tableNumber: 7,
            correctAnswers: 4,
            totalQuestions: 10,
            durationInSeconds: 0,
          ),
        ]);
        service.tableOverallStats.putMany(<TableOverallStats>[
          TableOverallStats(
            tableNumber: 4,
            profileId: 101,
            totalAttempts: 2,
            totalCorrectAnswersSum: 17,
            totalQuestionsSum: 20,
            bestTimeInSeconds: 42,
            bestScoreCorrect: 9,
            bestScoreTotal: 10,
          ),
          TableOverallStats(
            tableNumber: 7,
            profileId: 101,
            totalAttempts: 1,
            totalCorrectAnswersSum: 4,
            totalQuestionsSum: 10,
            bestTimeInSeconds: 0,
            bestScoreCorrect: 4,
            bestScoreTotal: 10,
          ),
        ]);

        SharedPreferences.setMockInitialValues(<String, Object>{});
        final prefs = await SharedPreferences.getInstance();

        await service.repairLegacyBestTimes(prefs: prefs);

        final repairedAttempts = service.quizAttempBox.getAll()
          ..sort((a, b) => a.tableNumber.compareTo(b.tableNumber));
        expect(
          repairedAttempts.map((attempt) => attempt.durationInSeconds),
          <int?>[8, 15, 50],
        );

        final repairedTableFourStats = service.tableOverallStats
            .query(
              TableOverallStats_.profileId
                  .equals(101)
                  .and(TableOverallStats_.tableNumber.equals(4)),
            )
            .build()
            .findFirst();
        final repairedTableSevenStats = service.tableOverallStats
            .query(
              TableOverallStats_.profileId
                  .equals(101)
                  .and(TableOverallStats_.tableNumber.equals(7)),
            )
            .build()
            .findFirst();

        expect(repairedTableFourStats, isNotNull);
        expect(repairedTableFourStats!.bestTimeInSeconds, 8);
        expect(repairedTableSevenStats, isNotNull);
        expect(repairedTableSevenStats!.bestTimeInSeconds, isNull);
        expect(prefs.getBool(AppPrefs.repairedLegacyBestTimesV1), isTrue);

        await service.repairLegacyBestTimes(prefs: prefs);
        final rerunAttempts = service.quizAttempBox.getAll()
          ..sort((a, b) => a.tableNumber.compareTo(b.tableNumber));
        expect(
          rerunAttempts.map((attempt) => attempt.durationInSeconds),
          <int?>[8, 15, 50],
        );
      });
    });
  });
}

Future<void> _withStore(
  Future<void> Function(ObjectBoxService service) body,
) async {
  final tempDirectory = await Directory.systemTemp.createTemp(
    'multy_objectbox_service_test_',
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
