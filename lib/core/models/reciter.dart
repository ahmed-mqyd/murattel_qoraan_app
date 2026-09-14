import 'package:shared_preferences/shared_preferences.dart';

/// مصدر الصوت للقارئ
enum ReciterSource {
  /// آية-بآية من cdn.islamic.network (بمعرّف الآية العام في المصحف) —
  /// نفس بنية alquran.cloud القديمة بعد توقف نطاق cdn.alquran.cloud عن العمل
  alquranCloud,

  /// آية-بآية من everyayah.com (بترقيم سورة + آية بثلاث خانات)
  everyAyah,

  /// ملف واحد للسورة كاملة (يتطلب surahUrlTemplate)
  fullSurah,
}

class Reciter {
  /// المعرّف المحفوظ في الإعدادات
  final String key;

  /// الاسم المعروض للمستخدم
  final String arabicName;

  /// معرّف المصدر الصوتي — يُستخدم أيضاً كاسم مجلد التنزيلات المحلية،
  /// فلا تغيّره لقارئ موجود وإلا فقد المستخدمون تنزيلاتهم السابقة
  final String audioId;

  final ReciterSource source;

  /// لقرّاء السورة الكاملة: قالب الرابط ويحتوي {surah} برقم من ثلاث خانات
  final String? surahUrlTemplate;

  /// معدّل البت المتوفر لهذا القارئ على cdn.islamic.network (لقرّاء alquranCloud فقط)
  final int bitrate;

  const Reciter({
    required this.key,
    required this.arabicName,
    required this.audioId,
    required this.source,
    this.surahUrlTemplate,
    this.bitrate = 128,
  });

  bool get isFullSurah => source == ReciterSource.fullSurah;
}

/// السجل المركزي الوحيد للقرّاء في التطبيق.
///
/// لإضافة قارئ جديد أضف عنصراً واحداً في [all] فقط — قائمة الإعدادات
/// وكل شاشات التشغيل والتنزيل تقرأ من هنا تلقائياً.
class Reciters {
  Reciters._();

  static const String defaultKey = 'alafasy';

  /// مفتاح التخزين في SharedPreferences للقارئ المختار
  static const String prefsKey = 'settings_selected_reciter';

  static const List<Reciter> all = [
    Reciter(
      key: 'alafasy',
      arabicName: 'مشاري راشد العفاسي',
      audioId: 'ar.alafasy',
      source: ReciterSource.alquranCloud,
    ),
    Reciter(
      key: 'abdulbasit',
      arabicName: 'عبد الباسط عبد الصمد',
      audioId: 'ar.abdulbasitmurattal',
      source: ReciterSource.alquranCloud,
      bitrate: 64,
    ),
    Reciter(
      key: 'almuaiqly',
      arabicName: 'ماهر المعيقلي',
      audioId: 'Maher_AlMuaiqly_64kbps',
      source: ReciterSource.everyAyah,
    ),
    Reciter(
      key: 'ghamdi',
      arabicName: 'سعد الغامدي',
      audioId: 'Ghamadi_40kbps',
      source: ReciterSource.everyAyah,
    ),
    Reciter(
      key: 'faresabbad',
      arabicName: 'فارس عباد',
      audioId: 'Fares_Abbad_64kbps',
      source: ReciterSource.everyAyah,
    ),
    Reciter(
      key: 'yasser',
      arabicName: 'ياسر الدوسري',
      audioId: 'Yasser_Ad-Dussary_128kbps',
      source: ReciterSource.everyAyah,
    ),
    Reciter(
      key: 'islamsobhi',
      arabicName: 'إسلام صبحي',
      audioId: 'islam_sobhi',
      source: ReciterSource.fullSurah,
      surahUrlTemplate:
          'https://server14.mp3quran.net/islam/Rewayat-Hafs-A-n-Assem/{surah}.mp3',
    ),
    Reciter(
      key: 'ahmedshafei',
      arabicName: 'أحمد الشافعي',
      audioId: 'ahmed_alshafey',
      source: ReciterSource.fullSurah,
      surahUrlTemplate:
          'https://archive.org/download/ahmed_alshafey_202211/{surah}.mp3',
    ),
    Reciter(
      key: 'husary',
      arabicName: 'محمود خليل الحصري',
      audioId: 'ar.husary',
      source: ReciterSource.alquranCloud,
    ),
    Reciter(
      key: 'minshawi',
      arabicName: 'محمد صديق المنشاوي',
      audioId: 'ar.minshawi',
      source: ReciterSource.alquranCloud,
    ),
    Reciter(
      key: 'sudais',
      arabicName: 'عبد الرحمن السديس',
      audioId: 'ar.abdurrahmaansudais',
      source: ReciterSource.alquranCloud,
      bitrate: 64,
    ),
    Reciter(
      key: 'shaatree',
      arabicName: 'أبو بكر الشاطري',
      audioId: 'ar.shaatree',
      source: ReciterSource.alquranCloud,
    ),
    Reciter(
      key: 'ajamy',
      arabicName: 'أحمد بن علي العجمي',
      audioId: 'ar.ahmedajamy',
      source: ReciterSource.alquranCloud,
    ),
    Reciter(
      key: 'hudhaify',
      arabicName: 'علي بن عبد الرحمن الحذيفي',
      audioId: 'ar.hudhaify',
      source: ReciterSource.alquranCloud,
    ),
  ];

  /// البحث بمفتاح الإعدادات، مع الرجوع للقارئ الافتراضي إن لم يوجد
  static Reciter byKey(String key) {
    return all.firstWhere((r) => r.key == key, orElse: () => all.first);
  }

  /// البحث بمعرّف المصدر الصوتي، مع الرجوع للقارئ الافتراضي إن لم يوجد
  static Reciter byAudioId(String audioId) {
    return all.firstWhere((r) => r.audioId == audioId, orElse: () => all.first);
  }

  /// القارئ المختار حالياً في إعدادات المستخدم
  static Reciter selected(SharedPreferences prefs) {
    return byKey(prefs.getString(prefsKey) ?? defaultKey);
  }
}
