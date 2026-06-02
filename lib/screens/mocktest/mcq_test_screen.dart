// lib/screens/mocktest/mcq_test_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../theme/app_theme.dart';
import '../../models/mocktest_model.dart';
import '../../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/routes.dart';

class McqTestScreen extends StatefulWidget {
  const McqTestScreen({super.key});

  @override
  State<McqTestScreen> createState() => _McqTestScreenState();
}

class _McqTestScreenState extends State<McqTestScreen> {
  late MocktestModel _test;
  final Map<String, int> _answers = {};
  int _currentQuestion = 0;
  late int _remainingSeconds;
  Timer? _timer;
  bool _submitted = false;
  final PageController _pageCtrl = PageController();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    _test = args['test'] as MocktestModel;
    _remainingSeconds = _test.durationMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds <= 0) {
        t.cancel();
        _autoSubmit();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _autoSubmit() {
    if (!_submitted) _submitTest();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitTest() async {
    _timer?.cancel();
    setState(() => _submitted = true);

    int totalMarks = 0;
    int obtained = 0;

    for (final q in _test.questions) {
      totalMarks += q.marks;
      final selected = _answers[q.id];
      if (selected != null && selected == q.correctOptionIndex) {
        obtained += q.marks;
      }
    }

    final timeTaken =
        (_test.durationMinutes * 60) - _remainingSeconds;
    final student = AuthService.instance.studentData.value!;

    final result = TestResultModel(
      id: '',
      studentId: student.uid,
      studentName: student.name,
      testId: _test.id,
      testType: TestType.mcq,
      answers: _answers,
      marksObtained: obtained,
      totalMarks: totalMarks,
      submittedAt: DateTime.now(),
      timeTakenSeconds: timeTaken,
    );

    final docRef = await FirebaseFirestore.instance
        .collection('testResults')
        .add(result.toFirestore());

    Get.offAllNamed(
      AppRoutes.testResult,
      arguments: {
        'result': TestResultModel(
          id: docRef.id,
          studentId: result.studentId,
          studentName: result.studentName,
          testId: result.testId,
          testType: result.testType,
          answers: result.answers,
          marksObtained: obtained,
          totalMarks: totalMarks,
          submittedAt: result.submittedAt,
          timeTakenSeconds: timeTaken,
        ),
        'test': _test,
      },
    );
  }

  String get _timerDisplay {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color get _timerColor {
    if (_remainingSeconds <= 60) return AppColors.error;
    if (_remainingSeconds <= 300) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final q = _test.questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / _test.questions.length;

    return WillPopScope(
      onWillPop: () async {
        final exit = await _confirmExit();
        return exit;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_test.title,
              style: TextStyle(fontSize: 15.sp)),
          actions: [
            // Timer
            Container(
              margin: EdgeInsets.only(right: 12.w),
              padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: _timerColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: _timerColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_rounded,
                      size: 14.w, color: _timerColor),
                  SizedBox(width: 4.w),
                  Text(
                    _timerDisplay,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: _timerColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress bar
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${_currentQuestion + 1}/${_test.questions.length}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Marks: ${q.marks}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.primary,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                    valueColor: const AlwaysStoppedAnimation(
                        AppColors.primary),
                    borderRadius: BorderRadius.circular(4.r),
                    minHeight: 5,
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _test.questions.length,
                itemBuilder: (_, i) =>
                    _buildQuestion(_test.questions[i], isDark),
              ),
            ),

            // Navigation bar
            _buildNavBar(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion(QuestionModel q, bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          // Question text
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isDark
                    ? AppColors.borderDark
                    : AppColors.borderLight,
              ),
            ),
            child: Text(
              q.question,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontFamily: 'Poppins',
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Choose the correct option:',
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 10.h),
          // Options
          ...q.options.asMap().entries.map(
                (entry) => _optionTile(
                    q.id, entry.key, entry.value, isDark),
              ),
        ],
      ),
    );
  }

  Widget _optionTile(
      String qId, int index, String text, bool isDark) {
    final selected = _answers[qId] == index;
    final optionLetters = ['A', 'B', 'C', 'D', 'E'];

    return GestureDetector(
      onTap: () => setState(() => _answers[qId] = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(
            horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.08)
              : isDark
                  ? AppColors.cardDark
                  : AppColors.cardLight,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : isDark
                    ? AppColors.borderDark
                    : AppColors.borderLight,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  optionLetters[index],
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppColors.primary,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: selected
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: selected
                      ? AppColors.primary
                      : isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 18.w),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar(bool isDark) {
    final isFirst = _currentQuestion == 0;
    final isLast =
        _currentQuestion == _test.questions.length - 1;
    final answered = _answers.length;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 20.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$answered/${_test.questions.length} answered',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                '${(_test.questions.length - answered)} remaining',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.warning,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              if (!isFirst)
                Expanded(
                  flex: 1,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _currentQuestion--);
                      _pageCtrl.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    },
                    icon: Icon(Icons.arrow_back_rounded,
                        size: 16.w),
                    label: const Text('Prev'),
                  ),
                ),
              if (!isFirst) SizedBox(width: 10.w),
              Expanded(
                flex: 2,
                child: isLast
                    ? ElevatedButton.icon(
                        onPressed: () async {
                          if (await _confirmSubmit()) {
                            await _submitTest();
                          }
                        },
                        icon: Icon(Icons.check_rounded,
                            size: 16.w, color: Colors.white),
                        label: const Text('Submit Test'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success),
                      )
                    : ElevatedButton.icon(
                        onPressed: () {
                          setState(() => _currentQuestion++);
                          _pageCtrl.nextPage(
                              duration:
                                  const Duration(milliseconds: 300),
                              curve: Curves.easeInOut);
                        },
                        icon: Icon(Icons.arrow_forward_rounded,
                            size: 16.w, color: Colors.white),
                        label: const Text('Next'),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmSubmit() async {
    final unanswered =
        _test.questions.length - _answers.length;
    if (unanswered == 0) return true;

    return await Get.dialog<bool>(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: const Text('Submit Test?'),
            content: Text(
                '$unanswered question(s) still unanswered. Are you sure you want to submit?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success),
                child: const Text('Submit'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _confirmExit() async {
    return await Get.dialog<bool>(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: const Text('Exit Test?'),
            content: const Text(
                'Your progress will be lost. Are you sure you want to exit?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Stay'),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error),
                child: const Text('Exit'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
