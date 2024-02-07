import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  _updateConnectionStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      Get.rawSnackbar(
        messageText: const Text(
          'No internet connection',
          style: TextStyle(color: Colors.white),
        ),
        isDismissible: false,
        duration: const Duration(days: 1),
        snackPosition: SnackPosition.BOTTOM,
        icon: const Icon(
          Icons.wifi_off,
          color: Colors.white,
        ),
        backgroundColor: Colors.black,
        snackStyle: SnackStyle.GROUNDED,
      );
    } else {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
    }
  }
}
