<?php
/**
 * ═══════════════════════════════════════════════════════════════════
 *  الخادم الوسيط لنصائح التسميع الذكي — مرتل القرآن
 * ═══════════════════════════════════════════════════════════════════
 *
 *  لماذا هذا الملف؟
 *  مفتاح Gemini لا يوضع داخل التطبيق أبداً (يُستخرج من الـ APK بسهولة).
 *  هذا الملف يحمل المفتاح على خادمك، والتطبيق يطلب منه النصائح فقط.
 *  الطلب محصور في مهمة واحدة (نصائح تحفيظ) بحدود صارمة، فحتى لو
 *  استُخرج رابط الخادم من التطبيق لا يمكن استغلاله كبوابة عامة لـ Gemini.
 *
 *  خطوات التشغيل على استضافة Hostinger (أو أي استضافة PHP):
 *  1. ضع مفتاح Gemini في GEMINI_API_KEY أدناه.
 *  2. غيّر APP_TOKEN لسلسلة عشوائية طويلة من عندك.
 *  3. ارفع الملف إلى public_html/api/hifz_tips_proxy.php
 *  4. تأكد أن المجلد قابل للكتابة (سيُنشئ مجلد بيانات بجواره تلقائياً).
 *  5. انسخ الرابط النهائي وضعه في _tipsProxyUrl داخل hifz_controller.dart
 *     وضع نفس APP_TOKEN في _tipsProxyToken.
 */

// ══════════════════ الإعدادات ══════════════════

const GEMINI_API_KEY = 'ضع_مفتاح_Gemini_هنا';
const APP_TOKEN      = 'غيّر-هذا-لسلسلة-عشوائية-طويلة';

// النموذج المستخدم — اسم رمزي يتتبع أحدث نموذج lite تلقائياً:
// الأرخص تكلفةً، ويكفي تماماً لنصائح قصيرة، ولا يتعطل عند تقاعد نموذج قديم
// (اختبرناه بالمفتاح الجديد: يعمل مع المخطط المنظم JSON بنجاح)
const GEMINI_MODEL = 'gemini-flash-lite-latest';

// حدود الاستهلاك (عدّادات يومية تُصفَّر تلقائياً مع تغير التاريخ)
const DAILY_GLOBAL_LIMIT     = 1500; // أقصى نداءات Gemini يومياً للتطبيق كله
const PER_DEVICE_DAILY_LIMIT = 10;   // أقصى نداءات يومياً للجهاز الواحد

// حدود حجم المدخلات (تمنع إساءة الاستخدام وتقلل التوكنز)
const MAX_TEXT_CHARS  = 4000;
const MAX_WRONG_WORDS = 60;

// مدة صلاحية الكاش بالثواني (30 يوماً) — نفس المقطع بنفس الأخطاء
// يُجاب من الكاش بدون أي استهلاك لـ Gemini
const CACHE_TTL = 30 * 24 * 3600;

// ══════════════════ التنفيذ ══════════════════

header('Content-Type: application/json; charset=utf-8');

function fail(int $status, string $reason): void {
    http_response_code($status);
    echo json_encode(['error' => $reason], JSON_UNESCAPED_UNICODE);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    fail(405, 'method_not_allowed');
}
if (GEMINI_API_KEY === 'ضع_مفتاح_Gemini_هنا') {
    fail(500, 'server_not_configured');
}

// التحقق من رمز التطبيق
$token = $_SERVER['HTTP_X_APP_TOKEN'] ?? '';
if (!hash_equals(APP_TOKEN, $token)) {
    fail(401, 'unauthorized');
}

// قراءة المدخلات والتحقق منها
$body = json_decode(file_get_contents('php://input'), true);
if (!is_array($body)) {
    fail(400, 'bad_json');
}

$target   = trim((string)($body['target'] ?? ''));
$recited  = trim((string)($body['recited'] ?? ''));
$wrong    = $body['wrong'] ?? [];
$deviceId = preg_replace('/[^a-zA-Z0-9_-]/', '', (string)($body['device'] ?? ''));

if ($target === '' || $recited === '' || $deviceId === '' || !is_array($wrong)) {
    fail(400, 'missing_fields');
}
if (mb_strlen($target) > MAX_TEXT_CHARS || mb_strlen($recited) > MAX_TEXT_CHARS) {
    fail(413, 'too_large');
}
if (count($wrong) > MAX_WRONG_WORDS) {
    $wrong = array_slice($wrong, 0, MAX_WRONG_WORDS);
}
$wrong = array_map(fn($w) => mb_substr(trim((string)$w), 0, 40), $wrong);

// مجلد البيانات (عدّادات + كاش) مع منع الوصول المباشر عبر الويب
$dataDir = __DIR__ . '/hifz_tips_data';
if (!is_dir($dataDir)) {
    mkdir($dataDir, 0755, true);
    file_put_contents($dataDir . '/.htaccess', "Deny from all\n");
}

// ── الكاش أولاً: نفس المقطع + نفس الأخطاء = نفس النصائح بلا استهلاك ──
$cacheKey  = md5($target . '|' . implode(',', $wrong));
$cacheFile = $dataDir . '/cache_' . $cacheKey . '.json';
if (is_file($cacheFile) && (time() - filemtime($cacheFile)) < CACHE_TTL) {
    $cached = json_decode(file_get_contents($cacheFile), true);
    if (is_array($cached) && !empty($cached['tips'])) {
        echo json_encode(['tips' => $cached['tips'], 'cached' => true], JSON_UNESCAPED_UNICODE);
        exit;
    }
}

// ── العدّادات اليومية (بقفل ملف لسلامة التزامن) ──
function bumpCounter(string $file, int $limit): bool {
    $handle = fopen($file, 'c+');
    if ($handle === false) return true; // لا نُفشل الطلب بسبب عطل عدّاد
    flock($handle, LOCK_EX);
    $count = (int)stream_get_contents($handle);
    if ($count >= $limit) {
        flock($handle, LOCK_UN);
        fclose($handle);
        return false;
    }
    ftruncate($handle, 0);
    rewind($handle);
    fwrite($handle, (string)($count + 1));
    flock($handle, LOCK_UN);
    fclose($handle);
    return true;
}

$today = date('Y-m-d');
if (!bumpCounter("$dataDir/global_$today.count", DAILY_GLOBAL_LIMIT)) {
    fail(429, 'daily_global_limit');
}
if (!bumpCounter("$dataDir/device_{$deviceId}_$today.count", PER_DEVICE_DAILY_LIMIT)) {
    fail(429, 'daily_device_limit');
}

// ── بناء المطالبة على الخادم (ثابتة — لا يمكن للعميل تغيير مهمة النموذج) ──
$wrongLine = empty($wrong) ? 'لا يوجد' : implode('، ', $wrong);
$prompt = <<<PROMPT
أنت معلم تحفيظ قرآن كريم خبير. سمّع الطالب المقطع التالي غيباً:
النص الصحيح: «{$target}»
ما نطقه الطالب كما دوّنه محرك التعرف على الكلام: «{$recited}»
الكلمات التي أخطأ فيها أو فاتته: {$wrongLine}

اكتب من 2 إلى 4 نصائح قصيرة عملية باللغة العربية تساعده على إتقان حفظ هذا المقطع وتلاوته، وخاطبه مباشرة بأسلوب مشجع. لا تُشِر إلى محرك التعرف على الكلام.
PROMPT;

$payload = [
    'contents' => [['parts' => [['text' => $prompt]]]],
    'generationConfig' => [
        'responseMimeType' => 'application/json',
        'responseSchema' => [
            'type' => 'OBJECT',
            'properties' => [
                'tips' => ['type' => 'ARRAY', 'items' => ['type' => 'STRING']],
            ],
            'required' => ['tips'],
        ],
    ],
];

$url = 'https://generativelanguage.googleapis.com/v1beta/models/'
     . GEMINI_MODEL . ':generateContent?key=' . urlencode(GEMINI_API_KEY);

$curl = curl_init($url);
curl_setopt_array($curl, [
    CURLOPT_POST           => true,
    CURLOPT_POSTFIELDS     => json_encode($payload, JSON_UNESCAPED_UNICODE),
    CURLOPT_HTTPHEADER     => ['Content-Type: application/json'],
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_TIMEOUT        => 20,
]);
$response = curl_exec($curl);
$status   = curl_getinfo($curl, CURLINFO_RESPONSE_CODE);
curl_close($curl);

if ($response === false || $status !== 200) {
    fail(502, 'upstream_failed');
}

$data  = json_decode($response, true);
$text  = $data['candidates'][0]['content']['parts'][0]['text'] ?? '';
$text  = trim(str_replace(['```json', '```'], '', $text));
$parsed = json_decode($text, true);
$tips   = (is_array($parsed) && isset($parsed['tips']) && is_array($parsed['tips']))
    ? array_values(array_filter(array_map('trim', $parsed['tips'])))
    : [];

if (empty($tips)) {
    fail(502, 'empty_tips');
}

// حفظ في الكاش ثم الرد
file_put_contents($cacheFile, json_encode(['tips' => $tips], JSON_UNESCAPED_UNICODE));
echo json_encode(['tips' => $tips], JSON_UNESCAPED_UNICODE);
