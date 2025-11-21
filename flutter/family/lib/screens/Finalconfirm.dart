import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../data/user_data.dart'; // ใช้ userPhone เก็บเบอร์เราเอง

class FinalConfirmPage extends StatelessWidget {
  final String to;
  final double amount;
  final String phone;

  const FinalConfirmPage({
    super.key,
    required this.to,
    required this.amount,
    required this.phone,
  });

  Future<void> _confirmTransfer(BuildContext context) async {
    final response = await http.post(
      Uri.parse('http://172.20.10.14:3000/transfer'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'from': phone, // ต้องมี userPhone จาก login
        'to': to,
        'amount': amount,
        'approved': true, // ✅ เพิ่มตรงนี้
      }),
    );

    final data = jsonDecode(response.body);

    if (data['status'] == 'approve') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('โอนเงินสำเร็จ')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'เกิดข้อผิดพลาด')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ยืนยันขั้นสุดท้าย')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('คุณกำลังจะโอนเงินให้: $to'),
            const SizedBox(height: 10),
            Text('จำนวนเงิน: $amount บาท'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _confirmTransfer(context),
              child: const Text('ยืนยันการโอนจริง'),
            ),
          ],
        ),
      ),
    );
  }
}
