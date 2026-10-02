const User = require('../models/User');
const Church = require('../models/church');

const generateTokens = (user) => {
  const token = user.generateToken();
  const refreshToken = user.generateRefreshToken();
  return { token, refreshToken };
};

exports.register = async (req, res) => {
  try {
    const {
      phoneNumber,
      pin,
      confirmPin,
      firstName,
      lastName,
      email,
      role,
      churchId,
    } = req.body;

    if (!phoneNumber || !pin || !firstName || !lastName) {
      return res.status(400).json({
        success: false,
        message: 'Please provide all required fields',
      });
    }

    if (pin !== confirmPin) {
      return res.status(400).json({
        success: false,
        message: 'PINs do not match',
      });
    }

    if (pin.length !== 4) {
      return res.status(400).json({
        success: false,
        message: 'PIN must be exactly 4 digits',
      });
    }

    const existingUser = await User.findOne({ phoneNumber });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'User with this phone number already exists',
      });
    }

    const user = await User.create({
      phoneNumber,
      pin,
      firstName,
      lastName,
      email,
      role: role || 'member',
      churchId: churchId || null,
    });

    const userData = user.toObject();
    delete userData.pin;
    delete userData.refreshToken;

    res.status(201).json({
      success: true,
      message: 'User registered successfully. Please login.',
      user: userData,
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({
      success: false,
      message: 'Registration failed',
      error: error.message,
    });
  }
};

exports.login = async (req, res) => {
  try {
    const { phoneNumber, pin } = req.body;

    if (!phoneNumber || !pin) {
      return res.status(400).json({
        success: false,
        message: 'Phone number and PIN are required',
      });
    }

    const user = await User.findOne({ phoneNumber });
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials',
      });
    }

    if (!user.isActive) {
      return res.status(403).json({
        success: false,
        message: 'Account is deactivated. Contact church admin.',
      });
    }

    const isPinValid = await user.comparePin(pin);
    if (!isPinValid) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials',
      });
    }

    user.lastLogin = new Date();
    await user.save();

    const { token, refreshToken } = generateTokens(user);
    user.refreshToken = refreshToken;
    await user.save();

    const userData = user.toObject();
    delete userData.pin;
    delete userData.refreshToken;

    res.status(200).json({
      success: true,
      token,
      refreshToken,
      user: userData,
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Login failed',
      error: error.message,
    });
  }
};

exports.getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-pin -refreshToken');
    res.status(200).json({
      success: true,
      user,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to get user',
    });
  }
};

exports.logout = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (user) {
      user.refreshToken = null;
      await user.save();
    }
    res.status(200).json({
      success: true,
      message: 'Logged out successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Logout failed',
    });
  }
};

exports.getUsers = async (req, res) => {
  try {
    const users = await User.find().select('-pin -refreshToken');
    res.status(200).json({
      success: true,
      count: users.length,
      users,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to get users',
    });
  }
};