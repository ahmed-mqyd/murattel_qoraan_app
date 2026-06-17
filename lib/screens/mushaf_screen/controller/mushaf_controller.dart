import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum MushafFilterMode { surah, juz, page }

class MushafController extends GetxController {
  final searchQuery = ''.obs;
  late final TextEditingController searchController;

  final filterMode = MushafFilterMode.surah.obs;

  final List<Map<String, dynamic>> surahs = [
    {'id': 1, 'name': 'الفَاتِحَة', 'verses': 7, 'type': 'مكية', 'page': 1, 'progress': 0.75},
    {'id': 2, 'name': 'البَقَرَة', 'verses': 286, 'type': 'مدنية', 'page': 2, 'progress': 0.25},
    {'id': 3, 'name': 'آل عِمرَان', 'verses': 200, 'type': 'مدنية', 'page': 50, 'progress': 0.0},
    {'id': 4, 'name': 'النِّسَاء', 'verses': 176, 'type': 'مدنية', 'page': 77, 'progress': 0.0},
    {'id': 5, 'name': 'المَائِدَة', 'verses': 120, 'type': 'مدنية', 'page': 106, 'progress': 0.0},
    {'id': 6, 'name': 'الأنعَام', 'verses': 165, 'type': 'مكية', 'page': 128, 'progress': 0.0},
    {'id': 7, 'name': 'الأعرَاف', 'verses': 206, 'type': 'مكية', 'page': 151, 'progress': 0.0},
    {'id': 8, 'name': 'الأنفَال', 'verses': 75, 'type': 'مدنية', 'page': 177, 'progress': 0.0},
    {'id': 9, 'name': 'التَّوبَة', 'verses': 129, 'type': 'مدنية', 'page': 187, 'progress': 0.0},
    {'id': 10, 'name': 'يُونُس', 'verses': 109, 'type': 'مكية', 'page': 208, 'progress': 0.0},
    {'id': 11, 'name': 'هُود', 'verses': 123, 'type': 'مكية', 'page': 221, 'progress': 0.0},
    {'id': 12, 'name': 'يُوسُف', 'verses': 111, 'type': 'مكية', 'page': 235, 'progress': 0.0},
    {'id': 13, 'name': 'الرَّعْد', 'verses': 43, 'type': 'مدنية', 'page': 249, 'progress': 0.0},
    {'id': 14, 'name': 'إِبْرَاهِيم', 'verses': 52, 'type': 'مكية', 'page': 255, 'progress': 0.0},
    {'id': 15, 'name': 'الحِجْر', 'verses': 99, 'type': 'مكية', 'page': 262, 'progress': 0.0},
    {'id': 16, 'name': 'النَّحْل', 'verses': 128, 'type': 'مكية', 'page': 267, 'progress': 0.0},
    {'id': 17, 'name': 'الإِسْرَاء', 'verses': 111, 'type': 'مكية', 'page': 282, 'progress': 0.0},
    {'id': 18, 'name': 'الكَهْف', 'verses': 110, 'type': 'مكية', 'page': 293, 'progress': 0.0},
    {'id': 19, 'name': 'مَرْيَم', 'verses': 98, 'type': 'مكية', 'page': 305, 'progress': 0.0},
    {'id': 20, 'name': 'طه', 'verses': 135, 'type': 'مكية', 'page': 312, 'progress': 0.0},
    {'id': 21, 'name': 'الأَنْبِيَاء', 'verses': 112, 'type': 'مكية', 'page': 322, 'progress': 0.0},
    {'id': 22, 'name': 'الحَجّ', 'verses': 78, 'type': 'مدنية', 'page': 332, 'progress': 0.0},
    {'id': 23, 'name': 'المُؤْمِنُون', 'verses': 118, 'type': 'مكية', 'page': 342, 'progress': 0.0},
    {'id': 24, 'name': 'النُّور', 'verses': 64, 'type': 'مدنية', 'page': 350, 'progress': 0.0},
    {'id': 25, 'name': 'الفُرْقَان', 'verses': 77, 'type': 'مكية', 'page': 359, 'progress': 0.0},
    {'id': 26, 'name': 'الشُّعَرَاء', 'verses': 227, 'type': 'مكية', 'page': 367, 'progress': 0.0},
    {'id': 27, 'name': 'النَّمْل', 'verses': 93, 'type': 'مكية', 'page': 377, 'progress': 0.0},
    {'id': 28, 'name': 'القَصَص', 'verses': 88, 'type': 'مكية', 'page': 385, 'progress': 0.0},
    {'id': 29, 'name': 'العَنْكَبُوت', 'verses': 69, 'type': 'مكية', 'page': 396, 'progress': 0.0},
    {'id': 30, 'name': 'الرُّوم', 'verses': 60, 'type': 'مكية', 'page': 404, 'progress': 0.0},
    {'id': 31, 'name': 'لُقْمَان', 'verses': 34, 'type': 'مكية', 'page': 411, 'progress': 0.0},
    {'id': 32, 'name': 'السَّجْدَة', 'verses': 30, 'type': 'مكية', 'page': 415, 'progress': 0.0},
    {'id': 33, 'name': 'الأَحْزَاب', 'verses': 73, 'type': 'مدنية', 'page': 418, 'progress': 0.0},
    {'id': 34, 'name': 'سَبَأ', 'verses': 54, 'type': 'مكية', 'page': 428, 'progress': 0.0},
    {'id': 35, 'name': 'فَاطِر', 'verses': 45, 'type': 'مكية', 'page': 434, 'progress': 0.0},
    {'id': 36, 'name': 'يس', 'verses': 83, 'type': 'مكية', 'page': 440, 'progress': 0.0},
    {'id': 37, 'name': 'الصَّافَّات', 'verses': 182, 'type': 'مكية', 'page': 446, 'progress': 0.0},
    {'id': 38, 'name': 'ص', 'verses': 88, 'type': 'مكية', 'page': 453, 'progress': 0.0},
    {'id': 39, 'name': 'الزُّمَر', 'verses': 75, 'type': 'مكية', 'page': 458, 'progress': 0.0},
    {'id': 40, 'name': 'غَافِر', 'verses': 85, 'type': 'مكية', 'page': 467, 'progress': 0.0},
    {'id': 41, 'name': 'فُصِّلَت', 'verses': 54, 'type': 'مكية', 'page': 477, 'progress': 0.0},
    {'id': 42, 'name': 'الشُّورَى', 'verses': 53, 'type': 'مكية', 'page': 483, 'progress': 0.0},
    {'id': 43, 'name': 'الزُّخْرُف', 'verses': 89, 'type': 'مكية', 'page': 489, 'progress': 0.0},
    {'id': 44, 'name': 'الدُّخَان', 'verses': 59, 'type': 'مكية', 'page': 496, 'progress': 0.0},
    {'id': 45, 'name': 'الجَاثِيَة', 'verses': 37, 'type': 'مكية', 'page': 499, 'progress': 0.0},
    {'id': 46, 'name': 'الأَحْقَاف', 'verses': 35, 'type': 'مكية', 'page': 502, 'progress': 0.0},
    {'id': 47, 'name': 'مُحَمَّد', 'verses': 38, 'type': 'مدنية', 'page': 507, 'progress': 0.0},
    {'id': 48, 'name': 'الفَتْح', 'verses': 29, 'type': 'مدنية', 'page': 511, 'progress': 0.0},
    {'id': 49, 'name': 'الحُجُرَات', 'verses': 18, 'type': 'مدنية', 'page': 515, 'progress': 0.0},
    {'id': 50, 'name': 'ق', 'verses': 45, 'type': 'مكية', 'page': 518, 'progress': 0.0},
    {'id': 51, 'name': 'الذَّارِيَات', 'verses': 60, 'type': 'مكية', 'page': 520, 'progress': 0.0},
    {'id': 52, 'name': 'الطُّور', 'verses': 49, 'type': 'مكية', 'page': 523, 'progress': 0.0},
    {'id': 53, 'name': 'النَّجْم', 'verses': 62, 'type': 'مكية', 'page': 526, 'progress': 0.0},
    {'id': 54, 'name': 'القَمَر', 'verses': 55, 'type': 'مكية', 'page': 528, 'progress': 0.0},
    {'id': 55, 'name': 'الرَّحْمَن', 'verses': 78, 'type': 'مدنية', 'page': 531, 'progress': 0.0},
    {'id': 56, 'name': 'الوَاقِعَة', 'verses': 96, 'type': 'مكية', 'page': 534, 'progress': 0.0},
    {'id': 57, 'name': 'الحَدِيد', 'verses': 29, 'type': 'مدنية', 'page': 537, 'progress': 0.0},
    {'id': 58, 'name': 'المُجَادِلَة', 'verses': 22, 'type': 'مدنية', 'page': 542, 'progress': 0.0},
    {'id': 59, 'name': 'الحَشْر', 'verses': 24, 'type': 'مدنية', 'page': 545, 'progress': 0.0},
    {'id': 60, 'name': 'المُمْتَحَنَة', 'verses': 13, 'type': 'مدنية', 'page': 549, 'progress': 0.0},
    {'id': 61, 'name': 'الصَّفّ', 'verses': 14, 'type': 'مدنية', 'page': 551, 'progress': 0.0},
    {'id': 62, 'name': 'الجُمُعَة', 'verses': 11, 'type': 'مدنية', 'page': 553, 'progress': 0.0},
    {'id': 63, 'name': 'المُنَافِقُون', 'verses': 11, 'type': 'مدنية', 'page': 554, 'progress': 0.0},
    {'id': 64, 'name': 'التَّغَابُن', 'verses': 18, 'type': 'مدنية', 'page': 556, 'progress': 0.0},
    {'id': 65, 'name': 'الطَّلَاق', 'verses': 12, 'type': 'مدنية', 'page': 558, 'progress': 0.0},
    {'id': 66, 'name': 'التَّحْرِيم', 'verses': 12, 'type': 'مدنية', 'page': 560, 'progress': 0.0},
    {'id': 67, 'name': 'المُلْك', 'verses': 30, 'type': 'مكية', 'page': 562, 'progress': 0.0},
    {'id': 68, 'name': 'القَلَم', 'verses': 52, 'type': 'مكية', 'page': 564, 'progress': 0.0},
    {'id': 69, 'name': 'الحَاقَّة', 'verses': 52, 'type': 'مكية', 'page': 566, 'progress': 0.0},
    {'id': 70, 'name': 'المَعَارِج', 'verses': 44, 'type': 'مكية', 'page': 568, 'progress': 0.0},
    {'id': 71, 'name': 'نُوح', 'verses': 28, 'type': 'مكية', 'page': 570, 'progress': 0.0},
    {'id': 72, 'name': 'الجِنّ', 'verses': 28, 'type': 'مكية', 'page': 572, 'progress': 0.0},
    {'id': 73, 'name': 'المُزَّمِّل', 'verses': 20, 'type': 'مكية', 'page': 574, 'progress': 0.0},
    {'id': 74, 'name': 'المُدَّثِّر', 'verses': 56, 'type': 'مكية', 'page': 575, 'progress': 0.0},
    {'id': 75, 'name': 'القِيَامَة', 'verses': 40, 'type': 'مكية', 'page': 577, 'progress': 0.0},
    {'id': 76, 'name': 'الإِنْسَان', 'verses': 31, 'type': 'مدنية', 'page': 578, 'progress': 0.0},
    {'id': 77, 'name': 'المُرْسَلَات', 'verses': 50, 'type': 'مكية', 'page': 580, 'progress': 0.0},
    {'id': 78, 'name': 'النَّبَأ', 'verses': 40, 'type': 'مكية', 'page': 582, 'progress': 0.0},
    {'id': 79, 'name': 'النَّازِعَات', 'verses': 46, 'type': 'مكية', 'page': 583, 'progress': 0.0},
    {'id': 80, 'name': 'عَبَس', 'verses': 42, 'type': 'مكية', 'page': 585, 'progress': 0.0},
    {'id': 81, 'name': 'التَّكْوِير', 'verses': 29, 'type': 'مكية', 'page': 586, 'progress': 0.0},
    {'id': 82, 'name': 'الانْفِطَار', 'verses': 19, 'type': 'مكية', 'page': 587, 'progress': 0.0},
    {'id': 83, 'name': 'المُطَفِّفِين', 'verses': 36, 'type': 'مكية', 'page': 587, 'progress': 0.0},
    {'id': 84, 'name': 'الانْشِقَاق', 'verses': 25, 'type': 'مكية', 'page': 589, 'progress': 0.0},
    {'id': 85, 'name': 'البُرُوج', 'verses': 22, 'type': 'مكية', 'page': 590, 'progress': 0.0},
    {'id': 86, 'name': 'الطَّارِق', 'verses': 17, 'type': 'مكية', 'page': 591, 'progress': 0.0},
    {'id': 87, 'name': 'الأَعْلَى', 'verses': 19, 'type': 'مكية', 'page': 591, 'progress': 0.0},
    {'id': 88, 'name': 'الغَاشِيَة', 'verses': 26, 'type': 'مكية', 'page': 592, 'progress': 0.0},
    {'id': 89, 'name': 'الفَجْر', 'verses': 30, 'type': 'مكية', 'page': 593, 'progress': 0.0},
    {'id': 90, 'name': 'البَلَد', 'verses': 20, 'type': 'مكية', 'page': 594, 'progress': 0.0},
    {'id': 91, 'name': 'الشَّمْس', 'verses': 15, 'type': 'مكية', 'page': 595, 'progress': 0.0},
    {'id': 92, 'name': 'اللَّيْل', 'verses': 21, 'type': 'مكية', 'page': 595, 'progress': 0.0},
    {'id': 93, 'name': 'الضُّحَى', 'verses': 11, 'type': 'مكية', 'page': 596, 'progress': 0.0},
    {'id': 94, 'name': 'الشَّرْح', 'verses': 8, 'type': 'مكية', 'page': 596, 'progress': 0.0},
    {'id': 95, 'name': 'التِّين', 'verses': 8, 'type': 'مكية', 'page': 597, 'progress': 0.0},
    {'id': 96, 'name': 'العَلَق', 'verses': 19, 'type': 'مكية', 'page': 597, 'progress': 0.0},
    {'id': 97, 'name': 'القَدْر', 'verses': 5, 'type': 'مكية', 'page': 598, 'progress': 0.0},
    {'id': 98, 'name': 'البَيِّنَة', 'verses': 8, 'type': 'مدنية', 'page': 598, 'progress': 0.0},
    {'id': 99, 'name': 'الزَّلْزَلَة', 'verses': 8, 'type': 'مدنية', 'page': 599, 'progress': 0.0},
    {'id': 100, 'name': 'العَادِيَات', 'verses': 11, 'type': 'مكية', 'page': 599, 'progress': 0.0},
    {'id': 101, 'name': 'القَارِعَة', 'verses': 11, 'type': 'مكية', 'page': 600, 'progress': 0.0},
    {'id': 102, 'name': 'التَّكَاثُر', 'verses': 8, 'type': 'مكية', 'page': 600, 'progress': 0.0},
    {'id': 103, 'name': 'العَصْر', 'verses': 3, 'type': 'مكية', 'page': 601, 'progress': 0.0},
    {'id': 104, 'name': 'الهُمَزَة', 'verses': 9, 'type': 'مكية', 'page': 601, 'progress': 0.0},
    {'id': 105, 'name': 'الفِيل', 'verses': 5, 'type': 'مكية', 'page': 601, 'progress': 0.0},
    {'id': 106, 'name': 'قُرَيْش', 'verses': 4, 'type': 'مكية', 'page': 602, 'progress': 0.0},
    {'id': 107, 'name': 'المَاعُون', 'verses': 7, 'type': 'مكية', 'page': 602, 'progress': 0.0},
    {'id': 108, 'name': 'الكَوْثَر', 'verses': 3, 'type': 'مكية', 'page': 602, 'progress': 0.0},
    {'id': 109, 'name': 'الكَافِرُون', 'verses': 6, 'type': 'مكية', 'page': 603, 'progress': 0.0},
    {'id': 110, 'name': 'النَّصْر', 'verses': 3, 'type': 'مدنية', 'page': 603, 'progress': 0.0},
    {'id': 111, 'name': 'المَسَد', 'verses': 5, 'type': 'مكية', 'page': 603, 'progress': 0.0},
    {'id': 112, 'name': 'الإِخْلَاص', 'verses': 4, 'type': 'مكية', 'page': 604, 'progress': 0.0},
    {'id': 113, 'name': 'الفَلَق', 'verses': 5, 'type': 'مكية', 'page': 604, 'progress': 0.0},
    {'id': 114, 'name': 'النَّاس', 'verses': 6, 'type': 'مكية', 'page': 604, 'progress': 0.0},
  ];

  final List<Map<String, dynamic>> juzs = [
    {'juz': 1, 'surahId': 1, 'ayahIndex': 0, 'page': 1, 'surahName': 'الفَاتِحَة'},
    {'juz': 2, 'surahId': 2, 'ayahIndex': 141, 'page': 22, 'surahName': 'البَقَرَة'},
    {'juz': 3, 'surahId': 2, 'ayahIndex': 252, 'page': 42, 'surahName': 'البَقَرَة'},
    {'juz': 4, 'surahId': 3, 'ayahIndex': 92, 'page': 62, 'surahName': 'آل عِمرَان'},
    {'juz': 5, 'surahId': 4, 'ayahIndex': 23, 'page': 82, 'surahName': 'النِّسَاء'},
    {'juz': 6, 'surahId': 4, 'ayahIndex': 147, 'page': 102, 'surahName': 'النِّسَاء'},
    {'juz': 7, 'surahId': 5, 'ayahIndex': 81, 'page': 122, 'surahName': 'المَائِدَة'},
    {'juz': 8, 'surahId': 6, 'ayahIndex': 110, 'page': 142, 'surahName': 'الأنعَام'},
    {'juz': 9, 'surahId': 7, 'ayahIndex': 87, 'page': 162, 'surahName': 'الأعرَاف'},
    {'juz': 10, 'surahId': 8, 'ayahIndex': 40, 'page': 182, 'surahName': 'الأنفَال'},
    {'juz': 11, 'surahId': 9, 'ayahIndex': 92, 'page': 202, 'surahName': 'التَّوبَة'},
    {'juz': 12, 'surahId': 11, 'ayahIndex': 5, 'page': 222, 'surahName': 'هُود'},
    {'juz': 13, 'surahId': 12, 'ayahIndex': 52, 'page': 242, 'surahName': 'يُوسُف'},
    {'juz': 14, 'surahId': 15, 'ayahIndex': 0, 'page': 262, 'surahName': 'الحِجْر'},
    {'juz': 15, 'surahId': 17, 'ayahIndex': 0, 'page': 282, 'surahName': 'الإِسْرَاء'},
    {'juz': 16, 'surahId': 18, 'ayahIndex': 74, 'page': 302, 'surahName': 'الكَهْف'},
    {'juz': 17, 'surahId': 21, 'ayahIndex': 0, 'page': 322, 'surahName': 'الأَنْبِيَاء'},
    {'juz': 18, 'surahId': 23, 'ayahIndex': 0, 'page': 342, 'surahName': 'المُؤْمِنُون'},
    {'juz': 19, 'surahId': 25, 'ayahIndex': 20, 'page': 362, 'surahName': 'الفُرْقَان'},
    {'juz': 20, 'surahId': 27, 'ayahIndex': 55, 'page': 382, 'surahName': 'النَّمْل'},
    {'juz': 21, 'surahId': 29, 'ayahIndex': 45, 'page': 402, 'surahName': 'العَنْكَبُوت'},
    {'juz': 22, 'surahId': 33, 'ayahIndex': 30, 'page': 422, 'surahName': 'الأَحْزَاب'},
    {'juz': 23, 'surahId': 36, 'ayahIndex': 27, 'page': 442, 'surahName': 'يس'},
    {'juz': 24, 'surahId': 39, 'ayahIndex': 31, 'page': 462, 'surahName': 'الزُّمَر'},
    {'juz': 25, 'surahId': 41, 'ayahIndex': 46, 'page': 482, 'surahName': 'فُصِّلَت'},
    {'juz': 26, 'surahId': 46, 'ayahIndex': 0, 'page': 502, 'surahName': 'الأَحْقَاف'},
    {'juz': 27, 'surahId': 51, 'ayahIndex': 30, 'page': 522, 'surahName': 'الذَّارِيَات'},
    {'juz': 28, 'surahId': 58, 'ayahIndex': 0, 'page': 542, 'surahName': 'المُجَادِلَة'},
    {'juz': 29, 'surahId': 67, 'ayahIndex': 0, 'page': 562, 'surahName': 'المُلْك'},
    {'juz': 30, 'surahId': 78, 'ayahIndex': 0, 'page': 582, 'surahName': 'النَّبَأ'},
  ];

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  List<Map<String, dynamic>> get filteredSurahs {
    final query = searchQuery.value.trim();
    if (query.isEmpty) {
      return surahs;
    }
    return surahs.where((surah) {
      final name = surah['name'] as String;
      final id = surah['id'].toString();
      final page = surah['page'].toString();
      return name.contains(query) || id == query || page == query;
    }).toList();
  }

  Map<String, dynamic> getSurahForPage(int pageNumber) {
    for (int i = surahs.length - 1; i >= 0; i--) {
      final surah = surahs[i];
      if (surah['page'] <= pageNumber) {
        return {
          'id': surah['id'],
          'name': surah['name'],
          'initialAyahIndex': 0,
        };
      }
    }
    return {
      'id': 1,
      'name': 'الفَاتِحَة',
      'initialAyahIndex': 0,
    };
  }
}
