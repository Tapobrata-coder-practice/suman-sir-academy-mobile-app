// lib/screens/admin/courses/admin_courses_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../theme/app_theme.dart';
import '../../../models/course_model.dart';
import '../../../services/course_service.dart';

class AdminCoursesScreen extends StatefulWidget {
  const AdminCoursesScreen({super.key});

  @override
  State<AdminCoursesScreen> createState() => _AdminCoursesScreenState();
}

class _AdminCoursesScreenState extends State<AdminCoursesScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Courses')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCourseDialog(context, isDark),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add Course', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13.sp)),
      ),
      body: StreamBuilder<List<CourseModel>>(
        stream: CourseService.instance.getAllCourses(),
        builder: (context, snap) {
          final courses = snap.data ?? [];
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (courses.isEmpty) return Center(child: Text('No courses yet. Add your first course!', style: TextStyle(fontSize: 14.sp, fontFamily: 'Poppins', color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)));

          return ListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 90.h),
            itemCount: courses.length,
            itemBuilder: (_, i) {
              final c = courses[i];
              return Container(
                margin: EdgeInsets.only(bottom: 10.h),
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(color: isDark ? AppColors.cardDark : AppColors.cardLight, borderRadius: BorderRadius.circular(14.r), border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                          SizedBox(height: 4.h),
                          Text('₹${c.effectivePrice} • ${c.totalVideos} videos • ${c.type.name}', style: TextStyle(fontSize: 11.sp, fontFamily: 'Poppins', color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      onSelected: (v) async {
                        if (v == 'delete') {
                          await CourseService.instance.deleteCourse(c.id);
                          Get.snackbar('Deleted', '${c.title} has been deleted', backgroundColor: AppColors.error, colorText: Colors.white, snackPosition: SnackPosition.TOP, margin: EdgeInsets.all(16.w));
                        } else if (v == 'toggle') {
                          await CourseService.instance.updateCourse(c.id, {'isActive': !c.isActive});
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit Course')),
                        const PopupMenuItem(value: 'toggle', child: Text('Toggle Active')),
                        const PopupMenuItem(value: 'videos', child: Text('Manage Videos')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.error))),
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

  void _showAddCourseDialog(BuildContext context, bool isDark) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String selectedType = 'fullCourse';

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add New Course', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
            SizedBox(height: 16.h),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Course Title', hintText: 'e.g. Macbeth Full Course')),
            SizedBox(height: 10.h),
            TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Description')),
            SizedBox(height: 10.h),
            TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price (₹)', prefixText: '₹ ')),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (titleCtrl.text.trim().isEmpty || priceCtrl.text.trim().isEmpty) return;
                  final course = CourseModel(
                    id: '',
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    thumbnailUrl: '',
                    price: double.tryParse(priceCtrl.text.trim()) ?? 0,
                    type: CourseType.values.firstWhere((e) => e.name == selectedType),
                    createdAt: DateTime.now(),
                  );
                  await CourseService.instance.addCourse(course);
                  Get.back();
                  Get.snackbar('Course Added!', '${course.title} has been created.', backgroundColor: AppColors.success, colorText: Colors.white, snackPosition: SnackPosition.TOP, margin: EdgeInsets.all(16.w));
                },
                child: const Text('Create Course'),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
