import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/giving_model.dart';
import '../providers/giving_providers.dart';

class GivingProcessingScreen
    extends StatefulWidget {
  final GivingModel giving;

  const GivingProcessingScreen({
    super.key,
    required this.giving,
  });

  @override
  State<GivingProcessingScreen> createState() =>
      _GivingProcessingScreenState();
}

class _GivingProcessingScreenState
    extends State<GivingProcessingScreen> {
  Timer? _timer;

  bool _isChecking = false;
  bool _paymentCompleted = false;
  bool _paymentFailed = false;

  int _attempts = 0;

  static const int _maxAttempts = 30;

  String _message =
      'Check your phone for the M-Pesa prompt and enter your PIN.';

  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 3),
      () {
        if (mounted) {
          _startChecking();
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ============================================================
  // START STATUS CHECKING
  // ============================================================

  void _startChecking() {
    if (!mounted) return;

    _checkPaymentStatus();

    _timer = Timer.periodic(
      const Duration(seconds: 4),
      (_) {
        _checkPaymentStatus();
      },
    );
  }

  // ============================================================
  // CHECK STATUS
  // ============================================================

  Future<void> _checkPaymentStatus() async {
    if (!mounted ||
        _isChecking ||
        _paymentCompleted ||
        _paymentFailed) {
      return;
    }

    if (_attempts >= _maxAttempts) {
      _timer?.cancel();

      setState(() {
        _message =
            'We could not confirm the payment yet. Please check your M-Pesa messages or giving history.';
      });

      return;
    }

    _isChecking = true;
    _attempts++;

    try {
      final checkoutRequestId =
          widget.giving.mpesaCheckoutId;

      if (checkoutRequestId == null ||
          checkoutRequestId.isEmpty) {
        _timer?.cancel();

        if (!mounted) return;

        setState(() {
          _paymentFailed = true;
          _message =
              'The M-Pesa checkout request ID is missing.';
        });

        return;
      }

      final provider =
          context.read<GivingProvider>();

      final updatedGiving =
          await provider.checkMpesaStatus(
        checkoutRequestId,
      );

      if (!mounted) return;

      if (updatedGiving == null) {
        setState(() {
          _message =
              'Waiting for M-Pesa confirmation...';
        });

        return;
      }

      final status =
          updatedGiving.status
              .toLowerCase();

      // ========================================================
      // SUCCESS
      // ========================================================

      if (updatedGiving.isCompleted ||
          status == 'completed' ||
          status == 'success') {
        _timer?.cancel();

        provider.setCompletedGiving(
          updatedGiving,
        );

        setState(() {
          _paymentCompleted = true;

          _message =
              'Your payment has been confirmed successfully!';
        });

        await Future.delayed(
          const Duration(milliseconds: 800),
        );

        if (!mounted) return;

        context.go(
          '/giving/success',
          extra: updatedGiving,
        );

        return;
      }

      // ========================================================
      // FAILED
      // ========================================================

      if (status == 'failed' ||
          status == 'cancelled' ||
          status == 'canceled') {
        _timer?.cancel();

        provider.setCompletedGiving(
          updatedGiving,
        );

        setState(() {
          _paymentFailed = true;

          _message =
              updatedGiving
                      .mpesaResultDescription ??
                  'The M-Pesa payment was not completed.';
        });

        return;
      }

      // ========================================================
      // PENDING
      // ========================================================

      setState(() {
        _message =
            'Waiting for M-Pesa confirmation...';
      });
    } catch (e) {
      debugPrint(
        '❌ Payment status error: $e',
      );

      if (!mounted) return;

      setState(() {
        _message =
            'Waiting for M-Pesa confirmation...';
      });
    } finally {
      _isChecking = false;
    }
  }

  // ============================================================
  // TRY AGAIN
  // ============================================================

  void _tryAgain() {
    _timer?.cancel();

    if (!mounted) return;

    context.go('/give');
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final giving = widget.giving;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor:
            Colors.grey.shade50,

        appBar: AppBar(
          automaticallyImplyLeading:
              false,
          title: const Text(
            'M-Pesa Payment',
            style: TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor:
              Colors.transparent,
          foregroundColor: Colors.black,
          elevation: 0,
        ),

        body: SafeArea(
          child: Center(
            child:
                SingleChildScrollView(
              padding:
                  const EdgeInsets.all(
                24,
              ),
              child: Column(
                children: [
                  _buildStatusIcon(),

                  const SizedBox(
                    height: 28,
                  ),

                  Text(
                    _paymentCompleted
                        ? 'Payment Successful!'
                        : _paymentFailed
                            ? 'Payment Failed'
                            : 'Processing Payment',
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      fontSize: 25,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  Text(
                    _message,
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors
                          .grey.shade700,
                    ),
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  _buildGivingDetails(
                    giving,
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  if (!_paymentCompleted &&
                      !_paymentFailed)
                    Column(
                      children: [
                        const CircularProgressIndicator(),

                        const SizedBox(
                          height: 14,
                        ),

                        Text(
                          'Checking payment status...',
                          style:
                              TextStyle(
                            fontSize: 13,
                            color: Colors
                                .grey
                                .shade600,
                          ),
                        ),
                      ],
                    ),

                  if (_paymentFailed)
                    Column(
                      children: [
                        SizedBox(
                          width:
                              double.infinity,
                          child:
                              ElevatedButton(
                            onPressed:
                                _tryAgain,
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  AppColors
                                      .primary,
                              foregroundColor:
                                  Colors
                                      .white,
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                vertical: 16,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  12,
                                ),
                              ),
                            ),
                            child:
                                const Text(
                              'Try Again',
                              style:
                                  TextStyle(
                                fontSize:
                                    16,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        TextButton(
                          onPressed: () {
                            context.go(
                              '/giving/history',
                            );
                          },
                          child:
                              const Text(
                            'View Giving History',
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(
                    height: 28,
                  ),

                  const Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 15,
                        color: Colors.grey,
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Text(
                        'Secure M-Pesa payment',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STATUS ICON
  // ============================================================

  Widget _buildStatusIcon() {
    if (_paymentCompleted) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green.shade100,
        ),
        child: Icon(
          Icons.check_circle,
          size: 70,
          color: Colors.green.shade600,
        ),
      );
    }

    if (_paymentFailed) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red.shade100,
        ),
        child: Icon(
          Icons.cancel,
          size: 70,
          color: Colors.red.shade600,
        ),
      );
    }

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary
            .withOpacity(0.1),
      ),
      child: Icon(
        Icons.phone_android,
        size: 55,
        color: AppColors.primary,
      ),
    );
  }

  // ============================================================
  // GIVING DETAILS
  // ============================================================

  Widget _buildGivingDetails(
    GivingModel giving,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          _detailRow(
            'Amount',
            'KSh ${giving.amount.toStringAsFixed(0)}',
            bold: true,
          ),

          const SizedBox(
            height: 14,
          ),

          _detailRow(
            'Category',
            giving.category,
          ),

          const SizedBox(
            height: 14,
          ),

          _detailRow(
            'Church',
            giving.churchName ??
                'Church',
          ),

          const SizedBox(
            height: 14,
          ),

          _detailRow(
            'Status',
            giving.status,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _detailRow(
    String label,
    String value, {
    bool bold = false,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color:
                  Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ),

        const SizedBox(
          width: 15,
        ),

        Flexible(
          child: Text(
            value,
            textAlign:
                TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold
                  ? FontWeight.bold
                  : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}