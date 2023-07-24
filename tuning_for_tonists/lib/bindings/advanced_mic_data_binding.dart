import 'package:get/get.dart';

import '../view_controllers/advanced_mic_data_controller.dart';

class AdvancedMicDataBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AdvancedMicDataController(), permanent: true);
  }
}
