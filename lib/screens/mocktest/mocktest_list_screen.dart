// lib/screens/mocktest/mocktest_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/mocktest_model.dart';
import '../../config/routes.dart';

class MocktestListScreen extends StatelessWidget {
  final bool isTab;
  const MocktestListScreen({super.key, this.isTab = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget body = StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('mocktests')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final tests = snap.data?.docs.map((d) => MocktestModel.fromFirestore(d)).toList() ?? [];
        if (tests.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.quiz_outlined, size: 56.w, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                SizedBox(height: 10.h),
                Text('No tests available yet', style: TextStyle(fontSize: 14.sp, fontFamily: 'Poppins', color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: tests.length,
          itemBuilder: (_, i) => _testCard(tests[i], isDark),
        );
      },
    );

    if (isTab) return body;
    return Scaffold(appBar: AppBar(title: const Text('Mock Tests')), body: body);
  }

  Widget _testCard(MocktestModel test, bool isDark) {
    final isMcq = test.type == TestType.mcq;
    final color = isMcq ? AppColors.primary : AppColors.secondary;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6.r)),
                child: Text(isMcq ? 'MCQ Test' : 'Written Test', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: color, fontFamily: 'Poppins')),
              ),
              const Spacer(),
              Text(DateFormat('dd MMM').format(test.createdAt), style: TextStyle(fontSize: 11.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontFamily: 'Poppins')),
            ],
          ),
          SizedBox(height: 10.h),
          Text(test.title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, fontFamily: 'Poppins')),
          if (test.description != null) ...[
            SizedBox(height: 4.h),
            Text(test.description!, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontFamily: 'Poppins')),
          ],
          SizedBox(height: 12.h),
          Row(
            children: [
              _chip(Icons.timer_rounded, '${test.durationMinutes} min', isDark),
              SizedBox(width: 8.w),
              _chip(Icons.star_rounded, '${test.totalMarks} marks', isDark),
              if (isMcq) ...[SizedBox(width: 8.w), _chip(Icons.quiz_rounded, '${test.questions.length} questions', isDark)],
              const Spacer(),
              ElevatedButton(
                onPressed: () => Get.toNamed(isMcq ? AppRoutes.mcqTest : AppRoutes.writtenTest, arguments: {'test': test}),
                style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h), minimumSize: Size.zero),
                child: Text('Start', style: TextStyle(fontSize: 13.sp, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.w, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        SizedBox(width: 3.w),
        Text(label, style: TextStyle(fontSize: 11.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontFamily: 'Poppins')),
      ],
    );
  }
}
