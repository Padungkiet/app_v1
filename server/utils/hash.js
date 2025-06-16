const bcrypt = require('bcryptjs'); // 🔹 นำเข้าไลบรารี bcrypt.js เพื่อใช้แฮชรหัสผ่าน

// 🔹 ฟังก์ชันแฮชรหัสผ่านก่อนบันทึกลงฐานข้อมูล
exports.hashPassword = (password) => bcrypt.hash(password, 10); 
// ใช้ bcrypt.hash() เพื่อสร้างแฮชของรหัสผ่าน
// ใช้ค่า salt เป็น 10 รอบเพื่อเพิ่มความปลอดภัย

// 🔹 ฟังก์ชันตรวจสอบรหัสผ่านที่ผู้ใช้กรอก เทียบกับแฮชที่เก็บไว้
exports.comparePassword = (password, hash) => bcrypt.compare(password, hash); 
// ใช้ bcrypt.compare() เพื่อเทียบรหัสผ่านที่กรอกกับแฮชที่บันทึกไว้
// ถ้าตรงกันจะส่งค่า true, ถ้าไม่ตรงจะส่งค่า false
