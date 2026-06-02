// lib/screens/recorded/video_player_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../theme/app_theme.dart';
import '../../models/course_model.dart';
import '../../services/auth_service.dart';
import '../../services/course_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoModel _video;
  late List<VideoModel> _playlist;
  late int _currentIndex;

  YoutubePlayerController? _ytController;
  VideoPlayerController? _vpController;
  ChewieController? _chewieController;

  double _playbackSpeed = 1.0;
  final List<double> _speeds = [0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    _video = args['video'] as VideoModel;
    _playlist = (args['playlist'] as List?)?.cast<VideoModel>() ?? [_video];
    _currentIndex = args['initialIndex'] as int? ?? 0;

    WakelockPlus.enable();
    _initPlayer();
  }

  void _initPlayer() {
    _disposeControllers();

    if (_video.isYouTube) {
      _ytController = YoutubePlayerController(
        initialVideoId: _video.youtubeId!,
        flags: YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          controlsVisibleAtStart: true,
          forceHD: false,
        ),
      );
    } else if (_video.firebaseUrl != null) {
      _vpController = VideoPlayerController.networkUrl(
        Uri.parse(_video.firebaseUrl!),
      );
      _vpController!.initialize().then((_) {
        _chewieController = ChewieController(
          videoPlayerController: _vpController!,
          autoPlay: true,
          looping: false,
          allowPlaybackSpeedChanging: true,
          playbackSpeeds: _speeds,
          allowFullScreen: true,
          allowMuting: true,
          showControls: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: AppColors.primary,
            handleColor: AppColors.primary,
            bufferedColor: AppColors.primary.withOpacity(0.3),
            backgroundColor: Colors.grey.withOpacity(0.3),
          ),
        );
        setState(() {});
      });
    }

    // Track progress
    _trackWatchStart();
  }

  void _trackWatchStart() {
    final userId = AuthService.instance.userId;
    if (userId.isNotEmpty) {
      CourseService.instance.updateWatchProgress(userId, _video.id, 0.01);
    }
  }

  void _disposeControllers() {
    _ytController?.dispose();
    _ytController = null;
    _chewieController?.dispose();
    _chewieController = null;
    _vpController?.dispose();
    _vpController = null;
  }

  @override
  void dispose() {
    _disposeControllers();
    WakelockPlus.disable();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _switchVideo(int index) {
    if (index < 0 || index >= _playlist.length) return;
    setState(() {
      _currentIndex = index;
      _video = _playlist[index];
    });
    _initPlayer();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Video player area
            _buildPlayerSection(),

            // Below player content
            Expanded(
              child: Container(
                color:
                    isDark ? AppColors.bgDark : AppColors.bgLight,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(14.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildVideoInfo(isDark),
                      SizedBox(height: 14.h),
                      _buildActionBar(isDark),
                      SizedBox(height: 14.h),
                      if (_video.isYouTube) _buildSpeedControl(isDark),
                      SizedBox(height: 14.h),
                      _buildPlaylistSection(isDark),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerSection() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Back button
          Positioned(
            top: 8.h,
            left: 8.w,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ),

          // Player
          if (_video.isYouTube && _ytController != null)
            YoutubePlayer(
              controller: _ytController!,
              showVideoProgressIndicator: true,
              progressIndicatorColor: AppColors.primary,
              onReady: () => _ytController!
                  .setPlaybackRate(_playbackSpeed),
            )
          else if (_chewieController != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Chewie(controller: _chewieController!),
            )
          else
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primary),
                ),
              ),
            ),

          // Watermark overlay
          Positioned(
            bottom: 20.h,
            right: 12.w,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.5,
                child: Text(
                  AuthService.instance.userName,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.8),
                        blurRadius: 3,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoInfo(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _video.title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
            fontFamily: 'Poppins',
          ),
        ),
        if (_video.description != null) ...[
          SizedBox(height: 4.h),
          Text(
            _video.description!,
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
      ],
    );
  }

  Widget _buildActionBar(bool isDark) {
    return Row(
      children: [
        if (_video.pdfUrl != null)
          _actionBtn(
            icon: Icons.picture_as_pdf_rounded,
            label: 'PDF',
            color: AppColors.error,
            onTap: () => _launchUrl(_video.pdfUrl!),
            isDark: isDark,
          ),
        if (_video.externalLink != null) ...[
          SizedBox(width: 10.w),
          _actionBtn(
            icon: Icons.open_in_new_rounded,
            label: 'Link',
            color: AppColors.info,
            onTap: () => _launchUrl(_video.externalLink!),
            isDark: isDark,
          ),
        ],
        if (_video.isDownloadable) ...[
          SizedBox(width: 10.w),
          _actionBtn(
            icon: Icons.download_rounded,
            label: 'Download',
            color: AppColors.success,
            onTap: _downloadVideo,
            isDark: isDark,
          ),
        ],
      ],
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16.w),
            SizedBox(width: 5.w),
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
    );
  }

  Widget _buildSpeedControl(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Playback Speed',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: _speeds.map((s) {
            final isSelected = _playbackSpeed == s;
            return GestureDetector(
              onTap: () {
                setState(() => _playbackSpeed = s);
                _ytController?.setPlaybackRate(s);
                _vpController?.setPlaybackSpeed(s);
              },
              child: Container(
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.symmetric(
                    horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  '${s}x',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? Colors.white
                        : AppColors.primary,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPlaylistSection(bool isDark) {
    if (_playlist.length <= 1) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Up Next (${_playlist.length} videos)',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 10.h),
        ...List.generate(_playlist.length, (i) {
          final v = _playlist[i];
          final isCurrent = i == _currentIndex;
          return GestureDetector(
            onTap: () => _switchVideo(i),
            child: Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.primary.withOpacity(0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: isCurrent
                      ? AppColors.primary.withOpacity(0.3)
                      : isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCurrent
                          ? Icon(Icons.pause_rounded,
                              size: 14.w, color: Colors.white)
                          : Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      v.title,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: isCurrent
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isCurrent
                            ? AppColors.primary
                            : isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (v.duration > 0)
                    Text(
                      v.durationFormatted,
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
        }),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _downloadVideo() {
    Get.snackbar(
      'Download',
      'Download started for "${_video.title}"',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16.w),
      borderRadius: 12.r,
    );
  }
}
