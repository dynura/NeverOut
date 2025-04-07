// lib/features/receipt_processing/services/reminder_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_init;

class ReminderService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
      
  Future<void> initialize() async {
    tz_init.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
        
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
  
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'expiry_reminders',
          'Expiry Reminders',
          channelDescription: 'Notifications for items about to expire',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
 
  Future<void> setReminderForItem(
    String itemName,
    String expiryDateStr,
    String reminderSetting,
  ) async {
    try {
      final expiryDate = DateTime.parse(expiryDateStr);
      
      // Calculate reminder date based on setting
      DateTime reminderDate;
      if (reminderSetting == '1 day before') {
        reminderDate = expiryDate.subtract(const Duration(days: 1));
      } else if (reminderSetting == '3 days before') {
        reminderDate = expiryDate.subtract(const Duration(days: 3));
      } else {
        // Default to 1 week before
        reminderDate = expiryDate.subtract(const Duration(days: 7));
      }
      
      // Only schedule if reminder date is in the future
      if (reminderDate.isAfter(DateTime.now())) {
        // Generate unique ID for notification
        final id = itemName.hashCode;
        
        await scheduleReminder(
          id: id,
          title: 'Item Expiring Soon',
          body: '$itemName will expire on $expiryDateStr',
          scheduledDate: reminderDate,
        );
      }
    } catch (e) {
      print('Failed to set reminder: $e');
    }
  }
  
  Future<void> cancelReminder(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}