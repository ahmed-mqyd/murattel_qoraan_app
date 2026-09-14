import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// معرّف التطبيق على متجر Google Play
const String _playStorePackageId = 'com.murattel.quraan.murattel_qoraan_app';

const String playStoreUrl =
    'https://play.google.com/store/apps/details?id=$_playStorePackageId';

void _showLinkError() {
  Get.snackbar(
    'مرتل القرآن',
    'تعذر فتح الرابط، يرجى المحاولة مرة أخرى',
    snackPosition: SnackPosition.TOP,
    backgroundColor: Colors.red.withValues(alpha: 0.9),
    colorText: Colors.white,
  );
}

/// يفتح صفحة التطبيق على متجر Google Play للتقييم، مفضّلاً فتح تطبيق
/// Play Store مباشرة (market://) قبل الرجوع إلى المتصفح كحل بديل
Future<void> rateApp() async {
  try {
    final Uri marketUri = Uri.parse('market://details?id=$_playStorePackageId');
    if (await canLaunchUrl(marketUri)) {
      await launchUrl(marketUri);
      return;
    }
    await launchUrl(
      Uri.parse(playStoreUrl),
      mode: LaunchMode.externalApplication,
    );
  } catch (e) {
    _showLinkError();
  }
}

/// يفتح قائمة المشاركة في النظام لمشاركة رابط التطبيق على متجر Google Play
Future<void> shareApp() async {
  try {
    await Share.share(
      'تطبيق "مرتل القرآن" 🕌\nتلاوة وتدبّر القرآن الكريم، أذكار، مواقيت الصلاة، والمزيد:\n$playStoreUrl',
    );
  } catch (e) {
    _showLinkError();
  }
}
