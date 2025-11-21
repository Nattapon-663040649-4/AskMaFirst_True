import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../data/user_data.dart'; // ✅ import ตัวเก็บข้อมูลผู้ใช้

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  Future<void> transferMoney() async {
    final fromPhone = UserDataStore.userData?['phone'];
    final toPhone = _toController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    if (toPhone.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรอกข้อมูลให้ถูกต้อง')));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
          'http://172.20.10.14:3000/transfer',
        ), // 🔁 เปลี่ยนเป็น IP server จริงตอน deploy
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'from': fromPhone, 'to': toPhone, 'amount': amount}),
      );

      final result = jsonDecode(response.body);

      if (result['status'] == 'pending') {
        // ถ้ายอดเกิน limit ต้องรอผู้ปกครองอนุมัติ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('คำขอโอนถูกส่งไปยังผู้ปกครอง กรุณารอการอนุมัติ'),
          ),
        );
      } else if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'โอนสำเร็จ')),
        );
      } else {
        // เช่น 'error' หรือ 'rejected'
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'เกิดข้อผิดพลาด')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    }
  }

  @override
  void dispose() {
    _toController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('โอนเงิน')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _toController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'เบอร์โทรปลายทาง',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'จำนวนเงินที่ต้องการโอน',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: transferMoney,
              child: const Text('ยืนยันการโอน'),
            ),
          ],
        ),
      ),
    );
  }
}
