import 'package:flutter/material.dart'; // ใช้สร้าง UI

// สร้างหน้าหลักสำหรับแสดง Lobby
class LobbyScreen extends StatelessWidget {
  // 🔹 ตัวอย่างข้อมูลห้องกิจกรรม
  final List<Map<String, String>> rooms = [
    {'name': 'Room A', 'detail': 'เล่นได้ 2-4 คน'}, // ห้อง A
    {'name': 'Room B', 'detail': 'เล่นได้ 3-6 คน'}, // ห้อง B
    {'name': 'Room C', 'detail': 'เล่นได้ 2-8 คน'}, // ห้อง C
  ];

  LobbyScreen({super.key}); // กำหนด key สำหรับ Widget

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // ตั้งค่าสีพื้นหลัง
      appBar: AppBar(
        backgroundColor: Colors.black, // ตั้งค่าสี AppBar
        elevation: 0, // เอาเงาออก
        title: const Text(
          'Lobby ห้องกิจกรรม', // ชื่อหน้าจอ
          style: TextStyle(
            color: Colors.yellow, // ตั้งค่าสีข้อความ
            fontWeight: FontWeight.bold, // ตัวหนา
            fontSize: 28, // ขนาดตัวอักษร
            letterSpacing: 1.2, // ระยะห่างตัวอักษร
          ),
        ),
        centerTitle: true, // จัดให้อยู่ตรงกลาง
        automaticallyImplyLeading: false, // ❌ ไม่มีปุ่มย้อนกลับ
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(
          vertical: 24,
          horizontal: 16,
        ), // เว้นระยะห่าง
        itemCount: rooms.length, // กำหนดจำนวนรายการที่ต้องแสดง
        itemBuilder: (context, index) {
          final room = rooms[index]; // ดึงข้อมูลแต่ละห้อง
          return Container(
            margin: const EdgeInsets.only(bottom: 18), // กำหนดระยะห่าง
            decoration: BoxDecoration(
              color: Colors.grey[900], // ตั้งค่าสีพื้นหลัง
              borderRadius: BorderRadius.circular(16), // ทำมุมโค้งมน
              border: Border.all(
                color: Colors.yellow,
                width: 2,
              ), // กรอบสีเหลือง
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ), // กำหนดช่องว่างด้านใน
              title: Text(
                room['name'] ?? '', // แสดงชื่อห้อง
                style: const TextStyle(
                  color: Colors.yellow, // สีข้อความ
                  fontWeight: FontWeight.bold, // ตัวหนา
                  fontSize: 22, // ขนาดตัวอักษร
                ),
              ),
              subtitle: Text(
                room['detail'] ?? '', // แสดงรายละเอียดห้อง
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ), // สีตัวอักษร
              ),
              // 📌 ไม่มีปุ่มรีเฟรช
              // 📌 ไม่มีปุ่ม scroll to top
              // 🎯 สามารถเพิ่ม onTap ได้หากต้องการ
            ),
          );
        },
      ),
    );
  }
}
