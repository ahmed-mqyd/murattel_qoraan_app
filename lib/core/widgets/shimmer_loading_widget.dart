import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class CustomShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  const CustomShimmerWidget.rectangular({
    super.key,
    this.width = double.infinity,
    required this.height,
    double borderRadius = 12,
  }) : shapeBorder = const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        );

  const CustomShimmerWidget.circular({
    super.key,
    required this.width,
    required this.height,
  }) : shapeBorder = const CircleBorder();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF0A2E23) : Colors.grey[300]!;
    final highlightColor = isDark ? const Color(0xFF144D3B) : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: baseColor,
          shape: shapeBorder,
        ),
      ),
    );
  }
}

class PrayerTimesShimmerLoading extends StatelessWidget {
  const PrayerTimesShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          // Next Prayer Card Shimmer
          CustomShimmerWidget.rectangular(
            height: 160.h,
            borderRadius: 20.r,
          ),
          SizedBox(height: 32.h),

          // 6 Prayer Items Shimmers
          for (int i = 0; i < 6; i++) ...[
            CustomShimmerWidget.rectangular(
              height: 56.h,
              borderRadius: 12.r,
            ),
            SizedBox(height: 12.h),
          ],
        ],
      ),
    );
  }
}
