import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:new_app/src/constants/app_colors.dart';
import 'package:new_app/src/constants/app_strings.dart';
import 'package:new_app/src/constants/app_style.dart';
import 'package:new_app/src/controllers/connectivity_controller.dart';
import 'package:new_app/src/controllers/download_controller.dart';
import 'package:new_app/src/controllers/loading_controller.dart';
import 'package:new_app/src/services/notification_service.dart';
import 'package:new_app/src/widgets/app_box.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  final String url;
  const HomeScreen({super.key, this.url = ""});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String appLogo = "assets/icons/splash_logo.png";

  late InAppWebViewController webViewController;
  PullToRefreshController? pullToRefreshController;
  bool isOffline = false;
  bool showInitialLoader = true;   
  late Stream<ConnectivityResult> connectivityStream;
  bool isWebViewLoading = true;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          showInitialLoader = false;
        });
      }
    });

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationService.onTapNotification,
    );
    
    pullToRefreshController = PullToRefreshController(
      onRefresh: () {
        print("refresh");
        webViewController.reload();
        pullToRefreshController?.endRefreshing();
      },
      settings: PullToRefreshSettings(
        backgroundColor: AppColors.white,
        color: AppColors.primary,
      ),
    );
    _checkConnectivity();
  }
  
  Future<void> _checkConnectivity() async {
    final result = await (Connectivity().checkConnectivity());
    setState(() {
      isOffline = result == ConnectivityResult.none;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final provider = Provider.of<ConnectivityController>(context);
    // isOffline = provider.connectivityStatus == ConnectivityResult.none;
    print("isOffline******$isOffline");
    provider.addListener(() {
      // setState(() {
      //   isOffline = provider.connectivityStatus == ConnectivityResult.none;
      // });
      if(isOffline) {
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            isOffline = provider.connectivityStatus == ConnectivityResult.none;
          });
        },);
      } else {
        setState(() {
          isOffline = provider.connectivityStatus == ConnectivityResult.none;
        });
      }
    });
    print("isOffline******2$isOffline");
  }

  Future<String> getOneSignalUserId() async {
    var id = OneSignal.User.pushSubscription.id;
    return id ?? '';
  }

  Future<String> getDeviceInfo(BuildContext context) async {
    try {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      String osType;
      String osVersion;
      String deviceModel;
      String deviceId = await getOneSignalUserId();
      String screenWidth = MediaQuery.of(context).size.width.toString();
      String screenHeight = MediaQuery.of(context).size.height.toString();

      if (Theme.of(context).platform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        osType = 'iOS';
        osVersion = iosInfo.systemVersion;
        deviceModel = iosInfo.utsname.machine;
      } else if (Theme.of(context).platform == TargetPlatform.android) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        osType = 'Android';
        osVersion = androidInfo.version.release;
        deviceModel = androidInfo.model;
      } else {
        osType = 'unknown';
        osVersion = 'unknown';
        deviceModel = 'unknown';
      }

      final Map<String, String> dataDic = {
        'osType': osType,
        'osVersion': osVersion,
        'deviceModel': deviceModel,
        'appVersion': '1.0.0',
        'deviceId': deviceId,
        'screenWidth': screenWidth,
        'screenHeight': screenHeight,
      };

      print("Sending device info: $dataDic");
      return jsonEncode(dataDic);
    } catch (e) {
      print("Error getting device info: $e");
      return jsonEncode({'error': 'Failed to get device info'});
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        WebUri? url = await webViewController.getUrl();
        print("url====$url");
        if (url.toString() == "https://edelapp.accuratelogics.com/" ||
            url.toString() == "https://edelapp.accuratelogics.com/Account/Login") {
          return true;
        } else {
          if (await webViewController.canGoBack()) {
            webViewController.goBack();
            return false;
          } else {
            return true;
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          child: Stack(
            children: [
              _displayWebView(),
              if (isOffline)
                _noInternetConnection(),
              _loadingForDownloadFile(),
              if (showInitialLoader)
                  Container(
                    color: AppColors.white,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            appLogo,
                            height: 250,
                            width: 250,
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  _displayWebView() {
    return Container(
      color: AppColors.white,
      width: double.infinity,
      height: double.infinity,
      child: OverflowBox(
        maxWidth: MediaQuery.of(context).size.width + 0.5,
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri(widget.url.isNotEmpty 
              ? widget.url 
              : (Platform.isAndroid 
                  ? AppStrings.androidWebviewUrl 
                  : AppStrings.iosWebviewUrl)),
          ),
          pullToRefreshController: pullToRefreshController,
          onWebViewCreated: (controller) async {
            webViewController = controller;
            print("webviewcreated");
            controller.addJavaScriptHandler(
              handlerName: 'getDeviceInfo',
              callback: (args) async {
                print("JavaScript requested device info");
                final deviceInfo = await getDeviceInfo(context);
                print("Sending back device info: $deviceInfo");
                
                return deviceInfo;
              },
            );

            controller.addJavaScriptHandler(
              handlerName: 'shareHandler',
              callback: (args) {
                String sharedContent = args[0];
                print("Shared content received in Flutter: $sharedContent");

                _shareContent(sharedContent);
                return "Data received successfully in Flutter!";
              },
            );
          },
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              transparentBackground: true,
              javaScriptEnabled: true,

              useShouldOverrideUrlLoading: true,
              useOnLoadResource: true,
              javaScriptCanOpenWindowsAutomatically: true,
            ),
            android: AndroidInAppWebViewOptions(
              useHybridComposition: true,
              allowFileAccess: true,
              allowContentAccess: true,
            ),
            ios: IOSInAppWebViewOptions(
              allowsInlineMediaPlayback: true,
            ),
          ),
          initialSettings: InAppWebViewSettings(
            verticalScrollBarEnabled: false,
            horizontalScrollBarEnabled: false,
            underPageBackgroundColor: Colors.transparent,
            transparentBackground: true,
            javaScriptEnabled: true,

            useShouldOverrideUrlLoading: true,
            useOnLoadResource: true,
            javaScriptCanOpenWindowsAutomatically: true,
            useHybridComposition: true,
            allowsInlineMediaPlayback: true,
          ),
          onLoadStart: (controller, url) {
            print("url===${url}");
            if (context.read<LoadingController>().isFirstLoad) {
              context.read<LoadingController>().setLoading(true);
            }
          },
          onLoadStop: (controller, url) async {
            print("loaded : $url");
            pullToRefreshController?.endRefreshing();

            await controller.evaluateJavascript(source: """
              // Hook into the existing handleShare function
              (function() {
                const originalHandleShare = handleShare;
                window.handleShare = function() {
                  const content = shareWebviewContent();
                  // Call the original handleShare functionality (if needed)
                  originalHandleShare();
                  // Send the content to Flutter
                  window.flutter_inappwebview.callHandler('shareHandler', content);
                };
              })();
            """);

            final deviceInfo = await getDeviceInfo(context);
            await controller.evaluateJavascript(source: """
              if (window.getDataFromFlutter) {
                  const deviceInfo = $deviceInfo;
                  console.log('Device Info:', deviceInfo);
                  // Remove the alert call from here
                  window.getDataFromFlutter();
              }
            """);

            if (context.read<LoadingController>().isFirstLoad) {
              context.read<LoadingController>().stopFirstLoad();
            }

            context.read<LoadingController>().setLoading(false);
          },
          onConsoleMessage: (controller, consoleMessage) {
              print("consoleMessage==$consoleMessage");
          },

          androidOnPermissionRequest: (controller, origin, resources) async {
              return PermissionRequestResponse(
                  resources: resources,
                  action: PermissionRequestResponseAction.GRANT);
          },
          onJsAlert: (controller, jsAlertRequest) async {
            print("JavaScript alert: ${jsAlertRequest.message}");
            if (mounted) {
              await showDeviceInfoDialog(jsAlertRequest.message ?? "");
              return JsAlertResponse(handledByClient: true);
            }
            return JsAlertResponse(handledByClient: false);
          },
          onDownloadStartRequest: (controller, request) async {
            String url = request.url.toString();
            print("Downloading file from URL: $url");
            context.read<DownloadController>().startDownload(url);
          },
          onReceivedError: (controller, request, error) {
            if(error.toString() == "WebResourceError{description: net::ERR_NETWORK_CHANGED, type: UNKNOWN}") {
              webViewController.reload();
            } 
            if(error.toString() == "WebResourceError{description: net::ERR_INTERNET_DISCONNECTED, type: HOST_LOOKUP}") {
              context.read<LoadingController>().setLoading(true);
              webViewController.reload();
              setState(() {
                isOffline  = true;
              });
              context.read<LoadingController>().setLoading(false);
            }
            print("Error : $error");
        
          },
          shouldOverrideUrlLoading: (controller, request) async {
            String url = request.request.url.toString();
            if (url.endsWith('.pdf') ||
                url.endsWith('.docx') ||
                url.endsWith('.jpg')) {
              context.read<DownloadController>().startDownload(url);
              return NavigationActionPolicy.CANCEL;
            } else if (url.startsWith('http') || url.startsWith('https')) {
              return NavigationActionPolicy.ALLOW;
            } else if (url.startsWith('mailto:')) {
              final Uri launchUri = Uri.parse(url);
              if (await canLaunchUrl(launchUri)) {
                await launchUrl(launchUri);
              }
              return NavigationActionPolicy.CANCEL;
            } else if (url.startsWith('whatsapp://')) {
              final Uri launchUri = Uri.parse(url);
              final phoneNumber = launchUri.queryParameters['phone'];
              final message = launchUri.queryParameters['text'];
              if (phoneNumber != null && message != null) { 
                final newUrl = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
                final newLaunchUri = Uri.parse(newUrl);
                if (await canLaunchUrl(newLaunchUri)) {
                  await launchUrl(newLaunchUri);
                }
              }
              return NavigationActionPolicy.CANCEL;
            } else if (url.startsWith('tel:')) {
              final Uri launchUri = Uri.parse(url);
              if (await canLaunchUrl(launchUri)) {
                await launchUrl(launchUri);
              }
              return NavigationActionPolicy.CANCEL;
            } else {
              return NavigationActionPolicy.CANCEL;
            }
          },
        ),
      ),
    );
  }

  _loadingForDownloadFile() {
    return Consumer<DownloadController>(
      builder: (context, value, child) {
        if(value.isLoading) {
          return Container(
            color: Colors.black.withOpacity(0.5),
            width: double.infinity,
            height: double.infinity,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.white,
                strokeWidth: 2.0,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  _loadingLikeSplashScreen() {
    return Consumer<LoadingController>(
      builder: (context, value, child) {
        if(value.isLoading) {
          return Center(
            child: Image.asset(
              appLogo,
              height: 250,
              width: 250,
            ),
          );
        }
        return _displayWebView();
      },
    );
  }

  _noInternetConnection() {
    return Container(
      color: AppColors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/icons/no_internet_icon.png", height: 200,),
            AppBox.h12,
            Text("Oops! You're offline.\nCheck your connection and try again.", textAlign: TextAlign.center, style: AppStyles.customTextStyle(
              fontSize: 14,
            ),),
            AppBox.h16,
            GestureDetector(
              onTap: () async {
                setState(() {
                  isOffline = false;
                });
              },
              child: Text("Try Again", style: AppStyles.customTextStyle(color: AppColors.primary, fontWeight: FontWeight.w500,),)
            ),
          ],
        ),
      ),
    );
  }

  Future<void> flutterFunction(String data) async {
    print("Flutter function called with data: $data");
  }

  Future<void> showDeviceInfoDialog(String message) async {
    if (mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Device Information'),
            content: SingleChildScrollView(
              child: Text(message),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _shareContent(String content) async {
    await Share.share(content);
  }


  pickFileAndUpload() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;
      print("File path: $filePath");
    } else {
      print("No file selected");
    }
  }
}
