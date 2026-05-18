import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../repo/auth.dart';
import '../../../response/login_response.dart';
import '../../../routes/app_pages.dart';
import '../../../service/local_storage.dart';
import '../../../service/fcm_service.dart';

class PoultryLoginController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var showPassword = false.obs;
  AuthRepository authRepository = AuthRepository();
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

    if (loginTokenStorage.hasValidPoultryToken()) {
      debugPrint(
        'Guard poultry login skipped: token already found in SharedPreferences.',
      );
      Future.microtask(() => Get.back(result: true));
    }
  }

  Future<void> login({required String email, required String password}) async {
    debugPrint('Poultry login email: $email');
    // loader removed

    try {
      var response = await authRepository.setLogin(
        email: email,
        password: password,
        isPoultryFlow: true,
      );

      await response.fold(
        (l) async {
          debugPrint(l.message);
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
        (r) async {
          loginResponse.value = r;

          final token = loginResponse.value?.data?.token;
          final userId = loginResponse.value?.data?.userId;

          if (token == null || token.trim().isEmpty || userId == null) {
            debugPrint(
              'Poultry login response missing token/userId, cannot persist session.',
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

          await loginTokenStorage.setPoultryToken(token);
          await loginTokenStorage.setPoultryUserId(userId);

          // Update FCM token after successful login
          final fcmToken = await FcmService.getFcmToken();
          if (fcmToken != null) {
            await authRepository.updateFcmToken(
              fcmToken: fcmToken,
              isPoultryFlow: true,
            );
          }

          if (_openedFromGuard) {
            Get.back(result: true);
          } else {
            Get.offAllNamed(Routes.POULTRY_INDEX);
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
