const Giving = require('../models/giving');
const Church = require('../models/church');
const User = require('../models/User');
const GivingAccount = require('../models/givingAccount');
const mpesaService = require('../services/mpesaService');

// ============================================================
// PROCESS GIVING
// POST /api/v1/giving/process
// ============================================================

exports.processGiving = async (req, res) => {
  try {
    const {
      amount,
      category,
      memberName,
      phoneNumber,
      church,
      isRecurring,
    } = req.body;

    console.log('======================================');
    console.log('📩 PROCESSING GIVING');
    console.log('======================================');
    console.log('Request:', req.body);

    // --------------------------------------------------------
    // Validate amount
    // --------------------------------------------------------

    if (!amount || Number(amount) <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Invalid amount',
      });
    }

    // --------------------------------------------------------
    // Validate category
    // --------------------------------------------------------

    if (!category) {
      return res.status(400).json({
        success: false,
        message: 'Giving category is required',
      });
    }

    // --------------------------------------------------------
    // Validate church
    // --------------------------------------------------------

    if (!church) {
      return res.status(400).json({
        success: false,
        message: 'Church is required',
      });
    }

    // --------------------------------------------------------
    // Get logged-in user
    // --------------------------------------------------------

    const user = await User.findById(req.user.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    // --------------------------------------------------------
    // Find church
    // --------------------------------------------------------

    const churchData = await Church.findOne({
      name: church,
      isActive: true,
    });

    if (!churchData) {
      return res.status(404).json({
        success: false,
        message: 'Church not found',
      });
    }

    // --------------------------------------------------------
    // Find destination giving account
    // --------------------------------------------------------

    const givingAccount = await GivingAccount.findOne({
      churchId: churchData._id,
      category: category,
      isActive: true,
    });

    if (!givingAccount) {
      return res.status(404).json({
        success: false,
        message:
          `No active ${category} account found for ${churchData.name}`,
      });
    }

    console.log('🏦 Destination account found:', {
      id: givingAccount._id,
      category: givingAccount.category,
      accountName: givingAccount.accountName,
      bankName: givingAccount.bankName,
      bankAccount: givingAccount.bankAccount,
    });

    // --------------------------------------------------------
    // Phone number
    // --------------------------------------------------------

    const userPhone =
      phoneNumber || user.phoneNumber;

    if (!userPhone) {
      return res.status(400).json({
        success: false,
        message: 'Phone number is required',
      });
    }

    // --------------------------------------------------------
    // Create unique transaction reference
    // --------------------------------------------------------

    const accountReference =
      `GIVING${Date.now()}`;

    // --------------------------------------------------------
    // Send M-Pesa STK Push
    // --------------------------------------------------------

    console.log('📱 Sending M-Pesa STK Push...');

    const mpesaResponse =
      await mpesaService.stkPush(
        userPhone,
        Number(amount),
        accountReference,
        `${category} - ${churchData.name}`
      );

    console.log(
      '📱 M-Pesa Response:',
      mpesaResponse
    );

    // --------------------------------------------------------
    // Check whether Safaricom accepted request
    // --------------------------------------------------------

    if (
      !mpesaResponse ||
      String(mpesaResponse.ResponseCode) !== '0'
    ) {
      return res.status(400).json({
        success: false,
        message:
          mpesaResponse?.ResponseDescription ||
          'M-Pesa STK Push failed',
        mpesaResponse,
      });
    }

    // --------------------------------------------------------
    // Get CheckoutRequestID
    // --------------------------------------------------------

    const checkoutRequestId =
      mpesaResponse.CheckoutRequestID;

    if (!checkoutRequestId) {
      console.error(
        '❌ M-Pesa did not return CheckoutRequestID'
      );

      return res.status(500).json({
        success: false,
        message:
          'M-Pesa did not return a checkout request ID',
        mpesaResponse,
      });
    }

    // --------------------------------------------------------
    // Create pending giving record
    // --------------------------------------------------------

    const giving =
      await Giving.create({
        amount: Number(amount),

        category: category,

        memberId: req.user.id,

        memberName:
          memberName ||
          `${user.firstName || ''} ${user.lastName || ''}`
            .trim(),

        phoneNumber: userPhone,

        churchId: churchData._id,

        churchName: churchData.name,

        destinationAccountId:
          givingAccount._id,

        destinationBank:
          givingAccount.bankName,

        destinationBankAccount:
          givingAccount.bankAccount,

        destinationAccountName:
          givingAccount.accountName,

        status: 'pending',

        mpesaReceipt: null,

        mpesaCheckoutId:
          checkoutRequestId,

        mpesaMerchantRequestId:
          mpesaResponse.MerchantRequestID ||
          null,

        mpesaResponseCode:
          mpesaResponse.ResponseCode ||
          null,

        mpesaResultDescription:
          mpesaResponse.ResponseDescription ||
          null,

        transactionDate: null,

        isRecurring:
          Boolean(isRecurring),

        completedAt: null,
      });

    console.log('======================================');
    console.log('✅ GIVING RECORD CREATED');
    console.log('======================================');
    console.log('Giving ID:', giving._id);
    console.log(
      'CheckoutRequestID:',
      giving.mpesaCheckoutId
    );
    console.log('Status:', giving.status);
    console.log('======================================');

    // --------------------------------------------------------
    // Response
    // --------------------------------------------------------

    return res.status(201).json({
      success: true,

      message:
        'STK Push sent successfully. Please complete the payment on your phone.',

      giving: {
        id: giving._id,

        amount: giving.amount,

        category: giving.category,

        memberName: giving.memberName,

        phoneNumber: giving.phoneNumber,

        church: giving.churchName,

        churchName: giving.churchName,

        destinationAccount: {
          id: giving.destinationAccountId,

          name:
            giving.destinationAccountName,

          bank:
            giving.destinationBank,

          bankAccount:
            giving.destinationBankAccount,
        },

        status: giving.status,

        mpesaCheckoutId:
          giving.mpesaCheckoutId,

        mpesaMerchantRequestId:
          giving.mpesaMerchantRequestId,

        mpesaReceipt:
          giving.mpesaReceipt,

        isRecurring:
          giving.isRecurring,

        createdAt:
          giving.createdAt,
      },

      mpesaResponse,
    });
  } catch (error) {
    console.error(
      '❌ Giving processing error:',
      error
    );

    return res.status(500).json({
      success: false,

      message:
        'Failed to process giving',

      error: error.message,
    });
  }
};

// ============================================================
// GET GIVING HISTORY
// GET /api/v1/giving/history
// ============================================================

exports.getHistory = async (req, res) => {
  try {
    const giving =
      await Giving.find({
        memberId: req.user.id,
      })
        .populate(
          'churchId',
          'name location'
        )
        .populate(
          'destinationAccountId',
          'category accountName bankName bankAccount bankCode'
        )
        .sort({
          createdAt: -1,
        })
        .limit(100);

    return res.status(200).json({
      success: true,

      count: giving.length,

      history: giving,
    });
  } catch (error) {
    console.error(
      '❌ History error:',
      error
    );

    return res.status(500).json({
      success: false,

      message:
        'Failed to fetch history',

      error: error.message,
    });
  }
};

// ============================================================
// GET GIVING SUMMARY
// GET /api/v1/giving/summary
// ============================================================

exports.getSummary = async (req, res) => {
  try {
    const totalGiving =
      await Giving.aggregate([
        {
          $match: {
            memberId: req.user.id,
            status: 'completed',
          },
        },

        {
          $group: {
            _id: null,

            total: {
              $sum: '$amount',
            },
          },
        },
      ]);

    const monthlyGiving =
      await Giving.aggregate([
        {
          $match: {
            memberId: req.user.id,

            status: 'completed',

            createdAt: {
              $gte: new Date(
                new Date().getFullYear(),
                new Date().getMonth(),
                1
              ),
            },
          },
        },

        {
          $group: {
            _id: null,

            total: {
              $sum: '$amount',
            },
          },
        },
      ]);

    const byCategory =
      await Giving.aggregate([
        {
          $match: {
            memberId: req.user.id,
            status: 'completed',
          },
        },

        {
          $group: {
            _id: '$category',

            total: {
              $sum: '$amount',
            },
          },
        },

        {
          $sort: {
            total: -1,
          },
        },
      ]);

    const byChurch =
      await Giving.aggregate([
        {
          $match: {
            memberId: req.user.id,
            status: 'completed',
          },
        },

        {
          $group: {
            _id: '$churchName',

            total: {
              $sum: '$amount',
            },
          },
        },

        {
          $sort: {
            total: -1,
          },
        },
      ]);

    return res.status(200).json({
      success: true,

      summary: {
        totalGiving:
          totalGiving[0]?.total || 0,

        monthlyGiving:
          monthlyGiving[0]?.total || 0,

        byCategory,

        byChurch,
      },
    });
  } catch (error) {
    console.error(
      '❌ Summary error:',
      error
    );

    return res.status(500).json({
      success: false,

      message:
        'Failed to fetch summary',

      error: error.message,
    });
  }
};

// ============================================================
// GET GIVING BY CHURCH
// GET /api/v1/giving/by-church/:churchId
// ============================================================

exports.getByChurch = async (req, res) => {
  try {
    const { churchId } = req.params;

    const giving =
      await Giving.find({
        memberId: req.user.id,

        churchId,

        status: 'completed',
      })
        .populate(
          'destinationAccountId',
          'category accountName bankName bankAccount bankCode'
        )
        .sort({
          createdAt: -1,
        });

    return res.status(200).json({
      success: true,

      count: giving.length,

      giving,
    });
  } catch (error) {
    console.error(
      '❌ Get by church error:',
      error
    );

    return res.status(500).json({
      success: false,

      message:
        'Failed to get giving by church',

      error: error.message,
    });
  }
};

// ============================================================
// GET RECENT GIVING
// GET /api/v1/giving/recent
// ============================================================

exports.getRecent = async (req, res) => {
  try {
    const giving =
      await Giving.find({
        memberId: req.user.id,
      })
        .populate(
          'destinationAccountId',
          'category accountName bankName bankAccount bankCode'
        )
        .sort({
          createdAt: -1,
        })
        .limit(5);

    return res.status(200).json({
      success: true,

      recent: giving,
    });
  } catch (error) {
    console.error(
      '❌ Recent giving error:',
      error
    );

    return res.status(500).json({
      success: false,

      message:
        'Failed to get recent giving',

      error: error.message,
    });
  }
};

// ============================================================
// GET GIVING STATS
// GET /api/v1/giving/stats
// ============================================================

exports.getStats = async (req, res) => {
  try {
    const stats =
      await Giving.aggregate([
        {
          $match: {
            memberId: req.user.id,
            status: 'completed',
          },
        },

        {
          $group: {
            _id: null,

            totalAmount: {
              $sum: '$amount',
            },

            totalCount: {
              $sum: 1,
            },

            avgAmount: {
              $avg: '$amount',
            },

            maxAmount: {
              $max: '$amount',
            },

            minAmount: {
              $min: '$amount',
            },
          },
        },
      ]);

    const monthlyStats =
      await Giving.aggregate([
        {
          $match: {
            memberId: req.user.id,

            status: 'completed',

            createdAt: {
              $gte: new Date(
                new Date().getFullYear(),
                new Date().getMonth() - 6,
                1
              ),
            },
          },
        },

        {
          $group: {
            _id: {
              year: {
                $year: '$createdAt',
              },

              month: {
                $month: '$createdAt',
              },
            },

            total: {
              $sum: '$amount',
            },

            count: {
              $sum: 1,
            },
          },
        },

        {
          $sort: {
            '_id.year': 1,
            '_id.month': 1,
          },
        },
      ]);

    return res.status(200).json({
      success: true,

      stats:
        stats[0] || {
          totalAmount: 0,
          totalCount: 0,
          avgAmount: 0,
          maxAmount: 0,
          minAmount: 0,
        },

      monthlyStats,
    });
  } catch (error) {
    console.error(
      '❌ Stats error:',
      error
    );

    return res.status(500).json({
      success: false,

      message:
        'Failed to get stats',

      error: error.message,
    });
  }
};

// ============================================================
// M-PESA CALLBACK
// POST /api/v1/giving/mpesa/callback
// ============================================================

exports.mpesaCallback = async (req, res) => {
  try {
    console.log('======================================');
    console.log('📱 M-PESA CALLBACK RECEIVED');
    console.log('======================================');

    console.log(
      JSON.stringify(
        req.body,
        null,
        2
      )
    );

    const stkCallback =
      req.body?.Body?.stkCallback;

    if (!stkCallback) {
      console.error(
        '❌ Invalid M-Pesa callback payload'
      );

      return res.status(400).json({
        ResultCode: 1,

        ResultDesc:
          'Invalid callback payload',
      });
    }

    const checkoutRequestId =
      stkCallback.CheckoutRequestID;

    if (!checkoutRequestId) {
      console.error(
        '❌ Missing CheckoutRequestID'
      );

      return res.status(400).json({
        ResultCode: 1,

        ResultDesc:
          'CheckoutRequestID missing',
      });
    }

    // --------------------------------------------------------
    // Find giving record
    // --------------------------------------------------------

    const giving =
      await Giving.findOne({
        mpesaCheckoutId:
          checkoutRequestId,
      });

    if (!giving) {
      console.error(
        '❌ Giving record not found:',
        checkoutRequestId
      );

      // Acknowledge Safaricom callback
      return res.status(200).json({
        ResultCode: 0,

        ResultDesc: 'Accepted',
      });
    }

    // ========================================================
    // SUCCESS
    // ========================================================

    if (
      Number(stkCallback.ResultCode) === 0
    ) {
      const items =
        stkCallback
          .CallbackMetadata
          ?.Item || [];

      const getItem = (name) => {
        const item =
          items.find(
            (entry) =>
              entry.Name === name
          );

        return item?.Value;
      };

      const receiptNumber =
        getItem(
          'MpesaReceiptNumber'
        ) ||
        getItem(
          'ReceiptNumber'
        );

      const transactionDate =
        getItem(
          'TransactionDate'
        );

      const phoneNumber =
        getItem(
          'PhoneNumber'
        );

      const amount =
        getItem('Amount');

      // ------------------------------------------------------
      // Update giving
      // ------------------------------------------------------

      giving.status =
        'completed';

      giving.mpesaReceipt =
        receiptNumber ||
        giving.mpesaReceipt;

      giving.mpesaResponseCode =
        '0';

      giving.mpesaResultDescription =
        stkCallback.ResultDesc ||
        'Success';

      // ------------------------------------------------------
      // Transaction date
      // ------------------------------------------------------

      if (transactionDate) {
        const dateString =
          String(
            transactionDate
          );

        if (
          dateString.length >= 14
        ) {
          const year =
            dateString.substring(
              0,
              4
            );

          const month =
            dateString.substring(
              4,
              6
            );

          const day =
            dateString.substring(
              6,
              8
            );

          const hour =
            dateString.substring(
              8,
              10
            );

          const minute =
            dateString.substring(
              10,
              12
            );

          const second =
            dateString.substring(
              12,
              14
            );

          giving.transactionDate =
            new Date(
              `${year}-${month}-${day}T${hour}:${minute}:${second}`
            );
        } else {
          giving.transactionDate =
            new Date();
        }
      } else {
        giving.transactionDate =
          new Date();
      }

      giving.completedAt =
        new Date();

      console.log(
        '======================================'
      );

      console.log(
        '✅ M-PESA PAYMENT COMPLETED'
      );

      console.log(
        '======================================'
      );

      console.log(
        'Giving ID:',
        giving._id
      );

      console.log(
        'Amount:',
        amount || giving.amount
      );

      console.log(
        'Receipt:',
        giving.mpesaReceipt
      );

      console.log(
        'Category:',
        giving.category
      );

      console.log(
        'Church:',
        giving.churchName
      );

      console.log(
        'Destination:',
        giving.destinationAccountName
      );

      console.log(
        'Phone:',
        phoneNumber ||
          giving.phoneNumber
      );

      console.log(
        '======================================'
      );
    }

    // ========================================================
    // FAILED
    // ========================================================

    else {
      giving.status =
        'failed';

      giving.mpesaResponseCode =
        String(
          stkCallback.ResultCode
        );

      giving.mpesaResultDescription =
        stkCallback.ResultDesc ||
        'M-Pesa payment failed';

      console.log(
        '======================================'
      );

      console.log(
        '❌ M-PESA PAYMENT FAILED'
      );

      console.log(
        '======================================'
      );

      console.log(
        'CheckoutRequestID:',
        checkoutRequestId
      );

      console.log(
        'ResultCode:',
        stkCallback.ResultCode
      );

      console.log(
        'ResultDesc:',
        stkCallback.ResultDesc
      );

      console.log(
        '======================================'
      );
    }

    // --------------------------------------------------------
    // Save transaction
    // --------------------------------------------------------

    await giving.save();

    // --------------------------------------------------------
    // Always acknowledge callback
    // --------------------------------------------------------

    return res.status(200).json({
      ResultCode: 0,

      ResultDesc: 'Success',
    });
  } catch (error) {
    console.error(
      '❌ M-Pesa callback error:',
      error
    );

    // Important:
    // Safaricom should receive 200
    // even if our internal processing
    // encounters an error.

    return res.status(200).json({
      ResultCode: 0,

      ResultDesc: 'Accepted',
    });
  }
};

// ============================================================
// CHECK M-PESA STATUS
// GET /api/v1/giving/mpesa/status/:checkoutRequestId
// ============================================================

exports.checkMpesaStatus = async (
  req,
  res
) => {
  try {
    const {
      checkoutRequestId,
    } = req.params;

    console.log('======================================');
    console.log('📱 CHECKING M-PESA STATUS');
    console.log('======================================');

    console.log(
      'CheckoutRequestID:',
      checkoutRequestId
    );

    // --------------------------------------------------------
    // Validate checkout request ID
    // --------------------------------------------------------

    if (!checkoutRequestId) {
      return res.status(400).json({
        success: false,

        message:
          'Checkout Request ID is required',
      });
    }

    // --------------------------------------------------------
    // Find giving transaction
    // --------------------------------------------------------

    const giving =
      await Giving.findOne({
        mpesaCheckoutId:
          checkoutRequestId,
      });

    if (!giving) {
      console.log(
        '❌ Transaction not found:',
        checkoutRequestId
      );

      return res.status(404).json({
        success: false,

        message:
          'Transaction not found',
      });
    }

    console.log(
      '✅ Giving found:',
      giving._id
    );

    console.log(
      'Current status:',
      giving.status
    );

    // --------------------------------------------------------
    // If callback already completed payment,
    // don't need to query Safaricom again.
    // --------------------------------------------------------

    if (
      String(
        giving.status
      ).toLowerCase() ===
      'completed'
    ) {
      console.log(
        '✅ Payment already completed'
      );

      return res.status(200).json({
        success: true,

        message:
          'Payment already completed',

        status: {
          ResultCode: '0',

          ResultDesc:
            'Payment completed successfully',
        },

        giving,
      });
    }

    // --------------------------------------------------------
    // Query Safaricom
    // --------------------------------------------------------

    const status =
      await mpesaService.queryStatus(
        checkoutRequestId
      );

    console.log(
      '📱 M-Pesa query response:',
      JSON.stringify(
        status,
        null,
        2
      )
    );

    // --------------------------------------------------------
    // Determine result code
    // --------------------------------------------------------

    let resultCode = null;

    if (
      status.ResultCode !==
      undefined
    ) {
      resultCode =
        String(
          status.ResultCode
        );
    } else if (
      status.ResponseCode !==
      undefined
    ) {
      resultCode =
        String(
          status.ResponseCode
        );
    }

    console.log(
      '📱 ResultCode:',
      resultCode
    );

    // ========================================================
    // SUCCESS
    // ========================================================

    if (resultCode === '0') {
      giving.status =
        'completed';

      giving.mpesaResponseCode =
        '0';

      giving.mpesaResultDescription =
        status.ResultDesc ||
        status.ResponseDescription ||
        'Payment completed successfully';

      giving.completedAt =
        giving.completedAt ||
        new Date();

      await giving.save();

      console.log(
        '======================================'
      );

      console.log(
        '✅ PAYMENT COMPLETED'
      );

      console.log(
        '======================================'
      );

      return res.status(200).json({
        success: true,

        message:
          'Payment completed successfully',

        status,

        giving,
      });
    }

    // ========================================================
    // FAILED
    // ========================================================

    if (
      resultCode !== null &&
      resultCode !== '0'
    ) {
      const description =
        status.ResultDesc ||
        status.ResponseDescription ||
        'M-Pesa payment was not completed';

      // ------------------------------------------------------
      // Important:
      //
      // Some Safaricom responses can represent
      // an intermediate/pending state.
      //
      // We only mark as failed when Safaricom
      // actually gives a failure result.
      // ------------------------------------------------------

      const failedCodes = [
        '1',
        '1032',
        '1037',
        '2001',
        '1001',
        '1019',
        '1025',
      ];

      if (
        failedCodes.includes(
          resultCode
        )
      ) {
        giving.status =
          'failed';

        giving.mpesaResponseCode =
          resultCode;

        giving.mpesaResultDescription =
          description;

        await giving.save();

        console.log(
          '======================================'
        );

        console.log(
          '❌ PAYMENT FAILED'
        );

        console.log(
          '======================================'
        );

        return res.status(200).json({
          success: true,

          message: description,

          status,

          giving,
        });
      }

      // ------------------------------------------------------
      // Unknown/non-final response:
      // keep transaction pending.
      // ------------------------------------------------------

      console.log(
        '⏳ Payment still pending'
      );

      return res.status(200).json({
        success: true,

        message:
          'Payment is still pending',

        status,

        giving,
      });
    }

    // ========================================================
    // PENDING
    // ========================================================

    console.log(
      '⏳ Payment still pending'
    );

    return res.status(200).json({
      success: true,

      message:
        'Payment is still pending',

      status,

      giving,
    });
  } catch (error) {
    console.error(
      '❌ Check M-Pesa status error:',
      error
    );

    return res.status(500).json({
      success: false,

      message:
        'Failed to check M-Pesa status',

      error: error.message,
    });
  }
};

// ============================================================
// GET ALL GIVING - ADMIN
// GET /api/v1/giving/all
// ============================================================

exports.getAllGiving = async (
  req,
  res
) => {
  try {
    const giving =
      await Giving.find({})
        .populate(
          'memberId',
          'firstName lastName phoneNumber'
        )
        .populate(
          'churchId',
          'name location'
        )
        .populate(
          'destinationAccountId',
          'category accountName bankName bankAccount bankCode'
        )
        .sort({
          createdAt: -1,
        });

    return res.status(200).json({
      success: true,

      count: giving.length,

      giving,
    });
  } catch (error) {
    console.error(
      '❌ Get all giving error:',
      error
    );

    return res.status(500).json({
      success: false,

      message:
        'Failed to get all giving',

      error: error.message,
    });
  }
};

// ============================================================
// GET TOTAL GIVING BY CHURCH
// GET /api/v1/giving/total-by-church
// ============================================================

exports.getTotalByChurch = async (
  req,
  res
) => {
  try {
    const totals =
      await Giving.aggregate([
        {
          $match: {
            status: 'completed',
          },
        },

        {
          $group: {
            _id: '$churchName',

            total: {
              $sum: '$amount',
            },

            count: {
              $sum: 1,
            },
          },
        },

        {
          $sort: {
            total: -1,
          },
        },
      ]);

    return res.status(200).json({
      success: true,

      totals,
    });
  } catch (error) {
    console.error(
      '❌ Total by church error:',
      error
    );

    return res.status(500).json({
      success: false,

      message:
        'Failed to get totals by church',

      error: error.message,
    });
  }
};

