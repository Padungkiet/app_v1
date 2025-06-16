const db = require('../config/db'); // 🔹 นำเข้าไฟล์ตั้งค่าฐานข้อมูล

// 🔹 ฟังก์ชันค้นหาผู้ใช้ตาม ID
exports.findById = async (id) => {
  const [rows] = await db.query('SELECT * FROM users WHERE id = ?', [id]); // คำสั่ง SQL ดึงข้อมูลผู้ใช้ตาม ID
  return rows[0]; // ส่งข้อมูลผู้ใช้ที่พบกลับไป
};

// 📌 สามารถเพิ่มฟังก์ชันเพิ่มเติมได้ที่นี่ เช่น:
// exports.findByUsername = async (username) => { ... } // ค้นหาผู้ใช้ตาม username
// exports.createUser = async (userData) => { ... } // เพิ่มผู้ใช้ใหม่
// exports.updateUser = async (id, updateData) => { ... } // อัปเดตข้อมูลผู้ใช้ตาม ID
