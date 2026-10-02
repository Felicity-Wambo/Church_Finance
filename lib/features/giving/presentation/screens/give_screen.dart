import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/giving_providers.dart';
import '../widgets/church_selector.dart';
import '../widgets/mpesa_pay_button.dart';

class GiveScreen extends StatefulWidget {
  const GiveScreen({super.key});

  @override
  State<GiveScreen> createState() => _GiveScreenState();
}

class _GiveScreenState extends State<GiveScreen> {
  final _formKey = GlobalKey<FormState>();

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _customAmountController =
      TextEditingController();

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _phoneController =
      TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  String _selectedCategory = 'Tithe';

  String _selectedChurch = '';

  double _selectedAmount = 0;

  bool _isAnonymous = false;

  bool _isRecurring = false;

  // ============================================================
  // DATA
  // ============================================================

  final List<String> _categories = [
    'Tithe',
    'Offering',
    'Building Fund',
    'Mission',
    'Benevolence',
    'Thanksgiving',
  ];

  final List<String> _churches = [
    'Nairobi Church- Eastern Block',
    'Kisumu Church',
    'Mombasa Church',
    'Eldoret Church',
    'International Online Church',
  ];

  final List<double> _quickAmounts = [
    500,
    1000,
    2000,
    5000,
    10000,
    20000,
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _selectedChurch = _churches.first;
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _customAmountController.dispose();
    _nameController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GivingProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        title: const Text(
          'Give to the Lord',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor: Colors.transparent,

        foregroundColor: Colors.black,

        elevation: 0,

        actions: [
          IconButton(
            tooltip: 'Giving History',
            icon: const Icon(
              Icons.history,
              color: AppColors.primary,
            ),
            onPressed: () {
              context.push('/giving/history');
            },
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // ==================================================
                // CHURCH
                // ==================================================

                ChurchSelector(
                  churches: _churches,
                  selectedChurch: _selectedChurch,

                  onChanged: (church) {
                    setState(() {
                      _selectedChurch = church;
                    });
                  },
                ),

                const SizedBox(height: 26),

                // ==================================================
                // CATEGORY
                // ==================================================

                const Text(
                  'What type of giving?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,

                  children: _categories.map((category) {
                    final isSelected =
                        _selectedCategory == category;

                    return ChoiceChip(
                      label: Text(
                        category,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),

                      selected: isSelected,

                      selectedColor:
                          AppColors.primary,

                      backgroundColor:
                          Colors.grey.shade100,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20),
                      ),

                      onSelected: (selected) {
                        if (!selected) return;

                        setState(() {
                          _selectedCategory =
                              category;
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 26),

                // ==================================================
                // AMOUNT
                // ==================================================

                const Text(
                  'Select Amount (KSh)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 12,
                  runSpacing: 10,

                  children:
                      _quickAmounts.map((amount) {
                    final isSelected =
                        _selectedAmount ==
                            amount;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAmount =
                              amount;

                          _customAmountController
                              .clear();
                        });
                      },

                      child: Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),

                        decoration:
                            BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.white,

                          borderRadius:
                              BorderRadius.circular(
                            25,
                          ),

                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors
                                    .grey
                                    .shade300,

                            width:
                                isSelected
                                    ? 2
                                    : 1,
                          ),

                          boxShadow:
                              isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors
                                            .primary
                                            .withOpacity(
                                          0.25,
                                        ),
                                        blurRadius: 8,
                                        offset:
                                            const Offset(
                                          0,
                                          4,
                                        ),
                                      ),
                                    ]
                                  : null,
                        ),

                        child: Text(
                          'KSh ${amount.toStringAsFixed(0)}',

                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,

                            color: isSelected
                                ? Colors.white
                                : Colors.black87,

                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // ==================================================
                // CUSTOM AMOUNT
                // ==================================================

                _buildTextField(
                  controller:
                      _customAmountController,

                  label:
                      'Or enter custom amount',

                  hint:
                      'Enter amount',

                  prefixText:
                      'KSh ',

                  keyboardType:
                      const TextInputType
                          .numberWithOptions(
                    decimal: true,
                  ),

                  onChanged: (value) {
                    final amount =
                        double.tryParse(
                      value.trim(),
                    );

                    setState(() {
                      _selectedAmount =
                          amount ?? 0;
                    });
                  },

                  validator: (value) {
                    if (_selectedAmount <= 0) {
                      return 'Please select or enter an amount';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ==================================================
                // PHONE NUMBER
                // ==================================================

                _buildTextField(
                  controller:
                      _phoneController,

                  label:
                      'M-Pesa Phone Number',

                  hint:
                      '0712345678',

                  prefixText:
                      '+254 ',

                  keyboardType:
                      TextInputType.phone,

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter your M-Pesa phone number';
                    }

                    final cleaned =
                        value
                            .replaceAll(
                              RegExp(r'\s'),
                              '',
                            )
                            .replaceAll(
                              '+254',
                              '',
                            );

                    if (cleaned.length !=
                        10) {
                      return 'Enter a valid Kenyan phone number';
                    }

                    if (!RegExp(
                      r'^(07|01)\d{8}$',
                    ).hasMatch(cleaned)) {
                      return 'Use a number such as 0712345678';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ==================================================
                // OPTIONS
                // ==================================================

                Container(
                  decoration:
                      BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey
                            .withOpacity(
                          0.05,
                        ),
                        blurRadius: 8,
                      ),
                    ],
                  ),

                  child: Column(
                    children: [
                      // --------------------------------------------
                      // ANONYMOUS
                      // --------------------------------------------

                      SwitchListTile(
                        value:
                            _isAnonymous,

                        activeColor:
                            AppColors.primary,

                        title:
                            const Text(
                          'Give Anonymously',
                          style:
                              TextStyle(
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),

                        subtitle:
                            const Text(
                          'Your name will not be shown',
                          style:
                              TextStyle(
                            fontSize: 12,
                            color:
                                AppColors
                                    .textSecondary,
                          ),
                        ),

                        onChanged:
                            (value) {
                          setState(() {
                            _isAnonymous =
                                value;

                            if (value) {
                              _nameController
                                  .clear();
                            }
                          });
                        },
                      ),

                      Divider(
                        height: 1,
                        color:
                            Colors.grey.shade200,
                      ),

                      // --------------------------------------------
                      // RECURRING
                      // --------------------------------------------

                      SwitchListTile(
                        value:
                            _isRecurring,

                        activeColor:
                            AppColors.primary,

                        title:
                            const Text(
                          'Make it Monthly',
                          style:
                              TextStyle(
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),

                        subtitle:
                            const Text(
                          'We\'ll remind you every month',
                          style:
                              TextStyle(
                            fontSize: 12,
                            color:
                                AppColors
                                    .textSecondary,
                          ),
                        ),

                        onChanged:
                            (value) {
                          setState(() {
                            _isRecurring =
                                value;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // ==================================================
                // NAME
                // ==================================================

                if (!_isAnonymous) ...[
                  const SizedBox(height: 14),

                  _buildTextField(
                    controller:
                        _nameController,

                    label:
                        'Your Name',

                    hint:
                        'Enter your full name',

                    keyboardType:
                        TextInputType.name,

                    textCapitalization:
                        TextCapitalization
                            .words,

                    validator: (value) {
                      if (!_isAnonymous &&
                          (value == null ||
                              value
                                  .trim()
                                  .isEmpty)) {
                        return 'Please enter your name';
                      }

                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 28),

                // ==================================================
                // M-PESA BUTTON
                // ==================================================

                MpesaPayButton(
                  isLoading:
                      provider.isLoading,

                  amount:
                      _selectedAmount,

                  church:
                      _selectedChurch,

                  category:
                      _selectedCategory,

                  onPressed:
                      provider.isLoading
                          ? null
                          : _submitGiving,
                ),

                const SizedBox(height: 16),

                // ==================================================
                // ERROR
                // ==================================================

                if (provider.errorMessage !=
                    null)
                  Container(
                    width:
                        double.infinity,

                    margin:
                        const EdgeInsets.only(
                      top: 4,
                    ),

                    padding:
                        const EdgeInsets.all(
                      14,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          Colors.red.shade50,

                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),

                      border: Border.all(
                        color:
                            Colors.red.shade200,
                      ),
                    ),

                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        Icon(
                          Icons
                              .error_outline,
                          color: Colors
                              .red.shade700,
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Expanded(
                          child: Text(
                            provider
                                .errorMessage!,
                            style:
                                TextStyle(
                              color: Colors
                                  .red
                                  .shade700,
                              fontSize: 13,
                            ),
                          ),
                        ),

                        IconButton(
                          padding:
                              EdgeInsets.zero,

                          constraints:
                              const BoxConstraints(),

                          icon:
                              const Icon(
                            Icons.close,
                            size: 18,
                          ),

                          color: Colors
                              .red.shade700,

                          onPressed: () {
                            provider
                                .clearError();
                          },
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // ==================================================
                // SECURITY
                // ==================================================

                const Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,

                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 15,
                      color: AppColors
                          .textSecondary,
                    ),

                    SizedBox(width: 6),

                    Text(
                      'Secure M-Pesa payment',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors
                            .textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SUBMIT GIVING
  // ============================================================

  Future<void> _submitGiving() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider =
        context.read<GivingProvider>();

    provider.clearError();

    // ------------------------------------------------------------
    // NAME
    // ------------------------------------------------------------

    final name = _isAnonymous
        ? null
        : _nameController.text.trim();

    // ------------------------------------------------------------
    // PHONE
    // ------------------------------------------------------------

    String phone =
        _phoneController.text.trim();

    phone = phone.replaceAll(
      RegExp(r'\s'),
      '',
    );

    // Convert 07XXXXXXXX / 01XXXXXXXX to 254XXXXXXXXX
    if (phone.startsWith('0') &&
        phone.length == 10) {
      phone =
          '254${phone.substring(1)}';
    }

    // ------------------------------------------------------------
    // PROCESS GIVING
    // ------------------------------------------------------------

    final giving =
        await provider.processGiving(
      amount: _selectedAmount,

      category:
          _selectedCategory,

      church:
          _selectedChurch,

      memberName:
          name,

      phoneNumber:
          phone,

      isRecurring:
          _isRecurring,
    );

    if (!mounted) return;

    // ------------------------------------------------------------
    // FAILED TO CREATE PAYMENT
    // ------------------------------------------------------------

    if (giving == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                'Failed to initiate M-Pesa payment.',
          ),

          backgroundColor:
              Colors.red.shade700,
        ),
      );

      return;
    }

    // ------------------------------------------------------------
    // STK PUSH CREATED
    // ------------------------------------------------------------

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'M-Pesa prompt sent. Check your phone and enter your PIN.',
        ),

        duration:
            Duration(seconds: 4),
      ),
    );

    // ------------------------------------------------------------
    // GO TO PROCESSING SCREEN
    // ------------------------------------------------------------

    context.push(
      '/giving/processing',
      extra: giving,
    );
  }

  // ============================================================
  // TEXT FIELD BUILDER
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? prefixText,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization =
        TextCapitalization.none,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(12),

        boxShadow: [
          BoxShadow(
            color:
                Colors.grey.withOpacity(
              0.05,
            ),
            blurRadius: 8,
          ),
        ],
      ),

      child: TextFormField(
        controller: controller,

        keyboardType:
            keyboardType,

        textCapitalization:
            textCapitalization,

        onChanged:
            onChanged,

        validator:
            validator,

        decoration:
            InputDecoration(
          labelText: label,

          hintText: hint,

          prefixText:
              prefixText,

          prefixStyle:
              const TextStyle(
            fontWeight:
                FontWeight.bold,
            fontSize: 16,
          ),

          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
            borderSide:
                BorderSide.none,
          ),

          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
            borderSide:
                BorderSide.none,
          ),

          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
            borderSide:
                BorderSide(
              color:
                  AppColors.primary,
              width: 1.5,
            ),
          ),

          errorBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
            borderSide:
                BorderSide(
              color:
                  Colors.red.shade300,
            ),
          ),

          focusedErrorBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
            borderSide:
                BorderSide(
              color:
                  Colors.red.shade400,
            ),
          ),

          filled: true,

          fillColor:
              Colors.white,

          contentPadding:
              const EdgeInsets.all(
            16,
          ),
        ),
      ),
    );
  }
}

