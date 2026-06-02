// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final student = AuthService.instance.studentData.value;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            CircleAvatar(
              radius: 42.r,
              backgroundColor: AppColors.primary.withOpacity(0.15),
              child: Text(
                student?.name.isNotEmpty == true ? student!.name[0].toUpperCase() : '?',
                style: TextStyle(fontSize: 36.sp, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
            ),
            SizedBox(height: 12.h),
            Text(student?.name ?? '', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
            Text(student?.phone ?? '', style: TextStyle(fontSize: 13.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontFamily: 'Poppins')),
            SizedBox(height: 20.h),
            _infoTile(Icons.school_rounded, 'Purchased Courses', '${student?.purchasedCourses.length ?? 0}', isDark),
            _infoTile(Icons.group_rounded, 'Batches', '${student?.batchIds.length ?? 0}', isDark),
            SizedBox(height: 20.h),
            OutlinedButton.icon(
              onPressed: () => AuthService.instance.signOut(),
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              label: const Text('Logout', style: TextStyle(color: AppColors.error, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error), minimumSize: const Size(double.infinity, 48)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20.w),
          SizedBox(width: 12.w),
          Expanded(child: Text(label, style: TextStyle(fontSize: 13.sp, fontFamily: 'Poppins', color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight))),
          Text(value, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.primary, fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}
