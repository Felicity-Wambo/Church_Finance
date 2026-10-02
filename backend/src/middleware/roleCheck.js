exports.checkRole = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'Unauthorized',
      });
    }
    
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: `Insufficient permissions. Required role: ${roles.join(', ')}`,
      });
    }
    
    next();
  };
};

exports.ROLES = {
  ADMIN: 'admin',
  TREASURER: 'treasurer',
  DEPT_HEAD: 'dept_head',
  MEMBER: 'member',
};

exports.isAdmin = exports.checkRole('admin');
exports.isTreasurer = exports.checkRole('admin', 'treasurer');
exports.isDepartmentHead = exports.checkRole('admin', 'treasurer', 'dept_head');