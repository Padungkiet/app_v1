import 'package:flutter/material.dart'; // นำเข้า Flutter package สำหรับ UI
import 'package:http/http.dart' as http; // นำเข้า HTTP package เพื่อเรียก API
import 'dart:convert'; // นำเข้า JSON package เพื่อจัดการข้อมูล JSON

// 🔹 สร้างหน้าล็อกอิน
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key}); // กำหนด key สำหรับ Widget

  @override
  State<LoginScreen> createState() => _LoginScreenState(); // สร้าง state ของหน้าล็อกอิน
}

// 🔹 กำหนดสถานะของหน้าล็อกอิน
class _LoginScreenState extends State<LoginScreen> {
  final _phoneController =
      TextEditingController(); // สร้างตัวควบคุมข้อความสำหรับเบอร์โทร
  final _passwordController =
      TextEditingController(); // สร้างตัวควบคุมข้อความสำหรับรหัสผ่าน
  bool _rememberMe = false; // ตัวแปรสำหรับตรวจสอบการจำข้อมูลล็อกอิน
  String? phoneError; // ตัวแปรเก็บข้อความผิดพลาดของเบอร์โทร
  String? passwordError; // ตัวแปรเก็บข้อความผิดพลาดของรหัสผ่าน
  final bool _loading = false; // ตัวแปรตรวจสอบสถานะกำลังโหลดข้อมูล
  String? accessToken; // ตัวแปรสำหรับเก็บ accessToken

  // 🔹 ฟังก์ชันสร้างช่องกรอกข้อมูล
  Widget _buildInput({
    required String hint, // ข้อความใบ้ในช่องกรอก
    required TextEditingController controller, // ตัวควบคุมช่องกรอกข้อมูล
    bool obscure = false, // กำหนดว่าจะซ่อนข้อความหรือไม่ (ใช้กับรหัสผ่าน)
    TextInputType? keyboardType, // ประเภทของแป้นพิมพ์ที่ใช้
    String? errorText, // ข้อความผิดพลาดที่จะแสดง
  }) {
    return SizedBox(
      height: 80, // กำหนดความสูงของ input
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // กำหนดการจัดวางแนวแกนตั้ง
        children: [
          Container(
            width: 12, // กำหนดความกว้างของแถบสีเหลืองด้านซ้าย
            height: 56, // กำหนดความสูงของแถบสีเหลืองด้านซ้าย
            decoration: BoxDecoration(
              color: Colors.yellow[700], // ตั้งค่าสีของแถบด้านซ้ายเป็นสีเหลือง
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12), // มุมโค้งด้านบนซ้าย
                bottomLeft: Radius.circular(12), // มุมโค้งด้านล่างซ้าย
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 0,
              ), // กำหนดระยะห่างด้านซ้ายของช่องกรอก
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // จัดวางข้อความให้อยู่ทางซ้าย
                children: [
                  SizedBox(
                    height: 56, // กำหนดความสูงของช่องกรอก
                    child: TextField(
                      controller: controller, // กำหนดตัวควบคุมข้อความ
                      obscureText: obscure, // ซ่อนข้อความถ้าเป็นรหัสผ่าน
                      keyboardType: keyboardType, // กำหนดประเภทของแป้นพิมพ์
                      decoration: InputDecoration(
                        hintText: hint, // ข้อความใบ้ในช่องกรอก
                        filled: true, // เปิดใช้งานพื้นหลัง
                        fillColor: Colors.white, // กำหนดสีพื้นหลัง
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ), // กำหนดระยะห่างภายใน
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12), // มุมโค้งด้านบนขวา
                            bottomRight: Radius.circular(
                              12,
                            ), // มุมโค้งด้านล่างขวา
                          ),
                          borderSide: BorderSide.none, // ไม่มีขอบ
                        ),
                        hintStyle: const TextStyle(
                          color: Colors.grey, // กำหนดสีข้อความใบ้
                          fontWeight:
                              FontWeight.bold, // ตั้งค่าความหนาของตัวอักษร
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                      ), // กำหนดสีตัวอักษรให้เป็นดำ
                    ),
                  ),
                  if (errorText != null) // ถ้ามีข้อผิดพลาดให้แสดงข้อความ
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        top: 2,
                      ), // กำหนดระยะห่างของข้อความผิดพลาด
                      child: Text(
                        errorText, // แสดงข้อความผิดพลาด
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ), // กำหนดสีและขนาดของข้อความผิดพลาด
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔑 ฟังก์ชันล็อกอิน
  Future<void> login() async {
    final url = Uri.parse(
      'http://192.168.110.57:3000/users/login',
    ); // กำหนด URL API สำหรับการล็อกอิน
    final response = await http.post(
      url, // เรียก API ด้วย HTTP POST
      headers: {
        'Content-Type': 'application/json',
      }, // กำหนดค่า headers สำหรับ API
      body: jsonEncode({
        // แปลงข้อมูลเป็น JSON
        'phone': _phoneController.text, // ดึงค่าที่ผู้ใช้กรอกในช่องเบอร์โทร
        'password':
            _passwordController.text, // ดึงค่าที่ผู้ใช้กรอกในช่องรหัสผ่าน
      }),
    );
    if (!mounted) return; // ตรวจสอบว่า widget ยังอยู่ในหน้าจอหรือไม่

    if (response.statusCode == 200) {
      // เช็คว่า API ส่งกลับสถานะสำเร็จ
      final data = jsonDecode(response.body); // แปลงข้อมูล JSON จาก API
      final accessToken = data['accessToken']; // ดึง accessToken จาก API
      Navigator.pushReplacementNamed(
        context,
        '/lobby',
        arguments: accessToken,
      ); // เปลี่ยนไปยังหน้าหลัก พร้อมส่ง accessToken
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${response.body}'),
        ), // แจ้งเตือนหากล็อกอินไม่สำเร็จ
      );
    }
  }

  // 🔍 ตรวจสอบค่าก่อนล็อกอิน
  void _validateAndLogin() {
    setState(() {
      // อัปเดตค่าภายใน state
      phoneError =
          _phoneController
              .text
              .isEmpty // ตรวจสอบว่าผู้ใช้กรอกเบอร์โทรหรือไม่
          ? 'กรุณากรอกเบอร์โทร'
          : (!_phoneController.text.contains(
              RegExp(r'^[0-9]+$'),
            )) // เช็คว่าเป็นตัวเลขทั้งหมดหรือไม่
          ? 'เบอร์โทรต้องเป็นตัวเลข'
          : (_phoneController.text.length < 9
                ? 'เบอร์โทรไม่ถูกต้อง'
                : null); // ตรวจสอบความยาวของเบอร์โทร

      passwordError =
          _passwordController
              .text
              .isEmpty // ตรวจสอบว่าผู้ใช้กรอกรหัสผ่านหรือไม่
          ? 'กรุณากรอก Password'
          : (_passwordController.text.contains(
                  ' ',
                ) // ตรวจสอบว่ารหัสผ่านมีช่องว่างหรือไม่
                ? 'ห้ามเว้นวรรค'
                : (_passwordController.text.length >
                          15 // ตรวจสอบว่ารหัสผ่านเกิน 15 ตัวอักษรหรือไม่
                      ? 'Password ไม่เกิน 15 ตัวอักษร'
                      : null));
    });

    if (phoneError == null && passwordError == null) {
      // ถ้าไม่มีข้อผิดพลาด ให้ล็อกอิน
      login();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width; // ดึงขนาดหน้าจอ
    final formWidth = width > 400 ? 360.0 : width * 0.95; // กำหนดขนาดแบบฟอร์ม

    return Scaffold(
      backgroundColor: Colors.black, // ตั้งค่าพื้นหลังเป็นสีดำ
      body: Center(
        child: SingleChildScrollView(
          // ใช้เพื่อเลื่อนหน้าได้ถ้ามีข้อมูลเยอะ
          padding: const EdgeInsets.symmetric(
            vertical: 32,
          ), // กำหนดระยะห่างแนวตั้ง
          child: SizedBox(
            width: formWidth, // กำหนดขนาดแบบฟอร์ม
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // จัดวางให้อยู่กึ่งกลางแนวตั้ง
              children: [
                // 🔹 แสดงข้อความ Login พร้อมเน้นตัว g เป็นสีเหลือง
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 40, // ขนาดตัวอักษร
                      fontWeight: FontWeight.bold, // กำหนดตัวหนา
                      letterSpacing: 1.5, // กำหนดระยะห่างตัวอักษร
                    ),
                    children: [
                      const TextSpan(
                        text: 'Lo',
                        style: TextStyle(color: Colors.white),
                      ), // สีขาว
                      TextSpan(
                        text: 'g',
                        style: TextStyle(color: Colors.yellow[700]),
                      ), // สีเหลือง
                      const TextSpan(
                        text: 'in',
                        style: TextStyle(color: Colors.white),
                      ), // สีขาว
                    ],
                  ),
                ),
                const SizedBox(height: 8), // เว้นช่องว่างแนวตั้ง
                const Text(
                  'Please sign in to your account', // คำอธิบายใต้ Login
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32), // เว้นช่องว่างแนวตั้ง
                _buildInput(
                  // ช่องกรอกเบอร์โทร
                  hint: 'Phone Number', // ข้อความใบ้
                  controller: _phoneController, // กำหนดตัวควบคุม
                  keyboardType: TextInputType.phone, // กำหนดประเภทแป้นพิมพ์
                  errorText: phoneError, // แสดงข้อผิดพลาด (ถ้ามี)
                ),
                _buildInput(
                  // ช่องกรอกรหัสผ่าน
                  hint: 'Password', // ข้อความใบ้
                  controller: _passwordController, // กำหนดตัวควบคุม
                  obscure: true, // ซ่อนข้อความ
                  errorText: passwordError, // แสดงข้อผิดพลาด (ถ้ามี)
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe, // ตรวจสอบค่า remember me
                      onChanged: (v) {
                        setState(() {
                          _rememberMe = v ?? false; // อัปเดตค่า remember me
                        });
                      },
                      activeColor:
                          Colors.yellow[700], // สี checkbox เมื่อถูกเลือก
                    ),
                    const Text(
                      'Remember me', // ข้อความ remember me
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40), // เว้นช่องว่างแนวตั้ง
                GestureDetector(
                  onTap: _loading
                      ? null
                      : _validateAndLogin, // เรียกฟังก์ชันตรวจสอบค่าก่อนล็อกอิน
                  child: Container(
                    width: 90,
                    height: 90, // กำหนดขนาดของปุ่ม
                    decoration: BoxDecoration(
                      color: Colors.yellow[700],
                      shape: BoxShape.circle,
                    ), // กำหนดสีและรูปร่าง
                    child: Center(
                      child:
                          _loading // ถ้ากำลังโหลด ให้แสดง progress indicator
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Icon(
                              Icons.check,
                              size: 56,
                              color: Colors.black,
                            ), // ไอคอนปุ่มล็อกอิน
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
