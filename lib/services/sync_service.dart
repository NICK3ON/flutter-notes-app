import '../db/database_helper.dart';
import '../api/note_api.dart';

class SyncService {

  // 🔹 PUSH: local → server
  static Future<void> pushSync() async {
    print("PUSH SYNC STARTED");

    final db = DatabaseHelper.instance;
    final unsyncedNotes = await db.getUnsyncedNotes();

    print("UNSYNCED NOTES: $unsyncedNotes");

    for (var note in unsyncedNotes) {
      final success = await ApiService.sendNote(note);

      if (success) {
        await db.markAsSynced(note['id'], note['id']); // temp mapping
        print("Note pushed: ${note['title']}");
      }
    }
  }

  // 🔹 PULL: server → local
  static Future<void> pullSync() async {
    print("PULL SYNC STARTED");

    final serverNotes = await ApiService.fetchNotes();
    final db = DatabaseHelper.instance;
    final localServerIds = await db.getLocalServerIds();

    for (var note in serverNotes) {
      if (!localServerIds.contains(note['id'])) {
        await db.insertServerNote(note);
        print("Note pulled: ${note['title']}");
      }
    }
  }

  // 🔹 ONE BUTTON SYNC
  static Future<void> syncAll() async {
    await pushSync();
    await pullSync();
    print("SYNC COMPLETE");
  }
}
