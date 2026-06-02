import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../models/course_model.dart';
import '../../config/routes.dart';

class DemoClassesScreen extends StatelessWidget {
  const DemoClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Free Demo Classes')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('videos').where('folderId', isEqualTo: 'demo').orderBy('orderIndex').snapshots(),
        builder: (context, snap) {
          final videos = snap.data?.docs.map((d) => VideoModel.fromFirestore(d)).toList() ?? [];
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFFF6B35)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.play_circle_filled_rounded, color: Colors.white, size: 36.w),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Watch Before You Enroll', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Poppins')),
                          Text("Get a taste of Suman Sir's teaching — completely free!", style: TextStyle(fontSize: 11.sp, color: Colors.white.withOpacity(0.85), fontFamily: 'Poppins')),
                        ]),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Text('${videos.length} Free Videos', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                SizedBox(height: 12.h),
                if (videos.isEmpty)
                  Center(child: Padding(padding: EdgeInsets.all(32.w), child: Text('Demo videos coming soon!', style: TextStyle(fontSize: 14.sp, fontFamily: 'Poppins', color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight))))
                else
                  ...videos.asMap().entries.map((e) {
                    final v = e.value;
                    return GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.videoPlayer, arguments: {'video': v, 'playlist': videos, 'initialIndex': e.key}),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10.h),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(color: isDark ? AppColors.cardDark : AppColors.cardLight, borderRadius: BorderRadius.circular(14.r), border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
                        child: Row(
                          children: [
                            Container(width: 52.w, height: 52.w, decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(10.r)), child: Icon(Icons.play_circle_rounded, color: AppColors.secondary, size: 28.w)),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(v.title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight), maxLines: 2, overflow: TextOverflow.ellipsis),
                                SizedBox(height: 3.h),
                                Row(children: [
                                  Container(padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h), decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(4.r)), child: Text('FREE', style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppColors.success, fontFamily: 'Poppins'))),
                                  if (v.duration > 0) ...[SizedBox(width: 6.w), Text(v.durationFormatted, style: TextStyle(fontSize: 11.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontFamily: 'Poppins'))],
                                ]),
                              ]),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded, size: 14.w, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}
