const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const auth = require('../middleware/auth');
const { isAdmin } = require('../middleware/roleCheck');

router.post('/register', authController.register);
router.post('/login', authController.login);
router.get('/me', auth, authController.getMe);
router.post('/logout', auth, authController.logout);
router.get('/users', auth, isAdmin, authController.getUsers);

module.exports = router;