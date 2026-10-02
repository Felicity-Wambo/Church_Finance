import '../../data/models/auth_model.dart';
import '../../data/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;
  
  LoginUseCase(this._repository);
  
  Future<AuthResponse> execute(String phoneNumber, String pin) async {
    final request = LoginRequest(
      phoneNumber: phoneNumber,
      pin: pin,
    );
    return await _repository.login(request);
  }
}