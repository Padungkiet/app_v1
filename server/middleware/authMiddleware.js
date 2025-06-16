/****************************************************************
*  ตรวจสอบ JWT  (ต้องแนบ  Authorization: Bearer <token>)
****************************************************************/

const jwt = require('jsonwebtoken'); // 🔹 นำเข้าไลบรารี JSON Web Token (JWT) เพื่อใช้จัดการ token

// 🔹 ฟังก์ชันตรวจสอบ JWT
exports.verifyToken = (req, res, next) => {
  const authHeader = req.headers['authorization']; // 🔹 ดึงค่าจาก request header ที่ชื่อ 'authorization'

  // 🔹 ถ้าไม่มี header หรือไม่ได้ส่ง token มาให้
  if (!authHeader) {
    return res.status(401).json({ error: 'No token provided' }); // 🔹 ส่ง error 401 (Unauthorized)
  }

  const token = authHeader.split(' ')[1]; // 🔹 ตัดคำว่า "Bearer " ออกจาก header เพื่อให้เหลือแค่ token

  // 🔹 ถ้าไม่มี token หรือรูปแบบ token ไม่ถูกต้อง
  if (!token) {
    return res.status(401).json({ error: 'Invalid token format' }); // 🔹 ส่ง error 401 (Unauthorized)
  }

  // 🔹 ตรวจสอบความถูกต้องของ token โดยใช้ JWT_SECRET
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid token' }); // 🔹 ถ้า token ไม่ถูกต้อง ส่ง error 403 (Forbidden)
    }
    
    req.user = user; // 🔹 ฝากข้อมูลผู้ใช้ไว้ใน req.user เพื่อให้ใช้ต่อใน route ถัดไป
    next(); // 🔹 เรียก next() เพื่อให้ middleware ถัดไปทำงานต่อ
  });
};
