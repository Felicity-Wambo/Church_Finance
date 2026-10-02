const Giving = require('../models/giving');
const Church = require('../models/church');
const User = require('../models/User');

// @desc    Get dashboard summary
// @route   GET /api/v1/dashboard/summary
exports.getSummary = async (req, res) => {
  try {
    const userId = req.user.id;

    // ✅ FIX: Use Giving.aggregate correctly
    const totalGiving = await Giving.aggregate([
      { $match: { memberId: userId, status: 'completed' } },
      { $group: { _id: null, total: { $sum: '$amount' } } },
    ]);

    const now = new Date();
    const monthlyTithes = await Giving.aggregate([
      {
        $match: {
          memberId: userId,
          status: 'completed',
          category: 'Tithe',
          createdAt: {
            $gte: new Date(now.getFullYear(), now.getMonth(), 1),
            $lt: new Date(now.getFullYear(), now.getMonth() + 1, 1),
          },
        },
      },
      { $group: { _id: null, total: { $sum: '$amount' } } },
    ]);

    const weeklyOfferings = await Giving.aggregate([
      {
        $match: {
          memberId: userId,
          status: 'completed',
          category: 'Offering',
          createdAt: {
            $gte: new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000),
          },
        },
      },
      { $group: { _id: null, total: { $sum: '$amount' } } },
    ]);

    const totalGivers = await Giving.distinct('memberId', {
      status: 'completed',
    });

    res.status(200).json({
      totalGiving: totalGiving[0]?.total || 0,
      monthlyTithes: monthlyTithes[0]?.total || 0,
      weeklyOfferings: weeklyOfferings[0]?.total || 0,
      totalGivers: totalGivers.length,
      balance: 250000,
    });
  } catch (error) {
    console.error('❌ Dashboard summary error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get dashboard summary',
      error: error.message,
    });
  }
};

// @desc    Get chart data
// @route   GET /api/v1/dashboard/chart
exports.getChart = async (req, res) => {
  try {
    const now = new Date();
    const chartData = [];

    for (let i = 6; i >= 0; i--) {
      const date = new Date(now.getTime() - i * 24 * 60 * 60 * 1000);
      const nextDate = new Date(date.getTime() + 24 * 60 * 60 * 1000);

      const daily = await Giving.aggregate([
        {
          $match: {
            memberId: req.user.id,
            status: 'completed',
            createdAt: { $gte: date, $lt: nextDate },
          },
        },
        { $group: { _id: null, total: { $sum: '$amount' } } },
      ]);

      chartData.push({
        x: i,
        y: daily[0]?.total || 0,
      });
    }

    res.status(200).json({ chartData });
  } catch (error) {
    console.error('❌ Chart error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get chart data',
      error: error.message,
    });
  }
};

// @desc    Get recent transactions
// @route   GET /api/v1/dashboard/recent
exports.getRecent = async (req, res) => {
  try {
    // ✅ FIX: Use Giving.find correctly
    const transactions = await Giving.find({ memberId: req.user.id })
      .sort({ createdAt: -1 })
      .limit(5);

    const formattedTransactions = transactions.map(t => ({
      id: t._id,
      type: 'income',
      category: t.category,
      amount: t.amount,
      date: t.createdAt,
      memberName: t.memberName || 'Anonymous',
      status: t.status,
      description: `${t.category} - ${t.churchName}`,
      createdAt: t.createdAt,
      updatedAt: t.updatedAt,
    }));

    res.status(200).json({ transactions: formattedTransactions });
  } catch (error) {
    console.error('❌ Recent transactions error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get recent transactions',
      error: error.message,
    });
  }
};