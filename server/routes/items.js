/****************************************************************
*  items.js  — เส้นทาง CRUD item (การสร้าง, อ่าน, อัปเดต, ลบ)
****************************************************************/

const express = require('express'); // 🔹 นำเข้า Express framework เพื่อใช้สร้าง router
const router  = express.Router(); // 🔹 สร้าง instance ของ Router เพื่อกำหนดเส้นทาง API
const { verifyToken } = require('../middleware/authMiddleware'); // 🔹 นำเข้า middleware เพื่อตรวจสอบสิทธิ์การเข้าถึง
const items = require('../controllers/itemsController'); // 🔹 นำเข้า controller สำหรับจัดการ items

// 🔹 ใช้ verifyToken ทุกเส้นทาง (ต้องแนบ token เพื่อเข้าถึง API)
router.use(verifyToken);

// 🔹 กำหนดเส้นทาง API
router.post('/',        items.create);   // 🔹 POST   /items      → สร้าง item ใหม่
router.get('/',         items.listMine); // 🔹 GET    /items      → ดึงรายการของผู้ใช้ที่ล็อกอิน
router.get('/:id',      items.getOne);   // 🔹 GET    /items/:id  → ดึงข้อมูล item ตาม ID
router.put('/:id',      items.update);   // 🔹 PUT    /items/:id  → อัปเดต item ตาม ID
router.delete('/:id',   items.remove);   // 🔹 DELETE /items/:id  → ลบ item ตาม ID

module.exports = router; // 🔹 ส่งออก router เพื่อให้ใช้งานในไฟล์อื่น
