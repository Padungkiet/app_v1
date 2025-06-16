import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers
  final _usernameController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();

  // Error texts
  String? usernameError;
  String? firstnameError;
  String? lastnameError;
  String? emailError;
  String? phoneError;
  String? ageError;
  String? passwordError;
  String? genderError;
  String? genderValue;

  bool _loading = false;

  // Input builder
  Widget _buildInput({
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
    TextInputType? keyboardType,
    String? errorText,
  }) {
    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.yellow[700],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 56,
                    child: TextField(
                      controller: controller,
                      obscureText: obscure,
                      keyboardType: keyboardType,
                      decoration: InputDecoration(
                        hintText: hint,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  if (errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 2),
                      child: Text(
                        errorText,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
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

  // Validate and register
  void _validateAndRegister() {
    setState(() {
      usernameError = _usernameController.text.isEmpty
          ? 'กรุณากรอก User Name'
          : (_usernameController.text.contains(' ') ? 'ห้ามเว้นวรรค' : null);

      firstnameError = _firstnameController.text.isEmpty
          ? 'กรุณากรอก First Name'
          : (_firstnameController.text.contains(' ') ? 'ห้ามเว้นวรรค' : null);

      lastnameError = _lastnameController.text.isEmpty
          ? 'กรุณากรอก Last Name'
          : (_lastnameController.text.contains(' ') ? 'ห้ามเว้นวรรค' : null);

      emailError = _emailController.text.isEmpty
          ? 'กรุณากรอก E-mail'
          : (!_emailController.text.contains('@') ||
                !_emailController.text.contains('.'))
          ? 'E-mail ไม่ถูกต้อง'
          : (_emailController.text.contains(' ') ? 'ห้ามเว้นวรรค' : null);

      phoneError = _phoneController.text.isEmpty
          ? 'กรุณากรอกเบอร์โทร'
          : (!_phoneController.text.contains(RegExp(r'^[0-9]+$')))
          ? 'เบอร์โทรต้องเป็นตัวเลข'
          : (_phoneController.text.contains(' ') ? 'ห้ามเว้นวรรค' : null);

      ageError = _ageController.text.isEmpty
          ? 'กรุณากรอกอายุ'
          : (!_ageController.text.contains(RegExp(r'^[0-9]+$')))
          ? 'อายุต้องเป็นตัวเลข'
          : (_ageController.text.contains(' ') ? 'ห้ามเว้นวรรค' : null);

      passwordError = _passwordController.text.isEmpty
          ? 'กรุณากรอก Password'
          : (_passwordController.text.contains(' ')
                ? 'ห้ามเว้นวรรค'
                : (_passwordController.text.length > 15
                      ? 'Password ไม่เกิน 15 ตัวอักษร'
                      : null));

      genderError = (genderValue == null || genderValue!.isEmpty)
          ? 'เลือกเพศ'
          : null;
    });

    // ตรวจสอบว่าทุก error เป็น null ถึงจะไปต่อ
    if (usernameError == null &&
        firstnameError == null &&
        lastnameError == null &&
        emailError == null &&
        phoneError == null &&
        ageError == null &&
        passwordError == null &&
        genderError == null) {
      _register();
    }
  }

  // Register function
  Future<void> _register() async {
    setState(() => _loading = true);
    final url = Uri.parse('http://192.168.110.57:3000/users/register');
    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': _usernameController.text.trim(),
              'password': _passwordController.text,
              'first_name': _firstnameController.text.trim(),
              'last_name': _lastnameController.text.trim(),
              'age': _ageController.text.trim(),
              'gender': genderValue,
              'email': _emailController.text.trim(),
              'phone': _phoneController.text.trim(),
            }),
          )
          .timeout(const Duration(seconds: 5));
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
      if (response.statusCode == 200) {
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Register failed: ${response.body}')),
        );
      }
    } on TimeoutException {
      setState(() {
        _loading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เชื่อมต่อเซิร์ฟเวอร์ไม่ได้')),
      );
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final formWidth = width > 400 ? 360.0 : width * 0.95;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: SizedBox(
                width: formWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Register',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please sign in to your account',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildInput(
                      hint: 'User Name',
                      controller: _usernameController,
                      errorText: usernameError,
                    ),
                    _buildInput(
                      hint: 'First Name',
                      controller: _firstnameController,
                      errorText: firstnameError,
                    ),
                    _buildInput(
                      hint: 'Last Name',
                      controller: _lastnameController,
                      errorText: lastnameError,
                    ),
                    _buildInput(
                      hint: 'E-mail',
                      controller: _emailController,
                      errorText: emailError,
                    ),
                    _buildInput(
                      hint: 'Phone Number',
                      controller: _phoneController,
                      errorText: phoneError,
                      keyboardType: TextInputType.phone,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInput(
                            hint: 'Age',
                            controller: _ageController,
                            errorText: ageError,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 80,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 12,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.yellow[700],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomLeft: Radius.circular(12),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 56,
                                          child: DropdownButtonFormField<String>(
                                            value: genderValue,
                                            decoration: const InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 18,
                                                  ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(12),
                                                  bottomRight: Radius.circular(
                                                    12,
                                                  ),
                                                ),
                                                borderSide: BorderSide.none,
                                              ),
                                            ),
                                            hint: const Text(
                                              'Gender',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            items: const [
                                              DropdownMenuItem(
                                                value: 'male',
                                                child: Text('Male'),
                                              ),
                                              DropdownMenuItem(
                                                value: 'female',
                                                child: Text('Female'),
                                              ),
                                              DropdownMenuItem(
                                                value: 'other',
                                                child: Text('Other'),
                                              ),
                                            ],
                                            onChanged: (v) =>
                                                setState(() => genderValue = v),
                                          ),
                                        ),
                                        if (genderError != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 16,
                                              top: 2,
                                            ),
                                            child: Text(
                                              genderError!,
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    _buildInput(
                      hint: 'Password',
                      controller: _passwordController,
                      obscure: true,
                      errorText: passwordError,
                    ),
                    const SizedBox(height: 40),
                    GestureDetector(
                      onTap: _loading ? null : _validateAndRegister,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.yellow[700],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: _loading
                              ? const CircularProgressIndicator(
                                  color: Colors.black,
                                )
                              : const Icon(
                                  Icons.check,
                                  size: 56,
                                  color: Colors.black,
                                ),
                        ),
                      ),
                    ),
                    // Debug prints
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Print Values'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ปุ่มข้ามที่มุมล่างซ้าย
          Positioned(
            left: 16,
            bottom: 24,
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text(
                'ข้าม',
                style: TextStyle(
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
