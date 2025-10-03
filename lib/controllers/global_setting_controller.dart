import 'dart:developer';

import 'package:driver/constant/constant.dart';
import 'package:driver/models/currency_model.dart';
import 'package:driver/models/user_model.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/utils/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../constant/collection_name.dart';

class GlobalSettingController extends GetxController {
  @override
  void onInit() {
    notificationInit();
    getCurrentCurrency();

    super.onInit();
  }

  getCurrentCurrency() async {
    try {
      FireStoreUtils.fireStore.collection(CollectionName.currencies).where("isActive", isEqualTo: true).snapshots().listen((event) {
        if (event.docs.isNotEmpty) {
          Constant.currencyModel = CurrencyModel.fromJson(event.docs.first.data());
        } else {
          Constant.currencyModel = CurrencyModel(id: "", code: "USD", decimalDigits: 2, enable: true, name: "US Dollar", symbol: "\$", symbolAtRight: false);
        }
      });
      
      // Add timeout to getSettings
      await FireStoreUtils().getSettings().timeout(const Duration(seconds: 20), onTimeout: () {
        log("getSettings timeout in GlobalSettingController");
      });
    } catch (e) {
      log("Error in getCurrentCurrency: $e");
    }
  }

  NotificationService notificationService = NotificationService();

  notificationInit() {
    notificationService.initInfo().then((value) async {
      try {
        String token = await NotificationService.getToken();
        log(":::::::TOKEN:::::: $token");
        if (FirebaseAuth.instance.currentUser != null) {
          UserModel? userModel = await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid());
          if (userModel != null) {
            userModel.fcmToken = token;
            await FireStoreUtils.updateUser(userModel);
          }
        }
      } catch (e) {
        log("Error in notificationInit: $e");
      }
    }).catchError((error) {
      log("Error in notificationService.initInfo: $error");
    });
  }
}
