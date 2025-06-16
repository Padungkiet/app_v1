/****************************************************************
*  จุดเริ่มต้นของแอป (Express Entry-Point) ไฟล์ server.js
****************************************************************/
require('dotenv').config();  // 🔹 โหลดค่าตัวแปรลับจาก `.env`

const express = require('express'); // 🔹 นำเข้า Express framework เพื่อใช้สร้าง server
const helmet  = require('helmet');  // 🔹 ใช้ Helmet เพื่อป้องกันการโจมตีทั่วไป เช่น XSS
const cors    = require('cors');    // 🔹 ใช้ CORS เพื่อรองรับ Cross-Origin Requests
const cookieParser = require('cookie-parser');  // 🔹 ใช้จัดการ Cookie ที่ส่งเข้ามาใน request

const app = express(); // 🔹 สร้าง instance ของ Express

/* ───── Middleware (จัดการ Security & Requests) ───── */
app.use(helmet());  // 🔹 เปิดการป้องกัน Security Headers
app.use(cookieParser());  // 🔹 โหลดก่อน CORS เพื่อให้รองรับ Cookie
app.use(cors({ origin: 'http://localhost:3000', credentials: true }));  // 🔹 เปิดให้ Frontend ส่ง Cookie มาได้
app.use(express.json()); // 🔹 เปิดใช้งาน JSON body parser
app.use(express.urlencoded({ extended: false })); // 🔹 รองรับ URL-encoded request body

/* ───── Register Routes (กำหนดเส้นทาง API) ───── */
app.use('/users', require('./routes/users'));  // 🔹 เส้นทางจัดการผู้ใช้
app.use('/items', require('./routes/items'));  // 🔹 เส้นทางจัดการ Items (ถ้ามี)
app.use('/rooms', require('./routes/rooms'));  // 🔹 เส้นทางจัดการ Rooms (ถ้ามี)

/* ───── 404 Not Found (สำหรับเส้นทางที่ไม่พบ) ───── */
app.use((_, res) => res.status(404).json({ error: 'Not found' })); // 🔹 ส่ง error 404 ถ้าไม่มี route ตรงกัน

/* ───── Global Error Handler (จัดการข้อผิดพลาดทั่วระบบ) ───── */
app.use((err, _req, res, _next) => {
  console.error('💥 Server Error:', err); // 🔹 Log ข้อผิดพลาดที่เกิดขึ้น
  res.status(500).json({ error: 'Server Error' }); // 🔹 ส่ง error 500 ถ้ามีข้อผิดพลาดในระบบ
});

console.log('✅ Routes loaded: /rooms, /users, /items'); // 🔹 แสดงรายการ route ที่ถูกโหลด

/* ───── Start Server (เริ่มรัน Express) ───── */
const PORT = process.env.PORT || 3000; // 🔹 ใช้ port จาก .env หรือค่าเริ่มต้นคือ 3000
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`)); // 🔹 เริ่ม server และแสดงข้อความเมื่อเริ่มทำงาน
