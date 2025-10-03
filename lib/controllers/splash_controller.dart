import 'dart:async';
import 'dart:developer';

import 'package:driver/app/auth_screen/login_screen.dart';
import 'package:driver/app/dash_board_screen/dash_board_screen.dart';
import 'package:driver/app/on_boarding_screen.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/models/user_model.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/utils/notification_service.dart';
import 'package:driver/utils/preferences.dart';
import 'package:driver/utils/app_logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    AppLogger.log('SplashController onInit() called', tag: 'Controller');
    Timer(const Duration(seconds: 3), () => redirectScreen());
    super.onInit();
  }

  @override
  void onClose() {
    AppLogger.log('SplashController onClose() called', tag: 'Controller');
    super.onClose();
  }

  redirectScreen() async {
    String fromScreen = 'SplashScreen';
    if (Preferences.getBoolean(Preferences.isFinishOnBoardingKey) == false) {
      log(' [32m$fromScreen -> OnBoardingScreen [0m');
      Get.offAll(const OnBoardingScreen());
    } else {
      bool isLogin = await FireStoreUtils.isLogin();
      if (isLogin == true) {
        await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then((value) async {
          if (value != null) {
            UserModel userModel = value;
            log(userModel.toJson().toString());
            if (userModel.role == Constant.userRoleDriver) {
              if (userModel.active == true) {
                userModel.fcmToken = await NotificationService.getToken();
                await FireStoreUtils.updateUser(userModel);
                log(' [32m$fromScreen -> DashBoardScreen [0m');
                Get.offAll(const DashBoardScreen());
              } else {
                await FirebaseAuth.instance.signOut();
                log(' [32m$fromScreen -> LoginScreen (inactive) [0m');
                Get.offAll(const LoginScreen());
              }
            } else {
              await FirebaseAuth.instance.signOut();
              log(' [32m$fromScreen -> LoginScreen (not driver) [0m');
              Get.offAll(const LoginScreen());
            }
          }
        });
      } else {
        await FirebaseAuth.instance.signOut();
        log(' [32m$fromScreen -> LoginScreen (not logged in) [0m');
        Get.offAll(const LoginScreen());
      }
    }
  }
}
