// import 'package:church_finance/core/constants/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:go_router/go_router.dart';
// import 'dart:async';
// import '../providers/auth_provider.dart';
// import '../widgets/otp_input_field.dart';

// class OtpVerificationScreen extends StatefulWidget {
//   final String phoneNumber;
//   final bool isNewUser;
  
//   const OtpVerificationScreen({
//     super.key,
//     required this.phoneNumber,
//     this.isNewUser = false,
//   });

//   @override
//   State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
// }

// class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
//   final TextEditingController _otpController = TextEditingController();
//   String _otp = '';
//   int _resendTimer = 60;
//   bool _canResend = false;
//   Timer? _timer;
//   bool _isLoading = false;
//   String? _errorMessage;
  
//   @override
//   void initState() {
//     super.initState();
//     _startResendTimer();
//     _requestOtp();
//   }
  
//   @override
//   void dispose() {
//     _timer?.cancel();
//     _otpController.dispose();
//     super.dispose();
//   }
  
//   void _startResendTimer() {
//     _canResend = false;
//     _resendTimer = 60;
//     _timer?.cancel();
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         if (_resendTimer > 0) {
//           _resendTimer--;
//         } else {
//           _canResend = true;
//           _timer?.cancel();
//         }
//       });
//     });
//   }
  
//   Future<void> _requestOtp() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
    
//     try {
//       final auth = context.read<AuthProvider>();
//       final response = await auth.requestOtp(widget.phoneNumber);
      
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(response.message),
//             backgroundColor: Colors.green,
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _errorMessage = e.toString();
//         });
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
  
//   Future<void> _verifyOtp() async {
//     if (_otp.length < 6) {
//       setState(() {
//         _errorMessage = 'Please enter the complete 6-digit code';
//       });
//       return;
//     }
    
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
    
//     try {
//       final auth = context.read<AuthProvider>();
//       final success = await auth.verifyOtp(_otp);
      
//       if (success && mounted) {
//         // Navigate to dashboard
//         context.go('/dashboard');
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _errorMessage = e.toString();
//         });
//         // Clear OTP on error
//         _otpController.clear();
//         _otp = '';
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             context.go('/login');
//           },
//         ),
//         title: const Text(
//           'Verify Phone',
//           style: TextStyle(color: Colors.black),
//         ),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 20),
              
//               // Illustration/Icon
//               Container(
//                 width: 120,
//                 height: 120,
//                 decoration: BoxDecoration(
//                   gradient: AppColors.secondaryGradient,
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: AppColors.secondary.withOpacity(0.3),
//                       blurRadius: 30,
//                       offset: const Offset(0, 10),
//                     ),
//                   ],
//                 ),
//                 child: const Icon(
//                   Icons.sms_rounded,
//                   size: 60,
//                   color: Colors.white,
//                 ),
//               ),
              
//               const SizedBox(height: 32),
              
//               // Title
//               const Text(
//                 'Enter Verification Code',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
              
//               const SizedBox(height: 8),
              
//               // Subtitle
//               Text(
//                 'We sent a 6-digit code to ${widget.phoneNumber}',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   color: AppColors.textSecondary,
//                 ),
//               ),
              
//               const SizedBox(height: 32),
              
//               // OTP Input
//               OtpInputField(
//                 controller: _otpController,
//                 onChanged: (value) {
//                   setState(() {
//                     _otp = value;
//                     _errorMessage = null;
//                   });
//                   // Auto-submit when 6 digits entered
//                   if (value.length == 6) {
//                     _verifyOtp();
//                   }
//                 },
//                 onSubmitted: (_) => _verifyOtp(),
//               ),
              
//               const SizedBox(height: 8),
              
//               // Error Message
//               if (_errorMessage != null) ...[
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.red.shade50,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.red.shade200),
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(
//                         Icons.error_outline,
//                         color: Colors.red,
//                         size: 20,
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           _errorMessage!,
//                           style: const TextStyle(
//                             color: Colors.red,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
              
//               const SizedBox(height: 16),
              
//               // Resend Button
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     _canResend ? "Didn't receive code?" : 'Resend in $_resendTimer s',
//                     style: const TextStyle(
//                       color: AppColors.textSecondary,
//                       fontSize: 14,
//                     ),
//                   ),
//                   if (_canResend) ...[
//                     const SizedBox(width: 8),
//                     GestureDetector(
//                       onTap: () {
//                         _startResendTimer();
//                         _requestOtp();
//                       },
//                       child: const Text(
//                         'Resend Code',
//                         style: TextStyle(
//                           color: AppColors.primary,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
              
//               const SizedBox(height: 32),
              
//               // Verify Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _verifyOtp,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: _isLoading
//                       ? const SizedBox(
//                           height: 24,
//                           width: 24,
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 2,
//                           ),
//                         )
//                       : const Text(
//                           'Verify & Continue',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                 ),
//               ),
              
//               const SizedBox(height: 16),
              
//               // Change phone number
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     "Wrong number? ",
//                     style: TextStyle(
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       context.go('/login');
//                     },
//                     child: const Text(
//                       'Change Number',
//                       style: TextStyle(
//                         color: AppColors.secondary,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }