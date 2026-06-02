// lib/widgets/course_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/course_model.dart';
import '../theme/app_theme.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onTap;

  const CourseCard({super.key, required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 185.w,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          boxShadow: isDark
              ? []
              : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: course.thumbnailUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: course.thumbnailUrl,
                      height: 100.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _shimmerBox(185.w, 100.h),
                      errorWidget: (_, __, ___) => _defaultThumbnail(),
                    )
                  : _defaultThumbnail(),
            ),
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      if (course.hasDiscount)
                        Text(
                          '₹${course.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.textSecondaryLight,
                            decoration: TextDecoration.lineThrough,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      if (course.hasDiscount) SizedBox(width: 4.w),
                      Text(
                        '₹${course.effectivePrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  if (course.hasDiscount) ...[
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        '${course.discountPercent}% OFF',
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultThumbnail() {
    return Container(
      height: 100.h,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A56DB), Color(0xFF00C9A7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(Icons.play_lesson_rounded, color: Colors.white.withOpacity(0.6), size: 36.w),
      ),
    );
  }

  Widget _shimmerBox(double w, double h) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(width: w, height: h, color: Colors.white),
    );
  }
}

// ─────────────────────────────────────────────────
// lib/widgets/course_card_full.dart
// ─────────────────────────────────────────────────

class CourseCardFull extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onTap;

  const CourseCardFull({super.key, required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          boxShadow: isDark
              ? []
              : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(16.r)),
              child: course.thumbnailUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: course.thumbnailUrl,
                      width: 90.w,
                      height: 90.h,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _thumb(),
                    )
                  : _thumb(),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          child: Text(
                            course.type.name == 'monthly' ? 'Monthly' : 'Full Course',
                            style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w700, color: AppColors.primary, fontFamily: 'Poppins'),
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios_rounded, size: 12.w, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      course.title,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(Icons.play_circle_outline_rounded, size: 12.w, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        SizedBox(width: 3.w),
                        Text('${course.totalVideos} videos', style: TextStyle(fontSize: 10.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontFamily: 'Poppins')),
                        SizedBox(width: 8.w),
                        Icon(Icons.picture_as_pdf_outlined, size: 12.w, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        SizedBox(width: 3.w),
                        Text('${course.totalPdfs} PDFs', style: TextStyle(fontSize: 10.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontFamily: 'Poppins')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumb() {
    return Container(
      width: 90.w,
      height: 90.h,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A56DB), Color(0xFF00C9A7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(child: Icon(Icons.school_rounded, color: Colors.white.withOpacity(0.6), size: 28.w)),
    );
  }
}
