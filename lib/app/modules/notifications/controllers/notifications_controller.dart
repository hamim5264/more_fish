import 'dart:async';

import 'package:get/get.dart';
import '../../../common_widgets/common_alert_dialog.dart';
import '../../../repo/auth.dart';
import '../../../repo/notifications.dart';
import '../../../response/notification_response.dart';
import '../../../response/profile_response.dart';
import '../../../routes/app_pages.dart';
import '../../../service/local_storage.dart';
import '../../profile/controllers/profile_controller.dart';

class NotificationsController extends GetxController {
  var items = [
    "Aqua, the color of calm seas and clear skies, often symbolizes freshness, purity, and tranquility. It reminds us of flowing rivers, sparkling waves, and the cool serenity of water that brings life to everything around it.",
    "Aqua, the color of calm seas and clear skies, often symbolizes freshness, purity, and tranquility. It reminds us of flowing rivers, sparkling waves, and the cool serenity of water that brings life to everything around it.",
    "Aqua, the color of calm seas and clear skies, often symbolizes freshness, purity, and tranquility. It reminds us of flowing rivers, sparkling waves, and the cool serenity of water that brings life to everything around it.",
    "Aqua, the color of calm seas and clear skies, often symbolizes freshness, purity, and tranquility. It reminds us of flowing rivers, sparkling waves, and the cool serenity of water that brings life to everything around it.",
    "Aqua, the color of calm seas and clear skies, often symbolizes freshness, purity, and tranquility. It reminds us of flowing rivers, sparkling waves, and the cool serenity of water that brings life to everything around it.",
    "Aqua, the color of calm seas and clear skies, often symbolizes freshness, purity, and tranquility. It reminds us of flowing rivers, sparkling waves, and the cool serenity of water that brings life to everything around it.",
    "Aqua, the color of calm seas and clear skies, often symbolizes freshness, purity, and tranquility. It reminds us of flowing rivers, sparkling waves, and the cool serenity of water that brings life to everything around it.",
    "Aqua, the color of calm seas and clear skies, often symbolizes freshness, purity, and tranquility. It reminds us of flowing rivers, sparkling waves, and the cool serenity of water that brings life to everything around it.",
    "Aqua, the color of calm seas and clear skies, often symbolizes freshness, purity, and tranquility. It reminds us of flowing rivers, sparkling waves, and the cool serenity of water that brings life to everything around it.",
  ].obs;
  late LoginTokenStorage loginTokenStorage;
  var isLoggedIn = ''.obs;
  final _hasShownLoginPrompt = false.obs;
  NotificationsRepository notificationsRepository = NotificationsRepository();
  final notificationResponse = Rxn<NotificationResponse>();
  AuthRepository authRepository = AuthRepository();
  final profileResponse = Rxn<ProfileResponse>();
  ProfileController profileController = ProfileController();
  static const String _cacheNotificationsKey = 'morefish_notifications_cache';
  Timer? _pollingTimer;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    checkLogin();
  }

  checkLogin() {
    loginTokenStorage = Get.find<LoginTokenStorage>();
    final token = loginTokenStorage.getMoreFishToken();
    final id = loginTokenStorage.getMoreFishUserId();
    print(id);
    print(token);
    if (token != null) {
      isLoggedIn.value = token;
      _loadCachedNotifications();
      notificationList();
      _startPolling();
    } else {
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
          Get.offAllNamed(Routes.INDEX);
        },
        login: () {
          Get.back();
          Get.toNamed(Routes.LOGIN);
        },
      ),
      barrierDismissible: true,
    );
  }

  notificationList() async {
    var response = await notificationsRepository.getNotification();
    response.fold(
      (l) {
        print('${l.message}');
      },
      (r) {
        notificationResponse.value = r;
        _cacheNotifications(r);
        print("=================================");
        print(notificationResponse.value);
        print("=================================");
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
