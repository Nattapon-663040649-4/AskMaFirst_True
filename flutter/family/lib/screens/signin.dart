import 'package:family/screens/family.dart';
import 'package:family/screens/homepage.dart';
import 'package:family/screens/manage-fam.dart';
import 'package:family/screens/me-profile.dart';
import 'package:family/screens/start.dart';
import 'package:family/styles/font.dart';
import 'package:family/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../data/user_data.dart'; // 🔁 import ตัวเก็บข้อมูล
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final TextEditingController _controller = TextEditingController();
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        isButtonEnabled = _controller.text.trim().isNotEmpty;
      });
    });
  }

  Future<void> fetchUserData(String phoneNumber) async {
    final url = Uri.parse('http://172.20.10.14:3000/user');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phoneNumber}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("📦 ดึงข้อมูลสำเร็จ: $data");

        // 👉 เก็บข้อมูลไว้ในตัวเก็บข้อมูลกลาง
        UserDataStore.userData = data;

        // 🔥 ดึง FCM token และอัปเดตลง Firestore
        await updateFcmToken(phoneNumber);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("✅ ดึงข้อมูลเรียบร้อย")));

        // ไปหน้า Me
        navigateToPage(HomePage());
      } else {
        print("❌ ดึงข้อมูลไม่สำเร็จ: ${response.body}");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ไม่พบผู้ใช้ กรุณาลองใหม่')));
      }
    } catch (e) {
      print("🚫 Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    }
  }

  Future<void> updateFcmToken(String phoneNumber) async {
    //fumction อัพเดต fcmtoken
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        print("📲 FCM Token: $fcmToken");

        await FirebaseFirestore.instance
            .collection('Users')
            .doc(phoneNumber)
            .set({'fcm_token': fcmToken}, SetOptions(merge: true));
      }
    } catch (e) {
      print("❌ ไม่สามารถอัปเดต FCM Token ได้: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.wg,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close, color: MyColors.g),
          onPressed: () {
            exit(0);
          },
        ),
        title: Text("เข้าสู่ระบบ", style: FontStyle.H1),
        backgroundColor: MyColors.w,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20), // ให้เว้นขอบทั้งหน้าจอ
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // ทำให้ลูกยืดความกว้าง
            children: [
              Container(
                width: 200,
                height: 200,
                padding: EdgeInsets.all(20),
                child: Image.asset(
                  "assets/icons/TrueMoney.png",
                  fit: BoxFit.contain,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "กรอกเบอร์โทรศัพท์มือถือที่ต้องการใช้เข้าสู่ระบบ",
                    style: FontStyle.p1,
                  ),
                  const Text(
                    "รองรับทุกเครือข่าย True, Ais, Dtac",
                    style: FontStyle.p2,
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: MyColors.w,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color.fromARGB(255, 158, 200, 238),
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'เบอร์โทรศัพท์มือถือ',
                    labelStyle: TextStyle(
                      color: MyColors.fontcolor4,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.all(10.0),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: isButtonEnabled
                      ? () async {
                          await fetchUserData(_controller.text.trim());
                        }
                      : null,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>((
                      states,
                    ) {
                      if (states.contains(MaterialState.disabled)) {
                        return const Color.fromARGB(255, 206, 206, 206);
                      }
                      return MyColors.or1;
                    }),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 14),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    elevation: MaterialStateProperty.all(0),
                  ),
                  child: Text('ถัดไป', style: FontStyle.btn2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void navigateToPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (ctx) => page));
  }
}
