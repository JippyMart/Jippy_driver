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
    try {
      if (Preferences.getBoolean(Preferences.isFinishOnBoardingKey) == false) {
        log(' [32m$fromScreen -> OnBoardingScreen [0m');
        Get.offAll(const OnBoardingScreen());
      } else {
        log(' [32m$fromScreen -> Checking login status... [0m');
        bool isLogin = await FireStoreUtils.isLogin();
        log(' [32m$fromScreen -> Login status: $isLogin [0m');
        
        if (isLogin == true) {
          log(' [32m$fromScreen -> Getting user profile... [0m');
          UserModel? userModel = await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid());
          
          if (userModel != null) {
            log(' [32m$fromScreen -> User profile loaded: ${userModel.toJson().toString()} [0m');
            if (userModel.role == Constant.userRoleDriver) {
              if (userModel.active == true) {
                log(' [32m$fromScreen -> Getting FCM token... [0m');
                userModel.fcmToken = await NotificationService.getToken();
                log(' [32m$fromScreen -> Updating user with FCM token... [0m');
                await FireStoreUtils.updateUser(userModel);
                log(' [32m$fromScreen -> DashBoardScreen [0m');
                Get.offAll(const DashBoardScreen());
              } else {
                log(' [32m$fromScreen -> User inactive, signing out... [0m');
                await FirebaseAuth.instance.signOut();
                log(' [32m$fromScreen -> LoginScreen (inactive) [0m');
                Get.offAll(const LoginScreen());
              }
            } else {
              log(' [32m$fromScreen -> User not a driver, signing out... [0m');
              await FirebaseAuth.instance.signOut();
              log(' [32m$fromScreen -> LoginScreen (not driver) [0m');
              Get.offAll(const LoginScreen());
            }
          } else {
            log(' [32m$fromScreen -> User profile null, signing out... [0m');
            await FirebaseAuth.instance.signOut();
            log(' [32m$fromScreen -> LoginScreen (no profile) [0m');
            Get.offAll(const LoginScreen());
          }
        } else {
          log(' [32m$fromScreen -> Not logged in, signing out... [0m');
          await FirebaseAuth.instance.signOut();
          log(' [32m$fromScreen -> LoginScreen (not logged in) [0m');
          Get.offAll(const LoginScreen());
        }
      }
    } catch (e) {
      log(' [31m$fromScreen -> Error in redirectScreen: $e [0m');
      // Fallback to login screen on any error
      try {
        await FirebaseAuth.instance.signOut();
      } catch (signOutError) {
        log(' [31m$fromScreen -> Error signing out: $signOutError [0m');
      }
      log(' [32m$fromScreen -> LoginScreen (error fallback) [0m');
      Get.offAll(const LoginScreen());
    }
  }
}
