import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_app/app.dart';
import 'package:new_app/src/constants/app_colors.dart';
import 'package:new_app/src/services/notification_service.dart';
import 'package:new_app/src/services/one_signal_service.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await OneSignalService.initializeOneSignal();

  notificationsService.initNotifications();
  
  runApp(const MyApp());
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: AppColors.primary,
  ));
}
