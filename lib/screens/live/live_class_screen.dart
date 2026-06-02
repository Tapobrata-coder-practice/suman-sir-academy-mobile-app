// lib/screens/live/live_class_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../theme/app_theme.dart';
import '../../services/course_service.dart';
import '../../services/auth_service.dart';
import '../../models/course_model.dart';
import '../../widgets/section_header.dart';

class LiveClassScreen extends StatefulWidget {
  final String courseId;
  final String batchId;
  final bool isEmbedded;

  const LiveClassScreen({
    super.key,
    this.courseId = '',
    this.batchId = '',
    this.isEmbedded = false,
  });

  @override
  State<LiveClassScreen> createState() => _LiveClassScreenState();
}

class _LiveClassScreenState extends State<LiveClassScreen> {
  YoutubePlayerController? _ytController;
  bool _isFullscreen = false;

  @override
  void dispose() {
    _ytController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget body = SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLiveNowCard(isDark),
          SizedBox(height: 20.h),
          SectionHeader(title: 'Upcoming Classes'),
          SizedBox(height: 12.h),
          _buildUpcomingClasses(isDark),
          SizedBox(height: 20.h),
          _buildClassRules(isDark),
        ],
      ),
    );

    if (widget.isEmbedded) return body;

    return Scaffold(
      appBar: AppBar(title: const Text('Live Classes')),
      body: body,
    );
  }

  Widget _buildLiveNowCard(bool isDark) {
    return StreamBuilder<LiveClassModel?>(
      stream: CourseService.instance.getLiveClass(widget.batchId),
      builder: (context, snapshot) {
        final live = snapshot.data;

        if (live == null) {
          return Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondaryLight.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.live_tv_outlined,
                    size: 36.w,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'No Live Class Right Now',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Check the schedule below for upcoming classes',
                  textAlign: TextAlign.center,
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
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LIVE badge
            Row(
              children: [
                _pulseLiveBadge(),
                SizedBox(width: 8.w),
                Text(
                  live.title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // YouTube player or Meet link
            if (live.youtubeStreamId != null) ...[
              _buildYouTubePlayer(live.youtubeStreamId!),
            ] else if (live.meetLink != null) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A56DB), Color(0xFF00C9A7)],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    Icon(Icons.videocam_rounded,
                        color: Colors.white, size: 40.w),
                    SizedBox(height: 8.h),
                    Text(
                      'Class is Live!',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: 14.h),
                    ElevatedButton.icon(
                      onPressed: () => _launchUrl(live.meetLink!),
                      icon: const Icon(Icons.open_in_new_rounded,
                          color: Colors.white),
                      label: Text(
                        'Join Live Class',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 1.5),
                        minimumSize: Size(double.infinity, 48.h),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildYouTubePlayer(String videoId) {
    _ytController ??= YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        isLive: true,
      ),
    );

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: YoutubePlayer(
            controller: _ytController!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: AppColors.primary,
            onReady: () {},
          ),
        ),
        // Student watermark
        Positioned(
          bottom: 8.h,
          right: 8.w,
          child: Opacity(
            opacity: 0.55,
            child: Text(
              AuthService.instance.userName,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.7),
                    offset: const Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingClasses(bool isDark) {
    return FutureBuilder<List<LiveClassModel>>(
      future: CourseService.instance
          .getUpcomingLiveClasses(widget.batchId),
      builder: (context, snapshot) {
        final classes = snapshot.data ?? [];

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (classes.isEmpty) {
          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Center(
              child: Text(
                'No upcoming classes scheduled yet',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          );
        }

        return Column(
          children: classes.map((cls) => _scheduleCard(cls, isDark)).toList(),
        );
      },
    );
  }

  Widget _scheduleCard(LiveClassModel cls, bool isDark) {
    final now = DateTime.now();
    final diff = cls.scheduledAt.difference(now);
    final isToday = cls.scheduledAt.day == now.day &&
        cls.scheduledAt.month == now.month;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isToday
              ? AppColors.primary.withOpacity(0.4)
              : isDark
                  ? AppColors.borderDark
                  : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('d').format(cls.scheduledAt),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    fontFamily: 'Poppins',
                    height: 1,
                  ),
                ),
                Text(
                  DateFormat('MMM').format(cls.scheduledAt),
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: AppColors.primary,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cls.title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  DateFormat('hh:mm a').format(cls.scheduledAt),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          if (isToday)
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                'Today',
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
    );
  }

  Widget _buildClassRules(bool isDark) {
    final rules = [
      'Join 5 minutes before the scheduled time.',
      'Keep your phone on silent during the session.',
      'Submit doubts using the Doubt section.',
      'Recordings are available in the Recorded tab after class.',
    ];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.info.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: AppColors.info, size: 16.w),
              SizedBox(width: 6.w),
              Text(
                'Class Guidelines',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.info,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ...rules.map((r) => Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ',
                        style: TextStyle(
                            color: AppColors.info, fontSize: 13.sp)),
                    Expanded(
                      child: Text(
                        r,
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
              )),
        ],
      ),
    );
  }

  Widget _pulseLiveBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            'LIVE',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFamily: 'Poppins',
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
