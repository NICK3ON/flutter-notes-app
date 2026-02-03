import 'package:shared_preferences/shared_preferences.dart';

class SyncMeta {
  static const _key = 'last_sync_time';

  static Future<void> saveSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_key, DateTime.now().toIso8601String());
  }

  static Future<String?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }
}
