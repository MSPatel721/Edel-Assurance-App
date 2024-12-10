import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityController with ChangeNotifier {
  ConnectivityResult _connectivityStatus = ConnectivityResult.none;
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  ConnectivityController() {
    _subscription = Connectivity().onConnectivityChanged
        .distinct((previous, next) => _areListsEqual(previous, next))
        .listen(_updateStatus);
  }

  ConnectivityResult get connectivityStatus => _connectivityStatus;

  void _updateStatus(List<ConnectivityResult> resultList) {
    if (resultList.isNotEmpty) {
      final newStatus = resultList[0];

      if (_connectivityStatus != newStatus) {
        _connectivityStatus = newStatus;
        notifyListeners();
      }
    }
  }

  bool _areListsEqual(List<ConnectivityResult> a, List<ConnectivityResult> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
