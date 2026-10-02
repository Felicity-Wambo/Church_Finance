// import '../../data/models/auth_model.dart';
// import '../../data/repositories/auth_repository.dart';

// class RequestOtpUseCase {
//   final AuthRepository _repository;
  
//   RequestOtpUseCase(this._repository);
  
//   Future<OtpResponse> execute(String phoneNumber) async {
//     final request = OtpRequest(
//       phoneNumber: phoneNumber,
//       deviceId: await _getDeviceId(),
//     );
//     return await _repository.requestOtp(request);
//   }
  
//   Future<String?> _getDeviceId() async {
//     // TODO: Get device ID using device_info_plus package
//     return null;
//   }
// }

// class VerifyOtpUseCase {
//   final AuthRepository _repository;
  
//   VerifyOtpUseCase(this._repository);
  
//   Future<AuthResponse> execute(String phoneNumber, String otp) async {
//     final request = OtpVerificationRequest(
//       phoneNumber: phoneNumber,
//       otp: otp,
//       deviceId: await _getDeviceId(),
//     );
//     return await _repository.verifyOtp(request);
//   }
  
//   Future<String?> _getDeviceId() async {
//     // TODO: Get device ID using device_info_plus package
//     return null;
//   }
// }