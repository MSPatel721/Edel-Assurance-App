import 'package:flutter/material.dart';
import 'package:new_app/src/controllers/splash_controller.dart';
import 'package:new_app/src/views/home/home_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final splashController = Provider.of<SplashController>(context);
    const String appLogo = "assets/icons/splash_logo.png";

    if (splashController.isNavigating) {
      Future.microtask(() {
        Navigator.of(context).pushReplacement(
          PageTransition(
            child: const HomeScreen(),
            type: PageTransitionType.rightToLeft,
          ),
        );
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Image.asset(
            appLogo,
            height: 250,
            width: 250,
          ),
        ),
      ),
    );
  }
}
