# Push Notifications Setup Guide

This guide will help you configure Firebase Cloud Messaging (FCM) for push notifications in your Flutter Notes App.

## Features Added
✅ **📝 New note synced** - Notification when a note is synced  
✅ **☁️ Notes backed up successfully** - Notification when notes are backed up  
✅ **Foreground notifications** - Notifications visible when app is open  
✅ **Background notifications** - Notifications work even when app is closed  
✅ **Local notifications** - Using flutter_local_notifications for Android/iOS

## Prerequisites
- Firebase project created
- Firebase Console access
- Android: Minimum SDK 21
- iOS: Minimum deployment target 11.0

## Step 1: Setup Firebase Project

### 1.1 Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `flutter-notes-app`
4. Enable Google Analytics (optional)
5. Create project

### 1.2 Register Android App
1. In Firebase Console, click "Add app" → Select Android
2. Enter Android package name: `com.example.flutter_application_1`
3. Enter SHA-1 certificate fingerprint:
   ```bash
   cd android
   ./gradlew signingReport
   # Or on Windows:
   gradlew.bat signingReport
   ```
   Copy the SHA-1 from the debug certificate
4. Download `google-services.json`
5. Place it in `android/app/`

### 1.3 Register iOS App
1. In Firebase Console, click "Add app" → Select iOS
2. Enter iOS bundle ID: `com.example.flutterApplication1`
3. Download `GoogleService-Info.plist`
4. Open `ios/Runner.xcworkspace` in Xcode
5. Drag and drop `GoogleService-Info.plist` into Xcode (select "Copy items if needed")

## Step 2: Android Configuration

### 2.1 Update build.gradle (Project level)
Already configured in your project.

### 2.2 Update build.gradle.kts (App level)
The `firebase_messaging` plugin should auto-configure this. If issues occur, ensure:
```kotlin
plugins {
    id 'com.android.application'
    id 'kotlin-android'
    id 'com.google.gms.google-services'
}
```

## Step 3: iOS Configuration

### 3.1 Enable Push Notifications in Xcode
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner → Signing & Capabilities
3. Click "+ Capability"
4. Search for "Push Notifications"
5. Add it

### 3.2 Enable Background Modes
1. Still in Signing & Capabilities
2. Click "+ Capability" again
3. Search for "Background Modes"
4. Add it
5. Check "Background fetch" and "Remote notifications"

## Step 4: Run the App

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Step 5: Get Device Token

The app will automatically request notification permissions. You can get the device token for testing:

```dart
String? token = await NotificationService().getDeviceToken();
print('Device Token: $token');
```

Use this token to send test notifications from Firebase Console.

## Step 6: Send Test Notifications

### From Firebase Console:
1. Go to Firebase Console → Cloud Messaging
2. Click "Send your first message"
3. Enter:
   - Title: `📝 New note synced`
   - Body: `Your note has been synced successfully`
4. Click "Send test message"
5. Enter your device token
6. Click "Test"

### From Your Backend (Laravel):
Send FCM request to Google's FCM API:
```php
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'https://fcm.googleapis.com/fcm/send');
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
    'to' => $deviceToken,
    'notification' => [
        'title' => '📝 New note synced',
        'body' => 'Your note has been synced successfully'
    ]
]));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Authorization: key=' . env('FCM_SERVER_KEY'),
    'Content-Type: application/json'
]);
curl_exec($ch);
```

## Notification Methods

The NotificationService provides these methods:

```dart
// Show notification for new note synced
await NotificationService().showNoteSyncedNotification();

// Show notification for notes backed up
await NotificationService().showBackupSuccessNotification();

// Show notification for sync errors
await NotificationService().showSyncErrorNotification();

// Get device token for backend
String? token = await NotificationService().getDeviceToken();

// Subscribe to topic (for group notifications)
await NotificationService().subscribeToTopic('all_users');

// Unsubscribe from topic
await NotificationService().unsubscribeFromTopic('all_users');
```

## Automatic Notifications

Notifications are automatically triggered:
- **Push Sync**: When a note is successfully pushed to the server, "📝 New note synced" is shown
- **Pull Sync**: When notes are pulled from server, "☁️ Notes backed up successfully" is shown
- **Errors**: If sync fails, "⚠️ Sync failed" is shown

## Troubleshooting

### Notifications not working on Android
- Ensure `POST_NOTIFICATIONS` permission is in AndroidManifest.xml
- Check that your app has notification permission at runtime
- Verify `google-services.json` is in `android/app/`

### Notifications not working on iOS
- Verify `GoogleService-Info.plist` is in Xcode (check Build Phases → Copy Bundle Resources)
- Ensure Push Notifications capability is enabled
- Check Background Modes capability has Remote notifications enabled

### Not receiving background notifications
- iOS: Ensure app is properly signed
- Android: Ensure battery optimization is disabled for your app
- Check that FCM_SERVER_KEY is properly configured in backend

## Security Note

⚠️ **Important**: Never commit your Firebase configuration files publicly:
```bash
# In .gitignore (already added):
google-services.json
GoogleService-Info.plist
.env
```

## Next Steps

1. ✅ Tested local notifications with the app
2. 📱 Configure Firebase Cloud Messaging for remote notifications
3. 🔧 Integrate notification sending in your Laravel backend
4. 📊 Monitor FCM metrics in Firebase Console

---

For more help, visit:
- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Firebase Messaging](https://pub.dev/packages/firebase_messaging)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
