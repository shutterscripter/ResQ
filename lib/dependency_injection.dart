import 'package:get/get.dart';
import 'package:resq/Controller/NetworkController.dart';

class DependencyInjection {
  static void init() {
    Get.put<NetworkController>(NetworkController(), permanent: true);
  }
}
