import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> init() async {
    // Initialize timezone database.
    tz.initializeTimeZones();

    // Get the real timezone of the device.
    final TimezoneInfo timeZoneInfo = await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  // ============================================================
  // NOTIFICATION TAP
  // ============================================================

  void _onNotificationTapped(NotificationResponse response) {
    final String? noteId = response.payload;

    if (noteId == null) {
      return;
    }

    // Later we will open the note using noteId.
  }

  // ============================================================
  // SCHEDULE REMINDER
  // ============================================================

  Future<void> scheduleReminder({
    required String noteId,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    if (!scheduledDate.isAfter(now)) {
      return;
    }

    await _plugin.zonedSchedule(
      id: noteId.hashCode,
      title: title.isEmpty ? 'Reminder' : title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'notes_reminders',
          'Notes Reminders',
          channelDescription: 'Notifications for your note reminders',
          importance: Importance.high,
          priority: Priority.high,

          // نمایش متن کامل هنگام Expand شدن Notification
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: title.isEmpty ? 'Reminder' : title,
            summaryText: 'Daily Notes',
          ),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: noteId,
    );
  }

  // ============================================================
  // CANCEL REMINDER
  // ============================================================

  Future<void> cancelReminder(String noteId) async {
    await _plugin.cancel(id: noteId.hashCode);
  }
}
