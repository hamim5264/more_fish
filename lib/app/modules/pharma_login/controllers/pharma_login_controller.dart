import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../repo/auth.dart';
import '../../../response/login_response.dart';
import '../../../routes/app_pages.dart';
import '../../../service/fcm_service.dart';
import '../../../service/local_storage.dart';

class PharmaLoginController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var showPassword = false.obs;
  final authRepository = AuthRepository();
  final loginResponse = Rxn<LoginResponse>();
  final loginTokenStorage = Get.find<LoginTokenStorage>();
  var isActiveLoginButton = true.obs;

  bool get _openedFromGuard {
    final args = Get.arguments;
    if (args is Map) {
      return args['fromGuard'] == true;
    }
    return false;
  }

  bool get openedFromGuard => _openedFromGuard;

  @override
  void onInit() {
    super.onInit();
    _bypassGuardLoginIfAlreadyAuthenticated();
  }

  void _bypassGuardLoginIfAlreadyAuthenticated() {
    if (!_openedFromGuard) {
      return;
    }

    if (loginTokenStorage.hasValidPharmaToken()) {
      debugPrint(
        'Guard pharma login skipped: token already found in SharedPreferences.',
      );
      Future.microtask(() => Get.back(result: true));
    }
  }

  Future<void> login({required String email, required String password}) async {
    debugPrint('Pharma login email: $email');

    try {
      final response = await authRepository.setLogin(
        email: email,
        password: password,
      );

      await response.fold(
        (failure) async {
          debugPrint(failure.message);
          isActiveLoginButton.value = true;
          if (Get.context != null && Get.context!.mounted) {
            ScaffoldMessenger.of(Get.context!).showSnackBar(
              const SnackBar(
                content: Text('Oops! Invalid login credentials.'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        (loginResponse) async {
          final token = loginResponse.data?.token;
          final userId = loginResponse.data?.userId;

          if (token == null || token.trim().isEmpty || userId == null) {
            debugPrint(
              'Pharma login response missing token/userId, cannot persist session.',
            );
            isActiveLoginButton.value = true;
            if (Get.context != null && Get.context!.mounted) {
              ScaffoldMessenger.of(Get.context!).showSnackBar(
                const SnackBar(
                  content: Text('Session data not found from server response.'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            return;
          }

          await loginTokenStorage.setPharmaToken(token);
          await loginTokenStorage.setPharmaUserId(userId);

          final fcmToken = await FcmService.getFcmToken();
          if (fcmToken != null) {
            await authRepository.updateFcmToken(
              fcmToken: fcmToken,
              isPharmaFlow: true,
            );
          }

          if (_openedFromGuard) {
            Get.back(result: true);
          } else {
            Get.offAllNamed(Routes.CLEAN_AIR_INDEX);
          }

          isActiveLoginButton.value = true;
          if (Get.context != null && Get.context!.mounted) {
            ScaffoldMessenger.of(Get.context!).showSnackBar(
              const SnackBar(
                content: Text('Welcome back.'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      );
    } finally {
      isActiveLoginButton.value = true;
    }
  }
}
