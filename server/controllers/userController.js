const db = require('../config/db'); // นำเข้าไฟล์ตั้งค่าฐานข้อมูล
const bcrypt = require('bcrypt'); // ใช้สำหรับแฮชรหัสผ่าน
const jwt = require('jsonwebtoken'); // ใช้สร้างและตรวจสอบ token สำหรับการยืนยันตัวตน

// 🔹 สมัครสมาชิก
exports.register = async (req, res) => {
  try {
    // รับข้อมูลจาก request body ที่ส่งมา
    const { username, password, first_name, last_name, age, gender, email, phone } = req.body;

    // 🔹 ตรวจสอบว่าผู้ใช้กรอกข้อมูลครบหรือไม่
    if (!username || !first_name || !last_name || !email || !phone || !age || !gender || !password) {
      return res.status(400).json({ error: "❌ ต้องกรอกข้อมูลให้ครบ" }); // ถ้าข้อมูลไม่ครบ ให้ส่ง error
    }

    // 🔹 ตรวจสอบว่า username มีอยู่แล้วหรือไม่
    const [users] = await db.query('SELECT id FROM users WHERE username = ?', [username]);
    if (users.length > 0) {
      return res.status(409).json({ error: "❌ Username นี้ถูกใช้แล้ว" }); // ถ้าซ้ำ ให้ส่ง error
    }

    // 🔹 แฮชรหัสผ่านก่อนบันทึกลงฐานข้อมูล
    const hashedPassword = await bcrypt.hash(password, 10);
    await db.query(
      'INSERT INTO users (username, password_hash, first_name, last_name, age, gender, email, phone, role) VALUES (?,?,?,?,?,?,?,?,?)',
      [username, hashedPassword, first_name, last_name, age, gender, email, phone, 'user']
    );

    res.json({ message: "✅ สมัครสมาชิกสำเร็จ" }); // ส่งข้อความแจ้งเตือนว่า สมัครสมาชิกเรียบร้อย
  } catch (err) {
    console.error('REGISTER ERROR:', err); // Log ข้อผิดพลาด
    res.status(500).json({ error: "❌ เกิดข้อผิดพลาดในระบบ" }); // ส่งข้อความ error
  }
};

// 🔑 ล็อกอิน
exports.login = async (req, res) => {
  // รับข้อมูลจาก request body
  const { phone, password } = req.body;

  // 🔹 ค้นหาผู้ใช้จากเบอร์โทร
  const [rows] = await db.query('SELECT * FROM users WHERE phone = ?', [phone]);
  if (rows.length === 0) {
    return res.status(400).json({ error: 'ไม่พบผู้ใช้' }); // ถ้าไม่มีผู้ใช้ที่ตรงกับเบอร์โทร ให้ส่ง error
  }

  const user = rows[0]; // ดึงข้อมูลของผู้ใช้
  const match = await bcrypt.compare(password, user.password_hash); // ตรวจสอบรหัสผ่าน

  if (!match) {
    return res.status(400).json({ error: 'รหัสผ่านไม่ถูกต้อง' }); // ถ้ารหัสผ่านไม่ตรงกับฐานข้อมูล ส่ง error
  }

  // 🔹 สร้าง JWT token สำหรับใช้ในการเข้าถึงระบบ
  const payload = { id: user.id, username: user.username, role: user.role };
  const accessToken = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '2h' });

  res.json({ accessToken, user }); // ส่ง token และข้อมูลผู้ใช้กลับไปให้ client
};

// 🔍 ดึงข้อมูลผู้ใช้ที่ล็อกอินอยู่
exports.getProfile = async (req, res) => {
  res.json(req.user); // ส่งข้อมูลของผู้ใช้ที่ล็อกอินอยู่
};

// 🔄 อัปเดตข้อมูลผู้ใช้
exports.updateProfile = async (req, res) => {
  try {
    // รับข้อมูลที่ผู้ใช้ต้องการอัปเดต
    const { first_name, last_name, password } = req.body;
    const userId = req.user.id; // ดึง ID ของผู้ใช้ที่ล็อกอินอยู่

    // 🛑 ป้องกันไม่ให้แก้ไข username และ role
    if (req.body.username || req.body.role) {
      return res.status(403).json({ error: "❌ ไม่อนุญาตให้แก้ไขข้อมูลนี้" });
    }

    // 🔹 ถ้ามีรหัสผ่านใหม่ ให้แฮชก่อนอัปเดต
    let hashedPassword;
    if (password) {
      hashedPassword = await bcrypt.hash(password, 10);
    }

    // 🔹 อัปเดตข้อมูลผู้ใช้
    await db.query(
      `UPDATE users SET 
        first_name = COALESCE(?, first_name), 
        last_name = COALESCE(?, last_name), 
        password_hash = COALESCE(?, password_hash) 
      WHERE id = ?`,
      [first_name, last_name, hashedPassword, userId]
    );

    res.json({ message: "✅ อัปเดตข้อมูลสำเร็จ" }); // ส่งข้อความแจ้งเตือนว่าอัปเดตข้อมูลสำเร็จ
  } catch (err) {
    res.status(500).json({ error: "❌ เกิดข้อผิดพลาดในระบบ" }); // ส่งข้อความ error
  }
};

// 🚪 ล็อกเอาต์
exports.logout = async (req, res) => {
  res.json({ message: 'Logged out' }); // ส่งข้อความแจ้งเตือนว่าผู้ใช้ออกจากระบบเรียบร้อย
};
