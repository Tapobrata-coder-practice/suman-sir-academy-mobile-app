// lib/screens/admin/students/admin_students_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../theme/app_theme.dart';
import '../../../models/student_model.dart';

class AdminStudentsScreen extends StatelessWidget {
  const AdminStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Students')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final students = snap.data?.docs.map((d) => StudentModel.fromFirestore(d)).toList() ?? [];

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: students.length,
            itemBuilder: (_, i) {
              final s = students[i];
              return Container(
                margin: EdgeInsets.only(bottom: 10.h),
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: s.isBlocked ? AppColors.error.withOpacity(0.05) : isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: s.isBlocked ? AppColors.error.withOpacity(0.3) : isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20.r,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : '?', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.name, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                          Text(s.phone, style: TextStyle(fontSize: 11.sp, fontFamily: 'Poppins', color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                          Text('${s.purchasedCourses.length} courses', style: TextStyle(fontSize: 10.sp, fontFamily: 'Poppins', color: AppColors.primary)),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      onSelected: (v) async {
                        if (v == 'block') {
                          await FirebaseFirestore.instance.collection('students').doc(s.uid).update({'isBlocked': !s.isBlocked});
                          Get.snackbar(s.isBlocked ? 'Unblocked' : 'Blocked', '${s.name} has been ${s.isBlocked ? 'unblocked' : 'blocked'}', backgroundColor: s.isBlocked ? AppColors.success : AppColors.error, colorText: Colors.white, snackPosition: SnackPosition.TOP, margin: EdgeInsets.all(16.w));
                        } else if (v == 'doubt') {
                          await FirebaseFirestore.instance.collection('students').doc(s.uid).update({'canSubmitDoubt': !s.canSubmitDoubt});
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(value: 'block', child: Text(s.isBlocked ? 'Unblock Student' : 'Block Student', style: TextStyle(color: s.isBlocked ? AppColors.success : AppColors.error))),
                        PopupMenuItem(value: 'doubt', child: Text(s.canSubmitDoubt ? 'Disable Doubts' : 'Enable Doubts')),
                      ],
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
}
