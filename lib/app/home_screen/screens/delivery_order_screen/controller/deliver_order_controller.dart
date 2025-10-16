import 'package:driver/constant/constant.dart';
import 'package:driver/constant/send_notification.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/models/order_model.dart';
import 'package:driver/services/audio_player_service.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeliverOrderController extends GetxController {
  RxBool isLoading = true.obs;
  RxBool conformPickup = false.obs;

  @override
  void onInit() {
    AppLogger.log('DeliverOrderController onInit() called', tag: 'Controller');
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  @override
  void onClose() {
    AppLogger.log('DeliverOrderController onClose() called', tag: 'Controller');
    super.onClose();
  }

  Rx<OrderModel> orderModel = OrderModel().obs;

  RxInt totalQuantity = 0.obs;

  getArgument() {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      orderModel.value = argumentData['orderModel'];
      for (var element in orderModel.value.products!) {
        totalQuantity.value += (element.quantity ?? 0);
      }
    }
    isLoading.value = false;
  }

  completedOrder() async {
    ShowToastDialog.showLoader("Please wait".tr);
    try {
      print("[DeliverOrderController] Playing sound");
      await AudioPlayerService.playSound(false);

      print("[DeliverOrderController] Setting status to completed");
      orderModel.value.status = Constant.orderCompleted;

      // Ensure driverID is set
      if (orderModel.value.driverID == null) {
        orderModel.value.driverID = Constant.userModel?.id;
        print("[DeliverOrderController] driverID was null, set to: ${orderModel.value.driverID}");
      }

      print("driverID: ${orderModel.value.driverID}");
      print("paymentMethod: ${orderModel.value.paymentMethod}");
      print("deliveryCharge: ${orderModel.value.deliveryCharge}");
      print("tipAmount: ${orderModel.value.tipAmount}");

      if (orderModel.value.driverID == null ||
          orderModel.value.paymentMethod == null ||
          orderModel.value.deliveryCharge == null ||
          orderModel.value.tipAmount == null) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Order data is incomplete. Cannot complete order.");
        return;
      }

      print("[DeliverOrderController] Updating wallet amount");
      // Fetch ToPay from order_Billing collection before wallet deduction
      try {
        final billingDoc = await FirebaseFirestore.instance
            .collection('order_Billing')
            .doc(orderModel.value.id)
            .get();

        final toPay = billingDoc.data()?['ToPay'];
        if (toPay == null) {
          print('[DeliverOrderController][ERROR] ToPay is null in order_Billing for order: ${orderModel.value.id}');
          ShowToastDialog.closeLoader();
          ShowToastDialog.showToast("Order billing info missing. Cannot complete order.");
          return;
        }
        orderModel.value.toPay = toPay.toString();
        print('[DeliverOrderController] Set ToPay from order_Billing: ${orderModel.value.toPay}');
      } catch (e) {
        print('[DeliverOrderController][ERROR] Failed to fetch ToPay from order_Billing: ${e}');
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Failed to fetch billing info. Cannot complete order.");
        return;
      }
      await FireStoreUtils.updateWallateAmount(orderModel.value);

      print("[DeliverOrderController] Setting order in Firestore");
      await FireStoreUtils.setOrder(orderModel.value);

      // Remove order from other drivers' orderRequestData
      await FireStoreUtils.removeOrderFromOtherDrivers(
        orderId: orderModel.value.id!,
        assignedDriverId: orderModel.value.driverID!,
      );

      if (Constant.userModel?.vendorID?.isNotEmpty == true) {
        print("[DeliverOrderController] Removing order from user lists");
        Constant.userModel?.orderRequestData?.remove(orderModel.value.id);
        Constant.userModel?.inProgressOrderID?.remove(orderModel.value.id);
        await FireStoreUtils.updateUser(Constant.userModel!);
      }

      print("[DeliverOrderController] Checking if first order");
      await FireStoreUtils.getFirestOrderOrNOt(orderModel.value)
          .then((value) async {
        if (value == true) {
          print("[DeliverOrderController] Updating referral amount");
          await FireStoreUtils.updateReferralAmount(orderModel.value);
        }
      });

      print("[DeliverOrderController] Sending notification to customer");
      if (orderModel.value.author?.fcmToken != null) {
        await SendNotification.sendFcmMessage(
          Constant.driverCompleted,
          orderModel.value.author!.fcmToken.toString(),
          {},
        );
      }

      ShowToastDialog.closeLoader();
      print("[DeliverOrderController] Order completed, closing loader and going back");
      Get.back(result: true);
    } catch (e) {
      print("[DeliverOrderController] Error in completedOrder: $e");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Failed to complete order");
    }
  }
  // completedOrder() async {
  //   ShowToastDialog.showLoader("Please wait".tr);
  //   await AudioPlayerService.playSound(false);
  //   orderModel.value.status = Constant.orderCompleted;
  //   await FireStoreUtils.updateWallateAmount(orderModel.value);
  //   await FireStoreUtils.setOrder(orderModel.value);
  //   if (Constant.userModel?.vendorID?.isNotEmpty == true) {
  //     Constant.userModel?.orderRequestData?.remove(orderModel.value.id);
  //     Constant.userModel?.inProgressOrderID?.remove(orderModel.value.id);
  //     await FireStoreUtils.updateUser(Constant.userModel!);
  //   }
  //   await FireStoreUtils.getFirestOrderOrNOt(orderModel.value)
  //       .then((value) async {
  //     if (value == true) {
  //       await FireStoreUtils.updateReferralAmount(orderModel.value);
  //     }
  //   });
  //
  //   await SendNotification.sendFcmMessage(Constant.driverCompleted,
  //       orderModel.value.author!.fcmToken.toString(), {});
  //   ShowToastDialog.closeLoader();
  //   Get.back(result: true);
  // }
}
