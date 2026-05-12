import 'dart:async';

import 'package:get/get.dart';
import 'package:more_fish/app/repo/auth.dart';
import 'package:more_fish/app/response/profile_response.dart';
import 'package:more_fish/app/service/local_storage.dart';

class ProfileController extends GetxController {
  late LoginTokenStorage loginTokenStorage;
  var isLoggedIn = ''.obs;
  AuthRepository authRepository = AuthRepository();
  final profileResponse = Rxn<ProfileResponse>();
  static const String _cacheProfileKey = 'morefish_profile_cache';
  Timer? _pollingTimer;

  @override
  void onInit() {
    super.onInit();
  }

  checkLogin() {
    loginTokenStorage = Get.find<LoginTokenStorage>();
    final token = loginTokenStorage.getMoreFishToken();
    print(token);
    if (token != null) {
      isLoggedIn.value = token;
      _loadCachedProfile();
      userProfile();
      _startPolling();
    } else {
      _pollingTimer?.cancel();
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (isLoggedIn.value.isEmpty) return;
      userProfile();
    });
  }

  userProfile() async {
    var response = await authRepository.getProfile();
    response.fold(
      (l) {
        print('${l.message}');
      },
      (r) async {
        profileResponse.value = r;
        await _cacheProfile(r);
      },
    );
  }

  void _loadCachedProfile() {
    try {
      final prefs = loginTokenStorage.sharedPreferences;
      final cached = prefs.getString(_cacheProfileKey);
      if (cached == null || cached.isEmpty) return;

      profileResponse.value = ProfileResponse.fromRawJson(cached);
    } catch (_) {}
  }

  Future<void> _cacheProfile(ProfileResponse response) async {
    final prefs = loginTokenStorage.sharedPreferences;
    await prefs.setString(_cacheProfileKey, response.toRawJson());
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    super.onClose();
  }
}
