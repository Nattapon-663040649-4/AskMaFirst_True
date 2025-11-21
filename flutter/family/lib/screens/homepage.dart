import 'package:family/screens/me-profile.dart';
import 'package:family/screens/notification-page.dart';
import 'package:family/styles/colors.dart';
import 'package:family/styles/font.dart';
import 'package:family/widgets/list-home-screen.dart';
import 'package:family/widgets/list-icon-home.dart';
import 'package:family/widgets/tranfers_to_list.dart';
import 'package:flutter/material.dart';
import '../widgets/header_menu.dart';
import '../widgets/recent_transfers.dart';
// import '../widgets/transfer_to_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // เก็บ index ของเมนูที่เลือก
  
  bool hasNewNotification = true;

  void navigateToNotificationPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationPage()),
    );
    setState(() {
      hasNewNotification = false;
    });
  }

  

  // ฟังก์ชันเปลี่ยนแท็บ
  void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });

  if (index == 4) {
    // ไปหน้า MeProfile โดยไม่ต้อง setState ซ้อน
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MeProfile()),
    );
  }

  // กรณีอื่น ๆ เช่น
  else if (index == 0) {
    // ไปหน้า HomePage ตัวอย่าง
    // Navigator.push(...);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // เนื้อหาด้านบน
      body: SafeArea(
        child: Column(
          children: [
            // ส่วนหัว
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: MyColors.w,
              child: Row(
                children: [
                  // โลโก้
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: Image.asset(
                      "assets/icons/TrueMoney-no-text.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // ช่องค้นหา
                  Expanded(
                    child: Container(
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.grey, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "ค้นหา",
                                hintStyle: FontStyle.p2,
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ปุ่มข้อความ
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.sms_outlined),
                  ),

                  // ปุ่มแจ้งเตือน + จุดแดง
                  Stack(
                    children: [
                      IconButton(
                        onPressed: navigateToNotificationPage,
                        icon: const Icon(Icons.notifications_outlined),
                        color: MyColors.bg,
                      ),
                      if (hasNewNotification)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // เนื้อหาเลื่อน
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    HeaderMenu(),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: WalletFeaturesSection(),
                    ),
                    IconMenuGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 🔹 Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.orange, // สีของเมนูที่เลือก
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "หน้าหลัก",
          ),
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
