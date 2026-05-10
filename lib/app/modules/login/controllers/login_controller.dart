import 'package:flutter/material.dart';
// loader removed
import 'package:get/get.dart';
import '../../../repo/auth.dart';
import '../../../response/login_response.dart';
import '../../../routes/app_pages.dart';
import '../../../service/local_storage.dart';
import '../../../service/fcm_service.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var phoneNumber = "".obs;
  var showPassword = false.obs;
  var phoneError = RxnString();
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

    if (loginTokenStorage.hasValidToken()) {
      debugPrint(
        'Guard login skipped: token already found in SharedPreferences.',
      );
      Future.microtask(() => Get.back(result: true));
    }
  }

  login(context, email, password) async {
    debugPrint('Poultry live login email: $email');
    debugPrint('Poultry live login endpoint: /auth/login/');
    // loader removed

    try {
      var response = await authRepository.setLogin(
        email: email,
        password: password,
      );

      await response.fold(
        (l) async {
          debugPrint('${l.message}');
          isActiveLoginButton.value = true;
          Get.snackbar(
            'Login Failed',
            'Oops! Invalid login credentials.',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        (r) async {
          loginResponse.value = r;

          final token = loginResponse.value?.data?.token;
          final userId = loginResponse.value?.data?.userId;

          if (token == null || token.trim().isEmpty || userId == null) {
            debugPrint(
              'Login response missing token/userId, cannot persist session.',
            );
            isActiveLoginButton.value = true;
            Get.snackbar(
              'Login Failed',
              'Session data not found from server response.',
              snackPosition: SnackPosition.BOTTOM,
            );
            return;
          }

          await loginTokenStorage.setToken(token);
          await loginTokenStorage.setUserId(userId);
          debugPrint(
            'Saved token in SharedPreferences: ${loginTokenStorage.getToken() != null}',
          );

          // Update FCM token after successful login
          final fcmToken = await FcmService.getFcmToken();
          if (fcmToken != null) {
            await authRepository.updateFcmToken(
              fcmToken: fcmToken,
              isPoultryFlow: false,
            );
          }

          if (_openedFromGuard) {
            Get.back(result: true);
          } else {
            Get.offAllNamed(Routes.INDEX);
          }

          isActiveLoginButton.value = true;
          Get.snackbar(
            'Login Successful',
            'Welcome back.',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      );
    } finally {
      isActiveLoginButton.value = true;
    }
  }
}
