const express = require('express');

const router = express.Router();

const givingController = require('../controllers/givingController');

const auth = require('../middleware/auth');

const { isAdmin } = require('../middleware/roleCheck');

// ============================================================
// MEMBER ROUTES
// ============================================================

router.post(
  '/process',
  auth,
  givingController.processGiving
);

router.get(
  '/history',
  auth,
  givingController.getHistory
);

router.get(
  '/summary',
  auth,
  givingController.getSummary
);

router.get(
  '/recent',
  auth,
  givingController.getRecent
);

router.get(
  '/stats',
  auth,
  givingController.getStats
);

router.get(
  '/by-church/:churchId',
  auth,
  givingController.getByChurch
);

// ============================================================
// M-PESA
// ============================================================

// Safaricom callback
router.post(
  '/mpesa/callback',
  givingController.mpesaCallback
);

// Check STK Push status
router.get(
  '/mpesa/status/:checkoutRequestId',
  auth,
  givingController.checkMpesaStatus
);

// ============================================================
// ADMIN
// ============================================================

router.get(
  '/all',
  auth,
  isAdmin,
  givingController.getAllGiving
);

router.get(
  '/total-by-church',
  auth,
  isAdmin,
  givingController.getTotalByChurch
);

module.exports = router;
