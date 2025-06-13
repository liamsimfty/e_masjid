import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HeaderSection extends StatelessWidget {
  final VoidCallback onRefresh;
  final AnimationController refreshController;

  const HeaderSection({
    super.key,
    required this.onRefresh,
    required this.refreshController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lihat',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Status Permohonan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16.r),
                onTap: onRefresh,
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: AnimatedBuilder(
                    animation: refreshController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: refreshController.value * 2 * math.pi,
                        child: Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
