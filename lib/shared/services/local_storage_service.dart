import 'package:church_finance/core/constants/app_constants.dart';
import 'package:church_finance/features/auth/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class LocalStorageService {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  LocalStorageService(this._prefs);

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConstants.storageTokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConstants.storageTokenKey);
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: AppConstants.storageTokenKey);
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    await _secureStorage.write(key: AppConstants.storageRefreshTokenKey, value: refreshToken);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConstants.storageRefreshTokenKey);
  }

  Future<void> saveUser(UserModel user) async {
    final json = jsonEncode(user.toJson());
    await _prefs.setString(AppConstants.storageUserKey, json);
  }

  Future<UserModel?> getUser() async {
    final json = _prefs.getString(AppConstants.storageUserKey);
    if (json == null) return null;
    try {
      final map = jsonDecode(json);
      return UserModel.fromJson(map);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearUser() async {
    await _prefs.remove(AppConstants.storageUserKey);
  }

  Future<void> savePhoneNumber(String phoneNumber) async {
    await _prefs.setString(AppConstants.storagePhoneNumberKey, phoneNumber);
  }

  Future<String?> getPhoneNumber() async {
    return _prefs.getString(AppConstants.storagePhoneNumberKey);
  }

  Future<void> saveRememberMe(bool remember) async {
    await _prefs.setBool(AppConstants.storageRememberMeKey, remember);
  }

  bool getRememberMe() {
    return _prefs.getBool(AppConstants.storageRememberMeKey) ?? false;
  }

  Future<void> clearAll() async {
    await clearToken();
    await _secureStorage.delete(key: AppConstants.storageRefreshTokenKey);
    await _prefs.remove(AppConstants.storageUserKey);
    await _prefs.remove(AppConstants.storagePhoneNumberKey);
    await _prefs.remove(AppConstants.storageRememberMeKey);
  }
}