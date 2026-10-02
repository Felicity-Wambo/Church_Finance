const mongoose = require('mongoose');

const givingSchema = new mongoose.Schema(
  {
    amount: {
      type: Number,
      required: true,
      min: 1,
    },

    category: {
      type: String,
      required: true,
      trim: true,
      index: true,
    },

    memberId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },

    memberName: {
      type: String,
      required: true,
      trim: true,
    },

    phoneNumber: {
      type: String,
      required: true,
      trim: true,
    },

    churchId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Church',
      required: true,
      index: true,
    },

    churchName: {
      type: String,
      required: true,
      trim: true,
    },

    // Account selected based on giving category
    destinationAccountId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'GivingAccount',
      required: true,
    },

    destinationBank: {
      type: String,
      required: true,
      trim: true,
    },

    destinationBankAccount: {
      type: String,
      required: true,
      trim: true,
    },

    destinationAccountName: {
      type: String,
      required: true,
      trim: true,
    },

    status: {
      type: String,
      enum: ['pending', 'completed', 'failed'],
      default: 'pending',
      index: true,
    },

    mpesaReceipt: {
      type: String,
      default: null,
    },

    mpesaCheckoutId: {
      type: String,
      default: null,
      index: true,
    },

    mpesaMerchantRequestId: {
      type: String,
      default: null,
    },

    mpesaResponseCode: {
      type: String,
      default: null,
    },

    mpesaResultDescription: {
      type: String,
      default: null,
    },

    transactionDate: {
      type: Date,
      default: null,
    },

    isRecurring: {
      type: Boolean,
      default: false,
    },

    completedAt: {
      type: Date,
      default: null,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Giving', givingSchema);