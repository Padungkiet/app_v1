/****************************************************************
*  users.js — เส้นทาง API สำหรับ Register, Login, Logout
****************************************************************/
const express = require('express'); // เรียกใช้ express
const router = express.Router(); // สร้าง router
const userController = require('../controllers/userController'); // เรียก controller

// ✅ สมัครสมาชิก
router.post('/register', userController.register);
// ✅ ล็อกอิน
router.post('/login', userController.login);
// ✅ ดูข้อมูลตัวเอง
router.get('/me', userController.getProfile);
// ✅ ล็อกเอาท์
router.post('/logout', userController.logout);

module.exports = router; // export router