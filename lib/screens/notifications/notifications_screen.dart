// lib/screens/notifications/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../theme/app_theme.dart';
import '../../services/notification_service.dart';
import '../../models/mocktest_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<List<NotificationModel>>(
        stream: NotificationService.instance.getNotifications(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final notifs = snap.data ?? [];
          if (notifs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none_rounded, size: 56.w, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  SizedBox(height: 10.h),
                  Text('No notifications yet', style: TextStyle(fontSize: 14.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontFamily: 'Poppins')),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: notifs.length,
            separatorBuilder: (_, __) => SizedBox(height: 8.h),
            itemBuilder: (_, i) {
              final n = notifs[i];
              final typeColors = {
                'class_reminder': AppColors.primary,
                'payment': AppColors.warning,
                'exam': AppColors.secondary,
                'holiday': AppColors.success,
                'announcement': AppColors.info,
              };
              final color = typeColors[n.type] ?? AppColors.info;

              return Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: n.isImportant ? color.withOpacity(0.06) : isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: n.isImportant ? color.withOpacity(0.3) : isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
                      child: Icon(_notifIcon(n.type), color: color, size: 18.w),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(n.title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, fontFamily: 'Poppins'))),
                              if (n.isImportant) Container(padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h), decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(4.r)), child: Text('Important', style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w700, color: AppColors.error, fontFamily: 'Poppins'))),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(n.body, style: TextStyle(fontSize: 12.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontFamily: 'Poppins', height: 1.4)),
                          SizedBox(height: 6.h),
                          Text(timeago.format(n.createdAt), style: TextStyle(fontSize: 10.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontFamily: 'Poppins')),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _notifIcon(String type) {
    switch (type) {
      case 'class_reminder': return Icons.live_tv_rounded;
      case 'payment': return Icons.payment_rounded;
      case 'exam': return Icons.quiz_rounded;
      case 'holiday': return Icons.celebration_rounded;
      default: return Icons.campaign_rounded;
    }
  }
}
