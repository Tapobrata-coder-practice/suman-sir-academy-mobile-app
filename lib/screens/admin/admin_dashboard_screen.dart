// lib/screens/admin/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../config/routes.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _db = FirebaseFirestore.instance;
  int _studentsCount = 0;
  int _coursesCount = 0;
  int _pendingDoubts = 0;
  int _pendingResults = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final students = await _db.collection('students').count().get();
      final courses = await _db.collection('courses').count().get();
      final doubts = await _db
          .collection('doubts')
          .where('isAnswered', isEqualTo: false)
          .count()
          .get();
      final results = await _db
          .collection('testResults')
          .where('isChecked', isEqualTo: false)
          .where('testType', isEqualTo: 'written')
          .count()
          .get();

      setState(() {
        _studentsCount = students.count ?? 0;
        _coursesCount = courses.count ?? 0;
        _pendingDoubts = doubts.count ?? 0;
        _pendingResults = results.count ?? 0;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              final confirm = await Get.dialog<bool>(
                AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                        onPressed: () => Get.back(result: false),
                        child: const Text('Cancel')),
                    ElevatedButton(
                        onPressed: () => Get.back(result: true),
                        child: const Text('Logout')),
                  ],
                ),
              );
              if (confirm == true) {
                AuthService.instance.signOut();
              }
            },
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A56DB), Color(0xFF00C9A7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Text(
                          'SE',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, Suman Sir 👋',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
                          'Suman Sir English Academy',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.white.withOpacity(0.8),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Stats grid
              Text(
                'Overview',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      icon: Icons.people_rounded,
                      label: 'Students',
                      value: '$_studentsCount',
                      color: AppColors.primary,
                      isDark: isDark,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _statCard(
                      icon: Icons.library_books_rounded,
                      label: 'Courses',
                      value: '$_coursesCount',
                      color: AppColors.secondary,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      icon: Icons.help_outline_rounded,
                      label: 'Pending Doubts',
                      value: '$_pendingDoubts',
                      color: AppColors.warning,
                      isDark: isDark,
                      badge: _pendingDoubts > 0,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _statCard(
                      icon: Icons.assignment_rounded,
                      label: 'Unchecked Papers',
                      value: '$_pendingResults',
                      color: AppColors.info,
                      isDark: isDark,
                      badge: _pendingResults > 0,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              Text(
                'Manage',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 12.h),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.h,
                childAspectRatio: 1.4,
                children: [
                  _menuCard(
                    icon: Icons.library_books_rounded,
                    label: 'Courses & Videos',
                    subtitle: 'Upload, manage content',
                    color: AppColors.primary,
                    onTap: () => Get.toNamed(AppRoutes.adminCourses),
                    isDark: isDark,
                  ),
                  _menuCard(
                    icon: Icons.people_rounded,
                    label: 'Students',
                    subtitle: 'Block, remove access',
                    color: const Color(0xFF8B5CF6),
                    onTap: () => Get.toNamed(AppRoutes.adminStudents),
                    isDark: isDark,
                  ),
                  _menuCard(
                    icon: Icons.notifications_active_rounded,
                    label: 'Send Notification',
                    subtitle: 'Class alerts, reminders',
                    color: AppColors.secondary,
                    onTap: () =>
                        Get.toNamed(AppRoutes.adminNotifications),
                    isDark: isDark,
                  ),
                  _menuCard(
                    icon: Icons.quiz_rounded,
                    label: 'Mock Tests',
                    subtitle: 'Create, grade tests',
                    color: AppColors.warning,
                    onTap: () => Get.toNamed(AppRoutes.adminMocktests),
                    isDark: isDark,
                  ),
                  _menuCard(
                    icon: Icons.school_rounded,
                    label: 'Batches',
                    subtitle: 'Semester, special batches',
                    color: AppColors.success,
                    onTap: () => Get.toNamed(AppRoutes.adminBatches),
                    isDark: isDark,
                  ),
                  _menuCard(
                    icon: Icons.help_rounded,
                    label: 'Answer Doubts',
                    subtitle: 'Student questions',
                    color: AppColors.info,
                    onTap: () => _showDoubtsAdmin(),
                    isDark: isDark,
                    badge: _pendingDoubts > 0
                        ? '$_pendingDoubts'
                        : null,
                  ),
                  _menuCard(
                    icon: Icons.payment_rounded,
                    label: 'Payments',
                    subtitle: 'Approve, view history',
                    color: const Color(0xFF059669),
                    onTap: () => _showPaymentsAdmin(),
                    isDark: isDark,
                  ),
                  _menuCard(
                    icon: Icons.live_tv_rounded,
                    label: 'Schedule Live',
                    subtitle: 'Upcoming classes',
                    color: AppColors.error,
                    onTap: () => _scheduleLiveClass(),
                    isDark: isDark,
                  ),
                ],
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
    bool badge = false,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 20.w),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _menuCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, color: color, size: 20.w),
                ),
                SizedBox(height: 8.h),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            if (badge != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDoubtsAdmin() {
    Get.bottomSheet(
      _AdminDoubtsSheet(),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  void _showPaymentsAdmin() {
    Get.snackbar('Payments', 'Opening payment management...',
        snackPosition: SnackPosition.BOTTOM);
  }

  void _scheduleLiveClass() {
    Get.snackbar('Schedule', 'Open schedule live class...',
        snackPosition: SnackPosition.BOTTOM);
  }
}

class _AdminDoubtsSheet extends StatelessWidget {
  final _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: Get.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          SizedBox(height: 8.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              'Student Doubts',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db
                  .collection('doubts')
                  .where('isAnswered', isEqualTo: false)
                  .orderBy('submittedAt', descending: true)
                  .snapshots(),
              builder: (context, snap) {
                final docs = snap.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No pending doubts 🎉',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: 'Poppins',
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final data =
                        docs[i].data() as Map<String, dynamic>;
                    return _doubtItem(docs[i].id, data, isDark);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _doubtItem(
      String id, Map<String, dynamic> data, bool isDark) {
    final answerCtrl = TextEditingController();

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.bgLight,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['studentName'] ?? '',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            data['question'] ?? '',
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontFamily: 'Poppins',
              height: 1.4,
            ),
          ),
          SizedBox(height: 10.h),
          TextField(
            controller: answerCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Type your answer...',
              hintStyle:
                  TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
              contentPadding: EdgeInsets.all(10.w),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: isDark
                      ? AppColors.borderDark
                      : AppColors.borderLight,
                ),
              ),
              filled: true,
              fillColor: isDark ? AppColors.bgDark : Colors.white,
            ),
            style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (answerCtrl.text.trim().isEmpty) return;
                await FirebaseFirestore.instance
                    .collection('doubts')
                    .doc(id)
                    .update({
                  'answer': answerCtrl.text.trim(),
                  'isAnswered': true,
                });
                Get.snackbar(
                  'Done',
                  'Answer submitted successfully',
                  backgroundColor: AppColors.success,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 10.h),
              ),
              child: Text(
                'Submit Answer',
                style: TextStyle(
                    fontSize: 13.sp, fontFamily: 'Poppins'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
