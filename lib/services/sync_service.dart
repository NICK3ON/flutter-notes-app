import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../api/note_api.dart';
import 'notification_service.dart';
import '../sync_meta.dart';




class SyncService {

  // PUSH: local → server
  static Future<void> pushSync() async {
    print("PUSH SYNC STARTED");

    try {
      final db = DatabaseHelper.instance;
      final unsyncedNotes = await db.getUnsyncedNotes();

      print("UNSYNCED NOTES: $unsyncedNotes");

      for (var note in unsyncedNotes) {
        final success = await ApiService.sendNote(note);

        if (success) {
          await db.markAsSynced(note['id'], note['id']); // temp mapping
          print("Note pushed: ${note['title']}");
          
          // Show notification for synced note
          await NotificationService().showNoteSyncedNotification();
        }
      }
    } catch (e) {
      debugPrint('Push sync error: $e');
      await NotificationService().showSyncErrorNotification();
    }
  }

  // PULL: server → local
  static Future<void> pullSync() async {
    print("PULL SYNC STARTED");

    try {
      final serverNotes = await ApiService.fetchNotes();
      final db = DatabaseHelper.instance;
      final localServerIds = await db.getLocalServerIds();

      for (var note in serverNotes) {
        if (!localServerIds.contains(note['id'])) {
          await db.insertServerNote(note);
          print("Note pulled: ${note['title']}");
        }
      }

      // Show backup success notification after pulling notes
      if (serverNotes.isNotEmpty) {
        await NotificationService().showBackupSuccessNotification();
      }
    } catch (e) {
      debugPrint('Pull sync error: $e');
      await NotificationService().showSyncErrorNotification();
    }
  }
  

  // ONE BUTTON SYNC
 // ONE BUTTON SYNC
static Future<void> syncAll() async {
  try {
    await pushSync();
    await pullSync();

    // ✅ Save last successful sync time
    await SyncMeta.saveSyncTime();

    print("SYNC COMPLETE");
  } catch (e) {
    debugPrint('Full sync failed: $e');
  }
}

}

