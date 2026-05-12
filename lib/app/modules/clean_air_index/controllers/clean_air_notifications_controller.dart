import 'dart:async';

import 'package:get/get.dart';

import '../../../common_widgets/common_alert_dialog.dart';
import '../../../repo/notifications.dart';
import '../../../response/notification_response.dart';
import '../../../routes/app_pages.dart';
import '../../../service/local_storage.dart';

class CleanAirNotificationsController extends GetxController {
  late LoginTokenStorage loginTokenStorage;
  final isLoggedIn = ''.obs;
  final _hasShownLoginPrompt = false.obs;
  final notificationsRepository = NotificationsRepository();
  final notificationResponse = Rxn<NotificationResponse>();
  static const String _cacheNotificationsKey = 'pharma_notifications_cache';
  Timer? _pollingTimer;

  @override
  void onReady() {
    super.onReady();
    checkLogin();
  }

  void checkLogin() {
    loginTokenStorage = Get.find<LoginTokenStorage>();
    final token = loginTokenStorage.getPharmaToken();

    if (token != null) {
      isLoggedIn.value = token;
      _loadCachedNotifications();
      notificationList();
      _startPolling();
    } else {
      isLoggedIn.value = '';
      _pollingTimer?.cancel();
      _showLoginPromptOnce();
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (isLoggedIn.value.isEmpty) return;
      notificationList();
    });
  }

  void _showLoginPromptOnce() {
    if (_hasShownLoginPrompt.value) return;
    _hasShownLoginPrompt.value = true;

    Get.dialog(
      CommonAlertDialog(
        notNow: () {
          Get.back();
          Get.offAllNamed(Routes.CLEAN_AIR_INDEX);
        },
        login: () {
          Get.back();
          Get.toNamed(Routes.PHARMA_LOGIN);
        },
      ),
      barrierDismissible: true,
    );
  }

  Future<void> notificationList() async {
    final response = await notificationsRepository.getNotification(
      isPharmaFlow: true,
    );
    response.fold(
      (l) {
        print(l.message);
      },
      (r) {
        notificationResponse.value = r;
        _cacheNotifications(r);
      },
    );
  }

  void _loadCachedNotifications() {
    try {
      final prefs = loginTokenStorage.sharedPreferences;
      final cached = prefs.getString(_cacheNotificationsKey);
      if (cached == null || cached.isEmpty) return;

      notificationResponse.value = NotificationResponse.fromRawJson(cached);
    } catch (_) {}
  }

  Future<void> _cacheNotifications(NotificationResponse response) async {
    final prefs = loginTokenStorage.sharedPreferences;
    await prefs.setString(_cacheNotificationsKey, response.toRawJson());
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    super.onClose();
  }
}
