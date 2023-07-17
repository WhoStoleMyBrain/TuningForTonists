import 'package:get/get.dart';
import 'package:tuning_for_tonists/view_controllers/info_controller.dart';

class InfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InfoController());
  }
}
