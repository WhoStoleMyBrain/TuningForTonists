import 'package:get/get.dart';
import 'package:tuning_for_tonists/view_controllers/mic_detail_controller.dart';

class MicDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MicDetailController());
  }
}
