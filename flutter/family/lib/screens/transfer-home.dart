import 'package:family/screens/notification-page.dart';
import 'package:family/styles/colors.dart';
import 'package:family/styles/font.dart';
import 'package:family/widgets/list-home-screen.dart';
import 'package:family/widgets/recent_transfers.dart';
import 'package:family/widgets/tranfers_to_list.dart';
import 'package:flutter/material.dart';
import '../widgets/header_menu.dart';

class TransferHome extends StatefulWidget {
  const TransferHome({super.key});

  @override
  State<TransferHome> createState() => _TransferHomeState();
}

class _TransferHomeState extends State<TransferHome> {
  void navigateToNotificationPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationPage()),
    );
  }

  void goHome() {
    Navigator.pop(context); // กลับไปหน้าโฮม
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            HeaderMenu(),
            const SizedBox(height: 20),
            RecentTransferSection(),
            Divider(),
            TransferToSection(),
            const Spacer(), // ดันเนื้อหาให้ไอคอนอยู่ล่าง
            GestureDetector(
              onTap: goHome,
              child: Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2), // สีเงา
                        spreadRadius: 3,
                        blurRadius: 6,
                        offset: Offset(0, -3), // เงาขึ้นบน
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // จัดให้อยู่กึ่งกลางแนวตั้ง
                    children: [
                      Icon(Icons.arrow_upward, size: 36, color: Colors.grey),
                      const SizedBox(height: 6),
                      Text(
                        'กดเพื่อกลับหน้าแรก',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
