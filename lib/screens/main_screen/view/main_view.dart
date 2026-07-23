import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';
import 'package:murattel_qoraan_app/core/text_app/text_app.dart';
import '../controller/main_controller.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return PopScope(
      // نمنع الخروج التلقائي ونتحكم نحن فيه
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final now = DateTime.now();
        final lastPress = controller.lastBackPressTime;
        final bool isSecondPress =
            lastPress != null &&
            now.difference(lastPress) < const Duration(seconds: 2);

        if (isSecondPress) {
          // ضغطتين خلال ثانيتين → اخرج من التطبيق
          SystemNavigator.pop();
        } else {
          // ضغطة أولى → أظهر رسالة
          controller.lastBackPressTime = now;
          Get.snackbar(
            '',
            '',
            titleText: const SizedBox.shrink(),
            messageText: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.exit_to_app_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'اضغط مرة أخرى للخروج من التطبيق',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF003527).withValues(alpha: 0.95),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            borderRadius: 16,
            duration: const Duration(seconds: 2),
            isDismissible: false,
            forwardAnimationCurve: Curves.easeOutBack,
          );
        }
      },
      child: Scaffold(
        key: scaffoldKey,
        drawer: const Drawer(), // Side menu left empty/default for now
        body: SafeArea(
          child: Stack(
            children: [
              // Active Tab Content
              Positioned.fill(
                child: Obx(
                  () => controller.pages[controller.currentIndex.value],
                ),
              ),

              // Drawer Trigger Icon (Top right of the screen for RTL)
              Positioned(
                top: 16.h,
                right: 16.w,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF003527).withValues(alpha: 0.4),
                    border: Border.all(
                      color: const Color(0xFFC5A059).withValues(alpha: 0.3),
                      width: 1.w,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.menu_rounded,
                      color: const Color(0xFFC5A059),
                      size: 24.r,
                    ),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Obx(() {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final Color navBgColor = isDark
              ? const Color(0xFF052219)
              : const Color(0xFFF9F9FC);
          final Color navBorderColor = isDark
              ? const Color(0xFF204F3F).withValues(alpha: 0.3)
              : const Color(0xFFBFC9C3).withValues(alpha: 0.3);

          return SizedBox(
            height: 85.h,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Bottom background navigation bar
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 62.h,
                  child: Container(
                    decoration: BoxDecoration(
                      color: navBgColor,
                      border: Border(
                        top: BorderSide(color: navBorderColor, width: 1.w),
                      ),
                    ),
                  ),
                ),
                // Navigation Items
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  top: 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(controller.pages.length, (index) {
                        return _buildNavItem(
                          context,
                          index,
                          controller.pageIcons[index],
                          controller.pageNames[index],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    final bool isActive = controller.currentIndex.value == index;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color activeColor = isDark
        ? const Color(0xFFC5A059)
        : const Color(0xFF003527);
    final Color inactiveColor = isDark
        ? Colors.white.withValues(alpha: 0.4)
        : Colors.black.withValues(alpha: 0.4);

    if (index == 2) {
      // Middle circular and large button for 'الرئيسية'
      final Color buttonBgColor = isDark
          ? const Color(0xFF003527)
          : const Color(0xFFE6EFEA);
      final Color activeButtonBgColor = isDark
          ? const Color(0xFF004D3C)
          : const Color(0xFF003527);
      final Color iconColor = isActive
          ? (isDark ? const Color(0xFFC5A059) : Colors.white)
          : (isDark
                ? Colors.white.withValues(alpha: 0.7)
                : const Color(0xFF003527).withValues(alpha: 0.7));

      return Expanded(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            controller.changePage(index);
          },
          child: Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isActive
                          ? [
                              activeButtonBgColor,
                              activeButtonBgColor.withValues(alpha: 0.85),
                            ]
                          : [
                              buttonBgColor,
                              buttonBgColor.withValues(alpha: 0.9),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 8.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFC5A059),
                      width: isActive ? 2.w : 1.w,
                    ),
                  ),
                  child: Center(
                    child: Icon(icon, color: iconColor, size: 28.r),
                  ),
                ),
                TextApp(
                  text: label,
                  color: isActive ? activeColor : inactiveColor,
                  fontSize: 10.sp,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          controller.changePage(index);
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 24.w,
                height: 3.h,
                margin: EdgeInsets.only(bottom: 6.h),
                decoration: BoxDecoration(
                  color: isActive ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(1.5.r),
                ),
              ),
              Icon(
                icon,
                color: isActive ? activeColor : inactiveColor,
                size: 24.r,
              ),
              SizedBox(height: 4.h),
              TextApp(
                text: label,

                color: isActive ? activeColor : inactiveColor,
                fontSize: 10.sp,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
