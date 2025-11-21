import 'package:flutter/material.dart';
import 'package:family/styles/colors.dart';
import 'package:family/styles/font.dart';
import 'package:family/data/added_number_store.dart';
import '../data/user_data.dart'; // ดึงข้อมูล user ปัจจุบัน
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotiAddNum extends StatefulWidget {
  const NotiAddNum({super.key});

  @override
  State<NotiAddNum> createState() => _NotiAddNumState();
}

class _NotiAddNumState extends State<NotiAddNum> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      final phoneNumber = _controller.text.trim();

      try {
        // 👉 1) ดึง fcm_token ของเบอร์ปลายทางจาก Firestore
        final snapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(phoneNumber)
            .get();

        if (!snapshot.exists || snapshot.data()?['fcm_token'] == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ไม่พบ FCM token ของเบอร์นี้')),
          );
          return;
        }

        final targetToken = snapshot.data()!['fcm_token'];
        print("🎯 Token ของผู้รับ: $targetToken");

        // 👉 2) เรียก API backend เพื่อให้ส่งแจ้งเตือน
        final fromPhone =
            UserDataStore.userData?['phone']; // เบอร์ของคนที่ส่งคำเชิญ

        final res = await http.post(
          Uri.parse('http://172.20.10.14:3000/send-invite'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'from': fromPhone,
            'to': phoneNumber,
            'fcm_token': targetToken,
            'family_id': UserDataStore
                .userData?['family_id'], // ส่ง family_id ของผู้เชิญ
          }),
        );

        final result = jsonDecode(res.body);
        if (result['success'] == true) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('ส่งคำเชิญสำเร็จ')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'ส่งคำเชิญไม่สำเร็จ')),
          );
        }
      } catch (e) {
        print("❌ Error: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
      }

      // 👉 เก็บเบอร์ไว้ใน global store เหมือนเดิม
      AddedNumberStore.addedPhoneNumber = phoneNumber;

      // 👉 ปิด dialog
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('กรอกข้อมูลเพิ่มสมาชิก', style: FontStyle.p6),
      content: Form(
        key: _formKey,

        child: TextFormField(
          controller: _controller,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'เบอร์โทรศัพท์มือถือ',
            labelStyle: const TextStyle(
              fontFamily: 'Prompt',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: MyColors.fontcolor5, // สีส้มตามธีม TrueMoney
            ),
            filled: true,
            fillColor: MyColors.w, // พื้นหลังโทนอ่อนของส้ม
            hintText: 'เบอร์ทรูมันนี่',
            hintStyle: TextStyle(
              color: const Color.fromARGB(255, 165, 165, 165),
              fontSize: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: const Color.fromARGB(252, 80, 80, 80).withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: const Color.fromARGB(252, 80, 80, 80),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),

          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'กรุณากรอกเบอร์ทรูมันนี่';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('ยกเลิก', style: FontStyle.p2),
        ),
        ElevatedButton(
          onPressed: _onSubmit,
          child: const Text('ตกลง', style: FontStyle.btn2),
          style: ElevatedButton.styleFrom(backgroundColor: MyColors.or1),
        ),
      ],
    );
  }
}
