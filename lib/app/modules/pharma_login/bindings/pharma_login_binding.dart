import 'package:get/get.dart';

import '../controllers/pharma_login_controller.dart';

class PharmaLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PharmaLoginController>(() => PharmaLoginController());
  }
}
