import 'package:get/get.dart';

import '../controllers/clean_air_live_monitoring_controller.dart';

class CleanAirLiveMonitoringBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CleanAirLiveMonitoringController>(
      () => CleanAirLiveMonitoringController(),
    );
  }
}
