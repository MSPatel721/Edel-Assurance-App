import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:new_app/app.dart';
import 'package:new_app/src/views/home/home_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalService {
  static const String _appId = "f2d901c3-bbcb-4c71-a5cc-fbbb89625c89";

  static Future<void> initializeOneSignal() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(_appId);
    OneSignal.Notifications.requestPermission(true);

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      print(
          'NOTIFICATION WILL DISPLAY LISTENER CALLED WITH: ${event.notification.jsonRepresentation()}');
      
      final additionald = event.notification.additionalData;
      print("additionald =========== $additionald");

      event.preventDefault();

      event.notification.display();
    });

    OneSignal.Notifications.addClickListener((event) {
      print(
          'NOTIFICATION OPENED LISTENER CALLED WITH: ${event.notification.jsonRepresentation()}');
      
      final additionald = event.notification.additionalData;
      print("webview link =========== ${additionald?['app_webview_link']}");

      String url = additionald?['app_webview_link'];

      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(url: url),
        ),
      );
      _handleNotificationOpen(event.notification);
    });
  }

  static void _handleNotificationOpen(OSNotification notification) {
    final customData = notification.additionalData;
    String url = customData?['custom'];
    if (customData != null) {
      log("Custom Data: $url");
      log("Custom Data: $customData");
    } else {
      log("No custom data available.");
    }
  }
}
