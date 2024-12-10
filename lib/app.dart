import 'dart:async';
import 'dart:developer';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:new_app/src/controllers/connectivity_controller.dart';
import 'package:new_app/src/controllers/download_controller.dart';
import 'package:new_app/src/controllers/loading_controller.dart';
import 'package:new_app/src/controllers/splash_controller.dart';
import 'package:new_app/src/services/device_details_service.dart';
import 'package:new_app/src/services/one_signal_service.dart';
import 'package:new_app/src/views/home/home_screen.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  StreamSubscription<Uri?>? _sub;

  Future<void> initUniLinks() async {
    log("in to unilinks");

    AppLinks appLinks = AppLinks();
    try {
      appLinks.uriLinkStream.listen((uri) {
        if (mounted) {
          handleDeepLink(uri);
        }
      }, onError: (Object err) {
        log('Error receiving uri: $err');
      });
    } catch (e) {
      log('Failed to get initial uri: $e');
    }
  }

  void handleDeepLink(Uri uri) {
    print("uri.path================${uri.path}");
    navigatorKey.currentState?.pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen(url: "https://edelapp.accuratelogics.com${uri.path}",),));
    print("uri.path================${uri.path}");
    log("Received deep link: $uri");
    log("Received deep link: $uri");
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    OneSignalService.initializeOneSignal();
    DeviceDetailsService().getDeviceDetails(context);
    initUniLinks();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SplashController()),
        ChangeNotifierProvider(create: (_) => ConnectivityController()),
        ChangeNotifierProvider(create: (_) => LoadingController()),
        ChangeNotifierProvider(create: (_) => DownloadController()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey, 
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2280c3)),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      )
    );
  }
}