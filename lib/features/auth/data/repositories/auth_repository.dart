import 'package:church_finance/features/auth/data/models/user_model.dart';
import 'package:church_finance/shared/services/api_service.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/auth_model.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );
      
      if (response.data['success'] == false) {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
      
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );
      
      if (response.data['success'] == false) {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
      
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post(ApiEndpoints.logout);
    } catch (e) {
      // Ignore errors during logout
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _apiService.get(ApiEndpoints.me);
      return UserModel.fromJson(response.data['user']);
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }
}