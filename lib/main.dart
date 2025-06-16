import 'package:flutter/material.dart'; // ใช้สำหรับสร้าง UI
import 'screens/register_screen.dart'; // นำเข้าหน้าสมัครสมาชิก (Register)
import 'screens/login_screen.dart'; // นำเข้าหน้าล็อกอิน (Login)
import 'screens/home_screen.dart'; // นำเข้าหน้าหลัก (Home)
import 'package:app_v1/screens/create_room_screen.dart'; // นำเข้าหน้าสร้างห้อง (Create Room)

// ฟังก์ชันเริ่มต้นของแอป
void main() {
  runApp(const MyApp()); // เริ่มการทำงานของแอปโดยใช้ MyApp เป็น root widget
}

// คลาส MyApp ทำหน้าที่กำหนดโครงสร้างของแอป
class MyApp extends StatelessWidget {
  const MyApp({super.key}); // สร้าง Constructor แบบ const

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Demo V1', // กำหนดชื่อแอป
      theme: ThemeData(
        primarySwatch: Colors.yellow, // กำหนดสีหลักเป็นสีเหลือง
        useMaterial3: true, // ใช้ Material3 UI design
      ),
      initialRoute: '/register', // กำหนดหน้าเริ่มต้นเมื่อเปิดแอป
      routes: {
        // กำหนดเส้นทางของแอป (Routing)
        '/register': (context) =>
            const RegisterScreen(), // เส้นทางไปหน้าสมัครสมาชิก
        '/login': (context) => const LoginScreen(), // เส้นทางไปหน้าล็อกอิน
        '/lobby': (context) => const HomeScreen(), // เส้นทางไปหน้าหลัก
        '/create_room': (context) =>
            const CreateRoomScreen(), // เส้นทางไปหน้าสร้างห้อง
      },
    );
  }
}
