import 'package:church_finance/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class OtpInputField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  
  const OtpInputField({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  
  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(6, (_) => FocusNode());
    _controllers = List.generate(6, (_) => TextEditingController());
    
    // Sync main controller
    widget.controller.addListener(_syncControllers);
  }
  
  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    widget.controller.removeListener(_syncControllers);
    super.dispose();
  }
  
  void _syncControllers() {
    final text = widget.controller.text;
    for (int i = 0; i < 6; i++) {
      if (i < text.length) {
        _controllers[i].text = text[i];
      } else {
        _controllers[i].text = '';
      }
    }
  }
  
  void _onDigitEntered(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
    
    // Update main controller
    final fullOtp = _controllers.map((c) => c.text).join();
    widget.controller.text = fullOtp;
    widget.onChanged?.call(fullOtp);
    
    if (fullOtp.length == 6) {
      widget.onSubmitted?.call(fullOtp);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 48,
          height: 60,
          child: TextFormField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onChanged: (value) {
              _onDigitEntered(index, value);
            },
            onTap: () {
              // Move cursor to the first empty field
              int firstEmpty = 0;
              for (int i = 0; i < 6; i++) {
                if (_controllers[i].text.isEmpty) {
                  firstEmpty = i;
                  break;
                }
                firstEmpty = 5;
              }
              _focusNodes[firstEmpty].requestFocus();
            },
          ),
        );
      }),
    );
  }
}