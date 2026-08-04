import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multy_app/l10n/app_localizations.dart';
import 'package:multy_app/models/profile.dart';
import 'package:multy_app/providers/profile_provider.dart';
import 'package:multy_app/screens/home_screen.dart';
import 'package:provider/provider.dart';

void main() {
  group('Home profile selector', () {
    testWidgets(
      'shows selector and disables main actions until a profile is selected',
      (tester) async {
        final provider = FakeProfileProvider(
          profiles: <Profile>[
            Profile(
              id: 1,
              name: 'Mateo',
              avatarKey: 'lion',
              colorValue: 0xFF42A5F5,
            ),
          ],
        );

        await tester.pumpWidget(
          _TestApp(
            profileProvider: provider,
          ),
        );

        final context = tester.element(find.byType(HomeScreen));
        final l10n = AppLocalizations.of(context)!;

        expect(find.byKey(const Key('home-hero-card')), findsOneWidget);
        expect(find.byKey(const Key('home-profile-selector')), findsOneWidget);
        expect(find.byKey(const Key('home-study-card')), findsOneWidget);
        expect(find.byKey(const Key('home-quiz-card')), findsOneWidget);
        expect(find.text(l10n.homeProfileSelectorTitle), findsOneWidget);
        expect(find.text(l10n.homeProfileGuestLabel), findsOneWidget);
        expect(find.text(l10n.homeProfileSelectionRequired), findsOneWidget);

        final studyButton = tester.widget<ElevatedButton>(
          find.byKey(const Key('home-study-button')),
        );
        final quizButton = tester.widget<ElevatedButton>(
          find.byKey(const Key('home-quiz-button')),
        );

        expect(studyButton.onPressed, isNull);
        expect(quizButton.onPressed, isNull);

        await tester.tap(find.text('Mateo'));
        await tester.pump();

        final enabledStudyButton = tester.widget<ElevatedButton>(find.byKey(const Key('home-study-button')));
        final enabledQuizButton = tester.widget<ElevatedButton>(
          find.byKey(const Key('home-quiz-button')),
        );

        expect(provider.hasPersistentSelection, isTrue);
        expect(enabledStudyButton.onPressed, isNotNull);
        expect(enabledQuizButton.onPressed, isNotNull);
        expect(find.text(l10n.homeProfileSelectionRequired), findsNothing);
        expect(
          find.text(l10n.homeProfileActiveSummary('Mateo')),
          findsOneWidget,
        );
      },
    );

    testWidgets('allows selecting guest mode from home', (tester) async {
      final provider = FakeProfileProvider(
        profiles: <Profile>[
          Profile(
            id: 1,
            name: 'Mateo',
            avatarKey: 'lion',
            colorValue: 0xFF42A5F5,
          ),
        ],
      );

      await tester.pumpWidget(
        _TestApp(
          profileProvider: provider,
        ),
      );

      final context = tester.element(find.byType(HomeScreen));
      final l10n = AppLocalizations.of(context)!;

      await tester.tap(find.text(l10n.homeProfileGuestLabel));
      await tester.pump();

      expect(provider.isGuestSelected, isTrue);

      final studyButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('home-study-button')),
      );
      final quizButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('home-quiz-button')),
      );

      expect(studyButton.onPressed, isNotNull);
      expect(quizButton.onPressed, isNotNull);
      expect(find.text(l10n.homeProfileGuestSummary), findsOneWidget);
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
        home: const HomeScreen(),
      ),
    );
  }
}

class FakeProfileProvider extends ChangeNotifier implements ProfileProvider {
  FakeProfileProvider({required List<Profile> profiles})
    : _profiles = List<Profile>.unmodifiable(profiles);

  final List<Profile> _profiles;
  Profile? _activeProfile;
  ProfileSelectionMode _mode = ProfileSelectionMode.none;

  @override
  Profile? get activeProfile => _activeProfile;

  @override
  bool get hasPersistentSelection =>
      _mode == ProfileSelectionMode.persistent && _activeProfile != null;

  @override
  bool get hasSelection => _mode != ProfileSelectionMode.none;

  @override
  bool get isGuestSelected => _mode == ProfileSelectionMode.guest;

  @override
  bool get isInitialized => true;

  @override
  ProfileSelectionMode get mode => _mode;

  @override
  UnmodifiableListView<Profile> get profiles =>
      UnmodifiableListView<Profile>(_profiles);

  @override
  Future<void> clearSelection() async {
    _activeProfile = null;
    _mode = ProfileSelectionMode.none;
    notifyListeners();
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> selectGuest() async {
    _activeProfile = null;
    _mode = ProfileSelectionMode.guest;
    notifyListeners();
  }

  @override
  Future<void> selectProfileById(int profileId) async {
    final profile = _profiles.cast<Profile?>().firstWhere(
      (candidate) => candidate?.id == profileId,
      orElse: () => null,
    );
    if (profile == null) {
      return clearSelection();
    }

    _activeProfile = profile;
    _mode = ProfileSelectionMode.persistent;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
