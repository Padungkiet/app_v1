const db = require('../config/db'); // นำเข้าไฟล์ตั้งค่าฐานข้อมูล

// 🔹 POST /rooms (สร้างห้องใหม่)
exports.createRoom = async (req, res) => {
  try {
    const { title, description } = req.body; // รับค่า title และ description จาก request body
    const owner_id = req.user.id; // ดึง ID ของเจ้าของห้องจาก token
    
    // 🔹 ตรวจสอบว่าผู้ใช้กรอกข้อมูลครบหรือไม่
    if (!title || !description) {
      return res.status(400).json({ error: '❌ ต้องกรอกข้อมูลให้ครบ' });
    }

    // 🔹 เพิ่มข้อมูลห้องใหม่ลงในฐานข้อมูล
    const [rs] = await db.query(
      'INSERT INTO rooms (title, description, owner_id) VALUES (?,?,?)', // คำสั่ง SQL เพิ่มข้อมูล
      [title, description, owner_id]
    );

    res.status(201).json({ id: rs.insertId, title, description, owner_id }); // ส่งข้อมูลกลับให้ client
  } catch (err) {
    console.error("CREATE ROOM ERR →", err); // Log ข้อผิดพลาด
    res.status(500).json({ error: 'DB Error' }); // ส่งข้อความ error ถ้ามีปัญหากับฐานข้อมูล
  }
};

// 🔹 GET /rooms/:id (ดูรายละเอียดห้อง)
exports.getRoom = async (req, res) => {
  try {
    // 🔹 ดึงข้อมูลห้องจากฐานข้อมูลตาม ID ที่ได้รับ
    const [rows] = await db.query(
      'SELECT * FROM rooms WHERE id = ?', // คำสั่ง SQL ดึงข้อมูลห้อง
      [req.params.id]
    );

    // 🔹 ตรวจสอบว่าพบข้อมูลห้องหรือไม่
    if (!rows.length) {
      return res.status(404).json({ error: '❌ ไม่พบห้องนี้' });
    }

    res.json(rows[0]); // ส่งข้อมูลห้องกลับให้ client
  } catch (err) {
    console.error("GET ROOM ERR →", err); // Log ข้อผิดพลาด
    res.status(500).json({ error: 'DB Error' }); // ส่งข้อความ error ถ้ามีปัญหากับฐานข้อมูล
  }
};

// 🔹 PUT /rooms/:id (แก้ไขห้อง)
exports.updateRoom = async (req, res) => {
  try {
    const { title, description } = req.body; // รับข้อมูล title และ description ที่ต้องการแก้ไข
    const owner_id = req.user.id; // ดึง ID เจ้าของห้องจาก token

    // 🔹 ดึงข้อมูลห้องจากฐานข้อมูลเพื่อตรวจสอบสิทธิ์การแก้ไข
    const [rows] = await db.query(
      'SELECT * FROM rooms WHERE id = ?', // คำสั่ง SQL ดึงข้อมูลห้อง
      [req.params.id]
    );

    // 🔹 ตรวจสอบว่าห้องมีอยู่จริงหรือไม่
    if (!rows.length) {
      return res.status(404).json({ error: '❌ ไม่พบห้องนี้' });
    }

    // 🔹 ตรวจสอบสิทธิ์การแก้ไข
    if (rows[0].owner_id !== owner_id) {
      return res.status(403).json({ error: '❌ ไม่มีสิทธิ์แก้ไขห้องนี้' });
    }

    // 🔹 อัปเดตข้อมูลห้องในฐานข้อมูล
    await db.query(
      'UPDATE rooms SET title = ?, description = ? WHERE id = ?', // คำสั่ง SQL อัปเดตข้อมูล
      [title, description, req.params.id]
    );

    res.json({ message: '✅ ห้องถูกแก้ไขเรียบร้อย' }); // ส่งข้อความกลับให้ client
  } catch (err) {
    console.error("UPDATE ROOM ERR →", err); // Log ข้อผิดพลาด
    res.status(500).json({ error: 'DB Error' }); // ส่งข้อความ error ถ้ามีปัญหากับฐานข้อมูล
  }
};

// 🔹 DELETE /rooms/:id (ลบห้อง)
exports.deleteRoom = async (req, res) => {
  try {
    const owner_id = req.user.id; // ดึง ID เจ้าของห้องจาก token

    // 🔹 ดึงข้อมูลห้องจากฐานข้อมูลเพื่อตรวจสอบสิทธิ์การลบ
    const [rows] = await db.query(
      'SELECT * FROM rooms WHERE id = ?', // คำสั่ง SQL ดึงข้อมูลห้อง
      [req.params.id]
    );

    // 🔹 ตรวจสอบว่าห้องมีอยู่จริงหรือไม่
    if (!rows.length) {
      return res.status(404).json({ error: '❌ ไม่พบห้องนี้' });
    }

    // 🔹 ตรวจสอบสิทธิ์การลบ
    if (rows[0].owner_id !== owner_id) {
      return res.status(403).json({ error: '❌ ไม่มีสิทธิ์ลบห้องนี้' });
    }

    // 🔹 ลบข้อมูลห้องออกจากฐานข้อมูล
    await db.query(
      'DELETE FROM rooms WHERE id = ?', // คำสั่ง SQL ลบข้อมูล
      [req.params.id]
    );

    res.json({ message: '✅ ห้องถูกลบเรียบร้อย' }); // ส่งข้อความกลับให้ client
  } catch (err) {
    console.error("DELETE ROOM ERR →", err); // Log ข้อผิดพลาด
    res.status(500).json({ error: 'DB Error' }); // ส่งข้อความ error ถ้ามีปัญหากับฐานข้อมูล
  }
};
