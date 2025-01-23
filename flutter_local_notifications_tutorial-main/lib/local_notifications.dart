import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class LocalNotifications {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static final onClickNotification = BehaviorSubject<String>();

  // Request notification permissions
  static Future requestPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  // On tap on any notification
  static void onNotificationTap(NotificationResponse notificationResponse) {
    onClickNotification.add(notificationResponse.payload!);
  }

  static Future init() async {
    // Initialize timezone database with error handling
    try {
      tz.initializeTimeZones();
      print('Timezone initialized successfully.');
    } catch (e) {
      print('Error initializing timezone: $e');
    }

    // Request notification permissions
    await requestPermission();

    // Initialise the plugin
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();
    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap);
  }

// //simple notification
//   static Future showSimpleNotificationAtTwoPM({
//   required String title,
//   required String body,
//   required String payload,
// }) async {
//   // Get the current date
//   final now = tz.TZDateTime.now(tz.local);

//   // Set the notification time to today at 2:00 PM
//   final twoPM = tz.TZDateTime(tz.local, now.year, now.month, now.day, 13,32);

//   // Check if the current time has passed 2:00 PM
//   if (now.isAfter(twoPM)) {
//     print("The specified time (2:00 PM) has already passed today.");
//     return;
//   }

//   print("Scheduling notification for 2:00 PM today: $twoPM");

//   try {
//     await _flutterLocalNotificationsPlugin.zonedSchedule(
//       0, // Notification ID
//       title,
//       body,
//       twoPM, // Schedule the notification for 2:00 PM
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'general_notifications', // Channel ID
//           'General Notifications', // Channel Name
//           channelDescription: 'Notifications for general updates and messages.',
//           importance: Importance.max,
//           priority: Priority.high,
//           ticker: 'ticker',
//         ),
//       ),
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.wallClockTime,
//       payload: payload,
//     );
//     print("Notification scheduled successfully for $twoPM");
//   } catch (e) {
//     print('Error scheduling notification: $e');
//   }
// }


//simple notification
  static Future showSimpleNotification({
  required String title,
  required String body,
  required String payload,
  required tz.TZDateTime scheduleTime,
}) async {
  // Get the current local time in your desired timezone (e.g., Asia/Colombo)
  final localNow = tz.TZDateTime.now(tz.getLocation('Asia/Colombo'));

  // Add a duration to the local time if needed (for example, scheduling 5 seconds ahead)
  final localScheduleTime = localNow.add(const Duration(seconds: 5));

  print("Original Schedule Time (in local timezone): $scheduleTime");
  print("Converted Schedule Time (local timezone): $localScheduleTime");

  try {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      localScheduleTime, // Schedule the notification with the converted time
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'general_notifications', // Channel ID
          'General Notifications', // Channel Name
          channelDescription: 'Notifications for general updates and messages.',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exact,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      payload: payload,
    );
    print("Notification scheduled for $localScheduleTime");
  } catch (e) {
    print('Error scheduling notification: $e');
  }
}




  // Show periodic notification at regular interval
  static Future showPeriodicNotifications({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            'reminder_notifications', // Channel ID
            'Reminder Notifications', // Channel Name
            channelDescription:
                'Notifications to remind you of tasks and events.', // Channel Description
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin.periodicallyShow(
        1, title, body, RepeatInterval.everyMinute, notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload);
  }

  // Schedule a local notification
  static Future showScheduleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    // Initialize timezone database with error handling
    try {
      tz.initializeTimeZones();
      print('Timezone initialized successfully.');
    } catch (e) {
      print('Error initializing timezone: $e');
    }

    try {
      print('Scheduling notification...');
      await _flutterLocalNotificationsPlugin.zonedSchedule(
          2,
          title,
          body,
          tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
          const NotificationDetails(
              android: AndroidNotificationDetails(
                  'channel_3', 'Scheduled Notifications',
                  channelDescription: 'Notifications scheduled in advance.',
                  importance: Importance.max,
                  priority: Priority.high,
                  ticker: 'ticker')),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload);
      print('Notification scheduled successfully.');
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  // Cancel a specific notification
  static Future cancel(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  static Future cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
