// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../services/course_service.dart';
import '../../models/course_model.dart';
import '../../config/routes.dart';
import '../../widgets/course_card.dart';
import '../../widgets/section_header.dart';
import '../courses/my_courses_screen.dart';
import '../demo/demo_classes_screen.dart';
import '../doubts/doubts_screen.dart';
import '../about/about_screen.dart';
import '../mocktest/mocktest_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  int _currentBannerIndex = 0;

  final _screens = [
    const _HomeTab(),
    const MyCoursesScreen(isTab: true),
    const MocktestListScreen(isTab: true),
    const DoubtsScreen(isTab: true),
    const AboutScreen(isTab: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentNavIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (i) => setState(() => _currentNavIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline_rounded),
            activeIcon: Icon(Icons.play_circle_rounded),
            label: 'My Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz_outlined),
            activeIcon: Icon(Icons.quiz_rounded),
            label: 'Mock Test',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline_rounded),
            activeIcon: Icon(Icons.help_rounded),
            label: 'Doubts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'About',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => __HomeTabState();
}

class __HomeTabState extends State<_HomeTab> {
  int _bannerIndex = 0;
  final _auth = AuthService.instance;
  final _courseService = CourseService.instance;

  final List<Map<String, String>> _testimonials = [
    {
      'name': 'Priya Sharma',
      'text': 'Suman Sir\'s teaching style made Macbeth so easy to understand. Scored 92 in board exams!',
      'result': '92/100',
    },
    {
      'name': 'Rahul Das',
      'text': 'The live classes and recorded sessions together are a game-changer. Highly recommended!',
      'result': '89/100',
    },
    {
      'name': 'Anita Roy',
      'text': 'Best English coaching I\'ve attended. The mock tests helped me practice extensively.',
      'result': '95/100',
    },
    {
      'name': 'Sourav Mondal',
      'text': 'Doubt-solving feature is amazing! My queries get answered so quickly.',
      'result': '88/100',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: isDark ? AppColors.bgDark : AppColors.surfaceLight,
            title: Row(
              children: [
                Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Text(
                      'SE',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Hello, ${_auth.userName.split(' ').first} 👋',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          'Suman Sir English Academy',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    )),
              ],
            ),
            actions: [
              Obx(() => Stack(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.notifications_outlined,
                          size: 26.w,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                        onPressed: () => Get.toNamed(AppRoutes.notifications),
                      ),
                      if (NotificationService.instance.unreadCount.value > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  )),
              SizedBox(width: 4.w),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Slider
                _buildBannerSlider(isDark),

                SizedBox(height: 20.h),

                // Quick access menu
                _buildQuickMenu(isDark),

                SizedBox(height: 24.h),

                // All courses section
                SectionHeader(
                  title: 'Available Courses',
                  actionText: 'View All',
                  onActionTap: () => Get.toNamed(AppRoutes.myCourses),
                ),
                SizedBox(height: 12.h),
                _buildCoursesList(),

                SizedBox(height: 24.h),

                // Demo Classes
                _buildDemoSection(isDark),

                SizedBox(height: 24.h),

                // Testimonials
                SectionHeader(title: 'Student Success Stories'),
                SizedBox(height: 12.h),
                _buildTestimonials(isDark),

                SizedBox(height: 32.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSlider(bool isDark) {
    return StreamBuilder<List<CourseModel>>(
      stream: CourseService.instance.getAllCourses(),
      builder: (context, snapshot) {
        final courses = snapshot.data ?? [];
        final banners = courses
            .where((c) => c.bannerImageUrl != null)
            .take(5)
            .toList();

        if (banners.isEmpty) {
          return _buildDefaultBanner(isDark);
        }

        return Column(
          children: [
            CarouselSlider.builder(
              itemCount: banners.length,
              itemBuilder: (context, index, _) {
                final course = banners[index];
                return GestureDetector(
                  onTap: () => Get.toNamed(
                    AppRoutes.payment,
                    arguments: {'course': course},
                  ),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      gradient: AppColors.primaryGradient,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: CachedNetworkImage(
                        imageUrl: course.bannerImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            _bannerShimmer(),
                        errorWidget: (_, __, ___) => _defaultBannerContent(course, isDark),
                      ),
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                height: 170.h,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                enlargeCenterPage: true,
                enlargeFactor: 0.1,
                viewportFraction: 0.88,
                onPageChanged: (index, _) =>
                    setState(() => _bannerIndex = index),
              ),
            ),
            SizedBox(height: 10.h),
            AnimatedSmoothIndicator(
              activeIndex: _bannerIndex,
              count: banners.length,
              effect: ExpandingDotsEffect(
                activeDotColor: AppColors.primary,
                dotColor: AppColors.primary.withOpacity(0.25),
                dotHeight: 6.h,
                dotWidth: 6.w,
                expansionFactor: 3,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDefaultBanner(bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      height: 160.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A56DB), Color(0xFF00C9A7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Master English\nwith Suman Sir',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'Explore Courses →',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMenu(bool isDark) {
    final items = [
      {'icon': Icons.live_tv_rounded, 'label': 'Live\nClass', 'route': AppRoutes.liveClass, 'color': const Color(0xFFEF4444)},
      {'icon': Icons.video_library_rounded, 'label': 'Recorded\nClasses', 'route': AppRoutes.myCourses, 'color': const Color(0xFF8B5CF6)},
      {'icon': Icons.quiz_rounded, 'label': 'Mock\nTest', 'route': AppRoutes.mocktestList, 'color': const Color(0xFFF59E0B)},
      {'icon': Icons.play_lesson_rounded, 'label': 'Demo\nClass', 'route': AppRoutes.demo, 'color': const Color(0xFF10B981)},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: items.map((item) {
          return Expanded(
            child: GestureDetector(
              onTap: () => Get.toNamed(item['route'] as String),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: (item['color'] as Color).withOpacity(0.15),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: item['color'] as Color,
                      size: 26.w,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      item['label'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontFamily: 'Poppins',
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCoursesList() {
    return StreamBuilder<List<CourseModel>>(
      stream: CourseService.instance.getAllCourses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 200.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: 3,
              itemBuilder: (_, __) => Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 200.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        final courses = snapshot.data ?? [];
        if (courses.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Center(
              child: Text(
                'No courses available yet',
                style: TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontSize: 13.sp,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          );
        }

        return SizedBox(
          height: 210.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: courses.length,
            itemBuilder: (_, i) => Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: CourseCard(
                course: courses[i],
                onTap: () => Get.toNamed(
                  AppRoutes.payment,
                  arguments: {'course': courses[i]},
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDemoSection(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.demo),
        child: Container(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFFF6B35)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.play_circle_filled_rounded,
                  color: Colors.white,
                  size: 28.w,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Try Free Demo Classes',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      'Watch sample lectures before enrolling',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white.withOpacity(0.85),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.8),
                size: 16.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestimonials(bool isDark) {
    return SizedBox(
      height: 150.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _testimonials.length,
        itemBuilder: (context, i) {
          final t = _testimonials[i];
          return Container(
            width: 240.w,
            margin: EdgeInsets.only(right: 12.w),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16.r,
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      child: Text(
                        t['name']![0],
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        t['name']!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        t['result']!,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(Icons.star_rounded,
                        color: AppColors.warning, size: 12.w),
                  ),
                ),
                SizedBox(height: 6.h),
                Expanded(
                  child: Text(
                    '"${t['text']!}"',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      fontFamily: 'Poppins',
                      height: 1.4,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _bannerShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(color: Colors.white),
    );
  }

  Widget _defaultBannerContent(CourseModel course, bool isDark) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A56DB), Color(0xFF00C9A7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            course.title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '₹${course.effectivePrice.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
