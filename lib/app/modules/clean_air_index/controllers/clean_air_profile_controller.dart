import 'dart:async';

import 'package:get/get.dart';

import '../../../repo/auth.dart';
import '../../../response/profile_response.dart';
import '../../../service/local_storage.dart';

class CleanAirProfileController extends GetxController {
  late LoginTokenStorage loginTokenStorage;
  final isLoggedIn = ''.obs;
  final authRepository = AuthRepository();
  final profileResponse = Rxn<ProfileResponse>();
  static const String _cacheProfileKey = 'pharma_profile_cache';
  Timer? _pollingTimer;

  @override
  void onInit() {
    super.onInit();
  }

  void checkLogin() {
    loginTokenStorage = Get.find<LoginTokenStorage>();
    final token = loginTokenStorage.getPharmaToken();
    if (_hasValidToken(token)) {
      isLoggedIn.value = token!.trim();
      _loadCachedProfile();
      userProfile();
      _startPolling();
    } else {
      isLoggedIn.value = '';
      _pollingTimer?.cancel();
    }
  }

  bool _hasValidToken(String? token) {
    if (token == null) return false;
    final normalized = token.trim().toLowerCase();
    return normalized.isNotEmpty &&
        normalized != 'null' &&
        normalized != 'undefined';
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (isLoggedIn.value.isEmpty) return;
      userProfile();
    });
  }

  Future<void> userProfile() async {
    final response = await authRepository.getProfile(isPharmaFlow: true);
    response.fold(
      (failure) {
        print(failure.message);
      },
      (profile) async {
        profileResponse.value = profile;
        await _cacheProfile(profile);
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

  Future<void> logout() async {
    await loginTokenStorage.removePharmaToken();
    await loginTokenStorage.removePharmaUserId();
    final prefs = loginTokenStorage.sharedPreferences;
    await prefs.remove(_cacheProfileKey);
    isLoggedIn.value = '';
    profileResponse.value = null;
    _pollingTimer?.cancel();
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    super.onClose();
  }
}
