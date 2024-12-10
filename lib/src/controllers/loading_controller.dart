import 'package:flutter/material.dart';

class LoadingController with ChangeNotifier {
  bool _isLoading = true;
  bool isFirstLoad = true;

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void stopFirstLoad() {
    isFirstLoad = false;
    notifyListeners();
  }
}