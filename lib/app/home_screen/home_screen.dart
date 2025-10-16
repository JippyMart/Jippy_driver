
import 'dart:developer';
import 'package:android_pip/android_pip.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/app/chat_screens/chat_screen.dart';
import 'package:driver/app/home_screen/screens/delivery_order_screen/deliver_order_screen.dart';
import 'package:driver/app/home_screen/screens/pickup_order_screen/pickup_order_screen.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controllers/dash_board_controller.dart';
import 'package:driver/app/home_screen/controller/home_controller.dart';
import 'package:driver/main.dart';
import 'package:driver/models/order_model.dart';
import 'package:driver/models/user_model.dart';
import 'package:driver/services/audio_player_service.dart';
import 'package:driver/themes/app_them_data.dart';
import 'package:driver/themes/responsive.dart';
import 'package:driver/themes/round_button_fill.dart';
import 'package:driver/utils/app_logger.dart';
import 'package:driver/utils/dark_theme_provider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/utils/utils.dart';
import 'package:driver/widget/my_separator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutterMap;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as location;
import 'package:provider/provider.dart';
import 'package:timelines_plus/timelines_plus.dart';
import '../order_list_screen/order_details_screen.dart';


final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class HomeScreen extends StatelessWidget {
  final bool? isAppBarShow;
  const HomeScreen({super.key, this.isAppBarShow});
  @override
  Widget build(BuildContext context) {

    final themeChange = Provider.of<DarkThemeProvider>(context);
    AppLogger.log('HomeScreen build() called', tag: 'Screen');
    return GetX(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          appBar: isAppBarShow == true
              ? AppBar(
                  backgroundColor: themeChange.getThem()
                      ? AppThemeData.grey900
                      : AppThemeData.grey50,
                  centerTitle: false,
                  iconTheme: const IconThemeData(
                      color: AppThemeData.grey900, size: 20),
                  title: Text(
                    "Order".tr,
                    style: TextStyle(
                        color: themeChange.getThem()
                            ? AppThemeData.grey50
                            : AppThemeData.grey900,
                        fontSize: 18,
                        fontFamily: AppThemeData.medium),
                  ),
                )
              : null,
          body: controller.isLoading.value
              ? Constant.loader()
              : Constant.userModel?.vendorID?.isEmpty == true &&
                      Constant.isDriverVerification == true &&
                      Constant.userModel!.isDocumentVerify == false
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: ShapeDecoration(
                              color: themeChange.getThem()
                                  ? AppThemeData.grey700
                                  : AppThemeData.grey200,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(120),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: SvgPicture.asset(
                                  "assets/icons/ic_document.svg"),
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Text(
                            "Document Verification in Pending".tr,
                            style: TextStyle(
                                color: themeChange.getThem()
                                    ? AppThemeData.grey100
                                    : AppThemeData.grey800,
                                fontSize: 22,
                                fontFamily: AppThemeData.semiBold),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Your documents are being reviewed. We will notify you once the verification is complete."
                                .tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: themeChange.getThem()
                                    ? AppThemeData.grey50
                                    : AppThemeData.grey500,
                                fontSize: 16,
                                fontFamily: AppThemeData.bold,),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          RoundedButtonFill(
                            title: "View Status".tr,
                            width: 55,
                            height: 5.5,
                            color: AppThemeData.secondary300,
                            textColor: AppThemeData.grey50,
                            onPress: () async {
                              DashBoardController dashBoardController =
                                  Get.put(DashBoardController());
                              dashBoardController.drawerIndex.value = 4;
                            },
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Constant.userModel?.vendorID?.isEmpty == true &&
                                double.parse(
                                        Constant.userModel!.walletAmount == null
                                            ? "0.0"
                                            : Constant.userModel!.walletAmount
                                                .toString()) <
                                    double.parse(
                                        Constant.minimumDepositToRideAccept)
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "${'You have to minimum'.tr} ${Constant.amountShow(amount: Constant.minimumDepositToRideAccept.toString())} ${'wallet amount to receiving Order'.tr}",
                                  style: TextStyle(
                                      color: themeChange.getThem()
                                          ? AppThemeData.grey50
                                          : AppThemeData.grey900,
                                      fontSize: 14,
                                      fontFamily: AppThemeData.semiBold),
                                ),
                              )
                            : const SizedBox(),
                        Expanded(
                          child: Constant.mapType == "inappmap"
                              ? Constant.selectedMapType == "osm"
                                  ? Obx(() => flutterMap.FlutterMap(
                                        mapController:
                                            controller.osmMapController,
                                        options: flutterMap.MapOptions(
                                          initialCenter: location.LatLng(
                                              // Constant.locationDataFinal
                                              //         ?.latitude ??
                                              //     0.0,
                                              // Constant.locationDataFinal
                                              //         ?.longitude ??
                                              //     0.0
                                              controller.driverModel.value
                                                      .location?.latitude ??
                                                  0.0,
                                              controller.driverModel.value
                                                      .location?.longitude ??
                                                  0.0),
                                          initialZoom: 12,
                                        ),
                                        children: [
                                          flutterMap.TileLayer(
                                            urlTemplate:
                                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                            userAgentPackageName:
                                                'com.example.app',
                                          ),
                                          flutterMap.MarkerLayer(
                                              markers: controller.currentOrder
                                                          .value.id ==
                                                      null
                                                  ? []
                                                  : controller.osmMarkers),
                                          if (controller
                                                  .routePoints.isNotEmpty &&
                                              controller
                                                      .currentOrder.value.id !=
                                                  null)
                                            flutterMap.PolylineLayer(
                                              polylines: [
                                                flutterMap.Polyline(
                                                  points:
                                                      controller.routePoints,
                                                  strokeWidth: 7.0,
                                                  color:
                                                      AppThemeData.secondary300,
                                                ),
                                              ],
                                            ),
                                        ],
                                      ))
                                  : GoogleMap(
                                      onMapCreated: (mapController) {
                                        controller.mapController =
                                            mapController;
                                        controller.mapController!.animateCamera(
                                          CameraUpdate.newCameraPosition(
                                            CameraPosition(
                                                target: LatLng(
                                                    Constant.locationDataFinal
                                                            ?.latitude ??
                                                        0.0,
                                                    Constant.locationDataFinal
                                                            ?.longitude ??
                                                        0.0),
                                                zoom: 15,
                                                bearing: double.parse(
                                                    '${controller.driverModel.value.rotation ?? '0.0'}')),
                                          ),
                                        );
                                      },
                                      myLocationEnabled:
                                          controller.currentOrder.value.id !=
                                                      null &&
                                                  controller.currentOrder.value
                                                          .status ==
                                                      Constant.driverPending
                                              ? false
                                              : true,
                                      myLocationButtonEnabled: true,
                                      mapType: MapType.normal,
                                      zoomControlsEnabled: true,
                                      polylines: Set<Polyline>.of(
                                          controller.polyLines.values),
                                      markers:
                                          controller.markers.values.toSet(),
                                      initialCameraPosition: CameraPosition(
                                        zoom: 15,
                                        target: LatLng(
                                            controller.driverModel.value
                                                    .location?.latitude ??
                                                0.0,
                                            controller.driverModel.value
                                                    .location?.longitude ??
                                                0.0),
                                      ),
                                    )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                          "assets/images/ic_location_map.svg"),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "${'Navigate with'.tr} ${Constant.mapType == "google" ? "Google Map" : Constant.mapType == "googleGo" ? "Google Go" : Constant.mapType == "waze" ? "Waze Map" : Constant.mapType == "mapswithme" ? "MapsWithMe Map" : Constant.mapType == "yandexNavi" ? "VandexNavi Map" : Constant.mapType == "yandexMaps" ? "Vandex Map" : ""}",
                                        style: TextStyle(
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey50
                                                : AppThemeData.grey900,
                                            fontSize: 22,
                                            fontFamily: AppThemeData.semiBold),
                                      ),
                                      Text(
                                        "${'Easily find your destination with a single tap redirect to'.tr}  ${Constant.mapType == "google" ? "Google Map" : Constant.mapType == "googleGo" ? "Google Go" : Constant.mapType == "waze" ? "Waze Map" : Constant.mapType == "mapswithme" ? "MapsWithMe Map" : Constant.mapType == "yandexNavi" ? "VandexNavi Map" : Constant.mapType == "yandexMaps" ? "Vandex Map" : ""} ${'for seamless navigation.'.tr}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey50
                                                : AppThemeData.grey900,
                                            fontSize: 16,
                                            fontFamily: AppThemeData.regular),
                                      ),
                                      const SizedBox(
                                        height: 30,
                                      ),
                                      RoundedButtonFill(
                                        title:
                                            "${'Redirect'} ${Constant.mapType == "google" ? "Google Map" : Constant.mapType == "googleGo" ? "Google Go" : Constant.mapType == "waze" ? "Waze Map" : Constant.mapType == "mapswithme" ? "MapsWithMe Map" : Constant.mapType == "yandexNavi" ? "VandexNavi Map" : Constant.mapType == "yandexMaps" ? "Vandex Map" : ""}"
                                                .tr,
                                        width: 55,
                                        height: 5.5,
                                        color: AppThemeData.driverApp300,
                                        textColor: AppThemeData.grey50,
                                        onPress: () async {
                                          if (controller
                                                  .currentOrder.value.id !=
                                              null) {
                                            if (controller.currentOrder.value
                                                    .status !=
                                                Constant.driverPending) {
                                              if (controller.currentOrder.value
                                                      .status ==
                                                  Constant.orderShipped) {
                                                Utils.redirectMap(
                                                    name: controller
                                                        .currentOrder
                                                        .value
                                                        .vendor!
                                                        .title
                                                        .toString(),
                                                    latitude: controller
                                                            .currentOrder
                                                            .value
                                                            .vendor!
                                                            .latitude ??
                                                        0.0,
                                                    longLatitude: controller
                                                            .currentOrder
                                                            .value
                                                            .vendor!
                                                            .longitude ??
                                                        0.0);
                                              } else if (controller.currentOrder
                                                      .value.status ==
                                                  Constant.orderInTransit) {
                                                Utils.redirectMap(
                                                    name: controller
                                                        .currentOrder
                                                        .value
                                                        .author!
                                                        .firstName
                                                        .toString(),
                                                    latitude: controller
                                                            .currentOrder
                                                            .value
                                                            .address!
                                                            .location!
                                                            .latitude ??
                                                        0.0,
                                                    longLatitude: controller
                                                            .currentOrder
                                                            .value
                                                            .address!
                                                            .location!
                                                            .longitude ??
                                                        0.0);
                                              }
                                            } else {
                                              Utils.redirectMap(
                                                  name: controller.currentOrder
                                                      .value.author!.firstName
                                                      .toString(),
                                                  latitude: controller
                                                          .currentOrder
                                                          .value
                                                          .vendor!
                                                          .latitude ??
                                                      0.0,
                                                  longLatitude: controller
                                                          .currentOrder
                                                          .value
                                                          .vendor!
                                                          .longitude ??
                                                      0.0);
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                        // (controller.currentOrder.value.id != null &&
                        //     controller.currentOrder.value.status ==
                        //         Constant.driverPending &&
                        //     (controller.currentOrder.value.driverID ==
                        //             null ||
                        //         controller.currentOrder.value.driverID
                        //                 ?.isEmpty ==
                        //             true))
                        //     ? showDriverBottomSheet(themeChange, controller)
                        //     : (controller.currentOrder.value.id != null &&
                        //         controller.currentOrder.value.status !=
                        //             Constant.driverPending &&
                        //         controller.currentOrder.value.driverID ==
                        //             Constant.userModel?.id)
                        //         ? (() {
                        //             AppLogger.log(
                        //                 'Showing buildOrderActionsCard: currentDriverId=${Constant.userModel?.id}, orderDriverId=${controller.currentOrder.value.driverID}',
                        //                 tag: 'UI');
                        //             return buildOrderActionsCard(
                        //                 themeChange, controller);
                        //           })()
                        //         : (() {
                        //             // No active order: clear the map and show a message
                        //             controller.clearMap();
                        //             return Center(
                        //               child: Text(
                        //                 'No active orders. Waiting for new orders...',
                        //                 style: TextStyle(
                        //                     fontSize: 18, color: Colors.grey),
                        //               ),
                        //             );
                        //           })(),
Obx(
  () {
    bool hideUI = isInPipMode.value;
    return    hideUI?SizedBox():  (controller.currentOrder.value.id != null &&
        controller.currentOrder.value.status ==
            Constant.driverPending &&
        (controller.currentOrder.value.driverID ==
            null ||
            controller.currentOrder.value.driverID
                ?.isEmpty ==
                true))
        ? showDriverBottomSheet(themeChange, controller)
        : (controller.currentOrder.value.id != null &&
        controller.currentOrder.value.status !=
            Constant.driverPending &&
        controller.currentOrder.value.driverID ==
            Constant.userModel?.id)
        ? (() {
      AppLogger.log(
          'Showing buildOrderActionsCard: currentDriverId=${Constant.userModel?.id}, orderDriverId=${controller.currentOrder.value.driverID}',
          tag: 'UI');
      return buildOrderActionsCard(
          themeChange, controller);
    })()
        : (() {
      /// Clear the map ONLY if the current driver is NOT assigned
      if (controller
          .currentOrder.value.driverID !=
          Constant.userModel?.id) {
        controller.clearMap();
      }
      return SafeArea(
        child: Center(
          // child: Text(
          //   'No active orders. Waiting for new orders...',
          //   style: TextStyle(
          //       fontSize: 18, color: Colors.grey),
          // ),
        ),
      );
    })();
  }
),

                        // Obx(() {
                        //   if (controller.currentOrder.value.id == null) {
                        //     return Container(); // No active order
                        //   } else if (controller.currentOrder.value.status ==
                        //       Constant.driverPending) {
                        //     return showDriverBottomSheet(
                        //         themeChange, controller);
                        //   } else if (controller.currentOrder.value.status ==
                        //       Constant.orderShipped) {
                        //     // Don't show PickupOrderScreen inline - let the button handle navigation
                        //     return Container();
                        //   } else if (controller.currentOrder.value.status ==
                        //       Constant.orderInTransit) {
                        //     return DeliverOrderScreen();
                        //   }
                        //   else if (controller.currentOrder.value.status ==
                        //       Constant.orderCompleted) {
                        //     return Center(child: Text('Order Completed'));
                        //   }
                        //   else {
                        //     // Don't show buildOrderActionsCard inline to prevent overflow
                        //     // The bottom navigation bar will handle the actions
                        //     return Container();
                        //   }
                        // }),
                      ],
                    ),

          // bottomNavigationBar: Obx(() {
          //   // Show button for all active orders except pending and completed
          //   if (controller.currentOrder.value.id == null ||
          //       controller.currentOrder.value.status ==
          //           Constant.driverPending ||
          //       controller.currentOrder.value.status ==
          //           Constant.orderCompleted ||
          //       controller.currentOrder.value.status ==
          //           Constant.driverRejected) {
          //     return SizedBox.shrink();
          //   }
          //
          //   String buttonText;
          //   VoidCallback? onTap;
          //
          //   if (controller.currentOrder.value.status == Constant.orderShipped ||
          //       controller.currentOrder.value.status ==
          //           Constant.driverAccepted) {
          //     buttonText = "Reached restaurant for Pickup".tr;
          //     onTap = () {
          //       Get.to(const PickupOrderScreen(), arguments: {
          //         "orderModel": controller.currentOrder.value
          //       })?.then((v) async {
          //         if (v == true) {
          //           OrderModel? ordermodel = await FireStoreUtils.getOrderById(
          //               controller.currentOrder.value.id!);
          //           if (ordermodel?.id != null) {
          //             controller.currentOrder.value = ordermodel!;
          //           }
          //           controller.update();
          //         }
          //       });
          //     };
          //   } else if (controller.currentOrder.value.status ==
          //       Constant.orderInTransit) {
          //     buttonText =
          //         controller.driverModel.value.vendorID?.isEmpty == true
          //             ? "Reached the Customers Door Steps".tr
          //             : "Order Delivered".tr;
          //     onTap = () {
          //       Get.to(const DeliverOrderScreen(), arguments: {
          //         "orderModel": controller.currentOrder.value
          //       })?.then((value) async {
          //         if (value == true) {
          //           await AudioPlayerService.playSound(false);
          //           controller.driverModel.value.inProgressOrderID!
          //               .remove(controller.currentOrder.value.id);
          //           await FireStoreUtils.updateUser(
          //               controller.driverModel.value);
          //           controller.currentOrder.value = OrderModel();
          //           controller.clearMap();
          //           if (Constant.singleOrderReceive == false) {
          //             Get.back();
          //           }
          //         }
          //       });
          //     };
          //   } else {
          //     // For any other status, show a generic action button
          //     buttonText = "View Order Details".tr;
          //     onTap = () {
          //       // Show order details or handle other statuses
          //       Get.snackbar(
          //         "Order Status",
          //         "Current status: ${controller.currentOrder.value.status}",
          //         snackPosition: SnackPosition.BOTTOM,
          //         duration: Duration(seconds: 3),
          //       );
          //     };
          //   }
          //   return InkWell(
          //     onTap: onTap,
          //     child: Container(
          //       color: AppThemeData.driverApp300,
          //       width: Responsive.width(100, Get.context ?? context),
          //       child: Padding(
          //         padding: const EdgeInsets.symmetric(vertical: 16),
          //         child: Text(
          //           buttonText,
          //           textAlign: TextAlign.center,
          //           style: TextStyle(
          //             color: themeChange.getThem()
          //                 ? AppThemeData.grey900
          //                 : AppThemeData.grey900,
          //             fontSize: 16,
          //             fontFamily: AppThemeData.semiBold,
          //             fontWeight: FontWeight.w400,
          //           ),
          //         ),
          //       ),
          //     ),
          //   );
          // }),
          // bottomNavigationBar: Obx(() {
          //   if (controller.currentOrder.value.id == null) {
          //     return SizedBox.shrink();
          //   }
          //   String buttonText;
          //   VoidCallback? onTap;
          //   if (controller.currentOrder.value.status == Constant.orderShipped ||
          //       controller.currentOrder.value.status == Constant.driverAccepted) {
          //     buttonText = "Reached restaurant for Pickup".tr;
          //     onTap = () {
          //       Get.to(const PickupOrderScreen(), arguments: {
          //         "orderModel": controller.currentOrder.value
          //       })?.then((v) async {
          //         if (v == true) {
          //           OrderModel? ordermodel = await FireStoreUtils.getOrderById(
          //               controller.currentOrder.value.id!);
          //           if (ordermodel?.id != null) {
          //             controller.currentOrder.value = ordermodel!;
          //           }
          //           controller.update();
          //         }
          //       });
          //     };
          //   } else {
          //     buttonText = controller.driverModel.value.vendorID?.isEmpty == true
          //         ? "Reached the Customers Door Steps".tr
          //         : "Order Delivered".tr;
          //     onTap = () {
          //       Get.to(const DeliverOrderScreen(), arguments: {
          //         "orderModel": controller.currentOrder.value
          //       })?.then((value) async {
          //         if (value == true) {
          //           await AudioPlayerService.playSound(false);
          //           controller.driverModel.value.inProgressOrderID!
          //               .remove(controller.currentOrder.value.id);
          //           await FireStoreUtils.updateUser(
          //               controller.driverModel.value);
          //           controller.currentOrder.value = OrderModel();
          //           controller.clearMap();
          //           if (Constant.singleOrderReceive == false) {
          //             Get.back();
          //           }
          //         }
          //       });
          //     };
          //   }
          //   return InkWell(
          //     onTap: onTap,
          //     child: Container(
          //       color: AppThemeData.driverApp300,
          //       width: Responsive.width(100, Get.context ?? context),
          //       child: Padding(
          //         padding: const EdgeInsets.symmetric(vertical: 16),
          //         child: Text(
          //           buttonText,
          //           textAlign: TextAlign.center,
          //           style: TextStyle(
          //             color: themeChange.getThem()
          //                 ? AppThemeData.grey900
          //                 : AppThemeData.grey900,
          //             fontSize: 16,
          //             fontFamily: AppThemeData.semiBold,
          //             fontWeight: FontWeight.w400,
          //           ),
          //         ),
          //       ),
          //     ),
          //   );
          // }),
        );
      },
    );
  }

// Helper method to get calculated charges
  Future<Map<String, dynamic>?> _getCalculatedCharges(HomeController controller) async {
    if (controller.currentOrder.value.calculatedCharges != null) {
      return controller.currentOrder.value.calculatedCharges;
    }

    // If not in local model, try to fetch from Firestore
    try {
      final orderDoc = await FirebaseFirestore.instance
          .collection('restaurant_orders')
          .doc(controller.currentOrder.value.id)
          .get();

      if (orderDoc.exists && orderDoc.data()?['calculatedCharges'] != null) {
        return Map<String, dynamic>.from(orderDoc.data()!['calculatedCharges']);
      }
    } catch (e) {
      print('Error fetching calculated charges: $e');
    }

    return null;
  }

// Helper widget for charge breakdown rows
  Widget _buildChargeBreakdownRow(String label, String distance, String amount, DarkThemeProvider themeChange) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: themeChange.getThem()
            ? AppThemeData.grey800
            : AppThemeData.grey100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppThemeData.regular,
                fontSize: 14,
                color: themeChange.getThem()
                    ? AppThemeData.grey300
                    : AppThemeData.grey700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              distance,
              style: TextStyle(
                fontFamily: AppThemeData.medium,
                fontSize: 14,
                color: themeChange.getThem()
                    ? AppThemeData.grey300
                    : AppThemeData.grey700,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              amount,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: AppThemeData.semiBold,
                fontSize: 14,
                color: AppThemeData.success400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  showDriverBottomSheet(themeChange, HomeController controller) {
    double distanceInMeters = Geolocator.distanceBetween(
        controller.currentOrder.value.vendor!.latitude ?? 0.0,
        controller.currentOrder.value.vendor!.longitude ?? 0.0,
        controller.currentOrder.value.address!.location!.latitude ?? 0.0,
        controller.currentOrder.value.address!.location!.longitude ?? 0.0);
    double kilometer = distanceInMeters / 1000;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: ShapeDecoration(
          color: themeChange.getThem()
              ? AppThemeData.grey900
              : AppThemeData.grey50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Timeline.tileBuilder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                theme: TimelineThemeData(
                  nodePosition: 0,
                ),
                builder: TimelineTileBuilder.connected(
                  contentsAlign: ContentsAlign.basic,
                  indicatorBuilder: (context, index) {
                    return index == 0
                        ? Container(
                            decoration: ShapeDecoration(
                              color: AppThemeData.primary50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(120),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: SvgPicture.asset(
                                "assets/icons/ic_building.svg",
                                colorFilter: const ColorFilter.mode(
                                    AppThemeData.primary300, BlendMode.srcIn),
                              ),
                            ),
                          )
                        : Container(
                            decoration: ShapeDecoration(
                              color: AppThemeData.driverApp50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(120),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: SvgPicture.asset(
                                "assets/icons/ic_location.svg",
                                colorFilter: ColorFilter.mode(
                                    AppThemeData.driverApp300, BlendMode.srcIn),
                              ),
                            ),
                          );
                  },
                  connectorBuilder: (context, index, connectorType) {
                    return const DashedLineConnector(
                      color: AppThemeData.grey300,
                      gap: 3,
                    );
                  },
                  contentsBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: index == 0
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${controller.currentOrder.value.vendor!.title}",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontFamily: AppThemeData.semiBold,
                                    fontSize: 16,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey50
                                        : AppThemeData.grey900,
                                  ),
                                ),
                                Text(
                                  "${controller.currentOrder.value.vendor!.location}",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontFamily: AppThemeData.medium,
                                    fontSize: 14,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey300
                                        : AppThemeData.grey600,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Deliver to the".tr,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontFamily: AppThemeData.semiBold,
                                    fontSize: 16,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey50
                                        : AppThemeData.grey900,
                                  ),
                                ),
                                Text(
                                  controller.currentOrder.value.address!
                                      .getFullAddress(),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontFamily: AppThemeData.medium,
                                    fontSize: 14,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey300
                                        : AppThemeData.grey600,
                                  ),
                                ),
                              ],
                            ),
                    );
                  },
                  itemCount: 2,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: MySeparator(
                    color: themeChange.getThem()
                        ? AppThemeData.grey700
                        : AppThemeData.grey200),
              ),

              // Surge Fee Section - Made More Prominent
              FutureBuilder<double?>(
                future: fetchOrderSergeFee(
                    controller.currentOrder.value.id.toString()),
                builder: (context, snapshot) {
                  final surgeFee = snapshot.data ?? 0.0;
                  final hasSurge = surgeFee > 0;
              // FutureBuilder<Map<String, dynamic>?>(
              //   future: _getCalculatedCharges(controller),
              //   builder: (context, snapshot) {
              //     final charges = snapshot.data;
              //     final hasCalculatedCharges = charges != null;
                  return Column(
                    children: [
                      // Surge Fee Badge - Only show when there's surge
                      // if (hasSurge)
                      //   Container(
                      //     width: double.infinity,
                      //     padding: const EdgeInsets.symmetric(
                      //         vertical: 8, horizontal: 12),
                      //     margin: const EdgeInsets.only(bottom: 10),
                      //     decoration: BoxDecoration(
                      //       // color: AppThemeData.warning50.withOpacity(0.2),
                      //       color: Color(0xffff5200),
                      //       border: Border.all(
                      //         color: AppThemeData.warning300,
                      //         width: 1,
                      //       ),
                      //       borderRadius: BorderRadius.circular(8),
                      //     ),
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         Icon(
                      //           Icons.bolt_rounded,
                      //           color: AppThemeData.warning500,
                      //           size: 18,
                      //         ),
                      //         const SizedBox(width: 6),
                      //         Text(
                      //           "High Demand Area".tr,
                      //           style: TextStyle(
                      //             fontFamily: AppThemeData.semiBold,
                      //             fontSize: 14,
                      //             color: AppThemeData.warning600,
                      //           ),
                      //         ),
                      //         const SizedBox(width: 6),
                      //         Text(
                      //           "+${surgeFee.toStringAsFixed(2)}",
                      //           style: TextStyle(
                      //             fontFamily: AppThemeData.bold,
                      //             fontSize: 14,
                      //             color: AppThemeData.warning600,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),

                      // Trip Distance
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              "Trip Distance".tr,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontFamily: AppThemeData.regular,
                                color: themeChange.getThem()
                                    ? AppThemeData.grey300
                                    : AppThemeData.grey600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            "${double.parse(kilometer.toString()).toStringAsFixed(2)} ${Constant.distanceType}",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: AppThemeData.semiBold,
                              color: themeChange.getThem()
                                  ? AppThemeData.grey50
                                  : AppThemeData.grey900,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),

                      // NEW: Restaurant to Customer Charge

                      // const SizedBox(height: 8),
                      // if (hasCalculatedCharges) ...[
                      //   _buildChargeBreakdownRow(
                      //     "To Restaurant:",
                      //     "${charges['driverToRestaurantDistance']?.toStringAsFixed(2) ?? '0.00'} km",
                      //     "+₹${charges['driverToRestaurantCharge']?.toStringAsFixed(2) ?? '0.00'}",
                      //     themeChange,
                      //   ),
                      //   _buildChargeBreakdownRow(
                      //     "To Customer:",
                      //     "${charges['restaurantToCustomerDistance']?.toStringAsFixed(2) ?? '0.00'} km",
                      //     "+₹${charges['restaurantToCustomerCharge']?.toStringAsFixed(2) ?? '0.00'}",
                      //     themeChange,
                      //   ),
                      //   const SizedBox(height: 8),
                      //   Container(
                      //     padding: const EdgeInsets.all(8),
                      //     decoration: BoxDecoration(
                      //       color: AppThemeData.success50.withOpacity(0.2),
                      //       borderRadius: BorderRadius.circular(8),
                      //       border: Border.all(color: AppThemeData.success200),
                      //     ),
                      //     child: Row(
                      //       children: [
                      //         Expanded(
                      //           child: Text(
                      //             "Total Calculated:".tr,
                      //             style: TextStyle(
                      //               fontFamily: AppThemeData.semiBold,
                      //               color: themeChange.getThem()
                      //                   ? AppThemeData.grey50
                      //                   : AppThemeData.grey900,
                      //               fontSize: 16,
                      //             ),
                      //           ),
                      //         ),
                      //         Text(
                      //           "₹${charges['totalCalculatedCharge']?.toStringAsFixed(2) ?? '0.00'}",
                      //           style: TextStyle(
                      //             fontFamily: AppThemeData.bold,
                      //             color: AppThemeData.success500,
                      //             fontSize: 18,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      //   const SizedBox(height: 8),
                      // ],
                      controller.currentOrder.value.tipAmount == null ||
                          controller.currentOrder.value.tipAmount!.isEmpty ||
                          double.parse(controller.currentOrder.value.tipAmount
                              .toString()) <=
                              0
                          ? const SizedBox()
                          : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              "Tips".tr,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontFamily: AppThemeData.regular,
                                color: themeChange.getThem()
                                    ? AppThemeData.grey300
                                    : AppThemeData.grey600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            Constant.amountShow(
                                amount:
                                controller.currentOrder.value.tipAmount ??
                                    "0.0"),
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: AppThemeData.semiBold,
                              color: themeChange.getThem()
                                  ? AppThemeData.grey50
                                  : AppThemeData.grey900,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      // Delivery Charge
                      Visibility(
                        visible:
                            (controller.driverModel.value.vendorID?.isEmpty ==
                                true),
                        child: Column(children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  "Delivery Charge".tr,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontFamily: AppThemeData.regular,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey300
                                        : AppThemeData.grey600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Text(
                                "${controller.driverToRestaurantCharge.value} + ${controller.restaurantToCustomerCharge.value} = ${controller.totalCalculatedCharge.value}",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: AppThemeData.semiBold,
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey50
                                      : AppThemeData.grey900,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ]),
                      ),

                      // Surge Fee - Always show but with different styling
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        decoration: BoxDecoration(
                          color:
                          hasSurge
                              ? AppThemeData.success50.withOpacity(0.3)
                              :
                          Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    "Surge Fee".tr,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontFamily: AppThemeData.regular,
                                      color: themeChange.getThem()
                                          ? AppThemeData.grey300
                                          : AppThemeData.grey600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (hasSurge) const SizedBox(width: 6),
                                  if (hasSurge)
                                    Icon(
                                      Icons.trending_up_rounded,
                                      color: AppThemeData.success400,
                                      size: 16,
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              "+${surgeFee.toStringAsFixed(2)}",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontFamily: AppThemeData.semiBold,
                                color: hasSurge
                                    ? AppThemeData.success500
                                    : (themeChange.getThem()
                                        ? AppThemeData.grey50
                                        : AppThemeData.grey900),
                                fontSize: hasSurge ? 17 : 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Total Earnings Estimate - New Section
                      if (hasSurge)
                        Column(
                          children: [
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppThemeData.primary50.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppThemeData.primary200,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Total Earnings".tr,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontFamily: AppThemeData.semiBold,
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey50
                                            : AppThemeData.grey900,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    // Calculate total: delivery charge + surge fee
                                    // "${(23.00 + surgeFee).toStringAsFixed(2)}",
                                    "${double.parse(controller.currentOrder.value.tipAmount
                                        .toString())+ controller.totalCalculatedCharge.value + (surgeFee)}",
                                    // (surgeFee).toStringAsFixed(2),
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontFamily: AppThemeData.bold,
                                      color: AppThemeData.primary500,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 8),

              // Tips Section
              // controller.currentOrder.value.tipAmount == null ||
              //         controller.currentOrder.value.tipAmount?.isEmpty ==
              //             true ||
              //         double.parse(controller.currentOrder.value.tipAmount
              //                     ?.toString() ??
              //                 "0.0") <=
              //             0
              //     ? const SizedBox()
              //     : Column(
              //         children: [
              //           Row(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               Expanded(
              //                 child: Text(
              //                   "Tips".tr,
              //                   textAlign: TextAlign.start,
              //                   style: TextStyle(
              //                     fontFamily: AppThemeData.regular,
              //                     color: themeChange.getThem()
              //                         ? AppThemeData.grey300
              //                         : AppThemeData.grey600,
              //                     fontSize: 16,
              //                   ),
              //                 ),
              //               ),
              //               Text(
              //                 Constant.amountShow(
              //                     amount:
              //                         controller.currentOrder.value.tipAmount),
              //                 textAlign: TextAlign.start,
              //                 style: TextStyle(
              //                   fontFamily: AppThemeData.semiBold,
              //                   color: themeChange.getThem()
              //                       ? AppThemeData.grey50
              //                       : AppThemeData.grey900,
              //                   fontSize: 16,
              //                 ),
              //               ),
              //             ],
              //           ),
              //           const SizedBox(height: 8),
              //         ],
              //       ),

              const SizedBox(height: 10),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: RoundedButtonFill(
                      title: "Reject".tr,
                      width: 24,
                      height: 5.5,
                      borderRadius: 10,
                      color: AppThemeData.danger300,
                      textColor: AppThemeData.grey50,
                      onPress: () {
                        AppLogger.log('User clicked Reject Order button',
                            tag: 'UserAction');
                        controller.rejectOrder();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RoundedButtonFill(
                      title: "Accept".tr,
                      width: 24,
                      height: 5.5,
                      borderRadius: 10,
                      color: AppThemeData.success400,
                      textColor: AppThemeData.grey50,
                      onPress: () async {
                        AppLogger.log('User clicked Accept Order button',
                            tag: 'UserAction');
                        await controller.acceptOrder();
                        // Manual refresh: fetch latest order and update controller
                        if (controller.currentOrder.value.id != null) {
                          final updatedOrder =
                              await FireStoreUtils.getOrderById(
                                  controller.currentOrder.value.id!);
                          if (updatedOrder != null) {
                            controller.currentOrder.value = updatedOrder;
                            controller.update();
                          }
                        }
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // showDriverBottomSheet(themeChange, HomeController controller) {
  buildOrderActionsCard(themeChange, HomeController controller) {
    double totalAmount = 0.0;
    double subTotal = 0.0;
    double taxAmount = 0.0;
    double specialDiscount = 0.0;

    for (var element in controller.currentOrder.value.products!) {
      if (double.parse(element.discountPrice.toString()) <= 0) {
        subTotal = subTotal +
            double.parse(element.price.toString()) *
                double.parse(element.quantity.toString()) +
            (double.parse(element.extrasPrice.toString()) *
                double.parse(element.quantity.toString()));
      } else {
        subTotal = subTotal +
            double.parse(element.discountPrice.toString()) *
                double.parse(element.quantity.toString()) +
            (double.parse(element.extrasPrice.toString()) *
                double.parse(element.quantity.toString()));
      }
    }

    if (controller.currentOrder.value.taxSetting != null) {
      for (var element in controller.currentOrder.value.taxSetting!) {
        taxAmount = taxAmount +
            Constant.calculateTax(
                amount: (subTotal -
                        double.parse(
                            controller.currentOrder.value.discount.toString()))
                    .toString(),
                taxModel: element);
      }
    }

    if (controller.currentOrder.value.specialDiscount != null &&
        controller.currentOrder.value.specialDiscount!['special_discount'] !=
            null) {
      specialDiscount = double.parse(controller
          .currentOrder.value.specialDiscount!['special_discount']
          .toString());
    }

    totalAmount = subTotal -
        double.parse(controller.currentOrder.value.discount.toString()) -
        specialDiscount +
        taxAmount +
        double.parse(controller.currentOrder.value.deliveryCharge.toString()) +
        double.parse(controller.currentOrder.value.tipAmount.toString());

    return Container(
      color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                controller.currentOrder.value.status == Constant.orderShipped ||
                        controller.currentOrder.value.status ==
                            Constant.driverAccepted
                    ? Row(
                        children: [
                          Container(
                            decoration: ShapeDecoration(
                              color: AppThemeData.primary50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(120),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: SvgPicture.asset(
                                "assets/icons/ic_building.svg",
                                colorFilter: const ColorFilter.mode(
                                    AppThemeData.primary300, BlendMode.srcIn),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${controller.currentOrder.value.vendor!.title}",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontFamily: AppThemeData.semiBold,
                                    fontSize: 16,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey50
                                        : AppThemeData.grey900,
                                  ),
                                ),
                                Text(
                                  "${controller.currentOrder.value.vendor!.location}",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontFamily: AppThemeData.medium,
                                    fontSize: 14,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey300
                                        : AppThemeData.grey600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () {
                              Constant.makePhoneCall(controller
                                  .currentOrder.value.vendor!.phonenumber
                                  .toString());
                            },
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      width: 1,
                                      color: themeChange.getThem()
                                          ? AppThemeData.grey700
                                          : AppThemeData.grey200),
                                  borderRadius: BorderRadius.circular(120),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SvgPicture.asset(
                                    "assets/icons/ic_phone_call.svg"),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Timeline.tileBuilder(
                        /*
                  shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        theme: TimelineThemeData(
                          nodePosition: 0,
                          // indicatorPosition: 0,
                        ),
                        builder: TimelineTileBuilder.connected(
                          contentsAlign: ContentsAlign.basic,
                          indicatorBuilder: (context, index) {
                            return index == 0
                                ? Container(
                                    decoration: ShapeDecoration(
                                      color: AppThemeData.primary50,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(120),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: SvgPicture.asset(
                                        "assets/icons/ic_building.svg",
                                        colorFilter: const ColorFilter.mode(
                                            AppThemeData.primary300,
                                            BlendMode.srcIn),
                                      ),
                                    ),
                                  )
                                : Container(
                                    decoration: ShapeDecoration(
                                      color: AppThemeData.driverApp50,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(120),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: SvgPicture.asset(
                                      */

                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        theme: TimelineThemeData(
                          nodePosition: 0,
                          // indicatorPosition: 0,
                        ),
                        builder: TimelineTileBuilder.connected(
                          contentsAlign: ContentsAlign.basic,
                          indicatorBuilder: (context, index) {
                            return index == 0
                                ? Container(
                                    decoration: ShapeDecoration(
                                      color: AppThemeData.primary50,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(120),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: SvgPicture.asset(
                                        "assets/icons/ic_building.svg",
                                        colorFilter: const ColorFilter.mode(
                                            AppThemeData.primary300,
                                            BlendMode.srcIn),
                                      ),
                                    ),
                                  )
                                : Container(
                                    decoration: ShapeDecoration(
                                      color: AppThemeData.driverApp50,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(120),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: SvgPicture.asset(
                                        "assets/icons/ic_location.svg",
                                        colorFilter: ColorFilter.mode(
                                            AppThemeData.driverApp300,
                                            BlendMode.srcIn),
                                      ),
                                    ),
                                  );
                          },
                          connectorBuilder: (context, index, connectorType) {
                            return const DashedLineConnector(
                              color: AppThemeData.grey300,
                              gap: 3,
                            );
                          },
                          contentsBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: index == 0
                                  ? Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${controller.currentOrder.value.vendor!.title}",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppThemeData.semiBold,
                                                  fontSize: 16,
                                                  color: themeChange.getThem()
                                                      ? AppThemeData.grey50
                                                      : AppThemeData.grey900,
                                                ),
                                              ),
                                              Text(
                                                "${controller.currentOrder.value.vendor!.location}",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppThemeData.medium,
                                                  fontSize: 14,
                                                  color: themeChange.getThem()
                                                      ? AppThemeData.grey300
                                                      : AppThemeData.grey600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Constant.makePhoneCall(controller
                                                .currentOrder
                                                .value
                                                .vendor!
                                                .phonenumber
                                                .toString());
                                          },
                                          child: Container(
                                            width: 42,
                                            height: 42,
                                            decoration: ShapeDecoration(
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    width: 1,
                                                    color: themeChange.getThem()
                                                        ? AppThemeData.grey700
                                                        : AppThemeData.grey200),
                                                borderRadius:
                                                    BorderRadius.circular(120),
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: SvgPicture.asset(
                                                  "assets/icons/ic_phone_call.svg"),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Deliver to the".tr,
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppThemeData.semiBold,
                                                  fontSize: 16,
                                                  color: themeChange.getThem()
                                                      ? AppThemeData.grey50
                                                      : AppThemeData.grey900,
                                                ),
                                              ),
                                              Text(
                                                controller
                                                    .currentOrder.value.address!
                                                    .getFullAddress(),
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppThemeData.medium,
                                                  fontSize: 14,
                                                  color: themeChange.getThem()
                                                      ? AppThemeData.grey300
                                                      : AppThemeData.grey600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        InkWell(
                                          onTap: () async {
                                            ShowToastDialog.showLoader(
                                                "Please wait".tr);

                                            UserModel? customer =
                                                await FireStoreUtils
                                                    .getUserProfile(controller
                                                        .currentOrder
                                                        .value
                                                        .authorID
                                                        .toString());

                                            ShowToastDialog.closeLoader();

                                            if (customer != null &&
                                                customer.phoneNumber != null) {
                                              Constant.makePhoneCall(
                                                  customer.phoneNumber!);
                                            } else {
                                              ShowToastDialog.showToast(
                                                  "Customer phone number not available");
                                            }
                                          },
                                          child: Container(
                                            width: 42,
                                            height: 42,
                                            decoration: ShapeDecoration(
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    width: 1,
                                                    color: themeChange.getThem()
                                                        ? AppThemeData.grey700
                                                        : AppThemeData.grey200),
                                                borderRadius:
                                                    BorderRadius.circular(120),
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: SvgPicture.asset(
                                                  "assets/icons/ic_phone_call.svg"),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        InkWell(
                                          onTap: () async {
                                            ShowToastDialog.showLoader(
                                                "Please wait".tr);

                                            /*

                                UserModel? customer =
                                                await FireStoreUtils
                                                    .getUserProfile(controller
                                                        .currentOrder
                                                        .value
                                                        .authorID
                                                        .toString());
                                            UserModel? driver =
                                                await FireStoreUtils
                                                    .getUserProfile(controller
                                                        .currentOrder
                                                        .value
                                                        .driverID
                                                        .toString());
                                */
                                            UserModel? customer =
                                                await FireStoreUtils
                                                    .getUserProfile(controller
                                                        .currentOrder
                                                        .value
                                                        .authorID
                                                        .toString());
                                            UserModel? driver =
                                                await FireStoreUtils
                                                    .getUserProfile(controller
                                                        .currentOrder
                                                        .value
                                                        .driverID
                                                        .toString());

                                            ShowToastDialog.closeLoader();

                                            Get.to(const ChatScreen(),
                                                arguments: {
                                                  "customerName":
                                                      '${customer!.fullName()}',
                                                  "restaurantName":
                                                      driver!.fullName(),
                                                  "orderId": controller
                                                      .currentOrder.value.id,
                                                  "restaurantId": driver.id,
                                                  "customerId": customer.id,
                                                  "customerProfileImage": customer
                                                          .profilePictureURL ??
                                                      "",
                                                  "restaurantProfileImage":
                                                      driver.profilePictureURL ??
                                                          "",
                                                  "token": customer.fcmToken,
                                                  "chatType": "Driver",
                                                });
                                          },
                                          child: Container(
                                            width: 42,
                                            height: 42,
                                            decoration: ShapeDecoration(
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    width: 1,
                                                    color: themeChange.getThem()
                                                        ? AppThemeData.grey700
                                                        : AppThemeData.grey200),
                                                borderRadius:
                                                    BorderRadius.circular(120),
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: SvgPicture.asset(
                                                  "assets/icons/ic_wechat.svg"),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                            );
                          },
                          itemCount: 2,
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: MySeparator(
                      color: themeChange.getThem()
                          ? AppThemeData.grey700
                          : AppThemeData.grey200),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "Payment Type".tr,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: AppThemeData.regular,
                          color: themeChange.getThem()
                              ? AppThemeData.grey300
                              : AppThemeData.grey600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      controller.currentOrder.value.paymentMethod
                                  ?.toLowerCase() ==
                              "cod"
                          ? "Cash on delivery"
                          : "Online",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: AppThemeData.semiBold,
                        color: themeChange.getThem()
                            ? AppThemeData.grey50
                            : AppThemeData.grey900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                controller.currentOrder.value.paymentMethod?.toLowerCase() ==
                        "cod"
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              "Collect Payment from customer".tr,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontFamily: AppThemeData.regular,
                                color: themeChange.getThem()
                                    ? AppThemeData.grey300
                                    : AppThemeData.grey600,
                                fontSize: 16,
                              ),
                            ),
                          ),

                          // Amount Field here need to Update

                          //  Text(
                          //     Constant.amountShow(amount: totalAmount.toString()),
                          //     textAlign: TextAlign.start,
                          //     style: TextStyle(
                          //       fontFamily: AppThemeData.semiBold,
                          //       color: themeChange.getThem()
                          //           ? AppThemeData.grey50
                          //           : AppThemeData.grey900,
                          //       fontSize: 16,
                          //     ), =

                          FutureBuilder<double?>(
                            future: fetchToPayForOrder(
                                controller.currentOrder.value.id!),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                );
                              }
                              if (snapshot.hasError) {
                                return const Text('Error');
                              }
                              final toPay = snapshot.data;
                              return Text(
                                Constant.amountShow(
                                    amount: (toPay ?? 0.0).toString()),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: AppThemeData.semiBold,
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey50
                                      : AppThemeData.grey900,
                                  fontSize: 16,
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    : const SizedBox(),
                const SizedBox(
                  height: 5,
                ),

              ],
            ),
          ),
          InkWell(
            onTap: () async {
              if (controller.currentOrder.value.status ==
                      Constant.orderShipped ||
                  controller.currentOrder.value.status ==
                      Constant.driverAccepted) {
                log('\u001b[32mHomeScreen -> PickupOrderScreen\u001b[0m');
                Get.to(const PickupOrderScreen(), arguments: {
                  "orderModel": controller.currentOrder.value
                })?.then((v) async {
                  if (v == true) {
                    OrderModel? ordermodel = await FireStoreUtils.getOrderById(
                        controller.currentOrder.value.id!);
                    if (ordermodel?.id != null) {
                      controller.currentOrder.value = ordermodel!;
                    }
                    controller.update();
                  }
                });
              } else {
                log('\u001b[32mHomeScreen -> DeliverOrderScreen\u001b[0m');
                Get.to(const DeliverOrderScreen(), arguments: {
                  "orderModel": controller.currentOrder.value
                })!
                    .then(
                  (value) async {
                    if (value == true) {
                      await AudioPlayerService.playSound(false);
                      controller.driverModel.value.inProgressOrderID!
                          .remove(controller.currentOrder.value.id);
                      await FireStoreUtils.updateUser(
                          controller.driverModel.value);
                      controller.currentOrder.value = OrderModel();
                      controller.clearMap();
                      if (Constant.singleOrderReceive == false) {
                        Get.back();
                      }
                    }
                  },
                );
              }
            },
            child: SafeArea(
              child: Container(
                color: AppThemeData.driverApp300,
                width: Responsive.width(100, Get.context!),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    controller.currentOrder.value.status ==
                                Constant.orderShipped ||
                            controller.currentOrder.value.status ==
                                Constant.driverAccepted
                        ? "Reached restaurant for Pickup".tr
                        : controller.driverModel.value.vendorID?.isEmpty == true
                            ? "Reached the Customers Door Steps".tr
                            : "Order Delivered".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: themeChange.getThem()
                          ? AppThemeData.grey900
                          : AppThemeData.grey900,
                      fontSize: 16,
                      fontFamily: AppThemeData.semiBold,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class HomeScreenLogger extends RouteAware {
  @override
  void didPush() {
    AppLogger.log('Navigated to HomeScreen', tag: 'Screen');
  }

  @override
  void didPop() {
    AppLogger.log('Popped HomeScreen', tag: 'Screen');
  }
}

Future<double?> fetchOrderSergeFee(String orderId) async {
  final doc = await FirebaseFirestore.instance
      .collection('order_Billing')
      .doc(orderId)
      .get();
  if (doc.exists && doc.data() != null && doc.data()!['total_surge_fee'] != null) {
    return double.tryParse(doc.data()!['total_surge_fee'].toString());
  }
  return null;
}

class ShiningHighDemandWidget extends StatefulWidget {
  final double surgeFee;

  const ShiningHighDemandWidget({super.key, required this.surgeFee});

  @override
  State<ShiningHighDemandWidget> createState() =>
      _ShiningHighDemandWidgetState();
}

class _ShiningHighDemandWidgetState extends State<ShiningHighDemandWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: AppThemeData.warning300,
      end: Colors.orange.shade600,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.orange,
            border: Border.all(
              color: _colorAnimation.value!,
              width: 2, // Slightly thicker border for emphasis
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bolt_rounded,
                color: AppThemeData.warning500,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                "High Demand Area".tr,
                style: TextStyle(
                  fontFamily: AppThemeData.semiBold,
                  fontSize: 14,
                  color: AppThemeData.warning600,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "+${widget.surgeFee.toStringAsFixed(2)}",
                style: TextStyle(
                  fontFamily: AppThemeData.bold,
                  fontSize: 14,
                  color: AppThemeData.warning600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


// NEW: Helper widget for charge breakdown rows
