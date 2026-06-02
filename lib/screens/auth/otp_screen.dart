// lib/screens/auth/otp_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../config/routes.dart';
import '../../widgets/custom_button.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  final _auth = AuthService.instance;
  late Map<String, dynamic> _args;
  int _countdown = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _args = Get.arguments as Map<String, dynamic>;
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _countdown = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        timer.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _countdown--);
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _verifyOtp() {
    if (_otpController.text.length != 6) {
      Get.snackbar(
        'Invalid OTP',
        'Please enter the complete 6-digit OTP',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(16.w),
        borderRadius: 12.r,
      );
      return;
    }

    _auth.verifyOtp(
      otp: _otpController.text,
      name: _args['name'] ?? '',
      phone: _args['phone'] ?? '',
      onSuccess: () {
        if (_auth.isAdmin.value) {
          Get.offAllNamed(AppRoutes.adminDashboard);
        } else {
          Get.offAllNamed(AppRoutes.home);
        }
      },
      onError: (error) {
        _otpController.clear();
        Get.snackbar(
          'Error',
          error,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: EdgeInsets.all(16.w),
          borderRadius: 12.r,
        );
      },
    );
  }

  void _resendOtp() {
    if (!_canResend) return;
    _auth.sendOtp(
      phone: _args['phone'] ?? '',
      onCodeSent: (_) {
        _startTimer();
        Get.snackbar(
          'OTP Sent',
          'A new OTP has been sent to ${_args['phone']}',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: EdgeInsets.all(16.w),
          borderRadius: 12.r,
        );
      },
      onError: (error) {
        Get.snackbar(
          'Error',
          error,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: EdgeInsets.all(16.w),
          borderRadius: 12.r,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final phone = _args['phone'] as String? ?? '';

    final defaultPinTheme = PinTheme(
      width: 52.w,
      height: 56.h,
      textStyle: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        fontFamily: 'Poppins',
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.bgLight,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderLight, width: 1.5),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.sms_rounded,
                      color: AppColors.primary,
                      size: 24.w,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'OTP sent to $phone',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              Text(
                'Enter Verification Code',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Enter the 6-digit code sent to your phone',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 32.h),
              Center(
                child: Pinput(
                  controller: _otpController,
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyDecorationWith(
                    border: Border.all(color: AppColors.primary, width: 2),
                    color: AppColors.primary.withOpacity(0.05),
                  ),
                  submittedPinTheme: defaultPinTheme.copyDecorationWith(
                    border: Border.all(color: AppColors.success, width: 1.5),
                    color: AppColors.success.withOpacity(0.05),
                  ),
                  onCompleted: (otp) => _verifyOtp(),
                  autofocus: true,
                  hapticFeedbackType: HapticFeedbackType.lightImpact,
                ),
              ),
              SizedBox(height: 28.h),
              // Resend
              Center(
                child: _canResend
                    ? GestureDetector(
                        onTap: _resendOtp,
                        child: Text(
                          'Resend OTP',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      )
                    : RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Resend OTP in ',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextSpan(
                              text: '${_countdown}s',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const Spacer(),
              Obx(() => CustomButton(
                    text: 'Verify & Login',
                    isLoading: _auth.isLoading.value,
                    onPressed: _verifyOtp,
                  )),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
