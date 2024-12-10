import 'package:flutter/material.dart';

class SplashController with ChangeNotifier {
  bool _isNavigating = false;

  SplashController() {
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    _isNavigating = true;
    notifyListeners();
  }

  bool get isNavigating => _isNavigating;
}
