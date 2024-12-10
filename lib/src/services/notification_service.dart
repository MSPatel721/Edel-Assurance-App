import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:new_app/src/constants/app_colors.dart';
import 'package:open_file/open_file.dart';

class NotificationService {
  final AwesomeNotifications _notifications = AwesomeNotifications();

  void initNotifications() {
    _notifications.initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'edle_assurance_group',
          channelKey: 'edle_assurance',
          channelName: 'edle_assurance',
          channelDescription: 'edle_assurance',
          importance: NotificationImportance.High,
          enableVibration: true,
          playSound: true,
          defaultColor: AppColors.primary,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'edle_assurance_group',
          channelGroupName: 'Edle Assurance',
        ),
      ],
    );
  }

  void showProgressNotification(int id, int progress) async {

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: "edle_assurance",
        title: "Downloading file...",
        body: "Progress: $progress%",
        groupKey: 'edle_assurance',
        progress: progress.toDouble(),
        roundedLargeIcon: true,
      ),
    );
  }

    void showCompletedNotification(int id, String fileName, String filePath) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: "edle_assurance",
        title: "Download Complete",
        body: fileName,
        groupKey: 'edle_assurance',
        roundedLargeIcon: true,
        payload: {"filePath": filePath},
      ),
    );
  }

  static Future<void> onTapNotification(ReceivedAction receivedAction) async {
    String? filePath = receivedAction.payload?['filePath'];
    if(filePath != null) {
      print("Notification Tapped with filePath: $filePath");
      final file = File(filePath);
      print('Attempting to open file: $filePath');

      if (await file.exists()) {
        final result = await OpenFile.open(filePath);
        if (result.message != 'Success') {
          throw 'Could not open the file: ${result.message}';
        }
      } else {
        throw 'File not found: $filePath';
      }
    }
  }
}


final NotificationService notificationsService = NotificationService();