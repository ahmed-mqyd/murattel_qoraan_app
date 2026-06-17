import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:murattel_qoraan_app/core/animated_fade_in/animated_fade_in_wedget.dart';
import 'package:murattel_qoraan_app/core/images/images_const.dart';
import 'package:murattel_qoraan_app/core/text_app/text_app.dart';
import '../controller/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF052219), Color(0xFF02160F)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main content in center
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo Container
                    FadeIn(
                      duration: const Duration(milliseconds: 1000),
                      slideOffset: 30.0,
                      startScale: 0.9,
                      child: Container(
                        width: 180.w,
                        height: 180.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 20.r,
                              offset: Offset(0, 10.h),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: Padding(
                            padding: EdgeInsets.all(4.w),
                            child: Image.asset(
                              appLogo,
                              // 'assets/images/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 40.h),

                    // English App Name
                    FadeIn(
                      duration: const Duration(milliseconds: 1000),
                      delay: const Duration(milliseconds: 300),
                      slideOffset: 20.0,
                      child: Text(
                        'MURATTEL QURAAN',
                        style: GoogleFonts.cinzel(
                          textStyle: TextStyle(
                            color: const Color(0xFFC5A059),
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0.w,
                          ),
                        ),
                      ),
                    ),

                    // Small divider
                    FadeIn(
                      duration: const Duration(milliseconds: 1000),
                      delay: const Duration(milliseconds: 500),
                      child: Container(
                        width: 50.w,
                        height: 1.h,
                        margin: EdgeInsets.symmetric(vertical: 16.h),
                        color: const Color(0xFFC5A059).withValues(alpha: 0.4),
                      ),
                    ),

                    // Arabic App Name
                    FadeIn(
                      duration: const Duration(milliseconds: 1000),
                      delay: const Duration(milliseconds: 600),
                      slideOffset: -20.0,
                      child: TextApp(
                        text: 'مرتل القرآن',
                        color: const Color(0xFFC5A059),
                        fontSize: 34.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom content (Sadaqah Jariyah and Spinner)
              Positioned(
                bottom: 40.h,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 24.h),
                    SpinKitThreeBounce(
                      color: const Color(0xFFC5A059),
                      size: 16.w,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
