const express = require('express');

const router = express.Router();

const churchController = require('../controllers/churchController');

const auth = require('../middleware/auth');
const { isAdmin } = require('../middleware/roleCheck');


// ============================================
// CHURCHES
// ============================================

// Get all active churches
router.get(
  '/',
  auth,
  churchController.getChurches
);

// Create church
router.post(
  '/',
  auth,
  isAdmin,
  churchController.createChurch
);

// Update church
router.put(
  '/:id',
  auth,
  isAdmin,
  churchController.updateChurch
);


// ============================================
// GIVING ACCOUNTS
// ============================================

// Get accounts for a church
router.get(
  '/:id/accounts',
  auth,
  churchController.getChurchAccounts
);

// Create giving account
router.post(
  '/:id/accounts',
  auth,
  isAdmin,
  churchController.createGivingAccount
);

// Update giving account
router.put(
  '/:id/accounts/:accountId',
  auth,
  isAdmin,
  churchController.updateGivingAccount
);


module.exports = router;