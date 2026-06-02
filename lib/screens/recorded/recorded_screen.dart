// lib/screens/recorded/recorded_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../services/course_service.dart';
import '../../models/course_model.dart';
import '../../config/routes.dart';

class RecordedScreen extends StatefulWidget {
  final String courseId;
  final bool isEmbedded;

  const RecordedScreen({
    super.key,
    this.courseId = '',
    this.isEmbedded = false,
  });

  @override
  State<RecordedScreen> createState() => _RecordedScreenState();
}

class _RecordedScreenState extends State<RecordedScreen> {
  List<FolderModel> _folders = [];
  Map<String, List<VideoModel>> _videosByFolder = {};
  final Set<String> _expandedFolders = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.courseId.isNotEmpty) _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final folders =
          await CourseService.instance.getCourseFolders(widget.courseId);
      final Map<String, List<VideoModel>> map = {};
      for (final f in folders) {
        final videos = await CourseService.instance.getFolderVideos(f.id);
        map[f.id] = videos;
      }
      setState(() {
        _folders = folders;
        _videosByFolder = map;
        _loading = false;
        if (folders.isNotEmpty) _expandedFolders.add(folders.first.id);
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget body = _loading
        ? const Center(child: CircularProgressIndicator())
        : _folders.isEmpty
            ? _emptyState(isDark)
            : ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: _folders.length,
                itemBuilder: (_, i) =>
                    _folderTile(_folders[i], isDark),
              );

    if (widget.isEmbedded) return body;

    return Scaffold(
      appBar: AppBar(title: const Text('Recorded Classes')),
      body: body,
    );
  }

  Widget _folderTile(FolderModel folder, bool isDark) {
    final isExpanded = _expandedFolders.contains(folder.id);
    final videos = _videosByFolder[folder.id] ?? [];

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14.r),
            onTap: () => setState(() {
              if (isExpanded) {
                _expandedFolders.remove(folder.id);
              } else {
                _expandedFolders.add(folder.id);
              }
            }),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 14.w, vertical: 14.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      isExpanded
                          ? Icons.folder_open_rounded
                          : Icons.folder_rounded,
                      color: AppColors.primary,
                      size: 20.w,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          folder.title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
                          '${videos.length} videos',
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
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    size: 22.w,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Divider(
              height: 1,
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
            ...videos.asMap().entries.map(
                  (e) => _videoTile(e.value, e.key, isDark, videos),
                ),
          ],
        ],
      ),
    );
  }

  Widget _videoTile(
      VideoModel video, int index, bool isDark, List<VideoModel> allVideos) {
    return InkWell(
      onTap: () => Get.toNamed(
        AppRoutes.videoPlayer,
        arguments: {
          'video': video,
          'playlist': allVideos,
          'initialIndex': index,
        },
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      if (video.duration > 0) ...[
                        Icon(Icons.access_time_rounded,
                            size: 11.w,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                        SizedBox(width: 3.w),
                        Text(
                          video.durationFormatted,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(width: 8.w),
                      ],
                      if (video.isYouTube)
                        _tag('YouTube', const Color(0xFFFF0000)),
                      if (video.pdfUrl != null)
                        _tag('PDF', AppColors.warning),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            // Action icons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (video.isDownloadable)
                  Icon(Icons.download_rounded,
                      size: 18.w,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
                SizedBox(width: 4.w),
                Icon(Icons.play_circle_filled_rounded,
                    size: 28.w, color: AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      margin: EdgeInsets.only(right: 4.w),
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w700,
          color: color,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _emptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.video_library_outlined,
              size: 60.w,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight),
          SizedBox(height: 12.h),
          Text(
            'No recorded classes yet',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Videos will appear here once uploaded',
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
}
