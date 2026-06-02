// lib/config/firebase_config.dart
// IMPORTANT: Run `flutterfire configure` to auto-generate this file
// with your actual Firebase project credentials.
// Then replace this file with the generated firebase_options.dart

import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Replace these with your actual Firebase config values from:
    // Firebase Console → Project Settings → Your Apps → Android
    return const FirebaseOptions(
      apiKey: 'YOUR_API_KEY',
      appId: 'YOUR_APP_ID',
      messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
      projectId: 'suman-sir-academy',
      storageBucket: 'suman-sir-academy.appspot.com',
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// FIRESTORE SECURITY RULES  (paste in Firebase Console)
// ─────────────────────────────────────────────────────────────────
/*
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isAdmin() {
      return get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.isAdmin == true;
    }
    function isOwner(uid) {
      return request.auth.uid == uid;
    }
    function isAuthenticated() {
      return request.auth != null;
    }
    function notBlocked() {
      return !get(/databases/$(database)/documents/students/$(request.auth.uid)).data.isBlocked;
    }

    match /students/{userId} {
      allow read: if isAuthenticated() && (isOwner(userId) || isAdmin());
      allow create: if isAuthenticated() && isOwner(userId);
      allow update: if isAuthenticated() && (isOwner(userId) || isAdmin());
      allow delete: if isAdmin();
    }

    match /courses/{courseId} {
      allow read: if isAuthenticated();
      allow write: if isAdmin();

      match /videos/{videoId} {
        allow read: if isAuthenticated() && notBlocked();
        allow write: if isAdmin();
      }
    }

    match /batches/{batchId} {
      allow read: if isAuthenticated();
      allow write: if isAdmin();
    }

    match /doubts/{doubtId} {
      allow read: if isAuthenticated() && (
        resource.data.studentId == request.auth.uid || isAdmin()
      );
      allow create: if isAuthenticated() && notBlocked();
      allow update: if isAdmin();
      allow delete: if isAdmin();
    }

    match /mocktests/{testId} {
      allow read: if isAuthenticated() && notBlocked();
      allow write: if isAdmin();
    }

    match /testResults/{resultId} {
      allow read: if isAuthenticated() && (
        resource.data.studentId == request.auth.uid || isAdmin()
      );
      allow create: if isAuthenticated();
      allow update: if isAdmin();
    }

    match /notifications/{notifId} {
      allow read: if isAuthenticated();
      allow write: if isAdmin();
    }

    match /payments/{paymentId} {
      allow read: if isAuthenticated() && (
        resource.data.studentId == request.auth.uid || isAdmin()
      );
      allow create: if isAuthenticated();
      allow update: if isAdmin();
    }

    match /admins/{adminId} {
      allow read: if isAdmin();
      allow write: if isAdmin();
    }
  }
}
*/
