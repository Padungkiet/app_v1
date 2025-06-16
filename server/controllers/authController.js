const db = require('../config/db'); // เรียกใช้ฐานข้อมูล
const bcrypt = require('bcryptjs'); // ใช้สำหรับ hash รหัสผ่าน
const jwt = require('jsonwebtoken'); // ใช้สร้างและตรวจสอบ token
require('dotenv').config(); // โหลดตัวแปรแวดล้อมจากไฟล์ .env

/****************************************************************
*  authController.js — ระบบล็อกอิน & จัดการผู้ใช้
****************************************************************/

/* ---------- POST /users/register (สมัครสมาชิก) ---------- */
exports.register = async (req, res) => {
  const { first_name, last_name, age, gender, username, password } = req.body; // รับข้อมูลจาก request

  // 🔹 ตรวจสอบว่าผู้ใช้กรอกข้อมูลครบทุกช่องหรือไม่
  if (!first_name || !last_name || !age || !gender || !username || !password) {
    return res.status(400).json({ error: '❌ ต้องกรอกข้อมูลให้ครบ' }); // ส่ง error ถ้ากรอกไม่ครบ
  }

  const salt = await bcrypt.genSalt(10); // สร้าง salt เพื่อใช้ hash รหัสผ่าน
  const hashedPassword = await bcrypt.hash(password, salt); // แปลงรหัสผ่านให้ปลอดภัยขึ้น

  try {
    // 🔹 เพิ่มข้อมูลผู้ใช้ลงฐานข้อมูล
    const [rs] = await db.query(
      'INSERT INTO users (first_name, last_name, age, gender, username, password_hash) VALUES (?,?,?,?,?,?)',
      [first_name, last_name, age, gender, username, hashedPassword]
    );

    res.status(201).json({ id: rs.insertId, first_name, last_name, username }); // ส่งข้อมูลกลับถ้าสำเร็จ
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') { // ตรวจสอบว่า username ซ้ำหรือไม่
      return res.status(409).json({ error: '❌ Username นี้ถูกใช้แล้ว' }); // แจ้ง error ว่า username ซ้ำ
    }
    console.error("REGISTER ERR →", err); // log error
    res.status(500).json({ error: 'DB Error' }); // แจ้งข้อผิดพลาดของระบบ
  }
};

/* ---------- POST /users/login (เข้าสู่ระบบ) ---------- */
exports.login = async (req, res) => {
  const { username, password } = req.body; // รับข้อมูล username และ password

  // 🔹 ดึงข้อมูลผู้ใช้จากฐานข้อมูลตาม username
  const [rows] = await db.query('SELECT * FROM users WHERE username = ?', [username]); 
  console.log('DEBUG ▸ rows =', rows); // log ข้อมูลผู้ใช้

  // 🔹 ตรวจสอบว่าพบข้อมูลผู้ใช้หรือไม่ และตรวจสอบรหัสผ่าน
  if (!rows.length || !(await bcrypt.compare(password, rows[0].password_hash))) {
    return res.status(401).json({ error: '❌ Invalid username or password' }); // แจ้ง error ถ้า login ไม่ผ่าน
  }

  const userData = { id: rows[0].id, username: rows[0].username, role: rows[0].role }; // เก็บข้อมูลผู้ใช้สำหรับ token
  const accessToken = jwt.sign(userData, process.env.JWT_SECRET, { expiresIn: '2h' }); // สร้าง accessToken
  const refreshToken = jwt.sign({ id: rows[0].id }, process.env.REFRESH_SECRET, { expiresIn: '7d' }); // สร้าง refreshToken

  // 🔹 ตั้งค่า refreshToken ใน cookie
  res.cookie('refreshToken', refreshToken, {
    httpOnly: true, // ป้องกันการเข้าถึง cookie จาก JavaScript
    secure: process.env.NODE_ENV === 'production', // ใช้ https ใน production
    sameSite: 'Strict', // ป้องกัน Cross-Site Request Forgery (CSRF)
    maxAge: 7 * 24 * 60 * 60 * 1000, // อายุของ token คือ 7 วัน
  });

  res.json({ accessToken }); // ส่ง accessToken กลับไป
};

/* ---------- POST /refresh-token (ออก Access Token ใหม่) ---------- */
exports.refreshToken = async (req, res) => {
  console.log("🔍 Cookies received:", req.cookies); // log cookie ที่ได้รับ
  const refreshToken = req.cookies.refreshToken; // ดึงค่า refreshToken จาก cookie
  console.log("🔹 Extracted refreshToken:", refreshToken); // log token ที่ดึงออกมา

  // 🔹 ตรวจสอบว่ามี refreshToken หรือไม่
  if (!refreshToken) {
    return res.status(401).json({ error: '❌ No refreshToken provided' }); // ส่ง error ถ้าไม่มี token
  }

  try {
    const decoded = jwt.verify(refreshToken, process.env.REFRESH_SECRET); // ตรวจสอบและถอดรหัส refreshToken
    console.log("🔹 Decoded Token:", decoded); // log ข้อมูลที่ถอดรหัสแล้ว
    
    const accessToken = jwt.sign({ id: decoded.id }, process.env.JWT_SECRET, { expiresIn: '2h' }); // สร้าง accessToken ใหม่
    res.json({ accessToken }); // ส่ง token ใหม่กลับไป
  } catch (err) {
    console.error("❌ JWT Error:", err); // log ข้อผิดพลาด
    res.status(403).json({ error: '❌ Invalid refreshToken' }); // แจ้งว่า token ไม่ถูกต้อง
  }
};

/* ---------- POST /logout (ออกจากระบบ) ---------- */
exports.logout = async (req, res) => {
  res.clearCookie('refreshToken'); // ลบ cookie refreshToken ออกจากระบบ
  res.json({ message: 'Logged out' }); // แจ้งว่าผู้ใช้ออกจากระบบแล้ว
};
