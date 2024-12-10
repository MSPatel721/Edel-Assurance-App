import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:new_app/src/services/notification_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadController extends ChangeNotifier {
  double _progress = 0.0;

  bool isLoading = false;

  Future<void> startDownload(String url) async {
    // if (await _requestStoragePermission()) {
      isLoading = true;
      notifyListeners();
      print("Start downloading from URL: $url");

      final dio = Dio();

      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final originalFileName = url.split('/').last;
      final fileName =
          "${originalFileName.split('.').first}_$timestamp.${originalFileName.split('.').last}";
      String? filePath;

      try {
        if (Platform.isAndroid) {
          final downloadsDirectory = await getDownloadsDirectory();
          if (downloadsDirectory == null) {
            throw 'Could not find Downloads directory';
          }

          filePath = "${downloadsDirectory.path}/$fileName";
          final directory = Directory(downloadsDirectory.path);
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }
        } else if (Platform.isIOS) {
          final directory = await getApplicationDocumentsDirectory();
          filePath = "${directory.path}/$fileName";
        }
        if (filePath != null) {
          print('File path: $filePath');

          await dio.download(
            url,
            filePath,
            onReceiveProgress: (received, total) {
              if (total != -1) {
                _progress = (received / total);
                notifyListeners();
                int progressPercentage = (_progress * 100).toInt();
                notificationsService.showProgressNotification(0, progressPercentage);
              }
            },
            options: Options(
              responseType: ResponseType.bytes,
              followRedirects: true,
              validateStatus: (status) => status! < 500,
            ),
          );

          await AwesomeNotifications().cancel(0);
          Future.delayed(const Duration(seconds: 2), () {
            notificationsService.showCompletedNotification(0, fileName, filePath!);
          });
          _progress = 0.0;
          notifyListeners();
          print('File downloaded to: $filePath');
        } else {
          print("Error: filePath is null.");
        }
      } on DioError catch (e) {
        print("Error downloading file: $e");
      } catch (e) {}
      isLoading = false;
      notifyListeners();
    // } else {
    //   print("Permission Denied..!");
    // }
  }

  Future<Directory?> getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      return Directory('${directory!.path}/Download');
    }
    return null;
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (Platform.isAndroid &&
          (await Permission.manageExternalStorage.isGranted)) {
        return true;
      } else if (Platform.isAndroid &&
          await Permission.manageExternalStorage.request().isGranted) {
        return true;
      } else if (Platform.isAndroid &&
          await Permission.storage.request().isGranted) {
        return true;
      } else {
        return false;
      }
    } else if (Platform.isIOS) {
      return true;
    }
    return false;
  }

}