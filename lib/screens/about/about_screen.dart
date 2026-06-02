// ═══════════════════════════════════════════════════════
// lib/screens/about/about_screen.dart
// ═══════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../config/routes.dart';

class AboutScreen extends StatelessWidget {
  final bool isTab;
  const AboutScreen({super.key, this.isTab = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget body = SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Teacher profile card
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A56DB), Color(0xFF00C9A7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44.r,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  child: Text(
                    'SS',
                    style: TextStyle(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Suman Sir',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  'English Language Expert',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.white.withOpacity(0.85),
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statPill('10+ Years\nExperience'),
                    _statPill('500+\nStudents'),
                    _statPill('95%\nSuccess Rate'),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Qualifications
          _infoCard(
            isDark: isDark,
            icon: Icons.school_rounded,
            title: 'Qualifications',
            children: [
              _bulletItem('M.A. in English Literature', isDark),
              _bulletItem('B.Ed (English)', isDark),
              _bulletItem('10+ years of teaching experience', isDark),
              _bulletItem('Specialized in Board & Competitive English', isDark),
            ],
          ),
          SizedBox(height: 12.h),

          // About
          _infoCard(
            isDark: isDark,
            icon: Icons.info_outline_rounded,
            title: 'About Suman Sir',
            children: [
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(
                  'Suman Sir is a highly experienced English teacher who has guided over 500 students to excel in their board exams and competitive tests. Known for his simplified teaching methods, he makes complex topics like Macbeth, grammar, and essay writing easy to understand.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    fontFamily: 'Poppins',
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Social links
          _infoCard(
            isDark: isDark,
            icon: Icons.link_rounded,
            title: 'Connect with Suman Sir',
            children: [
              SizedBox(height: 8.h),
              Row(
                children: [
                  _socialBtn('YouTube', const Color(0xFFFF0000),
                      Icons.play_circle_filled_rounded,
                      'https://youtube.com/@sumansirengacademy'),
                  SizedBox(width: 10.w),
                  _socialBtn('WhatsApp', const Color(0xFF25D366),
                      Icons.chat_rounded,
                      'https://wa.me/919876543210'),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  _socialBtn('Telegram', const Color(0xFF0088CC),
                      Icons.send_rounded,
                      'https://t.me/sumansirengacademy'),
                  SizedBox(width: 10.w),
                  _socialBtn('Facebook', const Color(0xFF1877F2),
                      Icons.facebook_rounded,
                      'https://facebook.com/sumansirengacademy'),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Logout & privacy
          OutlinedButton.icon(
            onPressed: () async {
              final confirm = await Get.dialog<bool>(
                AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
                    ElevatedButton(onPressed: () => Get.back(result: true), child: const Text('Logout')),
                  ],
                ),
              );
              if (confirm == true) AuthService.instance.signOut();
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              minimumSize: Size(double.infinity, 48.h),
            ),
          ),
          SizedBox(height: 8.h),
          TextButton(
            onPressed: () {},
            child: Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Version 1.0.0 • Suman Sir English Academy',
            style: TextStyle(
              fontSize: 11.sp,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );

    if (isTab) return body;
    return Scaffold(appBar: AppBar(title: const Text('About')), body: body);
  }

  Widget _statPill(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          fontFamily: 'Poppins',
          height: 1.4,
        ),
      ),
    );
  }

  Widget _infoCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 18.w),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ...children,
        ],
      ),
    );
  }

  Widget _bulletItem(String text, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_rounded, size: 14.w, color: AppColors.success),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontFamily: 'Poppins',
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialBtn(String label, Color color, IconData icon, String url) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18.w),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
