import 'dart:async'; // ใช้สำหรับจัดการเวลาและ Timer
import 'package:flutter/material.dart'; // ใช้สร้าง UI
import 'package:http/http.dart' as http; // ใช้เรียก API
import 'dart:convert'; // ใช้แปลงข้อมูล JSON

// สร้างหน้าหลักของแอป
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // เก็บ index ของ tab ที่เลือก
  String? accessToken; // เก็บ token สำหรับ API

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // TODO: เปลี่ยนหน้า/เนื้อหาตาม index ที่เลือก
    });
  }

  // ตัวอย่างข้อมูลห้องกิจกรรม
  List<Map<String, dynamic>> rooms = [];

  final ScrollController _scrollController =
      ScrollController(); // ใช้ควบคุมการเลื่อนหน้า

  Timer? _timer; // ใช้ refresh ข้อมูล

  @override
  void initState() {
    super.initState();
    fetchRooms(); // ดึงข้อมูลเมื่อเปิดหน้า
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchRooms(); // อัปเดตข้อมูลทุก 10 วินาที
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // หยุด timer เมื่อปิดหน้า
    _scrollController.dispose(); // ล้าง controller
    super.dispose();
  }

  // ดึงข้อมูลห้องจาก backend
  Future<void> fetchRooms() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.110.57:3000/rooms'), // เรียก API
        headers: {
          if (accessToken != null)
            'Authorization': 'Bearer $accessToken', // ใส่ token ถ้ามี
        },
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body); // แปลง JSON
        setState(() {
          rooms = data.cast<Map<String, dynamic>>(); // อัปเดตข้อมูล
        });
      } else {
        setState(() {
          rooms = []; // เคลียร์ข้อมูลหาก error
        });
      }
    } catch (e) {
      setState(() {
        rooms = []; // เคลียร์ข้อมูลหากมีข้อผิดพลาด
      });
    }
  }

  // สร้าง UI ตาม tab ที่เลือก
  Widget _buildBody() {
    if (_selectedIndex == 0) {
      return rooms.isEmpty
          ? const Center(child: Text('ยังไม่มีห้องกิจกรรม')) // ถ้าไม่มีห้อง
          : ListView.builder(
              controller: _scrollController, // ใส่ controller
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ), // กำหนดขอบ
                  child: ListTile(
                    title: Text(room['title'] ?? ''), // ชื่อห้อง
                    subtitle: Text(room['description'] ?? ''), // รายละเอียดห้อง
                    onTap: () {
                      // TODO: ไปหน้ารายละเอียดห้อง
                    },
                  ),
                );
              },
            );
    } else if (_selectedIndex == 1) {
      return const Center(child: Text('แชท')); // Tab แชท
    } else if (_selectedIndex == 2) {
      return const Center(child: Text('ค้นหา')); // Tab ค้นหา
    } else if (_selectedIndex == 3) {
      return const Center(child: Text('ร้านค้า')); // Tab ร้านค้า
    } else {
      return const Center(child: Text('โปรไฟล์')); // Tab โปรไฟล์
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(
      context,
    )?.settings.arguments; // รับ token จาก arguments
    if (args is String) {
      accessToken = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lobby ห้องกิจกรรม')), // แถบด้านบน
      body: _buildBody(), // แสดงเนื้อหาตาม tab
      floatingActionButton: FloatingActionButton(
        heroTag: 'addRoom', // ป้องกัน conflict กับ FAB อื่น
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/create_room',
            arguments: accessToken,
          ); // ไปหน้า "สร้างห้อง"
        },
        tooltip: 'สร้างห้องกิจกรรม', // ข้อความช่วยเหลือ
        child: const Icon(Icons.add), // ไอคอนปุ่ม
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black, // สีพื้นหลัง
        selectedItemColor: Colors.yellow, // สีเมื่อเลือก
        unselectedItemColor: Colors.white, // สีที่ไม่ได้เลือก
        currentIndex: _selectedIndex, // index ของ tab ที่เลือก
        type: BottomNavigationBarType.fixed, // ป้องกัน tab เลื่อน
        onTap: _onItemTapped, // กำหนดการคลิก tab
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: '',
          ), // หน้าแรก
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: '',
          ), // แชท
          const BottomNavigationBarItem(
            icon: Icon(Icons.language),
            label: '',
          ), // ค้นหา
          const BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            label: '',
          ), // ร้านค้า
          BottomNavigationBarItem(
            icon: CircleAvatar(
              backgroundColor: Colors.grey[800], // สีพื้นหลัง
              child: const Icon(
                Icons.person,
                color: Colors.white,
              ), // ไอคอนโปรไฟล์
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
