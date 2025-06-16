const express = require('express'); // 🔹 นำเข้า Express framework เพื่อใช้สร้าง router
const router = express.Router(); // 🔹 สร้าง instance ของ Router เพื่อกำหนดเส้นทาง API
const authMiddleware = require('../middleware/authMiddleware'); // 🔹 นำเข้า middleware เพื่อตรวจสอบสิทธิ์การเข้าถึง
const roomsController = require('../controllers/roomsController'); // 🔹 นำเข้า controller สำหรับจัดการข้อมูลห้องกิจกรรม
const db = require('../config/db'); // 🔹 นำเข้าไฟล์ตั้งค่าฐานข้อมูล

// 🔑 ทุก route ต้องผ่านการตรวจสอบ token ก่อนใช้งาน
router.use(authMiddleware.verifyToken); // 🔹 ใช้ middleware ตรวจสอบ token ทุกคำขอ

// 📌 เส้นทาง API สำหรับจัดการห้องกิจกรรม
router.post('/', roomsController.createRoom); // 🔹 POST   /rooms → สร้างห้องใหม่
router.get('/:id', roomsController.getRoom); // 🔹 GET    /rooms/:id → ดึงข้อมูลห้องตาม ID
router.put('/:id', roomsController.updateRoom); // 🔹 PUT    /rooms/:id → อัปเดตข้อมูลห้องตาม ID
router.delete('/:id', roomsController.deleteRoom); // 🔹 DELETE /rooms/:id → ลบห้องตาม ID

// 📌 ดึงข้อมูลห้องทั้งหมดจากฐานข้อมูล
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM rooms'); // 🔹 SQL ดึงข้อมูลทั้งหมดจากตาราง rooms
    res.json(rows); // 🔹 ส่งข้อมูลห้องทั้งหมดกลับไปยัง client
  } catch (error) {
    res.status(500).json({ error: 'เกิดข้อผิดพลาดในการดึงข้อมูล' }); // 🔹 ส่งข้อความ error หากมีข้อผิดพลาด
  }
});

// 📌 สร้างห้องใหม่และบันทึกลงฐานข้อมูล
router.post('/', async (req, res) => {
  const { title, description } = req.body; // 🔹 รับข้อมูล title และ description จาก request body
  try {
    await db.query(
      'INSERT INTO rooms (title, description, owner_id) VALUES (?, ?, ?)', // 🔹 SQL เพิ่มข้อมูลห้องใหม่
      [title, description, req.user.id] // 🔹 ใช้ owner_id จาก token ที่ได้รับ
    );
    res.status(201).json({ message: 'สร้างห้องสำเร็จ' }); // 🔹 ส่งข้อความแจ้งว่าห้องถูกสร้างเรียบร้อย
  } catch (error) {
    res.status(500).json({ error: 'เกิดข้อผิดพลาดในการสร้างห้อง' }); // 🔹 ส่งข้อความ error หากมีข้อผิดพลาด
  }
});

module.exports = router; // 🔹 ส่งออก router เพื่อให้ใช้งานในไฟล์อื่น
