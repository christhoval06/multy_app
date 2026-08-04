import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:multy_app/configs/app_prefs.dart';
import 'package:multy_app/models/profile.dart';
import 'package:multy_app/models/quiz_attemp.dart';
import 'package:multy_app/models/table_overall_stats.dart';
import 'package:multy_app/objectbox.g.dart';
import 'package:multy_app/services/objectbox_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ProfileSelectionMode { none, guest, persistent }

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({required this.objectboxService, required this.prefs})
    : _profileBox = objectboxService.profileBox,
      _quizAttemptBox = objectboxService.quizAttempBox,
      _tableStatsBox = objectboxService.tableOverallStats;

  static const _defaultProfileName = 'Perfil principal';
  static const _defaultAvatarKey = 'star';
  static const _defaultColorValue = 0xFFFFAB40;
  static const int _maxProfiles = 4;

  final ObjectBoxService objectboxService;
  final SharedPreferences prefs;
  final Box<Profile> _profileBox;
  final Box<QuizAttemp> _quizAttemptBox;
  final Box<TableOverallStats> _tableStatsBox;

  List<Profile> _profiles = <Profile>[];
  List<Profile> _allProfiles = <Profile>[];
  Profile? _activeProfile;
  ProfileSelectionMode _mode = ProfileSelectionMode.none;
  bool _isInitialized = false;

  UnmodifiableListView<Profile> get profiles =>
      UnmodifiableListView<Profile>(_profiles);
  UnmodifiableListView<Profile> get allProfiles =>
      UnmodifiableListView<Profile>(_allProfiles);
  Profile? get activeProfile => _activeProfile;
  ProfileSelectionMode get mode => _mode;
  bool get isInitialized => _isInitialized;
  bool get hasSelection => _mode != ProfileSelectionMode.none;
  bool get isGuestSelected => _mode == ProfileSelectionMode.guest;
  bool get hasPersistentSelection =>
      _mode == ProfileSelectionMode.persistent && _activeProfile != null;
  int get maxProfiles => _maxProfiles;
  bool get canCreateProfile => _allProfiles.length < _maxProfiles;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    final defaultProfile = _ensureSelectableDefaultProfile();
    _migrateLegacyRows(defaultProfile.id);
    _loadSelectableProfiles();
    await _restoreSelection();

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> selectProfileById(int profileId) async {
    final profile = _profiles.cast<Profile?>().firstWhere(
      (candidate) => candidate?.id == profileId,
      orElse: () => null,
    );
    if (profile == null) {
      await clearSelection();
      return;
    }

    _activeProfile = profile;
    _mode = ProfileSelectionMode.persistent;
    await _persistSelection();
    notifyListeners();
  }

  Future<void> selectGuest() async {
    _activeProfile = null;
    _mode = ProfileSelectionMode.guest;
    await _persistSelection();
    notifyListeners();
  }

  Future<void> clearSelection() async {
    _activeProfile = null;
    _mode = ProfileSelectionMode.none;
    await _persistSelection();
    notifyListeners();
  }

  Future<Profile> createProfile({
    required String name,
    required String avatarKey,
    required int colorValue,
  }) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Profile name cannot be empty.');
    }
    if (!canCreateProfile) {
      throw StateError('The maximum number of profiles has been reached.');
    }

    final profile = Profile(
      name: normalizedName,
      avatarKey: avatarKey,
      colorValue: colorValue,
    );
    final profileId = _profileBox.put(profile);
    profile.id = profileId;

    await _reloadProfilesAndSelection();
    notifyListeners();
    return _profileBox.get(profileId)!;
  }

  Future<Profile> updateProfile({
    required int profileId,
    required String name,
    required String avatarKey,
    required int colorValue,
  }) async {
    final profile = _profileBox.get(profileId);
    if (profile == null || profile.isArchived) {
      throw StateError('Profile not found.');
    }

    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Profile name cannot be empty.');
    }

    profile.name = normalizedName;
    profile.avatarKey = avatarKey;
    profile.colorValue = colorValue;
    profile.updatedAt = DateTime.now();
    _profileBox.put(profile);

    await _reloadProfilesAndSelection();
    notifyListeners();
    return _profileBox.get(profileId)!;
  }

  Future<void> archiveProfile(int profileId) async {
    _ensureCanRemoveSelectableProfile(profileId);

    final profile = _profileBox.get(profileId);
    if (profile == null || profile.isArchived) {
      throw StateError('Profile not found.');
    }

    profile.archive();
    _profileBox.put(profile);

    await _reloadProfilesAndSelection(removedProfileId: profileId);
    notifyListeners();
  }

  Future<void> deleteProfile(int profileId) async {
    _ensureCanRemoveSelectableProfile(profileId);

    final profile = _profileBox.get(profileId);
    if (profile == null) {
      throw StateError('Profile not found.');
    }

    _quizAttemptBox.removeMany(
      _quizAttemptBox
          .query(QuizAttemp_.profileId.equals(profileId))
          .build()
          .findIds(),
    );
    _tableStatsBox.removeMany(
      _tableStatsBox
          .query(TableOverallStats_.profileId.equals(profileId))
          .build()
          .findIds(),
    );
    _profileBox.remove(profileId);

    await _reloadProfilesAndSelection(removedProfileId: profileId);
    notifyListeners();
  }

  Profile _ensureSelectableDefaultProfile() {
    final selectableProfiles = _profileBox
        .query(Profile_.isArchived.equals(false))
        .build()
        .find()
      ..sort(_sortProfiles);
    if (selectableProfiles.isNotEmpty) {
      return selectableProfiles.first;
    }

    final defaultProfile = Profile(
      name: _defaultProfileName,
      avatarKey: _defaultAvatarKey,
      colorValue: _defaultColorValue,
    );
    final profileId = _profileBox.put(defaultProfile);
    defaultProfile.id = profileId;
    return defaultProfile;
  }

  void _migrateLegacyRows(int defaultProfileId) {
    final legacyAttempts = _quizAttemptBox
        .query(QuizAttemp_.profileId.equals(0))
        .build()
        .find();
    for (final attempt in legacyAttempts) {
      attempt.profileId = defaultProfileId;
    }
    if (legacyAttempts.isNotEmpty) {
      _quizAttemptBox.putMany(legacyAttempts);
    }

    final legacyStats = _tableStatsBox
        .query(TableOverallStats_.profileId.equals(0))
        .build()
        .find();
    for (final stat in legacyStats) {
      stat.profileId = defaultProfileId;
    }
    if (legacyStats.isNotEmpty) {
      _tableStatsBox.putMany(legacyStats);
    }
  }

  void _loadSelectableProfiles() {
    final allProfiles = _profileBox.getAll()..sort(_sortProfiles);
    _allProfiles = allProfiles;

    final profiles = _profileBox
        .query(Profile_.isArchived.equals(false))
        .build()
        .find();
    profiles.sort(_sortProfiles);
    _profiles = profiles;
  }

  Future<void> _restoreSelection() async {
    final savedModeName = prefs.getString(AppPrefs.activeProfileMode);
    final savedMode = ProfileSelectionMode.values.cast<ProfileSelectionMode?>()
        .firstWhere(
          (candidate) => candidate?.name == savedModeName,
          orElse: () => null,
        );

    switch (savedMode) {
      case ProfileSelectionMode.guest:
        _mode = ProfileSelectionMode.guest;
        _activeProfile = null;
        break;
      case ProfileSelectionMode.persistent:
        final savedProfileId = prefs.getInt(AppPrefs.activeProfileId);
        if (savedProfileId == null) {
          _mode = ProfileSelectionMode.none;
          _activeProfile = null;
          break;
        }

        final matchingProfile = _profiles.cast<Profile?>().firstWhere(
          (candidate) => candidate?.id == savedProfileId,
          orElse: () => null,
        );
        if (matchingProfile == null) {
          _mode = ProfileSelectionMode.none;
          _activeProfile = null;
          break;
        }

        _mode = ProfileSelectionMode.persistent;
        _activeProfile = matchingProfile;
        break;
      case ProfileSelectionMode.none:
      case null:
        _mode = ProfileSelectionMode.none;
        _activeProfile = null;
        break;
    }

    await _persistSelection();
  }

  Future<void> _persistSelection() async {
    await prefs.setString(AppPrefs.activeProfileMode, _mode.name);
    if (_mode == ProfileSelectionMode.persistent && _activeProfile != null) {
      await prefs.setInt(AppPrefs.activeProfileId, _activeProfile!.id);
      return;
    }

    await prefs.remove(AppPrefs.activeProfileId);
  }

  void _ensureCanRemoveSelectableProfile(int profileId) {
    final profile = _profileBox.get(profileId);
    if (profile == null || profile.isArchived) {
      throw StateError('Profile not found.');
    }
    if (_profiles.length <= 1) {
      throw StateError('At least one persistent profile must remain available.');
    }
  }

  Future<void> _reloadProfilesAndSelection({int? removedProfileId}) async {
    _loadSelectableProfiles();

    if (_activeProfile == null) {
      await _persistSelection();
      return;
    }

    if (removedProfileId != null && _activeProfile!.id == removedProfileId) {
      if (_profiles.isNotEmpty) {
        _activeProfile = _profiles.first;
        _mode = ProfileSelectionMode.persistent;
      } else {
        _activeProfile = null;
        _mode = ProfileSelectionMode.none;
      }
      await _persistSelection();
      return;
    }

    final refreshedActiveProfile = _profiles.cast<Profile?>().firstWhere(
      (candidate) => candidate?.id == _activeProfile!.id,
      orElse: () => null,
    );
    if (refreshedActiveProfile == null) {
      if (_profiles.isNotEmpty) {
        _activeProfile = _profiles.first;
        _mode = ProfileSelectionMode.persistent;
      } else {
        _activeProfile = null;
        _mode = ProfileSelectionMode.none;
      }
      await _persistSelection();
      return;
    }

    _activeProfile = refreshedActiveProfile;
    await _persistSelection();
  }

  static int _sortProfiles(Profile a, Profile b) {
    final createdAtComparison = a.createdAt.compareTo(b.createdAt);
    if (createdAtComparison != 0) {
      return createdAtComparison;
    }
    return a.id.compareTo(b.id);
  }
}
