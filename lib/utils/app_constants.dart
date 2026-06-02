// lib/utils/app_constants.dart

class AppConstants {
  // Razorpay
  static const String razorpayKeyId = 'rzp_test_YOUR_KEY_HERE';
  // Replace with live key for production: 'rzp_live_XXXX'

  // YouTube API
  static const String youtubeApiKey = 'YOUR_YOUTUBE_API_KEY';
  // Get from: https://console.cloud.google.com → YouTube Data API v3

  // FCM Topics
  static const String allStudentsTopic = 'all_students';

  // Admin phone numbers (add teacher's phone here)
  static const List<String> adminPhones = [
    '+919876543210', // Replace with actual admin phone
  ];

  // App info
  static const String appName = 'Suman Sir English Academy';
  static const String supportPhone = '+919876543210';
  static const String supportEmail = 'support@sumansiracademy.com';
  static const String privacyPolicyUrl = 'https://sumansiracademy.com/privacy-policy';
  static const String termsUrl = 'https://sumansiracademy.com/terms';
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.sumansiracademy.app';

  // Social links
  static const String youtubeChannelUrl = 'https://youtube.com/@sumansirengacademy';
  static const String facebookUrl = 'https://facebook.com/sumansirengacademy';
  static const String whatsappNumber = '+919876543210';
  static const String telegramUrl = 'https://t.me/sumansirengacademy';
}

// lib/utils/app_utils.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class AppUtils {
  static void showSuccess(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  static void showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  static void showInfo(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.info,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  static String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }

  static Future<bool> confirmDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    return await Get.dialog<bool>(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(title, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
            content: Text(message, style: const TextStyle(fontFamily: 'Poppins')),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text(cancelText, style: const TextStyle(fontFamily: 'Poppins')),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDestructive ? AppColors.error : AppColors.primary,
                ),
                child: Text(confirmText, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ) ??
        false;
  }
}
