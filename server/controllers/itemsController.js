/****************************************************************
*  itemsController.js  —  ระบบ CRUD สำหรับจัดการ Item
****************************************************************/
const db = require('../config/db'); // นำเข้าไฟล์ตั้งค่าฐานข้อมูล

/* ---------- CREATE /items (สร้างรายการใหม่) ---------- */
exports.create = async (req, res) => {
  try {
    const { title, note } = req.body; // รับค่า title และ note จาก request body
    if (!title) return res.status(400).json({ error: 'ต้องกรอก title' }); // ตรวจสอบว่ามี title หรือไม่

    // 🔹 เพิ่มข้อมูลใหม่ลงในฐานข้อมูล
    const [rs] = await db.query(
      'INSERT INTO items (user_id, title, note) VALUES (?,?,?)', // คำสั่ง SQL สำหรับเพิ่มข้อมูล
      [req.user.id, title, note || null] // ใช้ user_id จาก token และ note ถ้าไม่มีให้เป็น null
    );

    res.status(201).json({ id: rs.insertId, title, note }); // ส่งข้อมูลกลับให้ client เมื่อสำเร็จ
  } catch (err) {
    console.error('ITEMS ERR →', err.code || err); // Log ข้อผิดพลาด
    res.status(500).json({ error: 'DB Error' }); // ส่งข้อความ error ถ้ามีปัญหากับฐานข้อมูล
  }
};

/* ---------- GET /items (ดึงรายการทั้งหมดของผู้ใช้) ---------- */
exports.listMine = async (req, res) => {
  try {
    // 🔹 คำสั่ง SQL เพื่อดึงข้อมูล items ของ user ที่ล็อกอินอยู่
    const [rows] = await db.query(
      'SELECT * FROM items WHERE user_id = ? ORDER BY created_at DESC', // เรียงลำดับตามวันที่สร้างล่าสุด
      [req.user.id] // ใช้ user_id จาก token
    );
    res.json(rows); // ส่งข้อมูลกลับให้ client
  } catch (err) {
    console.error('ITEMS ERR →', err); // Log ข้อผิดพลาด
    res.status(500).json({ error: 'DB Error' }); // ส่งข้อความ error ถ้ามีปัญหากับฐานข้อมูล
  }
};

/* ---------- GET /items/:id (ดึงรายการตาม ID) ---------- */
exports.getOne = async (req, res) => {
  // 🔹 คำสั่ง SQL เพื่อดึงข้อมูลเฉพาะรายการที่ตรงกับ id และ user_id
  const [rows] = await db.query(
    'SELECT * FROM items WHERE id = ? AND user_id = ?', // ค้นหา item ตาม id และ user
    [req.params.id, req.user.id]
  );

  if (!rows.length) return res.status(404).json({ error: 'ไม่พบรายการนี้' }); // ถ้าไม่พบข้อมูล
  res.json(rows[0]); // ส่งข้อมูลกลับให้ client
};

/* ---------- PUT /items/:id (อัปเดตรายการ) ---------- */
exports.update = async (req, res) => {
  const { title, note } = req.body; // รับค่า title และ note จาก request body

  // 🔹 คำสั่ง SQL เพื่ออัปเดตข้อมูล
  const [result] = await db.query(
    'UPDATE items SET title = ?, note = ? WHERE id = ? AND user_id = ?', // อัปเดต item ตาม id และ user
    [title, note, req.params.id, req.user.id]
  );

  if (!result.affectedRows) return res.status(404).json({ error: 'ไม่พบหรือไม่มีสิทธิ์' }); // ถ้าไม่พบข้อมูลหรือไม่มีสิทธิ์แก้ไข
  res.json({ message: 'อัปเดตสำเร็จ' }); // ส่งข้อความกลับให้ client เมื่อสำเร็จ
};

/* ---------- DELETE /items/:id (ลบรายการ) ---------- */
exports.remove = async (req, res) => {
  // 🔹 คำสั่ง SQL เพื่อลบข้อมูล
  const [result] = await db.query(
    'DELETE FROM items WHERE id = ? AND user_id = ?', // ลบ item ตาม id และ user
    [req.params.id, req.user.id]
  );

  if (!result.affectedRows) return res.status(404).json({ error: 'ไม่พบหรือไม่มีสิทธิ์' }); // ถ้าไม่พบข้อมูลหรือไม่มีสิทธิ์ลบ
  res.json({ message: 'ลบสำเร็จ' }); // ส่งข้อความกลับให้ client เมื่อสำเร็จ
};