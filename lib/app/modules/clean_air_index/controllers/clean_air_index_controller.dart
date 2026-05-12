import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../service/local_storage.dart';

class CleanAirIndexController extends GetxController {
  final selectedIndex = 0.obs;
  final isLoggedIn = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkLogin();
  }

  void checkLogin() {
    final loginTokenStorage = Get.find<LoginTokenStorage>();
    final token = loginTokenStorage.getPharmaToken();
    if (_hasValidToken(token)) {
      isLoggedIn.value = token!.trim();
    } else {
      isLoggedIn.value = '';
    }
  }

  Future<bool> ensureLoggedIn() async {
    checkLogin();

    if (isLoggedIn.value.isNotEmpty) {
      return true;
    }

    final result = await Get.toNamed(
      Routes.PHARMA_LOGIN,
      arguments: {'fromGuard': true},
    );

    checkLogin();

    return result == true || isLoggedIn.value.isNotEmpty;
  }

  bool _hasValidToken(String? token) {
    if (token == null) return false;
    final normalized = token.trim().toLowerCase();
    return normalized.isNotEmpty &&
        normalized != 'null' &&
        normalized != 'undefined';
  }
}
