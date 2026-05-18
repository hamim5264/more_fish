import 'package:shared_preferences/shared_preferences.dart';

class LoginTokenStorage {
  LoginTokenStorage(this.sharedPreferences);

  final SharedPreferences sharedPreferences;
  static const _moreFishTokenKey = 'token';
  static const _pharmaTokenKey = 'pharmaToken';
  static const _poultryTokenKey = 'poultryToken';
  static const _cattleTokenKey = 'cattleToken';
  
  static const _moreFishUserIdKey = 'userId';
  static const _pharmaUserIdKey = 'pharmaUserId';
  static const _poultryUserIdKey = 'poultryUserId';
  static const _cattleUserIdKey = 'cattleUserId';

  String? getToken() {
    return getMoreFishToken();
  }

  Future<void> setToken(String value) async {
    await setMoreFishToken(value);
  }

  Future<void> removeToken() async {
    await removeMoreFishToken();
  }

  String? getMoreFishToken() {
    return _normalizedToken(sharedPreferences.getString(_moreFishTokenKey));
  }

  Future<void> setMoreFishToken(String value) async {
    await sharedPreferences.setString(_moreFishTokenKey, value.trim());
  }

  Future<void> removeMoreFishToken() async {
    await sharedPreferences.remove(_moreFishTokenKey);
  }

  String? getPharmaToken() {
    return _normalizedToken(sharedPreferences.getString(_pharmaTokenKey));
  }

  Future<void> setPharmaToken(String value) async {
    await sharedPreferences.setString(_pharmaTokenKey, value.trim());
  }

  Future<void> removePharmaToken() async {
    await sharedPreferences.remove(_pharmaTokenKey);
  }

  String? getPoultryToken() {
    return _normalizedToken(sharedPreferences.getString(_poultryTokenKey));
  }

  Future<void> setPoultryToken(String value) async {
    await sharedPreferences.setString(_poultryTokenKey, value.trim());
  }

  Future<void> removePoultryToken() async {
    await sharedPreferences.remove(_poultryTokenKey);
  }

  // --- Cattle Care Storage ---
  String? getCattleToken() {
    return _normalizedToken(sharedPreferences.getString(_cattleTokenKey));
  }

  Future<void> setCattleToken(String value) async {
    await sharedPreferences.setString(_cattleTokenKey, value.trim());
  }

  Future<void> removeCattleToken() async {
    await sharedPreferences.remove(_cattleTokenKey);
  }

  Future<void> removeAllTokens() async {
    await removeMoreFishToken();
    await removePharmaToken();
    await removePoultryToken();
    await removeCattleToken();
  }

  Future<void> clearMoreFishSession() async {
    await removeMoreFishToken();
    await removeMoreFishUserId();
  }

  Future<void> clearPharmaSession() async {
    await removePharmaToken();
    await removePharmaUserId();
  }

  Future<void> clearPoultrySession() async {
    await removePoultryToken();
    await removePoultryUserId();
  }

  Future<void> clearCattleSession() async {
    await removeCattleToken();
    await removeCattleUserId();
  }

  int? getUserId() {
    return getMoreFishUserId();
  }

  Future<void> setUserId(int value) async {
    await setMoreFishUserId(value);
  }

  Future<void> removeUserId() async {
    await removeMoreFishUserId();
  }

  int? getMoreFishUserId() {
    return sharedPreferences.getInt(_moreFishUserIdKey);
  }

  Future<void> setMoreFishUserId(int value) async {
    await sharedPreferences.setInt(_moreFishUserIdKey, value);
  }

  Future<void> removeMoreFishUserId() async {
    await sharedPreferences.remove(_moreFishUserIdKey);
  }

  int? getPharmaUserId() {
    return sharedPreferences.getInt(_pharmaUserIdKey);
  }

  Future<void> setPharmaUserId(int value) async {
    await sharedPreferences.setInt(_pharmaUserIdKey, value);
  }

  Future<void> removePharmaUserId() async {
    await sharedPreferences.remove(_pharmaUserIdKey);
  }

  int? getPoultryUserId() {
    return sharedPreferences.getInt(_poultryUserIdKey);
  }

  Future<void> setPoultryUserId(int value) async {
    await sharedPreferences.setInt(_poultryUserIdKey, value);
  }

  Future<void> removePoultryUserId() async {
    await sharedPreferences.remove(_poultryUserIdKey);
  }

  // --- Cattle Care User ID ---
  int? getCattleUserId() {
    return sharedPreferences.getInt(_cattleUserIdKey);
  }

  Future<void> setCattleUserId(int value) async {
    await sharedPreferences.setInt(_cattleUserIdKey, value);
  }

  Future<void> removeCattleUserId() async {
    await sharedPreferences.remove(_cattleUserIdKey);
  }

  bool hasValidToken() {
    return hasValidMoreFishToken();
  }

  bool hasValidMoreFishToken() {
    final token = getMoreFishToken();
    if (token == null) return false;
    final normalized = token.trim().toLowerCase();
    return normalized.isNotEmpty &&
        normalized != 'null' &&
        normalized != 'undefined';
  }

  bool hasValidPharmaToken() {
    final token = getPharmaToken();
    if (token == null) return false;
    final normalized = token.trim().toLowerCase();
    return normalized.isNotEmpty &&
        normalized != 'null' &&
        normalized != 'undefined';
  }

  bool hasValidPoultryToken() {
    final token = getPoultryToken();
    if (token == null) return false;
    final normalized = token.trim().toLowerCase();
    return normalized.isNotEmpty &&
        normalized != 'null' &&
        normalized != 'undefined';
  }

  bool hasValidCattleToken() {
    final token = getCattleToken();
    if (token == null) return false;
    final normalized = token.trim().toLowerCase();
    return normalized.isNotEmpty &&
        normalized != 'null' &&
        normalized != 'undefined';
  }

  String? _normalizedToken(String? token) {
    if (token == null) return null;
    final normalized = token.trim();
    return normalized.isEmpty ? null : normalized;
  }
}
