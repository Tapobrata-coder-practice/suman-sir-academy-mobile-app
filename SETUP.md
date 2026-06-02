# Suman Sir English Academy — Setup Guide

## Step 1: Firebase Setup
1. Go to https://console.firebase.google.com
2. Create project named "suman-sir-academy"
3. Add Android app with package: `com.sumansiracademy.app`
4. Download `google-services.json` → place in `android/app/`
5. Enable: Authentication (Phone), Firestore, Storage, Cloud Messaging
6. In terminal: `dart pub global activate flutterfire_cli` then `flutterfire configure`
7. Replace `lib/config/firebase_config.dart` with generated `firebase_options.dart`

## Step 2: Set Admin
In Firestore → collection `admins` → document = your Firebase UID → field: `isAdmin: true`

## Step 3: Razorpay
1. Sign up at https://razorpay.com
2. Get API keys from Dashboard → Settings → API Keys
3. Open `lib/utils/app_constants.dart` → set `razorpayKeyId`

## Step 4: YouTube API (optional)
1. Go to https://console.cloud.google.com
2. Enable YouTube Data API v3
3. Create API Key → set `youtubeApiKey` in `app_constants.dart`

## Step 5: Run
```bash
flutter pub get
flutter run
```

## Step 6: Build for Play Store
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

## Firestore Collections Structure
- `students/{uid}` — student profiles
- `courses/{id}` — course data
- `folders/{id}` — course folders
- `videos/{id}` — video entries
- `liveClasses/{id}` — live class schedule
- `batches/{id}` — batch data
- `doubts/{id}` — student questions
- `mocktests/{id}` — tests
- `testResults/{id}` — test results
- `notifications/{id}` — push notifications
- `payments/{id}` — payment records
- `admins/{uid}` — admin whitelist
