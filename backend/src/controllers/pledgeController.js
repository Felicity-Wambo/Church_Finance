const Pledge = require('../models/pledge');
const Church = require('../models/church');

// @desc    Create or update pledge
// @route   POST /api/v1/pledge
exports.createPledge = async (req, res) => {
  try {
    const { amount, churchId, churchName } = req.body;
    const memberId = req.user.id;

    if (!amount || amount <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Invalid amount',
      });
    }

    const now = new Date();
    const month = now.getMonth() + 1;
    const year = now.getFullYear();

    // Check if pledge exists for this month
    let pledge = await Pledge.findOne({
      memberId,
      month,
      year,
    });

    if (pledge) {
      // Update existing pledge
      pledge.amount = amount;
      if (churchId) pledge.churchId = churchId;
      if (churchName) pledge.churchName = churchName;
      await pledge.save();
    } else {
      // Create new pledge
      pledge = await Pledge.create({
        memberId,
        churchId: churchId || req.user.churchId,
        churchName: churchName || 'Main Church',
        amount,
        month,
        year,
      });
    }

    res.status(201).json({
      success: true,
      message: 'Pledge created successfully',
      pledge,
    });
  } catch (error) {
    console.error('Create pledge error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create pledge',
      error: error.message,
    });
  }
};

// @desc    Get current pledge
// @route   GET /api/v1/pledge
exports.getPledge = async (req, res) => {
  try {
    const now = new Date();
    const month = now.getMonth() + 1;
    const year = now.getFullYear();

    const pledge = await Pledge.findOne({
      memberId: req.user.id,
      month,
      year,
    }).populate('churchId');

    res.status(200).json({
      success: true,
      pledge: pledge || null,
    });
  } catch (error) {
    console.error('Get pledge error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get pledge',
      error: error.message,
    });
  }
};

// @desc    Get pledge history
// @route   GET /api/v1/pledge/history
exports.getPledgeHistory = async (req, res) => {
  try {
    const pledges = await Pledge.find({ memberId: req.user.id })
      .sort({ year: -1, month: -1 });

    res.status(200).json({
      success: true,
      pledges,
    });
  } catch (error) {
    console.error('Pledge history error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get pledge history',
      error: error.message,
    });
  }
};