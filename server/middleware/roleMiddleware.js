/****************************************************************
*  จำกัดสิทธิ์เฉพาะ Admin  (ยืดหยุ่นแก้ไขได้)
****************************************************************/
exports.onlyAdmin = (req, res, next) => {
  if (req.user.role !== 'admin') { // ถ้าไม่ใช่ admin
    return res.status(403).json({ error: 'Admin only!' }); // ไม่ให้ผ่าน
  }
  next(); // ผ่านได้
}