import 'package:get/get.dart';

import '../controllers/cattle_live_data_controller.dart';

class CattleLiveDataBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CattleLiveDataController>(() => CattleLiveDataController());
  }
}
