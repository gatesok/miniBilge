import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Wordle günlük hatırlatma bildirimi.
/// Her gün saat 09:00'da "Bugünün kelimesi hazır!" bildirimi gönderilir.
class WordleNotificationService {
  WordleNotificationService._();

  static const int _dailyNotificationId = 9001;
  static const String _channelId   = 'wordle_daily';
  static const String _channelName  = 'Günlük Wordle';

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  /// Uygulama başlangıcında çağrılır.
  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission:  false, // FCM zaten istiyor
      requestBadgePermission:  false,
      requestSoundPermission:  false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    _initialized = true;
  }

  /// Günlük 09:00 bildirimini planlar.
  /// Uygulama her açıldığında çağrılabilir — aynı ID yeniden planlanır.
  static Future<void> scheduleDailyReminder() async {
    await initialize();

    // İzin kontrolü (iOS)
    final iosPlatform = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPlatform != null) {
      final granted = await iosPlatform.requestPermissions(
          alert: true, badge: false, sound: true);
      if (granted != true) return;
    }

    final now    = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, 9, 0, 0);

    // Bugün 09:00 geçtiyse yarına planla
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id:                      _dailyNotificationId,
      title:                   'Günlük Wordle Hazır! 📝',
      body:                    'Bugünün kelimesini tahmin edebilir misin?',
      scheduledDate:           scheduled,
      notificationDetails:     const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.defaultImportance,
          priority:   Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode:     AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Wordle tamamlandıktan sonra çağrılır — bildirimi iptal eder (bugün için).
  /// Yarın otomatik olarak yeniden görünür.
  static Future<void> cancelTodayReminder() async {
    await _plugin.cancel(id: _dailyNotificationId);
    await scheduleDailyReminder();
  }

  /// Günlük Wordle bildirimi kalıcı olarak devre dışı bırakır.
  /// Dashboard'dan Wordle kaldırıldığı için çağrılır.
  static Future<void> disableDailyReminder() async {
    await initialize();
    await _plugin.cancel(id: _dailyNotificationId);
  }
}
