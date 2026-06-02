// lib/screens/mocktest/test_result_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:confetti/confetti.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../theme/app_theme.dart';
import '../../models/mocktest_model.dart';
import '../../config/routes.dart';

class TestResultScreen extends StatefulWidget {
  const TestResultScreen({super.key});

  @override
  State<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends State<TestResultScreen>
    with SingleTickerProviderStateMixin {
  late TestResultModel _result;
  MocktestModel? _test;
  late ConfettiController _confetti;
  late AnimationController _animCtrl;
  late Animation<double> _scoreAnim;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    _result = args['result'] as TestResultModel;
    _test = args['test'] as MocktestModel?;

    _confetti = ConfettiController(
        duration: const Duration(seconds: 3));

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scoreAnim = Tween<double>(begin: 0, end: _result.percentage / 100)
        .animate(CurvedAnimation(
            parent: _animCtrl, curve: Curves.easeOutCubic));

    _animCtrl.forward();

    if (_result.percentage >= 60) {
      Future.delayed(const Duration(milliseconds: 400), () {
        _confetti.play();
      });
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Color get _gradeColor {
    if (_result.percentage >= 80) return AppColors.success;
    if (_result.percentage >= 60) return AppColors.primary;
    if (_result.percentage >= 40) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Result'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => Get.offAllNamed(AppRoutes.home),
            child: Text(
              'Home',
              style: TextStyle(
                  color: AppColors.primary,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _buildScoreCard(isDark),
                SizedBox(height: 16.h),
                _buildStatsRow(isDark),
                SizedBox(height: 16.h),
                if (_test != null) _buildAnswerReview(isDark),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [
                AppColors.primary,
                AppColors.secondary,
                AppColors.success,
                AppColors.warning,
              ],
              numberOfParticles: 30,
              shouldLoop: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _gradeColor.withOpacity(0.8),
            _gradeColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          Text(
            _result.percentage >= 60 ? '🎉 Congratulations!' : 'Keep Practicing!',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 20.h),
          AnimatedBuilder(
            animation: _scoreAnim,
            builder: (_, __) => CircularPercentIndicator(
              radius: 72.r,
              lineWidth: 10.w,
              percent: _scoreAnim.value,
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(_scoreAnim.value * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    _result.grade,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.9),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              progressColor: Colors.white,
              backgroundColor: Colors.white.withOpacity(0.25),
              circularStrokeCap: CircularStrokeCap.round,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '${_result.marksObtained} / ${_result.totalMarks} marks',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            _result.studentName,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.white.withOpacity(0.8),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isDark) {
    final timeMin = _result.timeTakenSeconds ~/ 60;
    final timeSec = _result.timeTakenSeconds % 60;

    return Row(
      children: [
        _statCard(
          icon: Icons.check_circle_rounded,
          label: 'Correct',
          value: '${_result.marksObtained}',
          color: AppColors.success,
          isDark: isDark,
        ),
        SizedBox(width: 10.w),
        _statCard(
          icon: Icons.cancel_rounded,
          label: 'Wrong',
          value:
              '${(_result.totalMarks - _result.marksObtained).clamp(0, 999)}',
          color: AppColors.error,
          isDark: isDark,
        ),
        SizedBox(width: 10.w),
        _statCard(
          icon: Icons.timer_rounded,
          label: 'Time',
          value:
              '${timeMin}m ${timeSec}s',
          color: AppColors.info,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22.w),
            SizedBox(height: 6.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: color,
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
      ),
    );
  }

  Widget _buildAnswerReview(bool isDark) {
    final test = _test!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Answer Review',
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
        ...test.questions.asMap().entries.map((e) {
          final q = e.value;
          final selected = _result.answers[q.id];
          final isCorrect = selected == q.correctOptionIndex;

          return Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: isCorrect
                    ? AppColors.success.withOpacity(0.3)
                    : AppColors.error.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.error.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCorrect
                            ? Icons.check_rounded
                            : Icons.close_rounded,
                        size: 14.w,
                        color: isCorrect
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Q${e.key + 1}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  q.question,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 8.h),
                if (selected != null)
                  _answerRow(
                    'Your answer: ',
                    q.options[selected],
                    isCorrect ? AppColors.success : AppColors.error,
                    isDark,
                  ),
                if (!isCorrect)
                  _answerRow(
                    'Correct answer: ',
                    q.options[q.correctOptionIndex],
                    AppColors.success,
                    isDark,
                  ),
                if (selected == null)
                  Text(
                    'Not attempted',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.warning,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _answerRow(
      String label, String value, Color color, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: 3.h),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: label,
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontFamily: 'Poppins',
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: color,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
