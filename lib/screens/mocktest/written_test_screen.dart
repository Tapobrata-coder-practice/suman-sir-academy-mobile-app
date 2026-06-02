// lib/screens/mocktest/written_test_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../models/mocktest_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';

class WrittenTestScreen extends StatefulWidget {
  const WrittenTestScreen({super.key});

  @override
  State<WrittenTestScreen> createState() => _WrittenTestScreenState();
}

class _WrittenTestScreenState extends State<WrittenTestScreen> {
  late MocktestModel _test;
  File? _answerSheet;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    _test = args['test'] as MocktestModel;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) setState(() => _answerSheet = File(picked.path));
  }

  Future<void> _submitAnswer() async {
    if (_answerSheet == null) {
      Get.snackbar('Required', 'Please upload your answer sheet image', backgroundColor: AppColors.error, colorText: Colors.white, snackPosition: SnackPosition.TOP, margin: EdgeInsets.all(16.w));
      return;
    }

    setState(() => _uploading = true);
    try {
      final student = AuthService.instance.studentData.value!;
      final ref = FirebaseStorage.instance.ref().child('answerSheets/${student.uid}_${_test.id}_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(_answerSheet!);
      final url = await ref.getDownloadURL();

      final result = TestResultModel(
        id: '',
        studentId: student.uid,
        studentName: student.name,
        testId: _test.id,
        testType: TestType.written,
        marksObtained: 0,
        totalMarks: _test.totalMarks,
        answerSheetUrl: url,
        isChecked: false,
        submittedAt: DateTime.now(),
        timeTakenSeconds: 0,
      );

      await FirebaseFirestore.instance.collection('testResults').add(result.toFirestore());

      setState(() => _uploading = false);
      Get.snackbar('Submitted! ✅', 'Your answer sheet has been sent to Suman Sir for checking.', backgroundColor: AppColors.success, colorText: Colors.white, snackPosition: SnackPosition.TOP, margin: EdgeInsets.all(16.w));
      Get.back();
    } catch (e) {
      setState(() => _uploading = false);
      Get.snackbar('Error', 'Upload failed. Please try again.', backgroundColor: AppColors.error, colorText: Colors.white, snackPosition: SnackPosition.TOP, margin: EdgeInsets.all(16.w));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(_test.title, style: TextStyle(fontSize: 15.sp))),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_test.pdfUrl != null) ...[
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.07), borderRadius: BorderRadius.circular(14.r), border: Border.all(color: AppColors.primary.withOpacity(0.2))),
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary, size: 24.w),
                    SizedBox(width: 10.w),
                    Expanded(child: Text('Question paper available. Download and write your answers.', style: TextStyle(fontSize: 13.sp, color: AppColors.primary, fontFamily: 'Poppins'))),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ],
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(color: isDark ? AppColors.cardDark : AppColors.cardLight, borderRadius: BorderRadius.circular(14.r), border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Test Details', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                  SizedBox(height: 10.h),
                  _detailRow('Total Marks', '${_test.totalMarks}', isDark),
                  _detailRow('Duration', '${_test.durationMinutes} minutes', isDark),
                  if (_test.description != null) _detailRow('Instructions', _test.description!, isDark),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Text('Upload Answer Sheet', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
            SizedBox(height: 6.h),
            Text('Take a clear photo of your answer sheet and upload it here.', style: TextStyle(fontSize: 12.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontFamily: 'Poppins')),
            SizedBox(height: 14.h),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.bgLight,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: _answerSheet != null ? AppColors.success : AppColors.primary, width: 2, style: BorderStyle.solid),
                ),
                child: _answerSheet != null
                    ? ClipRRect(borderRadius: BorderRadius.circular(12.r), child: Image.file(_answerSheet!, fit: BoxFit.cover))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 40.w, color: AppColors.primary),
                          SizedBox(height: 8.h),
                          Text('Tap to upload answer sheet', style: TextStyle(fontSize: 13.sp, color: AppColors.primary, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                          Text('JPG, PNG supported', style: TextStyle(fontSize: 11.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontFamily: 'Poppins')),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 24.h),
            CustomButton(text: 'Submit Answer Sheet', isLoading: _uploading, onPressed: _submitAnswer, icon: Icons.upload_rounded),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100.w, child: Text(label, style: TextStyle(fontSize: 12.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontFamily: 'Poppins'))),
          Text(': ', style: TextStyle(fontSize: 12.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          Expanded(child: Text(value, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, fontFamily: 'Poppins'))),
        ],
      ),
    );
  }
}
