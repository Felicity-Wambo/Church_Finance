const express = require('express');
const router = express.Router();
const dashboardController = require('../controllers/dashboardController');
const auth = require('../middleware/auth');

router.get('/summary', auth, dashboardController.getSummary);
router.get('/chart', auth, dashboardController.getChart);
router.get('/recent', auth, dashboardController.getRecent);

module.exports = router;