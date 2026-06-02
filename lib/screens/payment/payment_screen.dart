// lib/screens/payment/payment_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/payment_service.dart';
import '../../services/course_service.dart';
import '../../models/course_model.dart';
import '../../widgets/custom_button.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  CourseModel? _selectedCourse;
  bool _paying = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _selectedCourse = args?['course'] as CourseModel?;
  }

  void _pay() {
    if (_selectedCourse == null) return;
    final student = AuthService.instance.studentData.value;
    if (student == null) return;

    if (student.purchasedCourses.contains(_selectedCourse!.id)) {
      Get.snackbar('Already Purchased', 'You already have access to this course.',
          backgroundColor: AppColors.info,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: EdgeInsets.all(16.w));
      return;
    }

    setState(() => _paying = true);
    PaymentService.instance.initiatePayment(
      courseId: _selectedCourse!.id,
      courseName: _selectedCourse!.title,
      amount: _selectedCourse!.effectivePrice,
      onSuccess: (paymentId, courseId) {
        setState(() => _paying = false);
        Get.snackbar('Payment Successful! 🎉',
            'You now have access to ${_selectedCourse!.title}',
            backgroundColor: AppColors.success,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            margin: EdgeInsets.all(16.w));
        Get.back();
      },
      onError: (error) {
        setState(() => _paying = false);
        Get.snackbar('Payment Failed', error,
            backgroundColor: AppColors.error,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            margin: EdgeInsets.all(16.w));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Enroll Now')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // All courses list when no course pre-selected
            if (_selectedCourse == null) ...[
              Text('Available Courses', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
              SizedBox(height: 12.h),
              StreamBuilder<List<CourseModel>>(
                stream: CourseService.instance.getAllCourses(),
                builder: (context, snap) {
                  final courses = snap.data ?? [];
                  return Column(
                    children: courses.map((c) => _courseSelectCard(c, isDark)).toList(),
                  );
                },
              ),
            ] else ...[
              _courseSummaryCard(_selectedCourse!, isDark),
              SizedBox(height: 16.h),
              _featuresList(_selectedCourse!, isDark),
              SizedBox(height: 24.h),
              CustomButton(text: 'Pay ₹${_selectedCourse!.effectivePrice.toStringAsFixed(0)}', isLoading: _paying, onPressed: _pay),
              SizedBox(height: 12.h),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_rounded, size: 12.w, color: AppColors.textSecondaryLight),
                    SizedBox(width: 4.w),
                    Text('Secured by Razorpay', style: TextStyle(fontSize: 11.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontFamily: 'Poppins')),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _courseSelectCard(CourseModel c, bool isDark) {
    final isSelected = _selectedCourse?.id == c.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedCourse = c),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.08) : isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: isSelected ? AppColors.primary : isDark ? AppColors.borderDark : AppColors.borderLight, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                  SizedBox(height: 4.h),
                  Text(c.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontFamily: 'Poppins')),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (c.hasDiscount) Text('₹${c.price.toStringAsFixed(0)}', style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondaryLight, decoration: TextDecoration.lineThrough, fontFamily: 'Poppins')),
                Text('₹${c.effectivePrice.toStringAsFixed(0)}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColors.primary, fontFamily: 'Poppins')),
                if (c.hasDiscount) Container(padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h), decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(4.r)), child: Text('${c.discountPercent}% OFF', style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w700, color: AppColors.success, fontFamily: 'Poppins'))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _courseSummaryCard(CourseModel c, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A56DB), Color(0xFF00C9A7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(c.title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'Poppins')),
          SizedBox(height: 6.h),
          Text(c.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.sp, color: Colors.white.withOpacity(0.85), fontFamily: 'Poppins')),
          SizedBox(height: 16.h),
          Row(
            children: [
              if (c.hasDiscount) ...[
                Text('₹${c.price.toStringAsFixed(0)}', style: TextStyle(fontSize: 14.sp, color: Colors.white.withOpacity(0.6), decoration: TextDecoration.lineThrough, fontFamily: 'Poppins')),
                SizedBox(width: 8.w),
              ],
              Text('₹${c.effectivePrice.toStringAsFixed(0)}', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Poppins')),
              if (c.hasDiscount) ...[
                SizedBox(width: 8.w),
                Container(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(6.r)), child: Text('${c.discountPercent}% OFF', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Poppins'))),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _featuresList(CourseModel c, bool isDark) {
    final features = c.features.isNotEmpty
        ? c.features
        : ['${c.totalVideos} Recorded Videos', '${c.totalPdfs} PDF Notes', 'Live Classes Access', 'Doubt Solving Support', 'Mock Tests & Quizzes'];

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("What's included", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
          SizedBox(height: 10.h),
          ...features.map((f) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, size: 16.w, color: AppColors.success),
                    SizedBox(width: 8.w),
                    Expanded(child: Text(f, style: TextStyle(fontSize: 13.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontFamily: 'Poppins'))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
