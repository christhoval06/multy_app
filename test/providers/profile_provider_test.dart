import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:multy_app/configs/app_prefs.dart';
import 'package:multy_app/models/profile.dart';
import 'package:multy_app/models/quiz_attemp.dart';
import 'package:multy_app/models/table_overall_stats.dart';
import 'package:multy_app/objectbox.g.dart';
import 'package:multy_app/providers/profile_provider.dart';
import 'package:multy_app/services/objectbox_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Profile creates a persistent child profile with archive disabled', () {
    final profile = Profile(
      name: 'Mateo',
      avatarKey: 'lion',
      colorValue: 0xFF42A5F5,
      goalDailySessions: 2,
      goalWeeklySessions: 10,
      favoriteTablesSerialized: '2,3,4',
    );

    expect(profile.id, 0);
    expect(profile.name, 'Mateo');
    expect(profile.avatarKey, 'lion');
    expect(profile.colorValue, 0xFF42A5F5);
    expect(profile.goalDailySessions, 2);
    expect(profile.goalWeeklySessions, 10);
    expect(profile.favoriteTablesSerialized, '2,3,4');
    expect(profile.isArchived, isFalse);
    expect(profile.archivedAt, isNull);
    expect(profile.createdAt, isNotNull);
    expect(profile.updatedAt, isNotNull);
    expect(profile.favoriteTables, <int>[2, 3, 4]);
  });

  test('Profile archive helpers update archive state and favorites serialization', () {
    final createdAt = DateTime(2026, 7, 4, 10);
    final archivedAt = DateTime(2026, 7, 4, 11);
    final profile = Profile(
      name: 'Lucia',
      avatarKey: 'fox',
      colorValue: 0xFFFFB300,
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    profile.favoriteTables = <int>[5, 7, 9];

    expect(profile.favoriteTablesSerialized, '5,7,9');
    expect(profile.favoriteTables, <int>[5, 7, 9]);
    expect(profile.updatedAt.isAfter(createdAt), isTrue);

    profile.archive(archivedAt);

    expect(profile.isArchived, isTrue);
    expect(profile.archivedAt, archivedAt);
    expect(profile.updatedAt, archivedAt);

    profile.restore();

    expect(profile.isArchived, isFalse);
    expect(profile.archivedAt, isNull);
    expect(profile.updatedAt.isAfter(archivedAt), isTrue);
  });

  test('ObjectBox model definition includes profile ownership schema', () {
    final modelDefinition = getObjectBoxModel();
    final entityNames =
        modelDefinition.model.entities.map((entity) => entity.name).toList();

    expect(modelDefinition.bindings.containsKey(Profile), isTrue);
    expect(modelDefinition.bindings.containsKey(QuizAttemp), isTrue);
    expect(modelDefinition.bindings.containsKey(TableOverallStats), isTrue);
    expect(entityNames, containsAll(<String>[
      'Profile',
      'QuizAttemp',
      'TableOverallStats',
    ]));

    final profileEntity = modelDefinition.model.entities.firstWhere(
      (entity) => entity.name == 'Profile',
    );
    final quizEntity = modelDefinition.model.entities.firstWhere(
      (entity) => entity.name == 'QuizAttemp',
    );
    final statsEntity = modelDefinition.model.entities.firstWhere(
      (entity) => entity.name == 'TableOverallStats',
    );

    expect(
      profileEntity.properties.map((property) => property.name),
      containsAll(<String>[
        'name',
        'avatarKey',
        'colorValue',
        'goalDailySessions',
        'goalWeeklySessions',
        'favoriteTablesSerialized',
        'isArchived',
        'archivedAt',
        'createdAt',
        'updatedAt',
      ]),
    );
    expect(
      quizEntity.properties.map((property) => property.name),
      contains('profileId'),
    );
    expect(
      statsEntity.properties.map((property) => property.name),
      contains('profileId'),
    );

    expect(Profile_.favoriteTablesSerialized, isNotNull);
    expect(QuizAttemp_.profileId, isNotNull);
    expect(TableOverallStats_.profileId, isNotNull);
  });

  group('ProfileProvider', () {
    test('bootstraps default profile and migrates legacy rows', () async {
      await _withStore((service) async {
        final legacyAttemptId = service.quizAttempBox.put(
          QuizAttemp(
            timestamp: DateTime(2026, 7, 4),
            profileId: 0,
            tableNumber: 4,
            correctAnswers: 8,
            totalQuestions: 10,
            durationInSeconds: 22,
          ),
        );
        final legacyStatsId = service.tableOverallStats.put(
          TableOverallStats(
            tableNumber: 4,
            profileId: 0,
            totalAttempts: 3,
            totalCorrectAnswersSum: 24,
            totalQuestionsSum: 30,
            bestTimeInSeconds: 20,
            bestScoreCorrect: 10,
            bestScoreTotal: 10,
          ),
        );

        SharedPreferences.setMockInitialValues(<String, Object>{});
        final prefs = await SharedPreferences.getInstance();
        final provider = ProfileProvider(
          objectboxService: service,
          prefs: prefs,
        );

        await provider.initialize();

        expect(provider.mode, ProfileSelectionMode.none);
        expect(provider.profiles, hasLength(1));
        expect(provider.activeProfile, isNull);

        final defaultProfile = provider.profiles.single;
        expect(defaultProfile.id, greaterThan(0));

        final migratedAttempt = service.quizAttempBox.get(legacyAttemptId);
        final migratedStats = service.tableOverallStats.get(legacyStatsId);

        expect(migratedAttempt, isNotNull);
        expect(migratedAttempt!.profileId, defaultProfile.id);
        expect(migratedStats, isNotNull);
        expect(migratedStats!.profileId, defaultProfile.id);

        expect(
          prefs.getString(AppPrefs.activeProfileMode),
          ProfileSelectionMode.none.name,
        );
        expect(prefs.getInt(AppPrefs.activeProfileId), isNull);
      });
    });

    test('persists guest selection and restores it on reload', () async {
      await _withStore((service) async {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        final prefs = await SharedPreferences.getInstance();
        final provider = ProfileProvider(
          objectboxService: service,
          prefs: prefs,
        );

        await provider.initialize();
        await provider.selectGuest();

        expect(provider.mode, ProfileSelectionMode.guest);
        expect(provider.isGuestSelected, isTrue);
        expect(provider.activeProfile, isNull);
        expect(
          prefs.getString(AppPrefs.activeProfileMode),
          ProfileSelectionMode.guest.name,
        );

        final restoredProvider = ProfileProvider(
          objectboxService: service,
          prefs: prefs,
        );
        await restoredProvider.initialize();

        expect(restoredProvider.mode, ProfileSelectionMode.guest);
        expect(restoredProvider.isGuestSelected, isTrue);
        expect(restoredProvider.activeProfile, isNull);
      });
    });

    test('restores persistent profile selection on reload', () async {
      await _withStore((service) async {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        final prefs = await SharedPreferences.getInstance();
        final provider = ProfileProvider(
          objectboxService: service,
          prefs: prefs,
        );

        await provider.initialize();
        final profileId = provider.profiles.single.id;

        await provider.selectProfileById(profileId);

        expect(provider.mode, ProfileSelectionMode.persistent);
        expect(provider.activeProfile, isNotNull);
        expect(provider.activeProfile!.id, profileId);
        expect(prefs.getInt(AppPrefs.activeProfileId), profileId);

        final restoredProvider = ProfileProvider(
          objectboxService: service,
          prefs: prefs,
        );
        await restoredProvider.initialize();

        expect(restoredProvider.mode, ProfileSelectionMode.persistent);
        expect(restoredProvider.activeProfile, isNotNull);
        expect(restoredProvider.activeProfile!.id, profileId);
      });
    });

    test('cleans up stale saved persistent profile selection', () async {
      await _withStore((service) async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          AppPrefs.activeProfileMode: ProfileSelectionMode.persistent.name,
          AppPrefs.activeProfileId: 999999,
        });
        final prefs = await SharedPreferences.getInstance();
        final provider = ProfileProvider(
          objectboxService: service,
          prefs: prefs,
        );

        await provider.initialize();

        expect(provider.mode, ProfileSelectionMode.none);
        expect(provider.activeProfile, isNull);
        expect(
          prefs.getString(AppPrefs.activeProfileMode),
          ProfileSelectionMode.none.name,
        );
        expect(prefs.getInt(AppPrefs.activeProfileId), isNull);
      });
    });

    test('creates a new selectable default when only archived profiles exist', () async {
      await _withStore((service) async {
        final archivedProfile = Profile(
          name: 'Archivado',
          avatarKey: 'owl',
          colorValue: 0xFF8D6E63,
        )..archive(DateTime(2026, 7, 4, 9));
        final archivedProfileId = service.profileBox.put(archivedProfile);

        final legacyAttemptId = service.quizAttempBox.put(
          QuizAttemp(
            timestamp: DateTime(2026, 7, 4),
            profileId: 0,
            tableNumber: 7,
            correctAnswers: 9,
            totalQuestions: 10,
            durationInSeconds: 18,
          ),
        );

        SharedPreferences.setMockInitialValues(<String, Object>{});
        final prefs = await SharedPreferences.getInstance();
        final provider = ProfileProvider(
          objectboxService: service,
          prefs: prefs,
        );

        await provider.initialize();

        expect(provider.profiles, hasLength(1));
        final defaultProfile = provider.profiles.single;
        expect(defaultProfile.id, isNot(archivedProfileId));
        expect(defaultProfile.isArchived, isFalse);

        final allProfiles = service.profileBox.getAll();
        expect(allProfiles, hasLength(2));

        final migratedAttempt = service.quizAttempBox.get(legacyAttemptId);
        expect(migratedAttempt, isNotNull);
        expect(migratedAttempt!.profileId, defaultProfile.id);
      });
    });

    test('supports create edit archive and delete operations', () async {
      await _withStore((service) async {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        final prefs = await SharedPreferences.getInstance();
        final provider = ProfileProvider(
          objectboxService: service,
          prefs: prefs,
        );

        await provider.initialize();
        final originalProfile = provider.profiles.single;

        final createdProfile = await provider.createProfile(
          name: 'Lucia',
          avatarKey: 'fox',
          colorValue: 0xFFF06292,
        );

        expect(provider.profiles, hasLength(2));
        expect(createdProfile.id, greaterThan(0));
        expect(createdProfile.name, 'Lucia');

        final updatedProfile = await provider.updateProfile(
          profileId: createdProfile.id,
          name: 'Lucia Editada',
          avatarKey: 'cat',
          colorValue: 0xFF81C784,
        );

        expect(updatedProfile.name, 'Lucia Editada');
        expect(updatedProfile.avatarKey, 'cat');
        expect(updatedProfile.colorValue, 0xFF81C784);

        await provider.selectProfileById(updatedProfile.id);
        await provider.archiveProfile(updatedProfile.id);

        expect(provider.profiles, hasLength(1));
        expect(provider.profiles.single.id, originalProfile.id);
        expect(provider.activeProfile, isNotNull);
        expect(provider.activeProfile!.id, originalProfile.id);
        expect(provider.mode, ProfileSelectionMode.persistent);

        final archivedProfile = service.profileBox.get(updatedProfile.id);
        expect(archivedProfile, isNotNull);
        expect(archivedProfile!.isArchived, isTrue);
        expect(provider.allProfiles, hasLength(2));

        final deletableProfile = await provider.createProfile(
          name: 'Mateo',
          avatarKey: 'bear',
          colorValue: 0xFF64B5F6,
        );
        expect(provider.profiles, hasLength(2));

        service.quizAttempBox.put(
          QuizAttemp(
            timestamp: DateTime(2026, 7, 5),
            profileId: deletableProfile.id,
            tableNumber: 8,
            correctAnswers: 7,
            totalQuestions: 10,
            durationInSeconds: 21,
          ),
        );
        service.tableOverallStats.put(
          TableOverallStats(
            tableNumber: 8,
            profileId: deletableProfile.id,
            totalAttempts: 1,
            totalCorrectAnswersSum: 7,
            totalQuestionsSum: 10,
            bestTimeInSeconds: 21,
            bestScoreCorrect: 7,
            bestScoreTotal: 10,
          ),
        );

        await provider.deleteProfile(deletableProfile.id);

        expect(provider.profiles, hasLength(1));
        expect(service.profileBox.get(deletableProfile.id), isNull);
        expect(
          service.quizAttempBox
              .query(QuizAttemp_.profileId.equals(deletableProfile.id))
              .build()
              .count(),
          0,
        );
        expect(
          service.tableOverallStats
              .query(TableOverallStats_.profileId.equals(deletableProfile.id))
              .build()
              .count(),
          0,
        );
      });
    });
  });
}

Future<void> _withStore(
  Future<void> Function(ObjectBoxService service) body,
) async {
  final tempDirectory = await Directory.systemTemp.createTemp(
    'multy_objectbox_test_',
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
