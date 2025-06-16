import 'package:flutter/material.dart'; // นำเข้าแพ็กเกจ Flutter สำหรับสร้าง UI

// 🔹 สร้าง Widget ปุ่มที่สามารถกำหนดข้อความและการทำงานได้
class CustomButton extends StatelessWidget {
  final String text; // ตัวแปรสำหรับเก็บข้อความปุ่ม
  final VoidCallback onPressed; // ฟังก์ชันเมื่อกดปุ่ม

  // 🔹 กำหนดค่าเริ่มต้นของปุ่มโดยรับข้อความและฟังก์ชันเป็น parameter
  const CustomButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      // สร้างปุ่มแบบ ElevatedButton
      onPressed: onPressed, // กำหนดการทำงานเมื่อกดปุ่ม
      child: Text(text), // กำหนดข้อความที่แสดงในปุ่ม
    );
  }
}
