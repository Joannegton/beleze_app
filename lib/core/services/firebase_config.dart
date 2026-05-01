// Firebase Configuration Guide
// This file documents the Firebase setup required for notifications

/*
STEP 1: Add dependencies to pubspec.yaml
```yaml
dependencies:
  firebase_core: ^3.0.0
  firebase_messaging: ^15.0.0
```

STEP 2: Run setup
flutter pub get

STEP 3: Configure Firebase Console
1. Go to https://console.firebase.google.com
2. Create new project "beleze-app" or select existing
3. Add Android and iOS apps
4. Download google-services.json (Android) and GoogleService-Info.plist (iOS)
5. Place files in project directories

STEP 4: Android Setup
File: android/app/build.gradle
- Add Google services plugin: apply plugin: 'com.google.gms.google-services'
- Update buildscript dependencies

File: android/build.gradle
- Add Google services classpath in dependencies:
  classpath 'com.google.gms:google-services:4.4.0'

STEP 5: iOS Setup
File: ios/Podfile
- Uncomment: platform :ios, '11.0' (or higher)
- Add Firebase pods handling

Run: cd ios && pod install --repo-update

STEP 6: Request Notification Permissions
- iOS: Automatically shown on first app launch
- Android: Automatically granted on Android 12+ (runtime on older versions)

STEP 7: Backend Integration
POST /users/me/fcm-token
{
  "fcmToken": "device-token-from-firebase"
}

The backend stores this token and uses it to send notifications via Firebase Admin SDK.
*/

class FirebaseConfig {
  // Firebase project configuration
  static const String projectId = 'beleze-app';
  static const String apiKey = 'YOUR_API_KEY';
  static const String appId = 'YOUR_APP_ID';
  static const String messagingSenderId = 'YOUR_MESSAGING_SENDER_ID';

  // Notification configuration
  static const String notificationChannelId = 'high_importance_channel';
  static const String notificationChannelName = 'Notificações Beleze';
  static const String notificationChannelDescription =
      'Notificações importantes de agendamentos e pagamentos';

  // Topic subscriptions for group notifications
  static const String topicAllClients = 'all-clients';
  static const String topicAllProfessionals = 'all-professionals';
  static const String topicSalonPrefix = 'salon-'; // salon-{tenantId}

  // Notification URLs (used by backend to send notifications)
  static const String sendNotificationUrl =
      'https://us-central1-beleze-app.cloudfunctions.net/sendNotification';
}
