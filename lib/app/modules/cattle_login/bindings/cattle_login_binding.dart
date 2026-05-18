import 'package:get/get.dart';

import '../controllers/cattle_login_controller.dart';

class CattleLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CattleLoginController>(
      () => CattleLoginController(),
    );
  }
}
