import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../repo/auth.dart';
import '../../../response/login_response.dart';
import '../../../routes/app_pages.dart';
import '../../../service/local_storage.dart';
import '../../../service/fcm_service.dart';

class CattleLoginController extends GetxController {

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

    if (loginTokenStorage.hasValidCattleToken()) {
      debugPrint(
        'Guard login skipped: token already found in SharedPreferences.',
      );
      
      // Use a safer way to navigate back without crashing if snackbars are present
      Future.microtask(() {
        if (Get.context != null) {
          Navigator.of(Get.context!).pop(true);
        } else {
          Get.back(result: true);
        }
      });
    }
  }

  login(context, email, password) async {
    debugPrint('Cattle care login email: $email');
    debugPrint('Cattle care login endpoint: /auth/login/');

    try {
      var response = await authRepository.setLogin(
        email: email,
        password: password,
      );

      await response.fold(
            (l) async {
          debugPrint('${l.message}');
          isActiveLoginButton.value = true;
          if (context != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
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
              'Login response missing token/userId, cannot persist session.',
            );
            isActiveLoginButton.value = true;
            if (context != null && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Session data not found from server response.'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            return;
          }

          // ✅ Store Cattle-specific session separately
          await loginTokenStorage.setCattleToken(token);
          await loginTokenStorage.setCattleUserId(userId);
          
          debugPrint(
            'Saved Cattle token in SharedPreferences: ${loginTokenStorage.getCattleToken() != null}',
          );

          // Update FCM token after successful login with Cattle Flow enabled
          final fcmToken = await FcmService.getFcmToken();
          if (fcmToken != null) {
            await authRepository.updateFcmToken(
              fcmToken: fcmToken,
              isCattleFlow: true,
            );
          }

          // ✅ Navigation logic updated for stability
          if (_openedFromGuard) {
            // Using standard Navigator pop to avoid GetX snackbar collisions
            if (Get.context != null) {
              Navigator.of(Get.context!).pop(true);
            } else {
              Get.back(result: true);
            }
          } else {
            Get.offAllNamed(Routes.CATTLE_INDEX);
          }

          isActiveLoginButton.value = true;
        },
      );
    } finally {
      isActiveLoginButton.value = true;
    }
  }

}
