const GivingAccount =
  require('../models/givingAccount');

const Church =
  require('../models/church');


// ============================================================
// CREATE ACCOUNT
// ============================================================

exports.createAccount = async (req, res) => {
  try {
    const {
      churchId,
      category,
      bankName,
      bankAccount,
      bankCode,
      accountName,
    } = req.body;

    if (
      !churchId ||
      !category ||
      !bankName ||
      !bankAccount
    ) {
      return res.status(400).json({
        success: false,
        message:
          'churchId, category, bankName and bankAccount are required',
      });
    }

    const church =
      await Church.findById(churchId);

    if (!church) {
      return res.status(404).json({
        success: false,
        message: 'Church not found',
      });
    }

    const existing =
      await GivingAccount.findOne({
        churchId,
        category,
      });

    if (existing) {
      return res.status(409).json({
        success: false,
        message:
          `A ${category} account already exists for this church`,
      });
    }

    const account =
      await GivingAccount.create({
        churchId,
        category,
        bankName,
        bankAccount,
        bankCode,
        accountName,
      });

    return res.status(201).json({
      success: true,
      message:
        'Giving account created successfully',
      account,
    });
  } catch (error) {
    console.error(
      '❌ Create giving account error:',
      error
    );

    return res.status(500).json({
      success: false,
      message:
        'Failed to create giving account',
      error: error.message,
    });
  }
};


// ============================================================
// GET CHURCH ACCOUNTS
// ============================================================

exports.getChurchAccounts = async (
  req,
  res
) => {
  try {
    const {
      churchId,
    } = req.params;

    const accounts =
      await GivingAccount.find({
        churchId,
        isActive: true,
      }).sort({
        category: 1,
      });

    return res.status(200).json({
      success: true,
      accounts,
    });
  } catch (error) {
    console.error(
      '❌ Get giving accounts error:',
      error
    );

    return res.status(500).json({
      success: false,
      message:
        'Failed to get giving accounts',
      error: error.message,
    });
  }
};


// ============================================================
// UPDATE ACCOUNT
// ============================================================

exports.updateAccount = async (
  req,
  res
) => {
  try {
    const {
      id,
    } = req.params;

    const account =
      await GivingAccount.findByIdAndUpdate(
        id,
        req.body,
        {
          new: true,
          runValidators: true,
        }
      );

    if (!account) {
      return res.status(404).json({
        success: false,
        message:
          'Giving account not found',
      });
    }

    return res.status(200).json({
      success: true,
      message:
        'Giving account updated successfully',
      account,
    });
  } catch (error) {
    console.error(
      '❌ Update giving account error:',
      error
    );

    return res.status(500).json({
      success: false,
      message:
        'Failed to update giving account',
      error: error.message,
    });
  }
};


// ============================================================
// DEACTIVATE ACCOUNT
// ============================================================

exports.deleteAccount = async (
  req,
  res
) => {
  try {
    const {
      id,
    } = req.params;

    const account =
      await GivingAccount.findByIdAndUpdate(
        id,
        {
          isActive: false,
        },
        {
          new: true,
        }
      );

    if (!account) {
      return res.status(404).json({
        success: false,
        message:
          'Giving account not found',
      });
    }

    return res.status(200).json({
      success: true,
      message:
        'Giving account deactivated',
      account,
    });
  } catch (error) {
    console.error(
      '❌ Delete giving account error:',
      error
    );

    return res.status(500).json({
      success: false,
      message:
        'Failed to deactivate giving account',
      error: error.message,
    });
  }
};