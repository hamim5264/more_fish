import 'package:get/get.dart';
import '../controllers/cattle_index_controller.dart';
import '../controllers/cattle_header_controller.dart';
import '../controllers/cattle_profile_controller.dart';
import '../controllers/cattle_live_monitoring_controller.dart';
import '../controllers/cattle_notifications_controller.dart';

class CattleIndexBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CattleIndexController>(() => CattleIndexController());
    Get.lazyPut<CattleHeaderController>(() => CattleHeaderController());
    Get.lazyPut<CattleProfileController>(() => CattleProfileController());
    Get.lazyPut<CattleNotificationsController>(
      () => CattleNotificationsController(),
    );

    Get.lazyPut<CattleLiveMonitoringController>(
      () => CattleLiveMonitoringController(),
    );
  }
}
