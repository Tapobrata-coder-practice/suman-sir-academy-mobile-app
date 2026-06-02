// lib/screens/splash/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../config/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _textController.forward();
    });

    Future.delayed(const Duration(milliseconds: 2800), _navigate);
  }

  void _navigate() {
    final auth = AuthService.instance;
    if (auth.isLoggedIn) {
      if (auth.isAdmin.value) {
        Get.offAllNamed(AppRoutes.adminDashboard);
      } else if (auth.isBlocked) {
        Get.offAllNamed(AppRoutes.login);
      } else {
        Get.offAllNamed(AppRoutes.home);
      }
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D1B4B), Color(0xFF1A56DB), Color(0xFF00C9A7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo
              ScaleTransition(
                scale: _logoScale,
                child: FadeTransition(
                  opacity: _logoOpacity,
                  child: Container(
                    width: 110.w,
                    height: 110.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'SE',
                        style: TextStyle(
                          fontSize: 44.sp,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Poppins',
                          color: AppColors.primary,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 28.h),
              // App name
              SlideTransition(
                position: _textSlide,
                child: FadeTransition(
                  opacity: _textController,
                  child: Column(
                    children: [
                      Text(
                        'Suman Sir',
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'English Academy',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.85),
                          fontFamily: 'Poppins',
                          letterSpacing: 3,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            'Learn. Grow. Excel.',
                            textStyle: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white.withOpacity(0.7),
                              fontFamily: 'Poppins',
                              letterSpacing: 1,
                            ),
                            speed: const Duration(milliseconds: 80),
                          ),
                        ],
                        totalRepeatCount: 1,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 3),
              // Loading indicator
              SizedBox(
                width: 40.w,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white.withOpacity(0.5),
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
