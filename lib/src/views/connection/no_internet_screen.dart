import 'package:flutter/material.dart';
import 'package:new_app/src/constants/app_colors.dart';
import 'package:new_app/src/constants/app_style.dart';
import 'package:new_app/src/widgets/app_box.dart';

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({super.key});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
              onTap: () async {},
              child: Text("Try Again", style: AppStyles.customTextStyle(color: AppColors.primary, fontWeight: FontWeight.w500,),)
            ),
          ],
        ),
      ),
    );
  }
}