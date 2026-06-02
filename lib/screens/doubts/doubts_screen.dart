// lib/screens/doubts/doubts_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../models/mocktest_model.dart';
import '../../widgets/custom_button.dart';

class DoubtsScreen extends StatefulWidget {
  final bool isTab;
  const DoubtsScreen({super.key, this.isTab = false});

  @override
  State<DoubtsScreen> createState() => _DoubtsScreenState();
}

class _DoubtsScreenState extends State<DoubtsScreen> {
  final _db = FirebaseFirestore.instance;
  final _questionCtrl = TextEditingController();
  final _auth = AuthService.instance;
  bool _submitting = false;
  bool _submittedToday = false;

  @override
  void initState() {
    super.initState();
    _checkTodayLimit();
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkTodayLimit() async {
    final uid = _auth.userId;
    if (uid.isEmpty) return;

    final today = DateTime.now();
    final startOfDay =
        DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snap = await _db
        .collection('doubts')
        .where('studentId', isEqualTo: uid)
        .where('submittedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('submittedAt',
            isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    setState(() => _submittedToday = snap.docs.isNotEmpty);
  }

  Future<void> _submitDoubt() async {
    if (_questionCtrl.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please write your question',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: EdgeInsets.all(16.w),
          borderRadius: 12.r);
      return;
    }

    final student = _auth.studentData.value;
    if (student == null) return;

    if (!student.canSubmitDoubt) {
      Get.snackbar('Disabled', 'Doubt submission has been disabled for your account.',
          backgroundColor: AppColors.warning,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: EdgeInsets.all(16.w),
          borderRadius: 12.r);
      return;
    }

    setState(() => _submitting = true);
    try {
      final doubt = DoubtModel(
        id: '',
        studentId: student.uid,
        studentName: student.name,
        studentPhone: student.phone,
        question: _questionCtrl.text.trim(),
        submittedAt: DateTime.now(),
      );

      await _db.collection('doubts').add(doubt.toFirestore());
      _questionCtrl.clear();
      setState(() {
        _submitting = false;
        _submittedToday = true;
      });
      Get.snackbar(
        'Submitted! ✅',
        'Your doubt has been sent to Suman Sir.',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(16.w),
        borderRadius: 12.r,
      );
    } catch (e) {
      setState(() => _submitting = false);
      Get.snackbar('Error', 'Failed to submit. Please try again.',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: EdgeInsets.all(16.w),
          borderRadius: 12.r);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final student = _auth.studentData.value;

    Widget body = SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student info card
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.primary.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22.r,
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  child: Text(
                    (student?.name.isNotEmpty == true)
                        ? student!.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student?.name ?? '',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      student?.phone ?? '',
                      style: TextStyle(
                        fontSize: 12.sp,
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
          ),

          SizedBox(height: 20.h),

          if (_submittedToday) ...[
            _buildAlreadySubmitted(isDark),
          ] else ...[
            Text(
              'Ask a Doubt',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'You can submit 1 question per day.',
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 14.h),
            TextField(
              controller: _questionCtrl,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText:
                    'Type your question clearly...\n\nExample: What is the significance of the dagger in Act 2 of Macbeth?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 2),
                ),
                filled: true,
                fillColor: isDark
                    ? AppColors.surfaceDark
                    : AppColors.bgLight,
                hintStyle: TextStyle(
                  fontSize: 13.sp,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  fontFamily: 'Poppins',
                  height: 1.6,
                ),
                contentPadding: EdgeInsets.all(14.w),
              ),
              style: TextStyle(
                fontSize: 13.sp,
                fontFamily: 'Poppins',
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                height: 1.5,
              ),
            ),
            SizedBox(height: 14.h),
            CustomButton(
              text: 'Submit Doubt',
              isLoading: _submitting,
              onPressed: _submitDoubt,
              icon: Icons.send_rounded,
            ),
          ],

          SizedBox(height: 24.h),

          // Previous doubts
          Text(
            'Your Previous Doubts',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 12.h),
          _buildDoubtHistory(isDark),
        ],
      ),
    );

    if (widget.isTab) return body;

    return Scaffold(
      appBar: AppBar(title: const Text('Doubt Solving')),
      body: body,
    );
  }

  Widget _buildAlreadySubmitted(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.warning.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: AppColors.warning, size: 24.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Doubt Already Submitted Today',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.warning,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'You can submit another doubt tomorrow. Suman Sir will answer it soon.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    fontFamily: 'Poppins',
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoubtHistory(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: _db
          .collection('doubts')
          .where('studentId', isEqualTo: _auth.userId)
          .orderBy('submittedAt', descending: true)
          .limit(20)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return Text(
            'No doubts submitted yet.',
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              fontFamily: 'Poppins',
            ),
          );
        }
        return Column(
          children: docs.map((doc) {
            final doubt = DoubtModel.fromFirestore(doc);
            return _doubtCard(doubt, isDark);
          }).toList(),
        );
      },
    );
  }

  Widget _doubtCard(DoubtModel doubt, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: doubt.isAnswered
              ? AppColors.success.withOpacity(0.3)
              : isDark
                  ? AppColors.borderDark
                  : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  doubt.question,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontFamily: 'Poppins',
                    height: 1.4,
                  ),
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: doubt.isAnswered
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  doubt.isAnswered ? 'Answered' : 'Pending',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: doubt.isAnswered
                        ? AppColors.success
                        : AppColors.warning,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          if (doubt.answer != null) ...[
            SizedBox(height: 10.h),
            Divider(
                color:
                    isDark ? AppColors.borderDark : AppColors.borderLight),
            SizedBox(height: 6.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Icon(Icons.school_rounded,
                      size: 12.w, color: AppColors.primary),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    doubt.answer!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      fontFamily: 'Poppins',
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 8.h),
          Text(
            DateFormat('dd MMM yyyy, hh:mm a')
                .format(doubt.submittedAt),
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
    );
  }
}
