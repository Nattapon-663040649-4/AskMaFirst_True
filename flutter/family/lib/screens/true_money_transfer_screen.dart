import 'package:family/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../data/user_data.dart';

class TrueMoneyTransferScreen extends StatefulWidget {
  const TrueMoneyTransferScreen({super.key});

  @override
  State<TrueMoneyTransferScreen> createState() =>
      _TrueMoneyTransferScreenState();
}

class _TrueMoneyTransferScreenState extends State<TrueMoneyTransferScreen> {
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  double? balance;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchLatestBalance();
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
        Uri.parse('http://172.20.10.14:3000/transfer'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'from': fromPhone, 'to': toPhone, 'amount': amount}),
      );

      final result = jsonDecode(response.body);

      if (result['status'] == 'pending') {
        // แสดง alert เตือนความเสี่ยงก่อน
        _showRiskAlertDialog();
      } else if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'โอนสำเร็จ')),
        );
        fetchLatestBalance(); // อัปเดตยอดหลังโอน
      } else {
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

  void _showRiskAlertDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              'คำเตือนความเสี่ยง',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: const Text(
            'บัญชีปลายทางนี้อาจมีความเสี่ยง กรุณาตรวจสอบข้อมูลให้ถูกต้องก่อนโอนเงิน',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6F00), // สีส้ม
                foregroundColor: Colors.white, // ตัวหนังสือสีขาว
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(100, 40),
              ),
              onPressed: () {
                Navigator.pop(context); // ปิด dialog ไม่ทำอะไร
              },
              child: const Text('ปฏิเสธ'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // ปิด dialog
                _startCountdown(); // เริ่มนับถอยหลัง 5 นาที
              },
              child: const Text('ยืนยันโอน'),
            ),
          ],
        );
      },
    );
  }

  void _startCountdown() {
    int secondsRemaining = 300;
    late Timer timer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
              if (secondsRemaining == 0) {
                t.cancel();
                Navigator.pop(context);
                _showDialog(
                  title: 'หมดเวลา',
                  content: 'คำขอหมดเวลา',
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('ตกลง'),
                    ),
                  ],
                );
              } else {
                setState(() {
                  secondsRemaining--;
                });
              }
            });

            String formatTime(int sec) {
              int min = sec ~/ 60;
              int rem = sec % 60;
              return '${min.toString().padLeft(2, '0')}:${rem.toString().padLeft(2, '0')}';
            }

            return AlertDialog(
              title: const Text(
                'นับถอยหลังคำขออนุญาต',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('กำลังรออนุมัติ...'),
                  const SizedBox(height: 10),
                  Text(
                    formatTime(secondsRemaining),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                Center(
                  child: OutlinedButton(
                    onPressed: () {
                      timer.cancel();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orange, width: 2),
                      minimumSize: const Size(120, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'ยกเลิก',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDialog({
    required String title,
    required String content,
    required List<Widget> actions,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: actions,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.orange, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'โอนเงิน',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ไปยังบัญชีทรูมันนี่',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'เบอร์โทรศัพท์ผู้รับ',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _toController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration('0XX-XXX-XXXX'),
                    ),
                    const SizedBox(height: 20),
                    const Text('จำนวนเงิน', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('฿ 00.00'),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'โอนเงินจาก',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        border: Border.all(color: Colors.orange, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'วอลเล็ท',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'ยอดเงินคงเหลือ',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            loading
                                ? 'กำลังโหลด...'
                                : '฿ ${balance?.toStringAsFixed(2) ?? "0.00"}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: transferMoney,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6F00),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'โอนเงิน',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
    );
  }
}
