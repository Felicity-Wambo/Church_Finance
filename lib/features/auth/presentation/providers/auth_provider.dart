import 'package:church_finance/features/auth/data/models/user_model.dart';
import 'package:church_finance/shared/services/local_storage_service.dart';
import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/auth_model.dart';

enum AuthStatus {
  unauthenticated,
  authenticating,
  authenticated,
}

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  final LocalStorageService _storage;

  AuthStatus _status = AuthStatus.unauthenticated;
  UserModel? _user;
  String? _token;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get token => _token;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.authenticating;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isAdmin => _user?.role == 'admin';
  bool get isTreasurer => _user?.role == 'treasurer';
  bool get isMember => _user?.role == 'member';

  AuthProvider({
    required AuthRepository repository,
    required LocalStorageService storage,
  }) : _repository = repository,
       _storage = storage {
    _loadCachedUser();
  }

  Future<void> _loadCachedUser() async {
    _token = await _storage.getToken();
    _user = await _storage.getUser();

    if (_token != null && _user != null) {
      _status = AuthStatus.authenticated;
      notifyListeners();
    }
  }

  Future<bool> login(String phoneNumber, String pin) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = LoginRequest(
        phoneNumber: phoneNumber,
        pin: pin,
      );

      final response = await _repository.login(request);

      _token = response.token;
      _user = response.user;

      await _storage.saveToken(response.token);
      await _storage.saveUser(response.user);
      await _storage.saveRefreshToken(response.refreshToken);
      await _storage.savePhoneNumber(phoneNumber);

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String phoneNumber,
    required String pin,
    required String confirmPin,
    required String firstName,
    required String lastName,
    String? email,
    String? role,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = RegisterRequest(
        phoneNumber: phoneNumber,
        pin: pin,
        confirmPin: confirmPin,
        firstName: firstName,
        lastName: lastName,
        email: email,
        role: role ?? 'member',
      );

      final response = await _repository.register(request);

      _token = response.token;
      _user = response.user;

      await _storage.saveToken(response.token);
      await _storage.saveUser(response.user);
      await _storage.saveRefreshToken(response.refreshToken);
      await _storage.savePhoneNumber(phoneNumber);

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _token = null;
    _user = null;
    _status = AuthStatus.unauthenticated;
    await _storage.clearAll();
    notifyListeners();
  }

  Future<void> savePhoneNumber(String phone) async {
    await _storage.savePhoneNumber(phone);
  }

  Future<String?> getSavedPhoneNumber() async {
    return await _storage.getPhoneNumber();
  }

  Future<void> clearError() async {
    _errorMessage = null;
    notifyListeners();
  }
}