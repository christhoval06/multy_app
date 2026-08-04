import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multy_app/configs/route_paths.dart';
import 'package:multy_app/l10n/app_localizations.dart';
import 'package:multy_app/models/profile.dart';
import 'package:multy_app/providers/profile_provider.dart';
import 'package:multy_app/routes.dart';
import 'package:multy_app/screens/settings_screen.dart';
import 'package:provider/provider.dart';

void main() {
  group('Profile management', () {
    testWidgets('opens profile management from settings', (tester) async {
      final profileProvider = FakeProfileProvider(
        profiles: <Profile>[
          Profile(
            id: 1,
            name: 'Mateo',
            avatarKey: 'lion',
            colorValue: 0xFF42A5F5,
          ),
        ],
      );

      await tester.pumpWidget(_TestApp(profileProvider: profileProvider));
      await tester.pumpAndSettle();

      final settingsContext = tester.element(find.byType(SettingsScreen));
      final l10n = AppLocalizations.of(settingsContext)!;

      await tester.scrollUntilVisible(
        find.byKey(const Key('settings-manage-profiles-tile')),
        200,
      );
      await tester.tap(find.byKey(const Key('settings-manage-profiles-tile')));
      await tester.pumpAndSettle();

      expect(find.text(l10n.profileManagementTitle), findsOneWidget);
      expect(find.text('Mateo'), findsOneWidget);
      expect(find.byKey(const Key('profile-management-create-button')), findsOneWidget);
      expect(
        find.text(l10n.profileManagementSavedCount(1, profileProvider.maxProfiles)),
        findsOneWidget,
      );
    });

    testWidgets('creates edits archives and deletes profiles', (tester) async {
      final profileProvider = FakeProfileProvider(
        profiles: <Profile>[
          Profile(
            id: 1,
            name: 'Mateo',
            avatarKey: 'lion',
            colorValue: 0xFF42A5F5,
          ),
          Profile(
            id: 2,
            name: 'Lucia',
            avatarKey: 'fox',
            colorValue: 0xFFF48FB1,
          ),
        ],
      );

      await tester.pumpWidget(_ManagementTestApp(profileProvider: profileProvider));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('profile-management-create-button')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('profile-form-name-field')), 'Sofia');
      await tester.tap(find.byKey(const Key('profile-avatar-bird')));
      await tester.tap(find.byKey(const Key('profile-color-2')));
      await tester.tap(find.byKey(const Key('profile-form-submit-button')));
      await tester.pumpAndSettle();

      expect(find.text('Sofia'), findsOneWidget);
      expect(profileProvider.profiles, hasLength(3));

      await tester.tap(find.byKey(const Key('profile-actions-2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('profile-action-edit-2')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('profile-form-name-field')), 'Lucia Pro');
      await tester.tap(find.byKey(const Key('profile-form-submit-button')));
      await tester.pumpAndSettle();

      expect(find.text('Lucia Pro'), findsOneWidget);

      await tester.tap(find.byKey(const Key('profile-actions-2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('profile-action-archive-2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('profile-confirm-archive-button')));
      await tester.pumpAndSettle();

      expect(find.text('Lucia Pro'), findsNothing);
      expect(profileProvider.archivedProfileIds, contains(2));

      await tester.tap(find.byKey(const Key('profile-actions-3')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('profile-action-delete-3')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('profile-confirm-delete-button')));
      await tester.pumpAndSettle();

      expect(find.text('Sofia'), findsNothing);
      expect(profileProvider.deletedProfileIds, contains(3));
    });
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.profileProvider});

  final ProfileProvider profileProvider;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileProvider>.value(
      value: profileProvider,
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateRoute: Routes.generateRoute,
        home: const SettingsScreen(),
      ),
    );
  }
}

class _ManagementTestApp extends StatelessWidget {
  const _ManagementTestApp({required this.profileProvider});

  final ProfileProvider profileProvider;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileProvider>.value(
      value: profileProvider,
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateRoute: Routes.generateRoute,
        initialRoute: RoutePaths.profileManagement,
      ),
    );
  }
}

class FakeProfileProvider extends ChangeNotifier implements ProfileProvider {
  FakeProfileProvider({required List<Profile> profiles})
    : _profiles = List<Profile>.of(profiles),
      _activeProfile = profiles.first;

  final List<Profile> _profiles;
  final List<int> archivedProfileIds = <int>[];
  final List<int> deletedProfileIds = <int>[];
  int _nextId = 3;
  Profile? _activeProfile;

  @override
  UnmodifiableListView<Profile> get allProfiles =>
      UnmodifiableListView<Profile>(List<Profile>.unmodifiable(_profiles));

  @override
  Profile? get activeProfile => _activeProfile;

  @override
  bool get canCreateProfile => allProfiles.length < maxProfiles;

  @override
  bool get hasPersistentSelection => _activeProfile != null;

  @override
  bool get hasSelection => false;

  @override
  bool get isGuestSelected => false;

  @override
  bool get isInitialized => true;

  @override
  int get maxProfiles => 4;

  @override
  ProfileSelectionMode get mode => ProfileSelectionMode.none;

  @override
  UnmodifiableListView<Profile> get profiles =>
      UnmodifiableListView<Profile>(List<Profile>.unmodifiable(_profiles));

  @override
  Future<void> archiveProfile(int profileId) async {
    final profile = _profiles.firstWhere((candidate) => candidate.id == profileId);
    profile.archive();
    _profiles.removeWhere((candidate) => candidate.id == profileId);
    if (_activeProfile?.id == profileId) {
      _activeProfile = _profiles.isEmpty ? null : _profiles.first;
    }
    archivedProfileIds.add(profileId);
    notifyListeners();
  }

  @override
  Future<void> clearSelection() async {}

  @override
  Future<Profile> createProfile({
    required String name,
    required String avatarKey,
    required int colorValue,
  }) async {
    final profile = Profile(
      id: _nextId++,
      name: name,
      avatarKey: avatarKey,
      colorValue: colorValue,
    );
    _profiles.add(profile);
    notifyListeners();
    return profile;
  }

  @override
  Future<void> deleteProfile(int profileId) async {
    _profiles.removeWhere((candidate) => candidate.id == profileId);
    if (_activeProfile?.id == profileId) {
      _activeProfile = _profiles.isEmpty ? null : _profiles.first;
    }
    deletedProfileIds.add(profileId);
    notifyListeners();
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> selectGuest() async {}

  @override
  Future<void> selectProfileById(int profileId) async {}

  @override
  Future<Profile> updateProfile({
    required int profileId,
    required String name,
    required String avatarKey,
    required int colorValue,
  }) async {
    final index = _profiles.indexWhere((candidate) => candidate.id == profileId);
    final current = _profiles[index];
    final updated = Profile(
      id: current.id,
      name: name,
      avatarKey: avatarKey,
      colorValue: colorValue,
      goalDailySessions: current.goalDailySessions,
      goalWeeklySessions: current.goalWeeklySessions,
      favoriteTablesSerialized: current.favoriteTablesSerialized,
      createdAt: current.createdAt,
    )..updatedAt = DateTime.now();
    _profiles[index] = updated;
    if (_activeProfile?.id == profileId) {
      _activeProfile = updated;
    }
    notifyListeners();
    return updated;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
