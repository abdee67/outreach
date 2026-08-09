import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../models/business.dart';
import 'notification_config.dart';

/// Top-level handler required for notification actions when the app is in
/// the background or terminated. Keep this function minimal.
@pragma('vm:entry-point')
void onBackgroundNotificationTap(NotificationResponse response) {
  debugPrint('Background notification tapped: ${response.payload}');
}

/// Manages local follow-up reminder notifications.
///
/// Follows the setup and scheduling patterns from the official
/// [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
/// package and example app.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final ValueNotifier<int?> pendingBusinessId = ValueNotifier(null);

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await _configureLocalTimeZone();
    await _createAndroidChannel();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationTap,
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    _handleLaunchFromNotification(launchDetails);

    await _requestPermissions();
    _initialized = true;
  }

  Future<void> _configureLocalTimeZone() async {
    if (kIsWeb || Platform.isLinux || Platform.isWindows) return;

    tz_data.initializeTimeZones();
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<void> _createAndroidChannel() async {
    if (!Platform.isAndroid) return;

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        NotificationConfig.followUpChannelId,
        NotificationConfig.followUpChannelName,
        description: NotificationConfig.followUpChannelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );
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

  void _handleLaunchFromNotification(
    NotificationAppLaunchDetails? launchDetails,
  ) {
    if (launchDetails?.didNotificationLaunchApp != true) return;

    final businessId = NotificationConfig.businessIdFromPayload(
      launchDetails?.notificationResponse?.payload,
    );
    if (businessId != null) {
      pendingBusinessId.value = businessId;
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    final businessId =
        NotificationConfig.businessIdFromPayload(response.payload);
    if (businessId != null) {
      pendingBusinessId.value = businessId;
    }
  }

  NotificationDetails _followUpDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        NotificationConfig.followUpChannelId,
        NotificationConfig.followUpChannelName,
        channelDescription: NotificationConfig.followUpChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );
  }

  Future<AndroidScheduleMode> _resolveAndroidScheduleMode() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final canScheduleExact =
        await androidPlugin?.canScheduleExactNotifications() ?? false;

    if (canScheduleExact) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    // Alarm clock scheduling is more reliable when exact alarms are denied.
    return AndroidScheduleMode.alarmClock;
  }

  tz.TZDateTime _toLocalScheduledTime(DateTime scheduledAt) {
    return tz.TZDateTime(
      tz.local,
      scheduledAt.year,
      scheduledAt.month,
      scheduledAt.day,
      scheduledAt.hour,
      scheduledAt.minute,
    );
  }

  /// Schedules or cancels a follow-up notification based on [business] state.
  Future<void> syncFollowUpForBusiness(Business business) async {
    final businessId = business.id;
    if (businessId == null) return;

    final followUpDate = business.followUpDate;
    if (followUpDate == null || !followUpDate.isAfter(DateTime.now())) {
      await cancelFollowUp(businessId);
      return;
    }

    await scheduleFollowUp(
      businessId: businessId,
      businessName: business.name,
      note: business.notes,
      scheduledAt: followUpDate,
    );
  }

  Future<void> scheduleFollowUp({
    required int businessId,
    required String businessName,
    required String note,
    required DateTime scheduledAt,
  }) async {
    await initialize();

    final scheduledTime = _toLocalScheduledTime(scheduledAt);
    if (!scheduledTime.isAfter(tz.TZDateTime.now(tz.local))) {
      await cancelFollowUp(businessId);
      return;
    }

    final body = note.trim().isNotEmpty
        ? note.trim()
        : 'Time to follow up with $businessName';

    try {
      await _plugin.zonedSchedule(
        id: businessId,
        title: 'Follow-up: $businessName',
        body: body,
        scheduledDate: scheduledTime,
        notificationDetails: _followUpDetails(),
        androidScheduleMode: await _resolveAndroidScheduleMode(),
        payload: NotificationConfig.followUpPayload(businessId),
      );
    } catch (error, stackTrace) {
      debugPrint('Failed to schedule follow-up notification: $error');
      debugPrint('$stackTrace');
    }
  }

  Future<void> cancelFollowUp(int businessId) async {
    await _plugin.cancel(id: businessId);
  }

  /// Re-registers all pending follow-ups from the database.
  ///
  /// Called on app launch to recover after reboots or app updates.
  Future<void> reschedulePendingFollowUps(List<Business> businesses) async {
    await initialize();

    for (final business in businesses) {
      await syncFollowUpForBusiness(business);
    }
  }

  int? consumePendingBusinessId() {
    final businessId = pendingBusinessId.value;
    pendingBusinessId.value = null;
    return businessId;
  }
}
