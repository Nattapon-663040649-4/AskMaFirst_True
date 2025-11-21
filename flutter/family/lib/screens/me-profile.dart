import 'dart:async';
import 'package:family/screens/homepage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:family/screens/start.dart';
import 'package:family/screens/transferpage.dart';
import 'package:family/styles/colors.dart';
import '../data/user_data.dart';

class MeProfile extends StatefulWidget {
  const MeProfile({super.key});

  @override
  State<MeProfile> createState() => _MeProfileState();
}

class _MeProfileState extends State<MeProfile> {
  int _selectedIndex = 4; // เก็บ index ของเมนูที่เลือก
  double? balance;
  bool loading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchLatestBalance();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchLatestBalance();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchLatestBalance() async {
    final phone = UserDataStore.userData?['phone'];
    if (phone == null) return;

    try {
      final response = await http.post(
        Uri.parse('http://172.20.10.14:3000/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          balance = data['balance']?.toDouble();
          loading = false;
        });
      } else {
        setState(() => loading = false);
        print("⚠️ ดึง balance ไม่ได้: ${response.body}");
      }
    } catch (e) {
      print("🚫 Error: $e");
      setState(() => loading = false);
    }
  }

  // ฟังก์ชันเปลี่ยนแท็บ
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      if (index == 0) {
        // กดปุ่มหน้าหลัก -> ไปหน้า HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }

  Widget _buildMenuSection(String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color.fromARGB(255, 70, 70, 70),
              ),
            ),
          ),
        ],
        Container(
          color: Colors.white,
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              return Column(
                children: [
                  ListTile(
                    leading: Icon(
                      item['icon'],
                      color: const Color.fromARGB(255, 55, 55, 55),
                    ),
                    title: Text(item['text']),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      // กดที่ "ครอบครัว" ให้ไปหน้า StartUsingPage()
                      if (item['text'] == "ครอบครัว") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StartUsingPage(),
                          ),
                        );
                      }
                      // else ถ้าจะเพิ่มหน้าอื่น ๆ ก็ตามต้องเขียนเพิ่ม
                    },
                  ),
                  if (index != items.length - 1)
                    const Divider(height: 1, indent: 50),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userData = UserDataStore.userData;

    if (userData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Me")),
        body: const Center(child: Text("⚠️ ยังไม่มีข้อมูลผู้ใช้")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // Header
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Stack(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 30, // Adjust the size as needed
                                backgroundColor: Colors
                                    .black26, // Set the background color of the circle
                                child: Icon(
                                  Icons.person, // The person icon
                                  color: Colors.white, // Color of the icon
                                  size: 40, // Size of the icon
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          userData['name'] ?? "ไม่มีชื่อ",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                // ดูโปรไฟล์ action
                                              },
                                              child: const Text(
                                                "ดูโปรไฟล์",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            const Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.blue,
                                              size: 5,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      userData['phone'] ?? "ไม่มีเบอร์โทร",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Text(
                                            "บัญชีขั้นสูง",
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 12,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 12,
                                            color: Colors.blue,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // จัดการบัญชีธนาคารและบัตรต่างๆ
                    _buildMenuSection("จัดการบัญชีธนาคารและบัตรต่างๆ", [
                      {"icon": Icons.account_balance, "text": "บัญชีธนาคาร"},
                      {"icon": Icons.credit_card, "text": "บัตรเครดิต / เดบิต"},
                      {"icon": Icons.payment, "text": "ทรูมันนี่มาสเตอร์การ์ด"},
                      {"icon": Icons.family_restroom, "text": "ครอบครัว"},
                    ]),

                    const SizedBox(height: 12),

                    // จัดการการตั้งค่าและการเชื่อมต่อบัญชี
                    _buildMenuSection("จัดการการตั้งค่าและการเชื่อมต่อบัญชี", [
                      {"icon": Icons.settings, "text": "การตั้งค่าการชำระเงิน"},
                      {
                        "icon": Icons.settings_applications,
                        "text": "การตั้งค่าแอปพลิเคชัน",
                      },
                      {
                        "icon": Icons.link,
                        "text": "การเชื่อมต่อกับบริการ / ร้านค้า",
                      },
                      {"icon": Icons.verified_user, "text": "บริการ NDID"},
                    ]),

                    const SizedBox(height: 12),

                    // จัดการความเป็นส่วนตัวและความปลอดภัย
                    _buildMenuSection("จัดการความเป็นส่วนตัวและความปลอดภัย", [
                      {"icon": Icons.privacy_tip, "text": "ความเป็นส่วนตัว"},
                      {"icon": Icons.security, "text": "ความปลอดภัย"},
                    ]),
                    const SizedBox(height: 12),
                    _buildMenuSection("เกี่ยวกับการใช้งานทั่วไป", [
                      {
                        "icon": Icons.question_mark_outlined,
                        "text": "วิธีใช้งาน",
                      },
                      {
                        "icon": Icons.question_answer,
                        "text": "สอบถาม/แจ้งปัญหา",
                      },
                      {"icon": Icons.info, "text": "เกี่ยวกับทรูมันนี่"},
                    ]),
                    const SizedBox(height: 12),
                    _buildMenuSection(" ", [
                      {"icon": Icons.logout, "text": "ออกจากระบบ"},
                    ]),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.orange, // สีของเมนูที่เลือก
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "หน้าหลัก"),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: "การเงิน",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            label: "รายการ",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard_outlined),
            label: "สิทธิพิเศษ",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "ฉัน",
          ),
        ],
      ),
    );
  }
}
