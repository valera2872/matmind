import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

abstract class AppRepository {
  Future<UserProfile> loadProfile();
  Future<void> saveProfile(UserProfile profile);
  Future<List<BoutRecord>> loadBouts();
  Future<void> saveBouts(List<BoutRecord> bouts);
}

class SharedPreferencesAppRepository implements AppRepository {
  SharedPreferencesAppRepository(this.preferences);

  final SharedPreferences preferences;

  static const _profileKey = 'svoya_borba_profile_v070';
  static const _boutsKey = 'svoya_borba_bouts_v070';

  @override
  Future<UserProfile> loadProfile() async {
    final source = preferences.getString(_profileKey);
    if (source == null) return const UserProfile();
    try {
      return UserProfile.fromJson(source);
    } catch (_) {
      return const UserProfile();
    }
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await preferences.setString(_profileKey, profile.toJson());
  }

  @override
  Future<List<BoutRecord>> loadBouts() async {
    final sources = preferences.getStringList(_boutsKey) ?? const <String>[];
    final records = <BoutRecord>[];
    for (final source in sources) {
      try {
        records.add(BoutRecord.fromJson(source));
      } catch (_) {
        // Skip one damaged local record instead of blocking the app.
      }
    }
    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return records;
  }

  @override
  Future<void> saveBouts(List<BoutRecord> bouts) async {
    final limited = bouts.take(60).map((record) => record.toJson()).toList();
    await preferences.setStringList(_boutsKey, limited);
  }
}

class MemoryAppRepository implements AppRepository {
  UserProfile _profile = const UserProfile();
  List<BoutRecord> _bouts = <BoutRecord>[];

  @override
  Future<UserProfile> loadProfile() async => _profile;

  @override
  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
  }

  @override
  Future<List<BoutRecord>> loadBouts() async =>
      List<BoutRecord>.from(_bouts);

  @override
  Future<void> saveBouts(List<BoutRecord> bouts) async {
    _bouts = List<BoutRecord>.from(bouts);
  }
}
