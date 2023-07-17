import 'package:get/get.dart';
import 'package:tuning_for_tonists/view_controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingsController());
  }
}
