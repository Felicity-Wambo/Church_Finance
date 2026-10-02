import 'package:church_finance/features/giving/data/models/giving_model.dart';
import 'package:church_finance/features/giving/presentation/providers/giving_providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';

class GivingHistoryScreen extends StatefulWidget {
  const GivingHistoryScreen({super.key});

  @override
  State<GivingHistoryScreen> createState() =>
      _GivingHistoryScreenState();
}

class _GivingHistoryScreenState
    extends State<GivingHistoryScreen> {
  String _filter = 'All';

  final List<String> _filters = [
    'All',
    'Tithe',
    'Offering',
    'Building Fund',
    'Mission',
    'Benevolence',
    'Thanksgiving',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context
          .read<GivingProvider>()
          .loadGivingHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<GivingProvider>();

    final history =
        provider.givingHistory;

    final filteredHistory =
        _getFilteredHistory(history);

    return Scaffold(
      backgroundColor:
          Colors.grey.shade50,

      // ============================================================
      // APP BAR
      // ============================================================

      appBar: AppBar(
        title: const Text(
          'Giving History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor:
            Colors.white,

        elevation: 0,

        foregroundColor:
            Colors.black,

        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(
              Icons.refresh,
            ),
            onPressed:
                provider.isLoading
                    ? null
                    : () {
                        provider
                            .loadGivingHistory();
                      },
          ),
        ],
      ),

      // ============================================================
      // BODY
      // ============================================================

      body: Column(
        children: [
          // ==========================================================
          // SUMMARY CARD
          // ==========================================================

          _buildSummaryCard(history),

          // ==========================================================
          // FILTERS
          // ==========================================================

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),

            child: SizedBox(
              height: 42,

              child:
                  ListView.separated(
                scrollDirection:
                    Axis.horizontal,

                itemCount:
                    _filters.length,

                separatorBuilder:
                    (context, index) =>
                        const SizedBox(
                      width: 8,
                    ),

                itemBuilder:
                    (context, index) {
                  final filter =
                      _filters[index];

                  final isSelected =
                      _filter ==
                          filter;

                  return FilterChip(
                    label:
                        Text(filter),

                    selected:
                        isSelected,

                    onSelected:
                        (selected) {
                      if (!selected) {
                        return;
                      }

                      setState(() {
                        _filter =
                            filter;
                      });
                    },

                    selectedColor:
                        AppColors.primary,

                    backgroundColor:
                        Colors.white,

                    labelStyle:
                        TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors
                              .textSecondary,

                      fontWeight:
                          isSelected
                              ? FontWeight
                                  .w600
                              : FontWeight
                                  .normal,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),

                      side:
                          BorderSide(
                        color: isSelected
                            ? AppColors
                                .primary
                            : Colors
                                .grey
                                .shade300,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          // ==========================================================
          // HISTORY
          // ==========================================================

          Expanded(
            child: provider.isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )
                : provider.errorMessage !=
                        null &&
                    history.isEmpty
                    ? _buildErrorState(
                        provider,
                      )
                    : filteredHistory
                            .isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh:
                                provider
                                    .loadGivingHistory,

                            child:
                                ListView.builder(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),

                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),

                              itemCount:
                                  filteredHistory
                                      .length,

                              itemBuilder:
                                  (
                                context,
                                index,
                              ) {
                                final giving =
                                    filteredHistory[
                                        index];

                                return _buildHistoryCard(
                                  giving,
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummaryCard(
    List<GivingModel> history,
  ) {
    final total =
        _getTotalGiving(history);

    final tithes =
        _getCategoryTotal(
      history,
      'Tithe',
    );

    final offerings =
        _getCategoryTotal(
      history,
      'Offering',
    );

    final others =
        _getCategoryTotal(
      history,
      'Other',
    );

    return Container(
      width: double.infinity,

      margin:
          const EdgeInsets.all(16),

      padding:
          const EdgeInsets.all(20),

      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,

          end:
              Alignment.bottomRight,

          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),

        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            'Total Giving',
            style: TextStyle(
              color:
                  Colors.white70,
              fontSize: 14,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            'KSh ${total.toStringAsFixed(0)}',

            style:
                const TextStyle(
              color:
                  Colors.white,
              fontSize: 28,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          Row(
            children: [
              Expanded(
                child:
                    _buildStatItem(
                  'Tithes',
                  tithes,
                ),
              ),

              Expanded(
                child:
                    _buildStatItem(
                  'Offerings',
                  offerings,
                ),
              ),

              Expanded(
                child:
                    _buildStatItem(
                  'Others',
                  others,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STAT ITEM
  // ============================================================

  Widget _buildStatItem(
    String label,
    double amount,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          label,

          style:
              const TextStyle(
            color:
                Colors.white70,
            fontSize: 12,
          ),
        ),

        const SizedBox(
          height: 2,
        ),

        Text(
          'KSh ${amount.toStringAsFixed(0)}',

          style:
              const TextStyle(
            color:
                Colors.white,
            fontWeight:
                FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HISTORY CARD
  // ============================================================

  Widget _buildHistoryCard(
    GivingModel giving,
  ) {
    final status =
        giving.status
            .toString()
            .toLowerCase();

    final isCompleted =
        status == 'completed' ||
        status == 'success' ||
        status == 'successful';

    final isFailed =
        status == 'failed' ||
        status == 'cancelled' ||
        status == 'canceled';

    final statusColor =
        _getStatusColor(status);

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      padding:
          const EdgeInsets.all(16),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          12,
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.grey.withOpacity(
              0.05,
            ),

            blurRadius:
                8,

            offset:
                const Offset(
              0,
              2,
            ),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,

        children: [
          // ========================================================
          // STATUS ICON
          // ========================================================

          Container(
            padding:
                const EdgeInsets.all(
              12,
            ),

            decoration:
                BoxDecoration(
              color: statusColor
                  .withOpacity(
                0.1,
              ),

              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),

            child: Icon(
              isCompleted
                  ? Icons
                      .check_circle
                  : isFailed
                      ? Icons
                          .cancel
                      : Icons
                          .pending,

              color:
                  statusColor,

              size: 24,
            ),
          ),

          const SizedBox(
            width: 16,
          ),

          // ========================================================
          // DETAILS
          // ========================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                Text(
                  giving.category,

                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  giving.formattedDate,

                  style:
                      const TextStyle(
                    fontSize: 12,
                    color: AppColors
                        .textSecondary,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                if (_getChurchName(
                        giving) !=
                    null)
                  Text(
                    'Church: ${_getChurchName(giving)}',

                    maxLines: 2,

                    overflow:
                        TextOverflow
                            .ellipsis,

                    style:
                        const TextStyle(
                      fontSize: 11,
                      color: AppColors
                          .textSecondary,
                    ),
                  ),

                if (giving.mpesaReceipt !=
                    null) ...[
                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    'Receipt: ${giving.mpesaReceipt}',

                    maxLines: 1,

                    overflow:
                        TextOverflow
                            .ellipsis,

                    style:
                        const TextStyle(
                      fontSize: 10,
                      color: AppColors
                          .textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          // ========================================================
          // AMOUNT + STATUS
          // ========================================================

          Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .end,

            children: [
              Text(
                'KSh ${giving.amount.toStringAsFixed(0)}',

                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 16,
                  color: AppColors
                      .primary,
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      statusColor
                          .withOpacity(
                    0.1,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    8,
                  ),
                ),

                child: Text(
                  _formatStatus(
                    status,
                  ),

                  style:
                      TextStyle(
                    fontSize: 10,
                    color:
                        statusColor,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState(
    GivingProvider provider,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          24,
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment
                  .center,

          children: [
            Icon(
              Icons
                  .cloud_off_outlined,

              size: 64,

              color:
                  Colors.red.shade300,
            ),

            const SizedBox(
              height: 16,
            ),

            const Text(
              'Unable to load giving history',

              textAlign:
                  TextAlign.center,

              style:
                  TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              provider.errorMessage ??
                  'Something went wrong.',

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color: AppColors
                    .textSecondary,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton.icon(
              onPressed:
                  provider.isLoading
                      ? null
                      : () {
                          provider
                              .clearError();

                          provider
                              .loadGivingHistory();
                        },

              icon:
                  const Icon(
                Icons.refresh,
              ),

              label:
                  const Text(
                'Try Again',
              ),

              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    AppColors
                        .primary,
                foregroundColor:
                    Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment
                .center,

        children: [
          Icon(
            Icons.history,

            size: 64,

            color:
                AppColors
                    .textSecondary,
          ),

          const SizedBox(
            height: 16,
          ),

          Text(
            _filter == 'All'
                ? 'No giving history yet'
                : 'No $_filter records',

            style:
                const TextStyle(
              fontSize: 18,
              color: AppColors
                  .textSecondary,
              fontWeight:
                  FontWeight.w500,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            _filter == 'All'
                ? 'Your giving records will appear here'
                : 'Try selecting another category',

            style:
                const TextStyle(
              color: AppColors
                  .textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOTAL
  // ============================================================

  double _getTotalGiving(
    List<GivingModel> history,
  ) {
    return history.fold(
      0.0,
      (
        sum,
        item,
      ) =>
          sum + item.amount,
    );
  }

  // ============================================================
  // CATEGORY TOTAL
  // ============================================================

  double _getCategoryTotal(
    List<GivingModel> history,
    String category,
  ) {
    return history
        .where(
          (item) {
            if (category ==
                'Other') {
              return ![
                'Tithe',
                'Offering',
              ].contains(
                item.category,
              );
            }

            return item.category ==
                category;
          },
        )
        .fold(
          0.0,
          (
            sum,
            item,
          ) =>
              sum + item.amount,
        );
  }

  // ============================================================
  // FILTER HISTORY
  // ============================================================

  List<GivingModel>
      _getFilteredHistory(
    List<GivingModel> history,
  ) {
    if (_filter == 'All') {
      return history;
    }

    return history
        .where(
          (item) =>
              item.category ==
              _filter,
        )
        .toList();
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _getStatusColor(
    String status,
  ) {
    switch (status) {
      case 'completed':
      case 'success':
      case 'successful':
        return Colors.green;

      case 'failed':
      case 'cancelled':
      case 'canceled':
        return Colors.red;

      case 'pending':
      case 'processing':
        return Colors.orange;

      default:
        return Colors.grey;
    }
  }

  // ============================================================
  // STATUS TEXT
  // ============================================================

  String _formatStatus(
    String status,
  ) {
    switch (status) {
      case 'completed':
        return 'Completed';

      case 'success':
      case 'successful':
        return 'Successful';

      case 'failed':
        return 'Failed';

      case 'cancelled':
      case 'canceled':
        return 'Cancelled';

      case 'pending':
        return 'Pending';

      case 'processing':
        return 'Processing';

      default:
        if (status.isEmpty) {
          return 'Unknown';
        }

        return status[0]
                .toUpperCase() +
            status.substring(1);
    }
  }

  // ============================================================
  // CHURCH NAME
  // ============================================================

  String? _getChurchName(
    GivingModel giving,
  ) {
    // If your GivingModel already exposes churchName,
    // use it first.

    try {
      if (giving.churchName != null &&
          giving.churchName!
              .trim()
              .isNotEmpty) {
        return giving.churchName;
      }
    } catch (_) {
      // Ignore if churchName isn't available
    }

    // Fallback to church.
    try {
      if (giving.churchId != null &&
          giving.churchId!
              .trim()
              .isNotEmpty) {
        return giving.churchId;
      }
    } catch (_) {
      // Ignore
    }

    return null;
  }
}

