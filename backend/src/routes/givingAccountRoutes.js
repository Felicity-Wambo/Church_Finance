const express = require('express');

const router = express.Router();

const controller =
  require('../controllers/givingAccountController');

const auth =
  require('../middleware/auth');


// Create giving account
router.post(
  '/',
  auth,
  controller.createAccount
);


// Get church accounts
router.get(
  '/church/:churchId',
  auth,
  controller.getChurchAccounts
);


// Update account
router.put(
  '/:id',
  auth,
  controller.updateAccount
);


// Deactivate account
router.delete(
  '/:id',
  auth,
  controller.deleteAccount
);


module.exports = router;