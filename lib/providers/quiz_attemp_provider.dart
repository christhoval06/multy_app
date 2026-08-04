import 'package:flutter/material.dart';
import 'package:multy_app/configs/app_prefs.dart';
import 'package:multy_app/models/quiz_attemp.dart';
import 'package:multy_app/models/table_overall_stats.dart';
import 'package:multy_app/objectbox.g.dart';
import 'package:multy_app/providers/profile_provider.dart';
import 'package:multy_app/services/objectbox_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OverallStatsData {
  final int totalQuizzesPlayed;
  final double overallAccuracy;

  OverallStatsData({
    required this.totalQuizzesPlayed,
    required this.overallAccuracy,
  });
}

class TableStatData {
  final int tableNumber;
  final int attemptsCount;
  final double averageAccuracy;
  final int bestScoreCorrect;
  final int bestScoreTotal;
  final int? bestTimeInSeconds;

  TableStatData({
    required this.tableNumber,
    required this.attemptsCount,
    required this.averageAccuracy,
    required this.bestScoreCorrect,
    required this.bestScoreTotal,
    this.bestTimeInSeconds,
  });
}

class QuizSessionSaveResult {
  final bool wasSaved;
  final bool isGuestSession;
  final int? profileId;
  final String? profileName;
  final int? quizAttemptId;

  const QuizSessionSaveResult({
    required this.wasSaved,
    required this.isGuestSession,
    this.profileId,
    this.profileName,
    this.quizAttemptId,
  });
}

class QuizAttempProvider extends ChangeNotifier {
  final Box<QuizAttemp> _quizAttempBox;
  final Box<TableOverallStats> _tableOverallStats;
  final Store _store;
  ObjectBoxService objectboxService;
  final SharedPreferences prefs;

  QuizAttempProvider({required this.objectboxService, required this.prefs})
    : _store = objectboxService.store,
      _quizAttempBox = objectboxService.quizAttempBox,
      _tableOverallStats = objectboxService.tableOverallStats;

  Future<void> deleteAllData() async => objectboxService.deleteAllData();

  OverallStatsData? _overallStats;
  OverallStatsData? get overallStats => _overallStats;

  List<TableOverallStats> _allTableStats = [];
  List<TableOverallStats> get allTableStats => _allTableStats;

  List<QuizAttemp> _sessionHistory = [];
  List<QuizAttemp> get sessionHistory => _sessionHistory;

  final List<int> _tablesToDisplay = List.generate(12, (index) => index + 1);
  List<int> get tablesToDisplay => _tablesToDisplay;

  Future<int> createQuizAttemp(QuizAttemp quizAttemp) async {
    if (quizAttemp.profileId <= 0) {
      throw ArgumentError(
        'QuizAttemp requires a persisted profileId before saving.',
      );
    }

    return _quizAttempBox.put(quizAttemp);
  }

  Future<List<QuizAttemp>> getAllQuizAttemp({int? profileId}) async {
    if (profileId == null || profileId <= 0) {
      return _quizAttempBox.getAll();
    }

    return _quizAttempBox
        .query(QuizAttemp_.profileId.equals(profileId))
        .build()
        .find();
  }

  Future<List<TableOverallStats>> getAllTableOverallStats({
    int? profileId,
  }) async {
    if (profileId == null || profileId <= 0) {
      return _tableOverallStats.getAll();
    }

    return _tableOverallStats
        .query(TableOverallStats_.profileId.equals(profileId))
        .build()
        .find();
  }

  Future<QuizSessionSaveResult> saveQuizSession({
    required QuizAttemp quizAttemp,
    ProfileSelectionMode? selectionMode,
    int? activeProfileId,
    String? activeProfileName,
  }) async {
    final selection =
        selectionMode == null && activeProfileId == null && activeProfileName == null
            ? await _resolveSelectionContext()
            : _SelectionContext(mode: selectionMode ?? ProfileSelectionMode.none, profileId: activeProfileId);
    final resolvedMode = selection.mode;
    final resolvedProfileId = activeProfileId ?? selection.profileId;
    final resolvedProfileName =
        activeProfileName ??
        (resolvedProfileId != null && resolvedProfileId > 0
            ? _profileNameForId(resolvedProfileId)
            : null);

    if (resolvedMode == ProfileSelectionMode.guest) {
      return const QuizSessionSaveResult(
        wasSaved: false,
        isGuestSession: true,
      );
    }

    if (resolvedMode != ProfileSelectionMode.persistent) {
      return const QuizSessionSaveResult(
        wasSaved: false,
        isGuestSession: false,
      );
    }

    if (resolvedProfileId == null || resolvedProfileId <= 0) {
      throw StateError(
        'Persistent quiz sessions require an active persisted profile ID.',
      );
    }

    quizAttemp.profileId = resolvedProfileId;
    late final int quizAttempId;
    _store.runInTransaction(TxMode.write, () {
      quizAttempId = _quizAttempBox.put(quizAttemp);
      _upsertTableOverallStats(quizAttemp);
    });

    return QuizSessionSaveResult(
      wasSaved: true,
      isGuestSession: false,
      profileId: resolvedProfileId,
      profileName: resolvedProfileName,
      quizAttemptId: quizAttempId,
    );
  }

  Future<void> loadStatistics() async {
    final selection = await _resolveSelectionContext();
    await loadStatisticsForSelection(
      selectionMode: selection.mode,
      activeProfileId: selection.profileId,
    );
  }

  Future<void> loadStatisticsForSelection({
    required ProfileSelectionMode selectionMode,
    required int? activeProfileId,
  }) async {
    if (selectionMode != ProfileSelectionMode.persistent ||
        activeProfileId == null ||
        activeProfileId <= 0) {
      _sessionHistory = <QuizAttemp>[];
      _allTableStats = _buildDisplayStats(
        scopedStats: const <TableOverallStats>[],
        profileId: activeProfileId,
      );
      _overallStats = OverallStatsData(
        totalQuizzesPlayed: 0,
        overallAccuracy: 0.0,
      );
      notifyListeners();
      return;
    }

    _sessionHistory = await getAllQuizAttemp(profileId: activeProfileId);
    _sessionHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final scopedStats = await getAllTableOverallStats(profileId: activeProfileId)
      ..sort((a, b) => a.tableNumber.compareTo(b.tableNumber));

    var totalQuizzesPlayedOverall = 0;
    var totalCorrectSumGlobal = 0;
    var totalQuestionsSumGlobal = 0;

    for (final stat in scopedStats) {
      totalQuizzesPlayedOverall += stat.totalAttempts;
      totalCorrectSumGlobal += stat.totalCorrectAnswersSum;
      totalQuestionsSumGlobal += stat.totalQuestionsSum;
    }

    final accuracyOverall = totalQuestionsSumGlobal > 0
        ? (totalCorrectSumGlobal / totalQuestionsSumGlobal) * 100
        : 0.0;

    _allTableStats = _buildDisplayStats(
      scopedStats: scopedStats,
      profileId: activeProfileId,
    );
    _overallStats = OverallStatsData(
      totalQuizzesPlayed: totalQuizzesPlayedOverall,
      overallAccuracy: accuracyOverall,
    );

    notifyListeners();
  }

  Future<void> updateTableOverallStats(QuizAttemp newAttempt) async {
    if (newAttempt.profileId <= 0) {
      throw ArgumentError(
        'TableOverallStats updates require a persisted profileId.',
      );
    }

    _store.runInTransaction(TxMode.write, () {
      _upsertTableOverallStats(newAttempt);
    });
  }

  void _upsertTableOverallStats(QuizAttemp newAttempt) {
    final tableNum = newAttempt.tableNumber;
    final existingStats = _tableOverallStats
        .query(
          TableOverallStats_.tableNumber
              .equals(tableNum)
              .and(TableOverallStats_.profileId.equals(newAttempt.profileId)),
        )
        .build()
        .findFirst();

    final stats =
        existingStats ??
        TableOverallStats(
          tableNumber: tableNum,
          profileId: newAttempt.profileId,
          totalAttempts: 0,
          totalCorrectAnswersSum: 0,
          totalQuestionsSum: 0,
        );

    stats.totalAttempts += 1;
    stats.totalCorrectAnswersSum += newAttempt.correctAnswers;
    stats.totalQuestionsSum += newAttempt.totalQuestions;

    if (newAttempt.durationInSeconds != null) {
      if (stats.bestTimeInSeconds == null ||
          newAttempt.durationInSeconds! < stats.bestTimeInSeconds!) {
        stats.bestTimeInSeconds = newAttempt.durationInSeconds;
      }
    }

    if (newAttempt.totalQuestions > 0) {
      final newAttemptAccuracy =
          newAttempt.correctAnswers / newAttempt.totalQuestions;
      final currentBestAccuracy = stats.bestScoreTotal > 0
          ? stats.bestScoreCorrect / stats.bestScoreTotal
          : 0.0;

      if (newAttemptAccuracy > currentBestAccuracy ||
          (newAttemptAccuracy == currentBestAccuracy &&
              newAttempt.correctAnswers > stats.bestScoreCorrect)) {
        stats.bestScoreCorrect = newAttempt.correctAnswers;
        stats.bestScoreTotal = newAttempt.totalQuestions;
      }
    } else if (stats.bestScoreTotal == 0) {
      stats.bestScoreCorrect = newAttempt.correctAnswers;
      stats.bestScoreTotal = newAttempt.totalQuestions;
    }

    _tableOverallStats.put(stats);
  }

  Future<_SelectionContext> _resolveSelectionContext() async {
    final modeName = prefs.getString(AppPrefs.activeProfileMode);
    final selectionMode = ProfileSelectionMode.values.cast<ProfileSelectionMode?>()
        .firstWhere(
          (candidate) => candidate?.name == modeName,
          orElse: () => null,
        );

    return _SelectionContext(
      mode: selectionMode ?? ProfileSelectionMode.none,
      profileId: prefs.getInt(AppPrefs.activeProfileId),
    );
  }

  String? _profileNameForId(int profileId) {
    final profile = objectboxService.profileBox.get(profileId);
    return profile?.name;
  }

  List<TableOverallStats> _buildDisplayStats({
    required List<TableOverallStats> scopedStats,
    required int? profileId,
  }) {
    return _tablesToDisplay.map((tableNum) {
      return scopedStats.cast<TableOverallStats?>().firstWhere(
            (candidate) => candidate?.tableNumber == tableNum,
            orElse: () => TableOverallStats(
              tableNumber: tableNum,
              profileId: profileId ?? -1,
            ),
          ) ??
          TableOverallStats(
            tableNumber: tableNum,
            profileId: profileId ?? -1,
          );
    }).toList(growable: false);
  }
}

class _SelectionContext {
  final ProfileSelectionMode mode;
  final int? profileId;

  const _SelectionContext({required this.mode, required this.profileId});
}
