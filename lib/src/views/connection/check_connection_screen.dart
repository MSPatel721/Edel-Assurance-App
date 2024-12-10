import 'package:flutter/material.dart';
import 'package:new_app/src/controllers/connectivity_controller.dart';
import 'package:new_app/src/views/connection/no_internet_screen.dart';
import 'package:new_app/src/views/home/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class CheckConnectionScreen extends StatelessWidget {
  const CheckConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityController>(
      builder: (context, provider, child) {
        if (provider.connectivityStatus == ConnectivityResult.none) {
          return const NoInternetScreen();
        } else {
          return const HomeScreen();
        }
      },
    );
  }
}
