import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

class DeviceDetailsService {
  Future<void> getDeviceDetails(BuildContext context) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? deviceDetails;

    try {
      if (Theme.of(context).platform == TargetPlatform.android) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        print("androidInfo====$androidInfo");
        deviceDetails = 'Android Device: ${androidInfo.model}, ${androidInfo.version.sdkInt}';
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        print("iosInfo====$iosInfo");
        deviceDetails = 'iOS Device: ${iosInfo.utsname.machine}, ${iosInfo.systemVersion}';
      }

      print("deviceDetails====$deviceDetails");
    } catch (e) {
      print('Error retrieving device details: $e');
    }
  }
}