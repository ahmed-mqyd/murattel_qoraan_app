/// بيانات السورة الثابتة: الرقم، الاسم، وعدد الآيات
class SurahMeta {
  final int id;
  final String arabicName;
  final int verseCount;

  const SurahMeta(this.id, this.arabicName, this.verseCount);
}

/// السجل المركزي لبيانات سور المصحف الشريف (114 سورة، 6236 آية).
class SurahMetas {
  SurahMetas._();

  static const List<SurahMeta> all = [
    SurahMeta(1, 'الفَاتِحَة', 7),
    SurahMeta(2, 'البَقَرَة', 286),
    SurahMeta(3, 'آل عِمرَان', 200),
    SurahMeta(4, 'النِّسَاء', 176),
    SurahMeta(5, 'المَائِدَة', 120),
    SurahMeta(6, 'الأنعَام', 165),
    SurahMeta(7, 'الأعرَاف', 206),
    SurahMeta(8, 'الأنفَال', 75),
    SurahMeta(9, 'التَّوبَة', 129),
    SurahMeta(10, 'يُونُس', 109),
    SurahMeta(11, 'هُود', 123),
    SurahMeta(12, 'يُوسُف', 111),
    SurahMeta(13, 'الرَّعْد', 43),
    SurahMeta(14, 'إِبْرَاهِيم', 52),
    SurahMeta(15, 'الحِجْر', 99),
    SurahMeta(16, 'النَّحْل', 128),
    SurahMeta(17, 'الإِسْرَاء', 111),
    SurahMeta(18, 'الكَهْف', 110),
    SurahMeta(19, 'مَرْيَم', 98),
    SurahMeta(20, 'طه', 135),
    SurahMeta(21, 'الأَنْبِيَاء', 112),
    SurahMeta(22, 'الحَجّ', 78),
    SurahMeta(23, 'المُؤْمِنُون', 118),
    SurahMeta(24, 'النُّور', 64),
    SurahMeta(25, 'الفُرْقَان', 77),
    SurahMeta(26, 'الشُّعَرَاء', 227),
    SurahMeta(27, 'النَّمْل', 93),
    SurahMeta(28, 'القَصَص', 88),
    SurahMeta(29, 'العَنْكَبُوت', 69),
    SurahMeta(30, 'الرُّوم', 60),
    SurahMeta(31, 'لُقْمَان', 34),
    SurahMeta(32, 'السَّجْدَة', 30),
    SurahMeta(33, 'الأَحْزَاب', 73),
    SurahMeta(34, 'سَبَأ', 54),
    SurahMeta(35, 'فَاطِر', 45),
    SurahMeta(36, 'يس', 83),
    SurahMeta(37, 'الصَّافَّات', 182),
    SurahMeta(38, 'ص', 88),
    SurahMeta(39, 'الزُّمَر', 75),
    SurahMeta(40, 'غَافِر', 85),
    SurahMeta(41, 'فُصِّلَت', 54),
    SurahMeta(42, 'الشُّورَى', 53),
    SurahMeta(43, 'الزُّخْرُف', 89),
    SurahMeta(44, 'الدُّخَان', 59),
    SurahMeta(45, 'الجَاثِيَة', 37),
    SurahMeta(46, 'الأَحْقَاف', 35),
    SurahMeta(47, 'مُحَمَّد', 38),
    SurahMeta(48, 'الفَتْح', 29),
    SurahMeta(49, 'الحُجُرَات', 18),
    SurahMeta(50, 'ق', 45),
    SurahMeta(51, 'الذَّارِيَات', 60),
    SurahMeta(52, 'الطُّور', 49),
    SurahMeta(53, 'النَّجْم', 62),
    SurahMeta(54, 'القَمَر', 55),
    SurahMeta(55, 'الرَّحْمَن', 78),
    SurahMeta(56, 'الوَاقِعَة', 96),
    SurahMeta(57, 'الحَدِيد', 29),
    SurahMeta(58, 'المُجَادِلَة', 22),
    SurahMeta(59, 'الحَشْر', 24),
    SurahMeta(60, 'المُمْتَحَنَة', 13),
    SurahMeta(61, 'الصَّفّ', 14),
    SurahMeta(62, 'الجُمُعَة', 11),
    SurahMeta(63, 'المُنَافِقُون', 11),
    SurahMeta(64, 'التَّغَابُن', 18),
    SurahMeta(65, 'الطَّلَاق', 12),
    SurahMeta(66, 'التَّحْرِيم', 12),
    SurahMeta(67, 'المُلْك', 30),
    SurahMeta(68, 'القَلَم', 52),
    SurahMeta(69, 'الحَاقَّة', 52),
    SurahMeta(70, 'المَعَارِج', 44),
    SurahMeta(71, 'نُوح', 28),
    SurahMeta(72, 'الجِنّ', 28),
    SurahMeta(73, 'المُزَّمِّل', 20),
    SurahMeta(74, 'المُدَّثِّر', 56),
    SurahMeta(75, 'القِيَامَة', 40),
    SurahMeta(76, 'الإِنْسَان', 31),
    SurahMeta(77, 'المُرْسَلَات', 50),
    SurahMeta(78, 'النَّبَأ', 40),
    SurahMeta(79, 'النَّازِعَات', 46),
    SurahMeta(80, 'عَبَس', 42),
    SurahMeta(81, 'التَّكْوِير', 29),
    SurahMeta(82, 'الانْفِطَار', 19),
    SurahMeta(83, 'المُطَفِّفِين', 36),
    SurahMeta(84, 'الانْشِقَاق', 25),
    SurahMeta(85, 'البُرُوج', 22),
    SurahMeta(86, 'الطَّارِق', 17),
    SurahMeta(87, 'الأَعْلَى', 19),
    SurahMeta(88, 'الغَاشِيَة', 26),
    SurahMeta(89, 'الفَجْر', 30),
    SurahMeta(90, 'البَلَد', 20),
    SurahMeta(91, 'الشَّمْس', 15),
    SurahMeta(92, 'اللَّيْل', 21),
    SurahMeta(93, 'الضُّحَى', 11),
    SurahMeta(94, 'الشَّرْح', 8),
    SurahMeta(95, 'التِّين', 8),
    SurahMeta(96, 'العَلَق', 19),
    SurahMeta(97, 'القَدْر', 5),
    SurahMeta(98, 'البَيِّنَة', 8),
    SurahMeta(99, 'الزَّلْزَلَة', 8),
    SurahMeta(100, 'العَادِيَات', 11),
    SurahMeta(101, 'القَارِعَة', 11),
    SurahMeta(102, 'التَّكَاثُر', 8),
    SurahMeta(103, 'العَصْر', 3),
    SurahMeta(104, 'الهُمَزَة', 9),
    SurahMeta(105, 'الفِيل', 5),
    SurahMeta(106, 'قُرَيْش', 4),
    SurahMeta(107, 'المَاعُون', 7),
    SurahMeta(108, 'الكَوْثَر', 3),
    SurahMeta(109, 'الكَافِرُون', 6),
    SurahMeta(110, 'النَّصْر', 3),
    SurahMeta(111, 'المَسَد', 5),
    SurahMeta(112, 'الإِخْلَاص', 4),
    SurahMeta(113, 'الفَلَق', 5),
    SurahMeta(114, 'النَّاس', 6),
  ];

  static SurahMeta byId(int id) => all[id - 1];

  /// رقم الآية العام (في المصحف كاملاً) لأول آية في السورة —
  /// الترقيم متسلسل عبر المصحف: الفاتحة 1-7، البقرة تبدأ من 8، وهكذا.
  static int globalAyahStart(int surahId) {
    int start = 1;
    for (int i = 0; i < surahId - 1; i++) {
      start += all[i].verseCount;
    }
    return start;
  }
}
