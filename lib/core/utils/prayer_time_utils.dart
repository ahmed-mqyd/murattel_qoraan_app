/// ينظّف نص وقت الصلاة القادم من API، حيث قد يُرجع صيغة مثل "04:32 (EET)"
/// فنُبقي على جزء الوقت "04:32" فقط.
String cleanPrayerTimeString(String rawTime) => rawTime.split(' ').first;
