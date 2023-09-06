import 'package:get/get.dart';
import 'package:tuning_for_tonists/view_controllers/knowledgebase_controller.dart';

class KnowledgebaseBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(KnowledgebaseController(), permanent: false);
  }
}
