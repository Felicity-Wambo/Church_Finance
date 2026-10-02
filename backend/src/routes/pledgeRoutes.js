const express = require('express');
const router = express.Router();
const pledgeController = require('../controllers/pledgeController');
const auth = require('../middleware/auth');

router.post('/', auth, pledgeController.createPledge);
router.get('/', auth, pledgeController.getPledge);
router.get('/history', auth, pledgeController.getPledgeHistory);

module.exports = router;