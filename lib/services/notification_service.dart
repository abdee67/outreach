import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    await _requestPermissions();
    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();

    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> scheduleFollowUp({
    required int businessId,
    required String businessName,
    required String note,
    required DateTime scheduledAt,
  }) async {
    await initialize();

    final tzScheduled = tz.TZDateTime.from(scheduledAt, tz.local);
    if (tzScheduled.isBefore(tz.TZDateTime.now(tz.local))) return;

    final body = note.isNotEmpty
        ? note
        : 'Time to follow up with $businessName';

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'follow_up_channel',
        'Follow-up Reminders',
        channelDescription: 'Reminders to call back businesses',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      businessId,
      'Follow-up: $businessName',
      body,
      tzScheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: businessId.toString(),
    );
  }

  Future<void> cancelFollowUp(int businessId) async {
    await _plugin.cancel(businessId);
  }
}
