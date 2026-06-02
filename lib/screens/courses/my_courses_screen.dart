// lib/screens/courses/my_courses_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/course_service.dart';
import '../../models/course_model.dart';
import '../../config/routes.dart';
import '../../widgets/course_card_full.dart';
import 'course_detail_screen.dart';

class MyCoursesScreen extends StatefulWidget {
  final bool isTab;
  const MyCoursesScreen({super.key, this.isTab = false});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _auth = AuthService.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
        automaticallyImplyLeading: !widget.isTab,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          labelStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Purchased'),
            Tab(text: 'Expired'),
          ],
        ),
      ),
      body: Obx(() {
        final student = _auth.studentData.value;
        final purchasedIds = student?.purchasedCourses ?? [];

        return StreamBuilder<List<CourseModel>>(
          stream: purchasedIds.isNotEmpty
              ? CourseService.instance.getStudentCourses(purchasedIds)
              : Stream.value([]),
          builder: (context, snapshot) {
            final courses = snapshot.data ?? [];

            final active = courses.where((c) => c.isActive &&
                (c.expiryDate == null ||
                    c.expiryDate!.isAfter(DateTime.now()))).toList();
            final purchased = courses;
            final expired = courses.where((c) =>
                c.expiryDate != null &&
                c.expiryDate!.isBefore(DateTime.now())).toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildCourseList(active, isDark, 'No active courses'),
                _buildCourseList(purchased, isDark, 'No purchased courses yet'),
                _buildCourseList(expired, isDark, 'No expired courses'),
              ],
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.payment),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Buy Course',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildCourseList(
      List<CourseModel> courses, bool isDark, String emptyMsg) {
    if (courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.school_outlined,
              size: 56.w,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            SizedBox(height: 12.h),
            Text(
              emptyMsg,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => Get.toNamed(AppRoutes.payment),
              child: const Text('Explore Courses'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: courses.length,
      itemBuilder: (_, i) => Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: CourseCardFull(
          course: courses[i],
          onTap: () => Get.toNamed(
            AppRoutes.courseDetail,
            arguments: {'course': courses[i]},
          ),
        ),
      ),
    );
  }
}
