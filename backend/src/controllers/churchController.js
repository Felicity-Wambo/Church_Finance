const Church = require('../models/church');
const GivingAccount = require('../models/givingAccount');

// ============================================
// GET ALL ACTIVE CHURCHES
// GET /api/v1/churches
// ============================================
exports.getChurches = async (req, res) => {
  try {
    const churches = await Church.find({
      isActive: true,
    }).sort({ name: 1 });

    res.status(200).json({
      success: true,
      count: churches.length,
      churches,
    });
  } catch (error) {
    console.error('❌ Get churches error:', error);

    res.status(500).json({
      success: false,
      message: 'Failed to get churches',
      error: error.message,
    });
  }
};


// ============================================
// CREATE CHURCH
// POST /api/v1/churches
// ADMIN ONLY
// ============================================
exports.createChurch = async (req, res) => {
  try {
    const {
      name,
      location,
    } = req.body;

    // Validate
    if (!name) {
      return res.status(400).json({
        success: false,
        message: 'Church name is required',
      });
    }

    // Check duplicate
    const existingChurch = await Church.findOne({
      name: name.trim(),
    });

    if (existingChurch) {
      return res.status(409).json({
        success: false,
        message: 'A church with this name already exists',
      });
    }

    // Create church
    const church = await Church.create({
      name: name.trim(),
      location: location?.trim() || 'Not specified',
      isActive: true,
    });

    res.status(201).json({
      success: true,
      message: 'Church created successfully',
      church,
    });
  } catch (error) {
    console.error('❌ Create church error:', error);

    res.status(500).json({
      success: false,
      message: 'Failed to create church',
      error: error.message,
    });
  }
};


// ============================================
// UPDATE CHURCH
// PUT /api/v1/churches/:id
// ADMIN ONLY
// ============================================
exports.updateChurch = async (req, res) => {
  try {
    const { id } = req.params;

    const {
      name,
      location,
      isActive,
    } = req.body;

    const updateData = {};

    if (name !== undefined) {
      updateData.name = name.trim();
    }

    if (location !== undefined) {
      updateData.location = location.trim();
    }

    if (isActive !== undefined) {
      updateData.isActive = isActive;
    }

    const church = await Church.findByIdAndUpdate(
      id,
      updateData,
      {
        new: true,
        runValidators: true,
      }
    );

    if (!church) {
      return res.status(404).json({
        success: false,
        message: 'Church not found',
      });
    }

    res.status(200).json({
      success: true,
      message: 'Church updated successfully',
      church,
    });
  } catch (error) {
    console.error('❌ Update church error:', error);

    res.status(500).json({
      success: false,
      message: 'Failed to update church',
      error: error.message,
    });
  }
};


// ============================================
// GET GIVING ACCOUNTS FOR A CHURCH
// GET /api/v1/churches/:id/accounts
// ============================================
exports.getChurchAccounts = async (req, res) => {
  try {
    const { id } = req.params;

    // Make sure church exists
    const church = await Church.findById(id);

    if (!church) {
      return res.status(404).json({
        success: false,
        message: 'Church not found',
      });
    }

    const accounts = await GivingAccount.find({
      churchId: id,
      isActive: true,
    }).sort({ category: 1 });

    res.status(200).json({
      success: true,
      church: {
        id: church._id,
        name: church.name,
        location: church.location,
      },
      count: accounts.length,
      accounts,
    });
  } catch (error) {
    console.error('❌ Get church accounts error:', error);

    res.status(500).json({
      success: false,
      message: 'Failed to get church accounts',
      error: error.message,
    });
  }
};


// ============================================
// CREATE GIVING ACCOUNT
// POST /api/v1/churches/:id/accounts
// ADMIN ONLY
// ============================================
exports.createGivingAccount = async (req, res) => {
  try {
    const { id } = req.params;

    const {
      category,
      accountName,
      bankName,
      bankAccount,
      bankCode,
    } = req.body;

    // Validate
    if (
      !category ||
      !accountName ||
      !bankName ||
      !bankAccount
    ) {
      return res.status(400).json({
        success: false,
        message:
          'Category, account name, bank name, and bank account are required',
      });
    }

    // Check church
    const church = await Church.findById(id);

    if (!church) {
      return res.status(404).json({
        success: false,
        message: 'Church not found',
      });
    }

    // Check duplicate category
    const existingAccount = await GivingAccount.findOne({
      churchId: id,
      category: category.trim(),
    });

    if (existingAccount) {
      return res.status(409).json({
        success: false,
        message:
          `A ${category} account already exists for this church`,
      });
    }

    // Create account
    const account = await GivingAccount.create({
      churchId: id,
      category: category.trim(),
      accountName: accountName.trim(),
      bankName: bankName.trim(),
      bankAccount: bankAccount.trim(),
      bankCode: bankCode?.trim() || '000',
      isActive: true,
    });

    res.status(201).json({
      success: true,
      message: 'Giving account created successfully',
      account,
    });
  } catch (error) {
    console.error('❌ Create giving account error:', error);

    res.status(500).json({
      success: false,
      message: 'Failed to create giving account',
      error: error.message,
    });
  }
};


// ============================================
// UPDATE GIVING ACCOUNT
// PUT /api/v1/churches/:churchId/accounts/:accountId
// ADMIN ONLY
// ============================================
exports.updateGivingAccount = async (req, res) => {
  try {
    const {
      id: churchId,
      accountId,
    } = req.params;

    const {
      category,
      accountName,
      bankName,
      bankAccount,
      bankCode,
      isActive,
    } = req.body;

    const updateData = {};

    if (category !== undefined) {
      updateData.category = category.trim();
    }

    if (accountName !== undefined) {
      updateData.accountName = accountName.trim();
    }

    if (bankName !== undefined) {
      updateData.bankName = bankName.trim();
    }

    if (bankAccount !== undefined) {
      updateData.bankAccount = bankAccount.trim();
    }

    if (bankCode !== undefined) {
      updateData.bankCode = bankCode.trim();
    }

    if (isActive !== undefined) {
      updateData.isActive = isActive;
    }

    const account = await GivingAccount.findOneAndUpdate(
      {
        _id: accountId,
        churchId,
      },
      updateData,
      {
        new: true,
        runValidators: true,
      }
    );

    if (!account) {
      return res.status(404).json({
        success: false,
        message: 'Giving account not found',
      });
    }

    res.status(200).json({
      success: true,
      message: 'Giving account updated successfully',
      account,
    });
  } catch (error) {
    console.error('❌ Update giving account error:', error);

    res.status(500).json({
      success: false,
      message: 'Failed to update giving account',
      error: error.message,
    });
  }
};