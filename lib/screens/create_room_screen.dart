import 'package:flutter/material.dart'; // ใช้สำหรับสร้าง UI
import 'package:http/http.dart' as http; // ใช้เรียก API
import 'dart:convert'; // ใช้จัดการข้อมูล JSON

// หน้าจอสำหรับสร้างห้องกิจกรรม
class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController _nameController =
      TextEditingController(); // ตัวเก็บข้อความชื่อห้อง
  final TextEditingController _descController =
      TextEditingController(); // ตัวเก็บข้อความรายละเอียด

  bool loading = false; // เช็คว่ากำลังโหลดอยู่หรือไม่
  String? accessToken; // ตัวเก็บ token สำหรับ API

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(
      context,
    )?.settings.arguments; // รับค่าจากหน้าก่อนหน้า
    if (args is String) {
      accessToken = args; // กำหนดค่า token
    }
  }

  // ฟังก์ชันสำหรับสร้างห้อง
  Future<void> createRoom() async {
    setState(() => loading = true); // เปลี่ยนสถานะเป็นโหลด
    final response = await http.post(
      Uri.parse(
        'http://192.168.110.57:3000/rooms',
      ), // ส่งข้อมูลไปยังเซิร์ฟเวอร์
      headers: {
        'Content-Type': 'application/json', // กำหนดรูปแบบข้อมูล
        if (accessToken != null)
          'Authorization': 'Bearer $accessToken', // ถ้ามี token ให้ใช้
      },
      body: jsonEncode({
        'title': _nameController.text, // ใส่ชื่อห้อง
        'description': _descController.text, // ใส่รายละเอียด
      }),
    );
    setState(() => loading = false); // หยุดโหลด
    if (!mounted) return; // เช็คว่าหน้าพร้อมแสดงผลหรือไม่
    if (response.statusCode == 201) {
      Navigator.pop(context, true); // กลับไปหน้าก่อนพร้อมข้อมูล
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('สร้างห้องไม่สำเร็จ'),
        ), // แสดงข้อความแจ้งเตือน
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // ตั้งค่าพื้นหลังเป็นสีดำ
      appBar: AppBar(
        backgroundColor: Colors.black, // ตั้งสีของ AppBar
        title: const Text('สร้างห้องกิจกรรม'), // ตั้งชื่อหน้าจอ
        centerTitle: true, // ทำให้ชื่ออยู่ตรงกลาง
      ),
      body: Padding(
        padding: const EdgeInsets.all(24), // กำหนดระยะขอบ
        child: Column(
          children: [
            TextField(
              controller: _nameController, // ช่องกรอกชื่อห้อง
              decoration: const InputDecoration(
                labelText: 'ชื่อห้อง', // ป้ายกำกับ
                filled: true,
                fillColor: Colors.white, // ตั้งค่าสีพื้นหลัง
              ),
            ),
            const SizedBox(height: 16), // ระยะห่าง
            TextField(
              controller: _descController, // ช่องกรอกรายละเอียด
              decoration: const InputDecoration(
                labelText: 'รายละเอียด', // ป้ายกำกับ
                filled: true,
                fillColor: Colors.white, // ตั้งค่าสีพื้นหลัง
              ),
              maxLines: 3, // จำกัดจำนวนบรรทัด
            ),
            const Spacer(), // ดันปุ่มลงไปด้านล่าง
            loading
                ? const CircularProgressIndicator(
                    color: Colors.yellow,
                  ) // แสดงตัวโหลด
                : FloatingActionButton(
                    backgroundColor: Colors.yellow, // ตั้งค่าสีปุ่ม
                    onPressed: createRoom, // เมื่อกดปุ่ม
                    child: const Icon(
                      Icons.check, // ตั้งค่าไอคอน
                      color: Colors.black, // ตั้งค่าสีไอคอน
                      size: 40, // ตั้งค่าขนาด
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
