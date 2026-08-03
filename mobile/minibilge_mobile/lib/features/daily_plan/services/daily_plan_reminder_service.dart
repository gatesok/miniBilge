import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// "Bugünkü Planım" günlük hatırlatma bildirimi (Sprint P5 - M07).
/// Kullanıcı tercihine bağlı olarak her gün belirlenen saatte hatırlatır.
class DailyPlanReminderService {
  DailyPlanReminderService._();

  static const int _dailyNotificationId = 9101;
  static const String _channelId = 'daily_plan_reminder';
  static const String _channelName = 'Günlük Plan Hatırlatması';
  static const String _prefKey = 'daily_plan_reminder_enabled';
  static const int _reminderHour = 17;

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    _initialized = true;
  }

  /// Kullanıcı tercihini okur (varsayılan: kapalı).
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  /// Tercihi kaydeder ve bildirimi planlar veya iptal eder.
  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, enabled);
    if (enabled) {
      await scheduleDailyReminder();
    } else {
      await disableDailyReminder();
    }
  }

  /// Uygulama açılışında tercih açıksa bildirimi yeniden planlar.
  static Future<void> syncOnLaunch() async {
    if (await isEnabled()) {
      await scheduleDailyReminder();
    }
  }

  static Future<void> scheduleDailyReminder() async {
    await initialize();

    final iosPlatform = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPlatform != null) {
      final granted = await iosPlatform.requestPermissions(
        alert: true,
        badge: false,
        sound: true,
      );
      if (granted != true) return;
    }

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      _reminderHour,
      0,
      0,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: _dailyNotificationId,
      title: 'Bugünkü Planın Seni Bekliyor!',
      body: 'Günlük görevlerini tamamlayıp yıldızlarını kazan.',
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> disableDailyReminder() async {
    await initialize();
    await _plugin.cancel(id: _dailyNotificationId);
  }
}
