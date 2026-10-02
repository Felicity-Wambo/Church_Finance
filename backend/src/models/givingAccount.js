const mongoose = require('mongoose');

const givingAccountSchema = new mongoose.Schema(
  {
    churchId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Church',
      required: true,
      index: true,
    },

    category: {
      type: String,
      required: true,
      trim: true,
    },

    accountName: {
      type: String,
      required: true,
      trim: true,
    },

    bankName: {
      type: String,
      required: true,
      trim: true,
    },

    bankAccount: {
      type: String,
      required: true,
      trim: true,
    },

    bankCode: {
      type: String,
      required: true,
      trim: true,
    },

    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

// Prevent duplicate active accounts for the same church/category
givingAccountSchema.index(
  { churchId: 1, category: 1 },
  { unique: true }
);

module.exports = mongoose.model('GivingAccount', givingAccountSchema);